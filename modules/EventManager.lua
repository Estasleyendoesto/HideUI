local EventManager = HideUI:NewModule("EventManager", "AceEvent-3.0")

local COMBAT_END_DELAY = 1
local EVENT_LOG = {}
local PRIORITIES = {
    -- Número más alto mayor prioridad
    PLAYER_MOUNT_STATE = 1,
    PLAYER_AFK_STATE = 2,
    PLAYER_COMBAT_STATE = 3,
    PLAYER_INSTANCE_STATE = 4,
}

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

function EventManager:Recall(state)
    if state == "PLAYER_AFK_STATE" then
        self:OnAFKState()
    elseif state == "PLAYER_MOUNT_STATE" then
        self.isMounted = false
        self:OnMountState(nil, "player")
    elseif state == "PLAYER_COMBAT_STATE" then
        self.inCombat = false
        self:OnCombatState("UNIT_COMBAT", "player")
    elseif state == "PLAYER_INSTANCE_STATE" then
        self.inInstance = false
        self:CheckInstance()
    end
end

function EventManager:ExitStates()
    self:NotifyEvent("PLAYER_AFK_STATE", false)
    self:NotifyEvent("PLAYER_COMBAT_STATE", false)
    self:NotifyEvent("PLAYER_MOUNT_STATE", false)
    self:NotifyEvent("PLAYER_INSTANCE_STATE", false)
end

function EventManager:GetLog()
    return EVENT_LOG
end

function EventManager:CreateEvent(state, isActive)
    return {
        state = state,
        priority = PRIORITIES[state] or 0,
        isActive = isActive
    }
end

function EventManager:NotifyEvent(state, isActive)
    local event = self:CreateEvent(state, isActive)
    self:EventHandler(event, EVENT_LOG)
    self:SendMessage("PLAYER_STATE_CHANGED", event)
end
 
function EventManager:EventHandler(event, registry, func, firstOut)
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
                self:EventSender(event, registry, func, firstOut)
            end
        end
    else
        for i = #registry, 1, -1 do
            local reg_ev = registry[i]
            if reg_ev.isActive and reg_ev.state == event.state then
                table.remove(registry, i) -- Elimina par registrado
                if func then
                    self:EventSender(event, registry, func, firstOut)
                end
                break
            end
        end
    end
end

function EventManager:EventSender(event, registry, func, firstOut)
    local max_event = self:GetMaxEvent(registry)
    -- _exit, lista vacía
    if not event.isActive and #registry == 0 then
        func(event.state .. "_EXIT")
        return
    end
    if event.isActive then
        -- _enter, actual máximo
        if event.state == max_event.state then
            func(event.state .. "_ENTER")
        end
    else
        -- _hold, sale inferior
        if event.priority < max_event.priority then
            func(max_event.state .. "_HOLD")
        else
            if firstOut then
                -- _exit, actual máximo
                if event.priority > max_event.priority then
                    func(event.state .. "_EXIT_FIRST")
                end
            else
                -- _next, segundo máximo
                if event.state ~= max_event.state then
                    func(max_event.state .. "_NEXT")
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
            self:NotifyEvent("PLAYER_INSTANCE_STATE", true)
            self.inInstance = true
        end
    else
        self:NotifyEvent("PLAYER_INSTANCE_STATE", false)
        self.inInstance = false
    end
end

-------------------------------------------------------------------------------->>>
-- AFK State
function EventManager:OnAFKState()
    if UnitIsAFK("player") then
        self:NotifyEvent("PLAYER_AFK_STATE", true)
    else
        self:NotifyEvent("PLAYER_AFK_STATE", false)
    end
end

-------------------------------------------------------------------------------->>>
-- Combat State
function EventManager:OnCombatState(event, unit, ...)
    local combat_enter = false
    local combat_end = false
    if event == "PLAYER_REGEN_ENABLED" then
        if self.inCombat then
            self.inCombat = false
            combat_end = true
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if not self.inCombat then
            self.inCombat = true
            combat_enter = true
        end
    elseif event == "UNIT_COMBAT" and unit == "player" then
        if UnitAffectingCombat("player") and not self.inCombat then
            self.inCombat = true
            combat_enter = true
        elseif not UnitAffectingCombat("player") and self.inCombat then
            self.inCombat = false
            combat_end = true
        end
    end
    if combat_enter then
        self:NotifyEvent("PLAYER_COMBAT_STATE", true)
    end
    if combat_end then
        C_Timer.After(COMBAT_END_DELAY, function()
            self:NotifyEvent("PLAYER_COMBAT_STATE", false)
        end)
    end
end

-------------------------------------------------------------------------------->>>
-- Mount State
function EventManager:OnMountState(event, unit)
    if unit ~= "player" then return end

    if IsMounted() or UnitInVehicle("player") then
        if not self.isMounted then
            self.isMounted = true
            self:NotifyEvent("PLAYER_MOUNT_STATE", true)
        end
    else
        if self.isMounted then
            self.isMounted = false
            self:NotifyEvent("PLAYER_MOUNT_STATE", false)
        end
    end
end