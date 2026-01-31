local _, ns = ...
local Interface = HideUI:NewModule("Interface", "AceConsole-3.0", "AceEvent-3.0")

local PANELS = { "About", "General", "Blizzard", "Others" }

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Interface:OnInitialize()
    -- Precarga de módulos de paneles para acceso rápido
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
end

---------------------------------------------------------------------
-- COMANDOS DE CHAT
---------------------------------------------------------------------
function Interface:HandleChatCommand(input)
    self:ToggleMainFrame()
end

---------------------------------------------------------------------
-- UTILIDADES DE INTERFAZ
---------------------------------------------------------------------
function Interface:ToggleMainFrame()
    local mainFrame = HideUI:GetModule("MainFrame", true)
    if mainFrame then
        mainFrame:Toggle()
    end
end