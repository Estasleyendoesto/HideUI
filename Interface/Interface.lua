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
    
    -- Registro de Eventos/Mensajes Internos
    self:RegisterMessage("HIDEUI_CONFIG_OPENED", "RefreshPanels")
end

---------------------------------------------------------------------
-- COMANDOS DE CHAT
---------------------------------------------------------------------
function Interface:HandleChatCommand(input)
    self:ToggleMainFrame()
end

---------------------------------------------------------------------
-- GESTIÓN DE PANELES (LOGICA)
---------------------------------------------------------------------
--- Recarga los datos de todos los paneles registrados
function Interface:RefreshPanels()
    -- 'isUpdating' actúa como un semáforo para evitar bucles de eventos
    self.isUpdating = true

    for name, module in pairs(self.panels) do
        if module.Refresh then 
            module:Refresh()
        end
    end
    
    self.isUpdating = false
end

--- Cambia el estado visual de todos los elementos (Enable/Disable)
function Interface:SetPanelsState(state)
    -- Si no viene estado, por defecto habilitamos
    local method = state or "SetEnable"

    for name, module in pairs(self.panels) do
        if module[method] then
            module[method](module)
        else
            -- Debug sutil para el desarrollador
        end
    end
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