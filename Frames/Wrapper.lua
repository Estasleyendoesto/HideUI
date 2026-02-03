local _, ns = ...
local Wrapper = gUI:NewModule("FrameWrapper", "AceHook-3.0")

Wrapper.__index = Wrapper

---------------------------------------------------------------------
-- Lógica de Estados
---------------------------------------------------------------------
function Wrapper:GetNextState()
    if not self.states then return end

    local maxPriority, nextState = -1, nil
    for name, info in pairs(self.states) do
        if info.state and info.priority > maxPriority then
            maxPriority = info.priority
            nextState = name
        end
    end
    return nextState
end

function Wrapper:UpdateState(event, state)
    if not self.states[event] then 
        self.states[event] = { 
            state = state, 
            priority = ns.PRIORITIES[event] or 0 
        }
    else
        if self.states[event].state == state then return end
        self.states[event].state = state
    end
    self:Refresh()
end

function Wrapper:Refresh()
    if not self.frame then return end

    local nextState = self:GetNextState()
    if nextState == self.activeState then return end
    
    self.activeState = nextState
    local targetAlpha = nextState and 0.2 or 1.0

    -- DEBUG: Solo para testeo de frames principales
    local fName = self.frame:GetName() or self.name
    if fName == "PlayerFrame" or fName == "MainMenuBar" then
        local color = nextState and "|cff00ff00" or "|cffffff00"
        print(string.format("|cff00ff00gUI:|r %s%s|r -> %.1f (%s)", color, fName, targetAlpha, nextState or "VISIBLE"))
    end

    self:Fade(targetAlpha)
end

---------------------------------------------------------------------
-- Control Visual
---------------------------------------------------------------------
function Wrapper:Fade(targetAlpha)
    if not self.frame then return end
    
    local currentAlpha = self.frame:GetAlpha()
    if currentAlpha == targetAlpha then return end

    -- Si no es visible, aplicamos alpha directo para evitar errores de Taint/Fade
    if not self.frame:IsVisible() then 
        self.frame:SetAlpha(targetAlpha)
        return 
    end
    
    self:StopFade()

    UIFrameFade(self.frame, {
        mode = (targetAlpha > currentAlpha) and "IN" or "OUT",
        timeToFade = 0.3,
        startAlpha = currentAlpha,
        endAlpha = targetAlpha,
        finishedArg1 = self.frame,
    })
end

function Wrapper:StopFade()
    if self.frame then
        UIFrameFadeRemoveFrame(self.frame)
        if self.frame.fadeInfo then self.frame.fadeInfo = nil end
    end
end

function Wrapper:SetAlpha(alpha) 
    if not self.frame then return end
    self:StopFade()
    self.frame:SetAlpha(alpha)
end

---------------------------------------------------------------------
-- Constructor / Destructor
---------------------------------------------------------------------
function Wrapper:Create(name, isVirtual)
    local realFrame = _G[name]
    if not isVirtual and not realFrame then return nil end

    local obj = setmetatable({}, self)
    obj.name = name
    obj.frame = realFrame
    obj.isVirtual = isVirtual
    obj.states = {}
    obj.activeState = nil

    -- Sincronización inicial con el registro global
    if ns.States then 
        for ev, info in pairs(ns.States) do
            obj.states[ev] = { state = info.state, priority = info.priority }
        end
    end

    -- Hook para asegurar el alpha cada vez que Blizzard muestra el frame
    if not isVirtual and obj.frame then
        obj:SecureHookScript(obj.frame, "OnShow", "Refresh")
    end
    
    obj:Refresh()
    return obj
end

function Wrapper:Destroy() 
    self:StopFade()
    if self.frame then self:SetAlpha(1.0) end
    self.frame = nil
    self.states = nil
end