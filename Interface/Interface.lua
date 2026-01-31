local _, ns = ...
local Interface = HideUI:NewModule("Interface", "AceConsole-3.0", "AceEvent-3.0")

local PANELS = { "About", "General", "Blizzard", "Others" }

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Interface:OnInitialize()
    self.panels = {}
    for _, name in ipairs(PANELS) do
        local module = HideUI:GetModule(name, true)
        if module then
            self.panels[name] = module
        end
    end
end

function Interface:OnEnable()
    -- Comandos de chat
    self:RegisterChatCommand("hideui", "HandleChatCommand")
    self:RegisterChatCommand("hui", "HandleChatCommand")

    -- Activación de Core Modules
    HideUI:EnableModule("MinimapButton")
    HideUI:EnableModule("MainFrame")

    -- Activación de Paneles
    for name in pairs(self.panels) do
        HideUI:EnableModule(name)
    end

    -- Escucha cambios globales para actualizar el estado de los paneles
    self:RegisterMessage("HIDEUI_GLOBAL_CHANGED", "OnGlobalSettingChanged")
end

---------------------------------------------------------------------
-- COMANDOS DE CHAT
---------------------------------------------------------------------
function Interface:HandleChatCommand(input)
    HideUI:GetModule("MainFrame"):Toggle()
end

---------------------------------------------------------------------
-- LÓGICA DE CONTROL (CEREBRO)
---------------------------------------------------------------------
function Interface:OnGlobalSettingChanged(message, field, value)
    if field == "addonEnabled" then
        local MainFrame = HideUI:GetModule("MainFrame")
        
        -- Ordenamos actualizar visuales (NavBar/Header)
        MainFrame:UpdateUIVisuals(value)
        
        -- Lógica de seguridad: si se apaga, mandamos a General
        if value == false and MainFrame.currentPanel ~= "General" then
            MainFrame:OpenPanel("General")
        end
    end
end

-- Determina qué panel mostrar al abrir la ventana
function Interface:SetupInitialPanel()
    local Database = HideUI:GetModule("Database")
    local MainFrame = HideUI:GetModule("MainFrame")
    
    local addonEnabled = Database:GetGlobals().addonEnabled
    local target = addonEnabled and "About" or "General"

    MainFrame:OpenPanel(target)
end