local _, ns = ...
local Popup = HideUI:NewModule("Popup")

local POPUP_NAME = "HIDEUI_CONFIRM_DIALOG"

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Popup:OnInitialize()
    -- Registramos la plantilla una sola vez al cargar el addon
    StaticPopupDialogs[POPUP_NAME] = {
        text = "%s", -- El texto se pasará dinámicamente
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
        preferredIndex = 3, -- Evita conflictos con otros popups
    }
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS
---------------------------------------------------------------------
function Popup:Confirm(text, onAccept, onCancel)
    local data = {
        onAccept = onAccept,
        onCancel = onCancel
    }
    
    -- Pasamos el texto al primer argumento y la data al segundo
    StaticPopup_Show(POPUP_NAME, text, nil, data)
end