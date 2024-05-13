local StateManager = HideUI:NewModule("StateManager", "AceEvent-3.0")

local EVENT_REGISTRY = {}
local MAX_REGISTRY_LENGTH = 3
local ENABLE_FIRST_OUT = false

local PRIORITIES = {
    PLAYER_MOUNT_STATE = 1,
    PLAYER_AFK_STATE = 2,
    PLAYER_COMBAT_STATE = 3
}

function StateManager:OnEnable()
    self:RegisterMessage("PLAYER_AFK_STATE_CHANGED", "EventHandler")
    self:RegisterMessage("PLAYER_MOUNT_STATE_CHANGED", "EventHandler")
    self:RegisterMessage("PLAYER_COMBAT_STATE_CHANGED", "EventHandler")
end

function StateManager:OnDisable()
    EVENT_REGISTRY = {}
    self:UnregisterMessage("PLAYER_AFK_STATE_CHANGED")
    self:UnregisterMessage("PLAYER_MOUNT_STATE_CHANGED")
    self:UnregisterMessage("PLAYER_COMBAT_STATE_CHANGED")
end

function StateManager:EventHandler(state, isActive)
    -- Reconstruye el evento en un diccionario
    local state_str = state:gsub("_CHANGED", "")
    local event = {
        state = state_str,
        priority = PRIORITIES[state_str] or 0,
        isActive = isActive
    }
    self:EventManager(event)
end

function StateManager:GetMaxPriorityEvent()
    local max_priority_event = nil
    for _, reg_event in ipairs(EVENT_REGISTRY) do
        if not max_priority_event then
            max_priority_event = reg_event
        else
            if reg_event.priority > max_priority_event.priority then
                max_priority_event = reg_event
            end
        end
    end

    return max_priority_event
end


function StateManager:EventManager(event) 
    if event.isActive then --"ENTERED"
        if #EVENT_REGISTRY > MAX_REGISTRY_LENGTH then
            table.remove(EVENT_REGISTRY, 1) --Borra más antiguo si alcanza el buffer
        end

        table.insert(EVENT_REGISTRY, event) --Se almacena en buffer

        local max_event = self:GetMaxPriorityEvent()

        if max_event then
            -- Si evento actual tiene la mayor prioridad, exit _ENTERED
            if event.state == max_event.state then
                self:SendMessage("PLAYER_STATE_CHANGED", event.state .. "_ENTERED")
            end
        end
    else --"EXITED"
        -- Primer evento de mayor prioridad
        local first_max_event = self:GetMaxPriorityEvent()

        -- Se elimina su alter true almacenado en buffer
        local i = 1
        while i <= #EVENT_REGISTRY do
            if EVENT_REGISTRY[i].state == event.state and EVENT_REGISTRY[i].isActive then
                table.remove(EVENT_REGISTRY, i)
            else
                i = i + 1
            end
        end

        -- Segundo evento de mayor prioridad 
        local second_max_event = self:GetMaxPriorityEvent()

        if not second_max_event then
            --Evento actual, si buffer vacío
            self:SendMessage("PLAYER_STATE_CHANGED", event.state .. "_EXITED") 
        else
            if ENABLE_FIRST_OUT and first_max_event == event then
                -- El último evento con máxima prioridad, salida
                self:SendMessage("PLAYER_STATE_CHANGED", event.state .. "_EXITED")
                return
            end
            if first_max_event ~= second_max_event then
                -- El segundo evento con máxima prioridad, salida
                self:SendMessage("PLAYER_STATE_CHANGED", second_max_event.state .. "_ENTERED")
            else
                -- Si salida de algún evento de prioridad inferior, aviso de mantención del evento actual
                self:SendMessage("PLAYER_STATE_CHANGED", second_max_event.state .. "_RETURNED")
            end         
        end
    end
end