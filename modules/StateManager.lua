local StateManager = HideUI:NewModule("StateManager", "AceEvent-3.0")
local Model

local COMBAT_END_DELAY = 1
local ENABLE_FIRST_OUT = false
local MAX_REGISTRY_LENGTH = 3
local EVENT_REGISTRY = {}
local PRIORITIES = {
    -- Número más alto mayor prioridad
    PLAYER_MOUNT_STATE = 1,
    PLAYER_AFK_STATE = 2,
    PLAYER_COMBAT_STATE = 3
}
local INSTANCE_ENABLED
local MOUNT_ENABLED
local AFK_ENABLED
local COMBAT_ENABLED

function StateManager:OnInitialize()
    Model = HideUI:GetModule("Model")
end

function StateManager:OnEnable()
    --Carga inicial 
    INSTANCE_ENABLED = Model:Find("isInstanceEnabled")
    COMBAT_ENABLED = Model:Find("isCombatEnabled")
    MOUNT_ENABLED = Model:Find("isMountEnabled")
    AFK_ENABLED = Model:Find("isAFKEnabled")
    --Global Settings
    self:RegisterMessage("GLOBAL_SETTINGS_CHANGED", "GlobalSettingsUpdate")
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
    self:CheckState()
end

function StateManager:OnDisable()
    --Global Settings
    self:UnregisterMessage("GLOBAL_SETTINGS_CHANGED")
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
    EVENT_REGISTRY = {}
    INSTANCE_ENABLED = nil
    COMBAT_ENABLED = nil
    MOUNT_ENABLED = nil
    AFK_ENABLED = nil
end

-------------------------------------------------------------------------------->>>
-- Global Settings
function StateManager:GlobalSettingsUpdate(msg, arg, value)
    if arg == "INSTANCE" then
        INSTANCE_ENABLED = value
    elseif arg == "MOUNT" then
        MOUNT_ENABLED = value
        self:OnMountState(nil, "player")
    elseif arg == "AFK" then
        AFK_ENABLED = value
        self:OnAFKState()
    elseif arg == "COMBAT" then
        COMBAT_ENABLED = value
        self:OnCombatState("UNIT_COMBAT", "player")
    end
end

-------------------------------------------------------------------------------->>>
-- State Manager
function StateManager:CheckState()
    -- Impide ejecución doble (solo al entrar al juego)
    if not self.executed then return end
    self.isMounted = false
    self.inCombat = false
    self:OnAFKState()
    self:OnMountState(nil, "player")
    self:OnCombatState("UNIT_COMBAT", "player")
end

function StateManager:ExitStates()
    self:EventHandler("PLAYER_AFK_STATE", false)
    self:EventHandler("PLAYER_COMBAT_STATE", false)
    self:EventHandler("PLAYER_MOUNT_STATE", false)

end

function StateManager:EventHandler(state, isActive)
    self:EventManager({
        state = state,
        priority = PRIORITIES[state] or 0,
        isActive = isActive
    })
end

function StateManager:EventManager(event)
    -- Evita el primer llamado de _exited si la entrada inicial es false
    if #EVENT_REGISTRY == 0 and not event.isActive then
        return
    end

    -- Inserta/elimina del registro
    if event.isActive then
        local exists
        for _, reg_ev in ipairs(EVENT_REGISTRY) do
            if reg_ev.state == event.state then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(EVENT_REGISTRY, event) -- Inserta si no existe
            self:NotifyState(event)
        end
    else
        for _, reg_ev in ipairs(EVENT_REGISTRY) do
            if reg_ev.isActive and reg_ev.state == event.state then
                table.remove(EVENT_REGISTRY, _) -- Elimina par registrado
                self:NotifyState(event)
                break
            end
        end
    end
end

function StateManager:NotifyState(event)
    local msg = "PLAYER_STATE_CHANGED"
    local max_event = self:GetMaxEvent()

    -- _exit, lista vacía
    if not event.isActive and #EVENT_REGISTRY == 0 then
        self:SendMessage(msg, event.state .. "_EXIT")
        return
    end

    if event.isActive then
        -- _enter, actual máximo
        if event.state == max_event.state then
            self:SendMessage(msg, event.state .. "_ENTER")
        end
    else
        -- _hold, sale inferior
        if event.priority < max_event.priority then
            self:SendMessage(msg, max_event.state .. "_HOLD")
        else
            if ENABLE_FIRST_OUT then
                -- _exit, actual máximo
                if event.priority > max_event.priority then
                    self:SendMessage(msg, event.state .. "_EXIT_FIRST")
                end
            else
                -- _next, segundo máximo
                if event.state ~= max_event.state then
                    self:SendMessage(msg, max_event.state .. "_NEXT")
                end
            end
        end
    end
end

function StateManager:GetMaxEvent()
    local max_event
    for _, reg_event in ipairs(EVENT_REGISTRY) do
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

-------------------------------------------------------------------------------->>>
-- New Instance
function StateManager:OnInstance()
    EVENT_REGISTRY = {}
    self.isMounted = false
    self.inCombat = false
    self:OnAFKState()
    self:OnMountState(nil, "player")
    self:OnCombatState("UNIT_COMBAT", "player")

    self.executed = true
end

function StateManager:CheckInstance()
    if INSTANCE_ENABLED and IsInInstance() then
        if not self.inInstance then
            EVENT_REGISTRY = {}
            self:SendMessage("PLAYER_STATE_CHANGED", "PLAYER_IN_INSTANCE")
            self.inInstance = true
        end
        return true
    else
        self.inInstance = false
        return false
    end
end

-------------------------------------------------------------------------------->>>
-- AFK State
function StateManager:OnAFKState()
    if self:CheckInstance() then return end
    if not AFK_ENABLED then
        self:EventHandler("PLAYER_AFK_STATE", false)
        return
    end

    if UnitIsAFK("player") then
        self:EventHandler("PLAYER_AFK_STATE", true)
    else
        self:EventHandler("PLAYER_AFK_STATE", false)
    end
end

-------------------------------------------------------------------------------->>>
-- Combat State
function StateManager:OnCombatState(event, unit, ...)
    if self:CheckInstance() then return end
    if not COMBAT_ENABLED then
        self:EventHandler("PLAYER_COMBAT_STATE", false)
        self.inCombat = false
        return
    end

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
        self:EventHandler("PLAYER_COMBAT_STATE", true)
    end
    if combat_end then
        C_Timer.After(COMBAT_END_DELAY, function()
            self:EventHandler("PLAYER_COMBAT_STATE", false)
        end)
    end
end

-------------------------------------------------------------------------------->>>
-- Mount State
function StateManager:OnMountState(event, unit)
    if self:CheckInstance() then return end
    if not MOUNT_ENABLED then
        self:EventHandler("PLAYER_MOUNT_STATE", false)
        self.isMounted = false
        return
    end

    if unit ~= "player" then return end

    if IsMounted() or UnitInVehicle("player") then
        if not self.isMounted then
            self.isMounted = true
            self:EventHandler("PLAYER_MOUNT_STATE", true)
        end
    else
        if self.isMounted then
            self.isMounted = false
            self:EventHandler("PLAYER_MOUNT_STATE", false)
        end
    end
end