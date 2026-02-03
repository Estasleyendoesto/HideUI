local _, ns = ...
local Wrapper = gUI:NewModule("FrameWrapper", "AceHook-3.0")

Wrapper.__index = Wrapper

---------------------------------------------------------------------
-- Lógica de Estados
---------------------------------------------------------------------
function Wrapper:UpdateConfig(frameConfig, globalConfig)
    self.config = frameConfig
    self.globals = globalConfig
    self:Refresh()
end

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
    if not self.frame or not self.config then return end

    -- Si ignoreFrame está activo, nos aseguramos de limpiar cualquier rastro del addon
    if self.config.ignoreFrame then
        self:SetAlpha(1.0)
        self.activeState = "IGNORED"
        return
    end

    local targetAlpha = self:GetTargetAlpha()

    -- Filtro de cambio para no ejecutar animaciones idénticas
    if targetAlpha == self.currentAlpha then return end
    self.currentAlpha = targetAlpha

    -- DEBUG (Opcional)
    -- print(string.format("|cff00ff00gUI:|r %s -> Target: %.1f", self.name, targetAlpha))

    self:Fade(targetAlpha)
end

function Wrapper:GetTargetAlpha()
    local cfg, glb = self.config, self.globals
    if cfg.ignoreFrame then return 1.0 end

    -- Determinamos qué fuente de datos usar
    local data = cfg.isEnabled and cfg or glb
    local state = self:GetNextState() -- Devuelve "COMBAT", "AFK", etc.

    -- Si hay un estado activo (ej: "AFK")
    if state then
        local useKey   = "use" .. state   -- "useAFK"
        local alphaKey = state .. "Alpha" -- "AFKAlpha"

        -- Si el evento está activado en la config, usamos su alpha
        if data[useKey] then
            return data[alphaKey] or 0
        end
    end

    -- Si no hay estado o el evento está desactivado, usamos el alpha base
    return cfg.isEnabled and cfg.frameAlpha or glb.globalAlpha
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