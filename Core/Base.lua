local Base = HideUI:NewModule("Base")
local EventManager

local NO_STATE = "NO_STATE"
local IS_LOADED = false
local ENABLE_FIRST_OUT = false
local FIRST_LOAD_DELAY = 1
local ORIGINAL_ALPHA = 1
local MOUSEOVER_REVEAL_ALPHA = 1
local ALPHA_CHANGE_DELAY = 0.18
local MAPPINGS = {
    fields = {}
}
do
    local data = {
        {event = "PLAYER_AFK_STATE",      enabled = "isAFKEnabled",      amount = "afkAlphaAmount"     },
        {event = "PLAYER_MOUNT_STATE",    enabled = "isMountEnabled",    amount = "mountAlphaAmount"   },
        {event = "PLAYER_COMBAT_STATE",   enabled = "isCombatEnabled",   amount = "combatAlphaAmount"  },
        {event = "PLAYER_INSTANCE_STATE", enabled = "isInstanceEnabled", amount = "instanceAlphaAmount"},
        -- Insertar aquí nuevos eventos, si los hay...
        -- ...
    }
    for _, entry in ipairs(data) do
        MAPPINGS[entry.event]   = {enabled = entry.enabled, amount = entry.amount}
        MAPPINGS[entry.enabled] = {event   = entry.event,   amount = entry.amount}
        MAPPINGS[entry.amount]  = {enabled = entry.enabled,  event = entry.event }
    end
    for _, entry in ipairs(data) do
        if entry.enabled then
            table.insert(MAPPINGS.fields, entry.enabled)
        end
    end
end

function Base:OnInitialize()
    EventManager = HideUI:GetModule("EventManager")
end

function Base:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
    LibStub("AceHook-3.0"):Embed(target)
end

