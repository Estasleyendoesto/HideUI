local _, ns = ...
local Wrapper = gUI:GetModule("FrameWrapper")

ns.StatusTrackingBars = {} 

function ns.StatusTrackingBars:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return end
    
    -- fuerza bruta con las animaciones de blizzard
    obj.forceAlpha = true

    obj.OnUpdate = function(self)
        if not self.frame or not self.config or not self.globals or self.config.ignoreFrame then return end

        -- 1. Sincronización de Mouseover
        local isOver = MouseIsOver(self.frame)
        if isOver ~= self.isMouseOver then
            self.isMouseOver = isOver
            
            -- Bypass temporal de forceAlpha para permitir fundido suave
            self.forceAlpha = false
            self:Refresh()
            self.forceAlpha = true
        end

        -- 2. Supresión de animaciones internas
        local bIn  = self.frame.FadeInAnimation
        local bOut = self.frame.FadeOutAnimation
        if (bIn and bIn:IsPlaying()) or (bOut and bOut:IsPlaying()) then
            if bIn then bIn:Stop() end
            if bOut then bOut:Stop() end
            -- Forzamos nuestro alpha inmediatamente tras el corte
            self.frame:SetAlpha(self:GetTargetAlpha())
        end

        -- 3. Corrección de Alpha
        -- Solo actuamos si no hay una animación nuestra (fadeInfo) activa
        if not self.frame.fadeInfo then
            local target = self:GetTargetAlpha()
            if math.abs(self.frame:GetAlpha() - target) > 0.01 then
                self.frame:SetAlpha(target)
            end
        end
    end

    return obj
end