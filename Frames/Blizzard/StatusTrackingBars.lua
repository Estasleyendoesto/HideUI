local _, ns = ...
local Wrapper = gUI:GetModule("FrameWrapper")

ns.StatusTrackingBars = {} 

function ns.StatusTrackingBars:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return end
    
    -- Estas barras requieren 'fuerza bruta' porque Blizzard las manipula constantemente
    obj.forceAlpha = true

    obj.OnUpdate = function(self)
        -- Validaciones básicas de seguridad
        if not self.frame or not self.config or self.config.ignoreFrame then 
            return 
        end

        -- 1. Sincronización de Mouseover
        -- Usamos un bypass temporal de forceAlpha para permitir que GhostUI haga un fade suave
        local isOver = MouseIsOver(self.frame)
        if isOver ~= self.isMouseOver then
            self.isMouseOver = isOver
            
            self.forceAlpha = false
            self:Refresh()
            self.forceAlpha = true
        end

        -- 2. Supresión de animaciones nativas
        -- Si Blizzard intenta disparar sus propios Fades, los detenemos en seco
        local bIn  = self.frame.FadeInAnimation
        local bOut = self.frame.FadeOutAnimation

        if (bIn and bIn:IsPlaying()) or (bOut and bOut:IsPlaying()) then
            if bIn then bIn:Stop() end
            if bOut then bOut:Stop() end
            
            -- Tras detener a Blizzard, restauramos nuestro alpha objetivo de inmediato
            self.frame:SetAlpha(self:GetTargetAlpha())
        end

        -- 3. Corrección de Alpha (Failsafe)
        -- Si no hay un fundido de GhostUI activo, nos aseguramos de que el alpha sea el correcto
        if not self.frame.fadeInfo then
            local target = self:GetTargetAlpha()
            
            if math.abs(self.frame:GetAlpha() - target) > 0.01 then
                self.frame:SetAlpha(target)
            end
        end
    end

    return obj
end