local MainStatusTrackingBarContainer = HideUI:NewModule("MainStatusTrackingBarContainer")

function MainStatusTrackingBarContainer:Create(initializer)
    local Initial = initializer

	function Initial:OnReady()
        if not self.frame.HideUI_loaded then
			local delay = 2.5
			self.frame.HideUI_loaded = true
			C_Timer.After(delay, function()
				self:OnCreate()
			end)
		else
			self:OnReload()
		end
	end

	return Initial
end