local Single = Fade:NewModule("Single")

function Single:Create(Initializer)
    function Initializer:OnReady()
        if not self.frame.Fade_loaded then
			local delay = 2
            local repeats = 3
            
            self.frame.Fade_loaded = true
            
            UIFrameFadeRemoveFrame(self.frame)
            C_Timer.NewTicker(delay, function()
                -- Impide que siga funcionando tras apagar el addon
                if self.globals.isEnabled then
                    self:OnCreate()
                end
            end, repeats)
		else
			self:OnReload()
		end
	end

    -- Funciones aqui
    function Initializer:LockSetAlpha(frame)
        frame = frame or self.frame
        if self:IsVisible(frame) and frame.SetAlpha then
            self.OldSetAlpha = frame.SetAlpha
            frame.SetAlpha = function() end
        end
    end

    function Initializer:UnlockSetAlpha(frame)
        frame = frame or self.frame
        if self:IsVisible(frame) and frame.SetAlpha and self.OldSetAlpha then
            frame.SetAlpha = self.OldSetAlpha
        end
    end

    -- Si el frame tiene su propio módulo, delega responsabilidad a su modulo ubicado siempre en carpeta /Frames
    local mod = Fade:GetModule(Initializer.name, true)
    if mod then
        return mod:Create(Initializer)
    else
        return Initializer
    end
end
