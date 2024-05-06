local Timer_mod = HideUI:NewModule("Timer_mod")

local TIMER_DELAY = 0.05 --Global timer delay

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
        mod[func_name]()
    end 
end