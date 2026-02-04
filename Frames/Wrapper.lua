local _, ns = ...
local Wrapper = gUI:NewModule("FrameWrapper", "AceHook-3.0")

Wrapper.__index = Wrapper

---------------------------------------------------------------------
-- Configuración y Estados
---------------------------------------------------------------------

function Wrapper:UpdateConfig(frameConfig, globalConfig)
    self.config, self.globals = frameConfig, globalConfig
    -- Eliminamos el 'true' para que los cambios de configuración 
    -- se apliquen con una transición suave.
    self:Refresh()
end

function Wrapper:UpdateState(event, state)
    if not self.states[event] then 
        self.states[event] = { state = state, priority = ns.PRIORITIES[event] or 0 }
    elseif self.states[event].state == state then 
        return 
    end

    self.states[event].state = state
    self:Refresh()
end

function Wrapper:GetNextState(data)
    local maxPriority, nextState = -1, nil
    for name, info in pairs(self.states) do
        if info.state and data["use" .. name] and info.priority > maxPriority then
            maxPriority, nextState = info.priority, name
        end
    end
    return nextState
end

function Wrapper:GetTargetAlpha()
    if not self.config or not self.globals or self.config.ignoreFrame then return 1.0 end

    local data = self.config.isEnabled and self.config or self.globals

    -- 1. Prioridad: Mouseover
    if self.isMouseOver and data.useMouseover then return 1.0 end

    -- 2. Prioridad: Estados (COMBAT, AFK, etc.)
    local state = self:GetNextState(data) 
    if state then return data[state .. "Alpha"] or 0 end

    -- 3. Alpha Base
    return self.config.isEnabled and self.config.frameAlpha or self.globals.globalAlpha
end

---------------------------------------------------------------------
-- Motor de Actualización (Ticker-ready)
---------------------------------------------------------------------

function Wrapper:OnUpdate()
    if not self.frame or not self.config or self.config.ignoreFrame then return end

    -- Sincronización de Mouseover
    local isOver = MouseIsOver(self.frame)
    if isOver ~= self.isMouseOver then
        self.isMouseOver = isOver
        self:Refresh()
    end

    -- Corrección de Alpha externo
    if not self.frame.fadeInfo then
        local target = self:GetTargetAlpha()
        if math.abs(self.frame:GetAlpha() - target) > 0.01 then -- epsilon
            if self.forceAlpha then self:SetAlpha(target) else self:Refresh() end
        end
    end
end

function Wrapper:Refresh(instant)
    if not self.frame or not self.config then return end

    if self.config.ignoreFrame then
        self:SetAlpha(1.0)
        self.targetAlpha = 1.0
        return
    end

    local target = self:GetTargetAlpha()
    if target == self.targetAlpha and not instant then return end
    
    self.targetAlpha = target

    -- Si el frame está oculto, el alpha se pone al instante para que 
    -- al mostrarse (OnShow) ya tenga el valor base o inicie el fade desde ahí.
    if instant or self.forceAlpha or not self.frame:IsVisible() then
        self:SetAlpha(target)
    else
        self:Fade(target)
    end
end

---------------------------------------------------------------------
-- Control Visual
---------------------------------------------------------------------

function Wrapper:Fade(targetAlpha)
    local currentAlpha = self.frame:GetAlpha()
    if currentAlpha == targetAlpha then return end

    self:StopFade()

    local data = self.config.isEnabled and self.config or self.globals
    
    -- Definimos duración según el contexto (Mouseover > Fade Out > Default)
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
        self.frame.fadeInfo = nil
    end
end

function Wrapper:SetAlpha(alpha) 
    self:StopFade()
    if self.frame then self.frame:SetAlpha(alpha) end
end

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------

function Wrapper:Create(name, isVirtual)
    local realFrame = _G[name]
    if not isVirtual and not realFrame then return nil end

    local obj = setmetatable({}, self)
    obj.name, obj.frame, obj.isVirtual = name, realFrame, isVirtual
    obj.states, obj.isMouseOver, obj.targetAlpha = {}, false, -1

    -- Copia de estados globales al nacer
    if ns.States then 
        for ev, info in pairs(ns.States) do
            obj.states[ev] = { state = info.state, priority = info.priority }
        end
    end

    -- Hook al OnShow: permite que el frame haga fade-in cada vez que aparece
    if not isVirtual and obj.frame then
        obj:SecureHookScript(obj.frame, "OnShow", "Refresh")
    end
    
    -- Quitamos el 'true' para permitir que el frame entre con suavidad al cargar
    obj:Refresh()
    return obj
end

function Wrapper:Destroy() 
    self:StopFade()
    if self.frame then self.frame:SetAlpha(1.0) end
    self.frame, self.states = nil, nil
end