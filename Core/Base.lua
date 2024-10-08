local Base = HideUI:NewModule("Base")
local EventManager

local PLAYER_COMBAT_STATE = "PLAYER_COMBAT_STATE"
local NO_STATE = "NO_STATE"
local ENABLE_FIRST_OUT = false
local ORIGINAL_ALPHA = 1
local MOUSEOVER_REVEAL_ALPHA = 1
local ALPHA_CHANGE_DELAY = 0
local FRAME_DESTROY_DELAY = 0

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
        if not self.frame.HideUI_loaded then
            self:OnCreate()
            self.frame.HideUI_loaded = true
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
        -- Solución a aquellos frames que se muestran/ocultan en medio del juego
        if not self:IsHooked(self.frame, "OnShow") then
            self:SecureHookScript(self.frame, "OnShow", function() self:OnShowHandler() end)
        end

        -- Actualiza su opacidad
        local alpha = self:GetAlpha()
        self:SelectFade(self.frame, nil, self.originalAlpha, alpha)
    end

    function Initial:Destroyer()
        if self.frame then
            if self:IsHooked(self.frame, "OnShow") then self:Unhook(self.frame, "OnShow") end
        end

        C_Timer.After(FRAME_DESTROY_DELAY, function()
            local alpha = self:GetAlpha()
            self:SelectFade(self.frame, nil, alpha, self.originalAlpha)
        end)
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

    function Initial:SetSelectedAlpha(field_name)
        -- Cambia el alpha desde la interfaz (slider)
        local mapping = self:GetMapping(field_name)
        local data = self:GetActiveData()
        local active_event = self:GetActiveEvent()
        local result = data[mapping.enabled] and mapping.event == active_event.name

        if result then
            self:SetAlpha(self.frame, data[field_name])
        end
    end

    function Initial:SetSelectedEvent(field_name)
        -- Según orden del usuario, fuerza la salida o reincorporación del evento seleccionado
        -- Si se reincorpora, primero comprueba si el evento se está ejecutando desde el log primario
        -- field = ejemplo: isAlphaEnabled
        local mapping = self:GetMapping(field_name)
        local event = EventManager:CreateEvent(mapping.event, false)
        local data = self:GetActiveData()

        local isEnabled = data[field_name]
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
        local mapping = self:GetMapping(event.state)
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
        EventManager:EventHandler(copy, self.registry, function(e) self:OnEnterEvent(e) end)
    end

    function Initial:OnEnterEvent(event_name)
        self:EnterEvent(event_name)
    end

    function Initial:OnExitEvent(event_name)
        self:ExitEvent(event_name)
    end

    function Initial:EnterEvent(event_name)
        -- Si es EXIT, vuelve a NO_STATE
        local isExitEvent = event_name:match(".EXIT")
        if isExitEvent then
            self:OnExitEvent(event_name)
            return
        end

        -- Cambia al nuevo alpha
        local formatted_event = EventManager:StripEventSuffix(event_name)
        local mapping = self:GetMapping(formatted_event)
        local data = self:GetActiveData()

        local base_alpha = self:GetAlpha()
        local event_alpha = data[mapping.amount]

        self:SelectFade(self.frame, nil, base_alpha, event_alpha)

        -- Fuerza a cambiar el alpha a aquellos frames rezagados
        C_Timer.After(1, function()
            local active_event = self:GetActiveEvent()
            if formatted_event == active_event.name then
                self:SetAlpha(self.frame, event_alpha)
            end
        end)

        -- Actualiza active_event
        self:SetActiveEvent(formatted_event, event_alpha)
    end

    function Initial:ExitEvent(event_name)
        -- Corrige problema de doble llamada al encender/apagar el addon
        if not self:IsGlobalEnabled() then return end

        -- Rescata el alpha del evento anterior y limpia active_event
        local active_event = self:GetActiveEvent()
        local base_alpha = active_event.alpha
        self:SetActiveEvent(NO_STATE)

        -- Si está en combate, cambia el retardo
        local alpha_delay = ALPHA_CHANGE_DELAY
        if event_name == PLAYER_COMBAT_STATE .. ".EXIT" then
            for _, event in ipairs(self.registry) do
                if event.state == PLAYER_COMBAT_STATE and event.isActive then
                    return -- Si evento sigue activo tras COMBAT_END_DELAY, no llamar a fade
                end
            end
            alpha_delay = self.globals.combatEndDelay
        end
        -- Actualiza al alpha base
        C_Timer.After(alpha_delay, function()
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

        local fields = self:GetEventFields()
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

    function Initial:SetExtra(field_name)
        -- Aquí llegan todos los fields actualizados desde la interfaz
        -- Solo para aquellos frames con fields adicionales y únicos, ejemplo: ChatFrame.lua
    end

    -------------------------------------------------------------------------------->>>
    -- Utils
    function Initial:IsLocalEnabled()
        return self.props.isEnabled
    end

    function Initial:IsGlobalEnabled()
        return self.globals.isEnabled
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
        if not base or not target then
            return
        end
        if frame then
            UIFrameFadeRemoveFrame(frame)
        end
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
        if frame then
            UIFrameFadeRemoveFrame(frame)
        end
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

    function Initial:GetMapping(data)
        return EventManager:GetMapping(data)
    end

    function Initial:GetEventFields()
        return EventManager:GetMapping("fields")
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
    Initial.frame = frame
    Initial.name  = props.name

    -- Si es Cluster, delega responsabilidad a Cluster.lua
    if props.cluster then
        local mod = HideUI:GetModule("Cluster", true)
        return mod:Create(Initial)
    -- Si es Community, delega responsabilidad a Single.lua
    elseif props.source == "community" then
        local mod = HideUI:GetModule("Single", true)
        return mod:Create(Initial)
    else
        -- Si existe un modulo con el nombre del frame en carpeta "/Frames" , redirige
        local mod = HideUI:GetModule(Initial.name, true)
        if mod then
            return mod:Create(Initial)
        else
            return Initial
        end
    end
end