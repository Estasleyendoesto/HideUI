local _, ns = ...
local Wrapper = gUI:NewModule("FrameWrapper", "AceHook-3.0")

Wrapper.__index = Wrapper

---------------------------------------------------------------------
-- Configuración y Estados
---------------------------------------------------------------------
function Wrapper:UpdateConfig(frameConfig, globalConfig)
    self.config = frameConfig
    self.globals = globalConfig
    self:Refresh()
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

function Wrapper:GetNextState(data)
    if not self.states or not data then return end

    local maxPriority, nextState = -1, nil
    for name, info in pairs(self.states) do
        if info.state and data["use" .. name] then
            if info.priority > maxPriority then
                maxPriority = info.priority
                nextState = name
            end
        end
    end
    return nextState
end

function Wrapper:GetTargetAlpha()
    if not self.config or not self.globals then return 1.0 end

    local cfg, glb = self.config, self.globals
    if cfg.ignoreFrame then return 1.0 end

    local data = cfg.isEnabled and cfg or glb

    -- 1. Prioridad: Mouseover
    if self.isMouseOver and data.useMouseover then return 1.0 end

    -- 2. Prioridad: Estados (COMBAT, AFK, etc.)
    local state = self:GetNextState(data) 
    if state then return data[state .. "Alpha"] or 0 end

    -- 3. Prioridad: Alpha Base / Global
    return cfg.isEnabled and cfg.frameAlpha or glb.globalAlpha
end

---------------------------------------------------------------------
-- Motor de Actualización (Ticker-ready)
---------------------------------------------------------------------
function Wrapper:OnUpdate()
    if not self.frame or not self.config or self.config.ignoreFrame then return end

    -- Sincronización de Mouseover sin hooks
    local isOver = MouseIsOver(self.frame)
    if isOver ~= self.isMouseOver then
        self.isMouseOver = isOver
        self:Refresh()
    end

    -- Corrección de Alpha (si Blizzard lo cambia y no estamos en un Fade activo)
    if not self.frame.fadeInfo then
        local target = self:GetTargetAlpha()
        if math.abs(self.frame:GetAlpha() - target) > 0.01 then
            if self.forceAlpha then
                self:SetAlpha(target)
            else
                self:Refresh() 
            end
        end
    end
end

function Wrapper:Refresh(instant)
    if not self.frame or not self.config or not self.globals then return end

    if self.config.ignoreFrame then
        if self.frame:GetAlpha() ~= 1 then self.frame:SetAlpha(1) end
        self.targetAlpha = 1
        return
    end

    local targetAlpha = self:GetTargetAlpha()
    if targetAlpha == self.targetAlpha and not instant then return end
    
    self.targetAlpha = targetAlpha

    -- Salto instantáneo si el frame está oculto o se requiere fuerza bruta
    if instant or self.forceAlpha or not self.frame:IsVisible() then
        self:SetAlpha(targetAlpha)
    else
        self:Fade(targetAlpha)
    end
end

---------------------------------------------------------------------
-- Control Visual
---------------------------------------------------------------------
function Wrapper:Fade(targetAlpha)
    if not self.frame then return end
    
    local currentAlpha = self.frame:GetAlpha()
    if currentAlpha == targetAlpha then return end

    if not self.frame:IsVisible() then 
        self.frame:SetAlpha(targetAlpha)
        return 
    end
    
    self:StopFade()

    local data = self.config.isEnabled and self.config or self.globals
    local duration = 0.3
    
    if self.isMouseOver then
        duration = data.mouseoverFadeInDuration or 0.3
    elseif targetAlpha < currentAlpha then 
        duration = data.mouseoverFadeOutDuration or 0.4
    end

    UIFrameFade(self.frame, {
        mode = (targetAlpha > currentAlpha) and "IN" or "OUT",
        timeToFade = duration,
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
-- Ciclo de Vida
---------------------------------------------------------------------
function Wrapper:Create(name, isVirtual)
    local realFrame = _G[name]
    if not isVirtual and not realFrame then return nil end

    local obj = setmetatable({}, self)
    obj.name, obj.frame, obj.isVirtual = name, realFrame, isVirtual
    obj.states = {}
    obj.isMouseOver = false 
    obj.targetAlpha = -1 

    if ns.States then 
        for ev, info in pairs(ns.States) do
            obj.states[ev] = { state = info.state, priority = info.priority }
        end
    end

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