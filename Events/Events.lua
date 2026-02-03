local _, ns = ...
local Events = gUI:NewModule("Events", "AceEvent-3.0")
Events:SetDefaultModuleState(false)

local DETECTORS = {
    "AFKDetector",
    "CombatDetector",
    "MountDetector",
    "InstanceDetector",
}

function Events:OnEnable()
    ns.States = {}
    
    -- Inicializamos ns.States con valores por defecto
    for _, module in ipairs(DETECTORS) do
        local key = module:gsub("Detector", ""):upper()
        ns.States[key] = { 
            state = false, 
            priority = ns.PRIORITIES[key] or 0 
        }
    end

    self:RegisterMessage("GHOSTUI_EVENT", "OnEvent")

    -- Activamos los detectores
    for _, module in ipairs(DETECTORS) do
        gUI:EnableModule(module)
    end
end

function Events:OnDisable()
    self:UnregisterMessage("GHOSTUI_EVENT")

    -- Desactivamos los detectores
    for _, module in ipairs(DETECTORS) do
        gUI:DisableModule(module)
    end

    ns.States = {}
end

function Events:OnEvent(_, event, state, extra)
    -- Actualizamos la fuente de la verdad global
    if not ns.States[event] then
        ns.States[event] = { priority = ns.PRIORITIES[event] or 0 }
    end

    ns.States[event].state = state
    ns.States[event].extra = extra

    -- Mensaje curado como un buen vino
    self:SendMessage("GHOSTUI_EVENT_READY", event, state, extra)
end