local _, ns = ...
local Events = gUI:NewModule("Events", "AceTimer-3.0", "AceEvent-3.0")
Events:SetDefaultModuleState(false)

local DETECTORS = { "AFKDetector", "CombatDetector", "MountDetector", "InstanceDetector" }
local DELAY_CONFIG = { COMBAT = "combatEndDelay" }

function Events:OnEnable()
    ns.States = {}

    for _, moduleName in ipairs(DETECTORS) do
        local key = moduleName:gsub("Detector", ""):upper()
        ns.States[key] = { state = false, priority = ns.PRIORITIES[key] or 0 }
        
        gUI:EnableModule(moduleName)
    end

    self:RefreshAllDetectors()
end

function Events:OnDisable()
    for _, moduleName in ipairs(DETECTORS) do
        local key = moduleName:gsub("Detector", ""):upper()
        if self[key .. "_Timer"] then
            self:CancelTimer(self[key .. "_Timer"])
            self[key .. "_Timer"] = nil
        end
        gUI:DisableModule(moduleName)
    end
    ns.States = {}
end

function Events:RefreshAllDetectors()
    for _, mod in ipairs(DETECTORS) do
        gUI:GetModule(mod):Refresh()
    end
end

-- Entrada principal: invocada directamente por los detectores para evitar lag de AceEvent
function Events:RegisterEvent(event, state, extra)
    if self[event .. "_Timer"] then
        self:CancelTimer(self[event .. "_Timer"])
        self[event .. "_Timer"] = nil
    end

    local delayKey = DELAY_CONFIG[event]
    if delayKey and state == false then
        local delay = gUI:GetModule("Database"):GetGlobals()[delayKey] or 0
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

    -- Notifica al resto de la UI que el estado global ha cambiado
    self:SendMessage("GHOSTUI_EVENT_READY", event, state, extra)
end