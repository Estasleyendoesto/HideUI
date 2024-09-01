local EventManager = HideUI:NewModule("EventManager", "AceEvent-3.0")

local EVENT_LOG = {}
local MAPPINGS = {
    fields = {}
}
do
    local data = {
        {event = "PLAYER_MOUNT_STATE",    enabled = "isMountEnabled",    amount = "mountAlphaAmount"   , priority = 1, name = "mount"},
        {event = "PLAYER_AFK_STATE",      enabled = "isAFKEnabled",      amount = "afkAlphaAmount"     , priority = 2, name = "afk"},
        {event = "PLAYER_COMBAT_STATE",   enabled = "isCombatEnabled",   amount = "combatAlphaAmount"  , priority = 3, name = "combat"},
        {event = "PLAYER_INSTANCE_STATE", enabled = "isInstanceEnabled", amount = "instanceAlphaAmount", priority = 4, name = "instance"},
        -- Insertar aquí nuevos eventos, si los hay...
        -- ...
    }
    for _, entry in ipairs(data) do
        MAPPINGS[entry.event]     = {enabled = entry.enabled, amount = entry.amount, priority = entry.priority,  name = entry.name}
        MAPPINGS[entry.enabled]   = {event   = entry.event,   amount = entry.amount, priority = entry.priority,  name = entry.name}
        MAPPINGS[entry.name]      = {enabled = entry.enabled, amount = entry.amount,    event = entry.event, priority = entry.priority}
        MAPPINGS[entry.priority]  = {enabled = entry.enabled, amount = entry.amount,    event = entry.event,     name = entry.name}
        MAPPINGS[entry.amount]    = {enabled = entry.enabled,  event = entry.event , priority = entry.priority,  name = entry.name}
    end
    for _, entry in ipairs(data) do
        if entry.enabled then
            table.insert(MAPPINGS.fields, entry.enabled)
        end
    end
end

function EventManager:OnEnable()
    --AFK
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnAFKState")
    --Combat
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatState")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatState")
    self:RegisterEvent("UNIT_COMBAT", "OnCombatState")
    --Mount
    self:RegisterEvent("UNIT_AURA", "OnMountState")
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "OnMountState")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", "OnMountState")
    self:RegisterEvent("UNIT_EXITED_VEHICLE", "OnMountState")
    --Al cambiar de instancia
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnInstance")
    --Evaluación inicial
    self:CheckEvents()
end

function EventManager:OnDisable()
    --AFK
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
    --Combat
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("UNIT_COMBAT")
    --Mount
    self:UnregisterEvent("UNIT_AURA")
    self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
    self:UnregisterEvent("UNIT_EXITED_VEHICLE")
    --Al cambiar de instancia
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    --Flush
    self:ExitStates()
    EVENT_LOG = {}
end

-------------------------------------------------------------------------------->>>
-- Events Manager
function EventManager:CheckEvents()
    self.isMounted = false
    self.inCombat = false
    self.inInstance = false
    self:OnAFKState()
    self:OnMountState(nil, "player")
    self:OnCombatState("UNIT_COMBAT", "player")
    self:CheckInstance()
end

function EventManager:Recall(event_name)
    if event_name == MAPPINGS.afk.event then
        self:OnAFKState()
    elseif event_name == MAPPINGS.mount.event then
        self.isMounted = false
        self:OnMountState(nil, "player")
    elseif event_name == MAPPINGS.combat.event then
        self.inCombat = false
        self:OnCombatState("UNIT_COMBAT", "player")
    elseif event_name == MAPPINGS.instance.event then
        self.inInstance = false
        self:CheckInstance()
    end
end

function EventManager:ExitStates()
    self:NotifyEvent(MAPPINGS.afk.event, false)
    self:NotifyEvent(MAPPINGS.combat.event, false)
    self:NotifyEvent(MAPPINGS.mount.event, false)
    self:NotifyEvent(MAPPINGS.instance.event, false)
end

function EventManager:StripEventSuffix(event_name)
    if event_name == "NO_STATE" then
        return "NO_STATE"
    end
    local patterns = {".EXIT$", ".NEXT$", ".HOLD$", ".ENTER$"}
    for _, pattern in ipairs(patterns) do
        event_name = string.gsub(event_name, pattern, "")
    end
    return event_name
end

function EventManager:GetMapping(data)
    return MAPPINGS[data]
end

function EventManager:GetMappings()
    return MAPPINGS
end

function EventManager:GetPriority(event_name)
    return MAPPINGS[event_name].priority
end

function EventManager:GetLog()
    return EVENT_LOG
end

