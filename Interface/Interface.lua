local _, ns = ...
local Interface = gUI:NewModule("Interface", "AceConsole-3.0", "AceEvent-3.0")

local PANELS = { "About", "General", "Blizzard", "Others" }

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Interface:OnInitialize()
    self.panels = {}
    for _, name in ipairs(PANELS) do
        local module = gUI:GetModule(name, true)
        if module then
            self.panels[name] = module
        end
    end
end

function Interface:OnEnable()
    -- Comandos de chat
    self:RegisterChatCommand("gUI", "HandleChatCommand")
    self:RegisterChatCommand("gui", "HandleChatCommand")
    self:RegisterChatCommand("ghostui", "HandleChatCommand")

    -- Activación de Core Modules
    gUI:EnableModule("MinimapButton")
    gUI:EnableModule("MainFrame")

    -- Activación de Paneles
    for name in pairs(self.panels) do
        gUI:EnableModule(name)
    end

    -- Escucha cambios globales para actualizar el estado de los paneles
    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalSettingChanged")
end

---------------------------------------------------------------------
-- COMANDOS DE CHAT
---------------------------------------------------------------------
function Interface:HandleChatCommand(input)
    gUI:GetModule("MainFrame"):Toggle()
end

---------------------------------------------------------------------
-- LÓGICA DE CONTROL (CEREBRO)
---------------------------------------------------------------------
function Interface:OnGlobalSettingChanged(message, field, value)
    if field == "addonEnabled" then
        local MainFrame = gUI:GetModule("MainFrame")
        
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
    local Database = gUI:GetModule("Database")
    local MainFrame = gUI:GetModule("MainFrame")
    
    local addonEnabled = Database:GetGlobals().addonEnabled
    local target = addonEnabled and "About" or "General"

    MainFrame:OpenPanel(target)
end
