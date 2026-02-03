local _, ns = ...
local MainBar = gUI:NewModule("MainStatusTrackingBarContainer")

MainBar.Create = function(self, name, isVirtual) 
    return ns.StatusTrackingBars:Create(name, isVirtual)
end