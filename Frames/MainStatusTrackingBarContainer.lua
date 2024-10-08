local MainStatusTrackingBarContainer = HideUI:NewModule("MainStatusTrackingBarContainer")

local DELAY = 2.5

function MainStatusTrackingBarContainer:Create(Initializer)
	function Initializer:OnReady()
        if not self.frame.HideUI_loaded then
			self.frame.HideUI_loaded = true
			C_Timer.After(DELAY, function()
				self:OnCreate()
			end)
		else
			self:OnReload()
		end
	end

	return Initializer
end