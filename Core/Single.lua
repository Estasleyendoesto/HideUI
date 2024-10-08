local Single = HideUI:NewModule("Single")

function Single:Create(initializer)
    -- Contenido que heredará
    local Initial = initializer

    function Initial:OnReady()
        if not self.frame.HideUI_loaded then
			local delay = 2
            local repeats = 3
            
            self.frame.HideUI_loaded = true
            
            UIFrameFadeRemoveFrame(self.frame)
            C_Timer.NewTicker(delay, function()
                self:OnCreate()
            end, repeats)
		else
			self:OnReload()
		end
	end

    -- Funciones aqui
    function Initial:LockSetAlpha(frame)
        frame = frame or self.frame
        if self:IsVisible(frame) and frame.SetAlpha then
            self.OldSetAlpha = frame.SetAlpha
            frame.SetAlpha = function() end
        end
    end

    function Initial:UnlockSetAlpha(frame)
        frame = frame or self.frame
        if self:IsVisible(frame) and frame.SetAlpha and self.OldSetAlpha then
            frame.SetAlpha = self.OldSetAlpha
        end
    end

    -- Si el frame tiene su propio módulo, delega responsabilidad a su modulo ubicado siempre en carpeta /Frames
    local mod = HideUI:GetModule(initializer.name, true)
    if mod then
        return mod:Create(Initial)
    else
        return Initial
    end
end