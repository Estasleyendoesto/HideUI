local SecondaryStatusTrackingBarContainer = Fade:NewModule("SecondaryStatusTrackingBarContainer")

local DELAY = 2.5

function SecondaryStatusTrackingBarContainer:Create(Initializer)
	function Initializer:OnReady()
        if not self.frame.Fade_loaded then
			self.frame.Fade_loaded = true
			C_Timer.After(DELAY, function()
				self:OnCreate()
			end)
		else
			self:OnReload()
		end
	end

	return Initializer
end
