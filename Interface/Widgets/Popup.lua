local _, ns = ...
local Popup = gUI:NewModule("Popup")

local POPUP_NAME = "GHOSTUI_CONFIRM_DIALOG"

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Popup:OnInitialize()
    StaticPopupDialogs[POPUP_NAME] = {
        text = "%s",
        button1 = YES,
        button2 = NO,
        OnAccept = function(self, data) 
            if data.onAccept then data.onAccept() end 
        end,
        OnCancel = function(self, data) 
            if data.onCancel then data.onCancel() end 
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

---------------------------------------------------------------------
-- API
---------------------------------------------------------------------
function Popup:Confirm(text, onAccept, onCancel)
    local data = {
        onAccept = onAccept,
        onCancel = onCancel
    }
    
    StaticPopup_Show(POPUP_NAME, text, nil, data)
end
