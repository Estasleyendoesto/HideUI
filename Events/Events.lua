local _, ns = ...
local Events = gUI:NewModule("Events", "AceEvent-3.0", "AceTimer-3.0")
Events:SetDefaultModuleState(false)

local DETECTORS = {
    "AFKDetector",
    "CombatDetector",
    "MountDetector",
    "InstanceDetector",
}

local DELAY_CONFIG = {
    COMBAT = "combatEndDelay",
    -- MOUNT = "mountEndDelay", -- Para otros delays
}

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------
function Events:OnEnable()
    ns.States = {}
    
    for _, module in ipairs(DETECTORS) do
        local key = module:gsub("Detector", ""):upper()
        ns.States[key] = { 
            state = false, 
            priority = ns.PRIORITIES[key] or 0 
        }
    end

    self:RegisterMessage("GHOSTUI_EVENT", "OnEvent")

    for _, module in ipairs(DETECTORS) do
        gUI:EnableModule(module)
    end
end

function Events:OnDisable()
    self:UnregisterMessage("GHOSTUI_EVENT")

    for _, module in ipairs(DETECTORS) do
        local key = module:gsub("Detector", ""):upper()
        if self[key .. "_Timer"] then
            self:CancelTimer(self[key .. "_Timer"])
            self[key .. "_Timer"] = nil
        end
        gUI:DisableModule(module)
    end

    ns.States = {}
end

---------------------------------------------------------------------
-- Procesador de Estados
---------------------------------------------------------------------
function Events:OnEvent(_, event, state, extra)
    -- Cancelamos cualquier retardo previo para este evento
    if self[event .. "_Timer"] then
        self:CancelTimer(self[event .. "_Timer"])
        self[event .. "_Timer"] = nil
    end

    -- Gestionamos el retardo si el evento pasa a false
    local delayKey = DELAY_CONFIG[event]
    if delayKey and state == false then
        local db = gUI:GetModule("Database"):GetGlobals()
        local delay = db[delayKey] or 0

        if delay > 0 then
            self[event .. "_Timer"] = self:ScheduleTimer("PublishState", delay, event, state, extra)
            return
        end
    end

    self:PublishState(event, state, extra)
end

function Events:PublishState(event, state, extra)
    self[event .. "_Timer"] = nil

    if not ns.States[event] then
        ns.States[event] = { priority = ns.PRIORITIES[event] or 0 }
    end

    ns.States[event].state = state
    ns.States[event].extra = extra

    self:SendMessage("GHOSTUI_EVENT_READY", event, state, extra)
end