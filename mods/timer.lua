local Timer_mod = HideUI:NewModule("Timer_mod")

local TIMER_DELAY = 0.02 --Global timer delay

function Timer_mod:OnInitialize()
    self.delay = TIMER_DELAY
end

function Timer_mod:OnEnable()
    self:Start()
end

function Timer_mod:OnDisable()
    self:End()
end

----------------------------------------------------------------------------
function Timer_mod:Start()
    self.timer = C_Timer.NewTicker(self.delay, function()
        self:OnTimer()
    end)
end

function Timer_mod:End()
    if self.timer then
        self.timer:Cancel()
    end
end

function Timer_mod:OnTimer()
    --print("Timer_mod is running")
end

----------------------------------------------------------------------------
function Timer_mod:Bind(mod, func_name)
    mod.oldTimer = self.OnTimer
    mod.lastUpdate = 0 --GetTime(), si se prefiere empezar tras el tiempo asignado
    self.OnTimer = function()
        Timer_mod:OnTimerDelay(mod, func_name)
        return mod.oldTimer()
    end
end

function Timer_mod:Unbind(mod)
    self.OnTimer = mod.oldTimer
end

function Timer_mod:OnTimerDelay(mod, func_name)
    local dif = GetTime() - mod.lastUpdate
    if dif >= mod.updateInterval then
        mod.lastUpdate = GetTime()
        mod[func_name](mod)
    end 
end

function Timer_mod:Wait(mod, func_name, time, noWait, ...)
    --Ejecuta una función tras esperar X tiempo
    local args = {...}
    local lastUpdate = func_name .. "_lastUpdate"
    if not mod[lastUpdate] then
        if noWait then
            mod[lastUpdate] = GetTime() - time --Si se empieza sin esperar
        else
            mod[lastUpdate] = GetTime()
        end
    end

    local dif = GetTime() - mod[lastUpdate]
    if dif >= time then
        mod[lastUpdate] = GetTime()
        mod[func_name](mod, unpack(args)) --Elapsed = (tiempo exacto cuando se ejecute esta función)
    end 
end