function Base:Create(frame, props, globals)
    local Initial = {}
    self:Embed(Initial)

    function Initial:OnReady()
        if not IS_LOADED then
            -- IS_LOADED solo se ejecuta una vez al iniciar el addon o al hacer /reload
            -- El temporizador de 1s es para aquellos frames que fijan su velocidad tarde
            local delay = FIRST_LOAD_DELAY

            -- Porque la barrita de exp es muy lenta en cargar
            if self.name == "MainStatusTrackingBarContainer" then
                delay = 2.5
            end
            ---

            C_Timer.After(delay, function()
                self:OnCreate()
                IS_LOADED = true
            end)
        else
            self:OnReload()
        end
    end

    function Initial:OnCreate()
        self:Initializer()
    end

    function Initial:OnReload()
        self:Initializer()
    end

    function Initial:OnDestroy()
        self:Destroyer()
    end

    function Initial:Initializer()
        -- Solo afecta a frames, no clusters
        if not self.frame then
            return
        end

        -- Solución a aquellos frames que se muestran/ocultan en medio del juego
        if not self:IsHooked(self.frame, "OnShow") then
            self:SecureHookScript(self.frame, "OnShow", function() self:OnShowHandler() end)
        end
         
        -- En cualquier caso, actualiza su opacidad
        local alpha = self:GetAlpha()
        self:SelectFade(self.frame, nil, self.originalAlpha, alpha)
    end

    function Initial:Destroyer()
        local alpha = self:GetAlpha()
        self:SelectFade(self.frame, nil, alpha, self.originalAlpha)

        if self.frame then
            if self:IsHooked(self.frame, "OnShow") then self:Unhook(self.frame, "OnShow") end
        end

        self.registry = nil
        self.activeEvent = nil
        self.globals = nil
        self.props = nil
    end

    -------------------------------------------------------------------------------->>>
    -- Hooks
    function Initial:OnShowHandler()
        local alpha = self:GetAlpha()
        self:SetAlpha(self.frame, alpha)
    end

    -- User settings (From Interface)
    -------------------------------------------------------------------------------->>>
    function Initial:SetBaseAlpha()
        -- Cambia .alphaAmount
        local data = self:GetActiveData()
        local active_event = self:GetActiveEvent()
        if active_event.name == NO_STATE then
            self:SetAlpha(self.frame, data.alphaAmount)
        end
    end

    function Initial:SetSelectedAlpha(field)
        -- Cambia el alpha desde la interfaz (slider)
        -- field = ejemplo: afkAlphaAmount
        local mapping = MAPPINGS[field]
        local data = self:GetActiveData()
        local active_event = self:GetActiveEvent()
        local result = data[mapping.enabled] and mapping.event == active_event.name

        if result then
            self:SetAlpha(self.frame, data[field])
        end
    end

    function Initial:SetSelectedEvent(field)
        -- Según orden del usuario, fuerza la salida o reincorporación del evento seleccionado
        -- Si se reincorpora, primero comprueba si el evento se está ejecutando desde el log primario
        -- field = ejemplo: isAlphaEnabled
        local mapping = MAPPINGS[field]
        local event = EventManager:CreateEvent(mapping.event, false)
        local data = self:GetActiveData()

        local isEnabled = data[field]
        if isEnabled then
            local eventLog = EventManager:GetLog()
            for _, log in ipairs(eventLog) do
                if log.state == mapping.event then
                    event.isActive = log.isActive
                    break
                end
            end
        end

        self:EventListener(event)
    end

    function Initial:EventListener(event)
        -- Recibe el evento en crudo, comprueba si está habilitado en memoria
        -- Según su estado en memoria, admite su registro u ordena su salida

        -- Comprueba si es evento global o local
        local mapping = MAPPINGS[event.state]
        local field = mapping.enabled

        local data = self:GetActiveData()
        local isEnabled = data[field]

        -- Crea una nueva instancia del evento
        local copy = EventManager:CreateEvent(event.state, event.isActive)

        -- Ordena entrada/salida del evento si está habilitado o no en memoria
        if isEnabled and event.isActive then
            copy.isActive = true
        elseif isEnabled == false then
            copy.isActive = false
        end
        EventManager:EventHandler(copy, self.registry, function(e) self:EnterEvent(e) end)
    end

    function Initial:EnterEvent(event)
        -- Si es EXIT, vuelve a NO_STATE
        local isExitEvent = event:match("_EXIT")
        if isExitEvent then
            self:ExitEvent()
            return
        end

        -- Cambia al nuevo alpha
        local formatted_event = EventManager:StripEventSuffix(event)
        local mapping = MAPPINGS[formatted_event]
        local data = self:GetActiveData()

        local base_alpha = self:GetAlpha()
        local event_alpha = data[mapping.amount]

        C_Timer.After(ALPHA_CHANGE_DELAY, function()
            self:SelectFade(self.frame, nil, base_alpha, event_alpha)
        end)

        -- Actualiza active_event
        self:SetActiveEvent(formatted_event, event_alpha)
    end

    function Initial:ExitEvent()
        -- Rescata el alpha del evento anterior y limpia active_event
        local base_alpha = self:GetActiveEvent().alpha
        self:SetActiveEvent(NO_STATE)

        -- Actualiza al alpha base
        C_Timer.After(ALPHA_CHANGE_DELAY, function()
            local target_alpha = self:GetAlpha()
            self:SelectFade(self.frame, nil, base_alpha, target_alpha)
        end)
    end

    function Initial:OnMouseover()
        local data = self:GetActiveData()
        local isEnabled = data.isMouseoverEnabled
        local isMouseover = self:IsOnMouseover()
        local alpha = self:GetAlpha()

        if isEnabled and isMouseover then
            if not self.fadedIn then
                self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, alpha, self.mouseoverAlpha)
                self.fadedIn = true
            end
        else
            if self.fadedIn then
                self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, self.mouseoverAlpha, alpha)
                self.fadedIn = false
            end
        end
    end

    function Initial:Refresh()
        -- Cambia entre la configuración local o global
        -- Se almacena el antiguo alpha
        local data
        local active_event
        local old_alpha

        data = self:GetNoActiveData()
        active_event = self:GetActiveEvent()
        old_alpha = active_event.alpha or data.alphaAmount

        -- Se reinician todos los eventos
        self:SetActiveEvent(NO_STATE, nil)
        self.registry = {}

        local fields = MAPPINGS.fields
        for _, field in ipairs(fields) do
            self:SetSelectedEvent(field)
        end

        -- Se actualiza el alpha del antiguo al nuevo si NO_STATE
        C_Timer.After(ALPHA_CHANGE_DELAY, function()
            active_event = self:GetActiveEvent()
            if active_event.name == NO_STATE then
                self:SelectFade(self.frame, nil, old_alpha, self:GetAlpha())
            end
        end)
    end

    function Initial:SetExtra(field)
        -- Aquí llegan todos los fields actualizados desde la interfaz
        -- Solo para aquellos frames con fields adicionales y únicos, ejemplo: ChatFrame.lua
    end

    -------------------------------------------------------------------------------->>>
    -- Utils
    function Initial:IsLocalEnabled()
        return self.props.isEnabled
    end

    function Initial:GetAlpha()
        local data = self:GetActiveData()
        local active_event = self:GetActiveEvent()

        local alpha = data.alphaAmount
        if active_event.name ~= NO_STATE then
            alpha = active_event.alpha
        end

        return alpha
    end

    function Initial:IsVisible(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() then
            return true
        else
            return false
        end
    end

    function Initial:IsOnMouseover(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() and frame:IsMouseOver() then
            return true
        else
            return false
        end
    end

    function Initial:FadeIn(frame, delay, base, target)
        if self:IsVisible(frame) then
            UIFrameFadeIn(frame, delay, base, target)
        end
    end

    function Initial:FadeOut(frame, delay, base, target)
        if self:IsVisible(frame) then
            UIFrameFadeOut(frame, delay, base, target)
        end
    end

    function Initial:SelectFade(frame, delay, base, target)
        UIFrameFadeRemoveFrame(frame)
        if base > target then
            delay = delay or self.globals.mouseoverFadeOutDuration
            self:FadeOut(frame, delay, base, target)
        elseif base < target then
            delay = delay or self.globals.mouseoverFadeInDuration
            self:FadeIn(frame, delay, base, target)
        else
            -- No_fade
        end
    end

    function Initial:SetAlpha(frame, amount)
        if self:IsVisible(frame) then
            frame:SetAlpha(amount)
        end
    end

    function Initial:GetActiveData()
        if self.props.isEnabled then
            return self.props
        else
            return self.globals
        end
    end

    function Initial:GetNoActiveData()
        -- Para SetMode(), para recuperar el alpha anterior
        if self.props.isEnabled then
            return self.globals
        else
            return self.props
        end
    end

    function Initial:SetActiveEvent(name, alpha)
        self.activeEvent = {
            name  = name,
            alpha = alpha or nil
        }
    end

    function Initial:GetActiveEvent()
        return self.activeEvent
    end

    Initial.registry = {}
    Initial.globals  = globals
    Initial.props    = props
    Initial.mouseoverAlpha = MOUSEOVER_REVEAL_ALPHA
    Initial.enableFirstOut = ENABLE_FIRST_OUT
    Initial.originalAlpha  = ORIGINAL_ALPHA
    Initial.activeEvent = {
        name  = NO_STATE,
        alpha = nil,
    }
    if frame and type(frame) == "table" then
        Initial.frame = frame
        Initial.name  = frame:GetName()
    end
    return Initial
end