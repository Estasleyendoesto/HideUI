local _, ns = ...
local SecondaryBar = gUI:NewModule("SecondaryStatusTrackingBarContainer")

SecondaryBar.Create = function(self, name, isVirtual) 
    return ns.StatusTrackingBars:Create(name, isVirtual)
end