function EventManager:CreateEvent(event_name, isActive)
    local priority = 0
    if MAPPINGS[event_name] then
        priority = MAPPINGS[event_name].priority
    end
    return {
        state = event_name,
        priority = priority,
        isActive = isActive
    }
end

function EventManager:NotifyEvent(event_name, isActive)
    local event = self:CreateEvent(event_name, isActive)
    self:EventHandler(event, EVENT_LOG) -- Log
    self:SendMessage("PLAYER_STATE_CHANGED", event)
end

function EventManager:EventHandler(event, registry, func, fifo)
    -- Evita el primer llamado de _exit si la entrada inicial es false
    if #registry == 0 and not event.isActive then
        return
    end

    -- Inserta/elimina del registro
    if event.isActive then
        local exists = false
        for _, reg_ev in ipairs(registry) do
            if reg_ev.state == event.state and reg_ev.isActive then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(registry, event) -- Inserta si no existe
            if func then
                self:EventSender(event, registry, func, fifo)
            end
        end
    else
        for i = #registry, 1, -1 do
            local reg_ev = registry[i]
            if reg_ev.isActive and reg_ev.state == event.state then
                table.remove(registry, i) -- Elimina par registrado
                if func then
                    self:EventSender(event, registry, func, fifo)
                end
                break
            end
        end
    end
end

function EventManager:EventSender(event, registry, func, fifo)
    local max_event = self:GetMaxEvent(registry)
    -- _exit, lista vacía
    if not event.isActive and #registry == 0 then
        func(event.state .. ".EXIT")
        return
    end
    if event.isActive then
        -- _enter, actual máximo
        if event.state == max_event.state then
            func(event.state .. ".ENTER")
        end
    else
        -- _hold, sale inferior
        if event.priority < max_event.priority then
            func(max_event.state .. ".HOLD")
        else
            if fifo then
                -- _exit, actual máximo
                if event.priority > max_event.priority then
                    func(event.state .. ".EXIT_FIRST")
                end
            else
                -- _next, segundo máximo
                if event.state ~= max_event.state then
                    func(max_event.state .. ".NEXT")
                end
            end
        end
    end
end

function EventManager:GetMaxEvent(registry)
    local max_event
    for _, reg_event in ipairs(registry) do
        if not max_event then
            max_event = reg_event
        else
            if reg_event.priority > max_event.priority then
                max_event = reg_event
            end
        end
    end
    return max_event
end

---------------------------------------------------------------------------->>>
-- New Instance
function EventManager:OnInstance()
    self:CheckEvents()
end

function EventManager:CheckInstance()
    if IsInInstance() then
        if not self.inInstance then
            self:NotifyEvent(MAPPINGS.instance.event, true)
            self.inInstance = true
        end
    else
        self:NotifyEvent(MAPPINGS.instance.event, false)
        self.inInstance = false
    end
end

-------------------------------------------------------------------------------->>>
-- AFK State
function EventManager:OnAFKState()
    if UnitIsAFK("player") then
        self:NotifyEvent(MAPPINGS.afk.event, true)
    else
        self:NotifyEvent(MAPPINGS.afk.event, false)
    end
end

-------------------------------------------------------------------------------->>>
-- Combat State
function EventManager:OnCombatState(event_name, unit, ...)
    local combat_enter = false
    local combat_end = false
    if event_name == "PLAYER_REGEN_ENABLED" then
        if self.inCombat then
            self.inCombat = false
            combat_end = true
        end
    elseif event_name == "PLAYER_REGEN_DISABLED" then
        if not self.inCombat then
            self.inCombat = true
            combat_enter = true
        end
    elseif event_name == "UNIT_COMBAT" and unit == "player" then
        if UnitAffectingCombat("player") and not self.inCombat then
            self.inCombat = true
            combat_enter = true
        elseif not UnitAffectingCombat("player") and self.inCombat then
            self.inCombat = false
            combat_end = true
        end
    end
    if combat_enter then
        self:NotifyEvent(MAPPINGS.combat.event, true)
    end
    if combat_end then
        self:NotifyEvent(MAPPINGS.combat.event, false)
    end
end

-------------------------------------------------------------------------------->>>
-- Mount State
function EventManager:OnMountState(event_name, unit)
    if unit ~= "player" then return end

    if IsMounted() or UnitInVehicle("player") then
        if not self.isMounted then
            self.isMounted = true
            self:NotifyEvent(MAPPINGS.mount.event, true)
        end
    else
        if self.isMounted then
            self.isMounted = false
            self:NotifyEvent(MAPPINGS.mount.event, false)
        end
    end
end