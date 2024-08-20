local BaseFrame = HideUI:NewModule("BaseFrame")
local EventManager

local IS_LOADED = false
local FIRST_LOAD_DELAY = 1
local ENABLE_FIRST_OUT = false
local MOUSEOVER_REVEAL_ALPHA = 1
local MAPPINGS = {
    fields = {}
}
do
    local data = {
        {event = "NO_STATE",              enabled = "isAlphaEnabled",    amount = "alphaAmount"        },
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
        if entry.enabled ~= "isAlphaEnabled" then
            --isAlphaEnabled no corresponde a ningún campo de estado, se omite
            table.insert(MAPPINGS.fields, entry.enabled)
        end
    end
end

function BaseFrame:OnInitialize()
    EventManager = HideUI:GetModule("EventManager")
end

function BaseFrame:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
    LibStub("AceHook-3.0"):Embed(target)
end

function BaseFrame:Create(frame, props, globals)
    local Initial = {}
    self:Embed(Initial)

    function Initial:OnReady()
        local SetOpacity = function()
            if not self.frame then
                self.originalAlpha = 1
            else
                self.originalAlpha = self.frame:GetAlpha()

                -- Solución a aquellos frames que se muestran/ocultan en medio del juego
                if not self:IsHooked(self.frame, "OnShow") then
                    self:SecureHookScript(self.frame, "OnShow", function() self:OnShowHandler() end)
                end
            end

            local alpha = self.event_alpha or self:GetAlpha()
            self:SelectFade(self.frame, nil, self.originalAlpha, alpha)
        end

        if not IS_LOADED then
            -- IS_LOADED solo se ejecuta una vez al iniciar el addon o al hacer /reload
            -- El temporizador de 1s es para aquellos frames que fijan su velocidad tarde
            local delay = FIRST_LOAD_DELAY
            if self.name == "MainStatusTrackingBarContainer" then
                delay = 2.5 --Porque la barrita de exp es muy lenta en cargar
            end
        
            C_Timer.After(delay, function()
                SetOpacity()
                IS_LOADED = true
            end)
        else
            SetOpacity()
        end
    end

    function Initial:OnDestroy()
        local alpha = self:GetAlpha()
        -- self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, alpha, 1)
        self:SelectFade(self.frame, nil, alpha, 1)

        if self.frame then
            if self:IsHooked(self.frame, "OnShow") then self:Unhook(self.frame, "OnShow") end
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Hooks
    function Initial:OnShowHandler()
        local alpha = self:GetAlpha()
        self:SetAlpha(self.frame, self.event_alpha or alpha)
    end

    -- Toggles (From Interface)
    -------------------------------------------------------------------------------->>>
    function Initial:OnAlphaUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
        if origin == "Global" then
            local args = MAPPINGS[field]
            local formatted = EventManager:StripEventSuffix(self.current_event_name)
            if not self.props.isEnabled then
                if formatted == args.event then
                    self:SetAlpha(self.frame, self.globals[field])
                end
            end
        elseif origin == "Custom" then
            if field == "alphaAmount" then
                if self.event_alpha then return end
                self:SetAlpha(self.frame, self.props.alphaAmount)
            else
                local args = MAPPINGS[field]
                local formatted = EventManager:StripEventSuffix(self.current_event_name)
                if self.props[args.enabled] then
                    if args.event == formatted then
                        self:SetAlpha(self.frame, self.props[field])
                    end
                end
            end
        end
    end

    function Initial:OnFrameToggle(change_to) --From FrameManager:FrameSettingsUpdate()
        local base_alpha
        local target_alpha
        self.registry = {}
        self.event_alpha = nil
        self.current_event_name = "NO_STATE"
        if change_to == "Custom" then
            for _, field in ipairs(MAPPINGS.fields) do
                if self.props[field] then
                    self:OnEventUpdate(field, "Custom")
                end
            end
            base_alpha = self.globals.alphaAmount
            target_alpha = self.props.alphaAmount
        elseif change_to == "Global" then
            for _, field in ipairs(MAPPINGS.fields) do
                self:OnEventUpdate(field, "Global")
            end
            base_alpha = self.props.alphaAmount
            target_alpha = self.globals.alphaAmount
        end
        if self.event_alpha then return end
        self:SelectFade(self.frame, nil, base_alpha, target_alpha)
    end

    function Initial:OnEventUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
        local EventHandler = function(field_name, isEnabled)
            local eventLog = EventManager:GetLog()
            local event
            if isEnabled then
                for _, log in ipairs(eventLog) do
                    if log.state == MAPPINGS[field_name].event then
                        -- Para un evento reactivado, si está en log copia el evento a su registro
                        event = EventManager:CreateEvent(log.state, log.isActive)
                        break
                    end
                end
            else
                event = EventManager:CreateEvent(MAPPINGS[field_name].event, isEnabled) --false
            end
            if event ~= nil then
                self:OnEvent(event, origin)
            end
        end
        if origin == "Global" then
            local isEnabled = self.globals[field]
            EventHandler(field, isEnabled)
        elseif origin == "Custom" then
            local isEnabled = self.props[field]
            EventHandler(field, isEnabled)
        end
    end

    function Initial:OnExtraUpdate(field) --From FrameManager:FrameSettingsUpdate()
        -- Aquí llegan todos los fields actualizados desde la interfaz
        -- Solo para aquellos frames con fields adicionales y únicos, ejemplo: ChatFrame.lua
    end

    -- Calls
    -------------------------------------------------------------------------------->>>
    function Initial:OnEvent(event, origin) --From FrameManager:EventReceiver()  
        local field = MAPPINGS[event.enabled]
        local isEnabled

        if origin == "Custom" then
            isEnabled = self.props[field]
        elseif origin == "Global" then
            isEnabled = self.globals[field]
        end

        -- Copia evento compartido por todos los frames
        local copy = EventManager:CreateEvent(event.state, event.isActive)

        if isEnabled and event.isActive then
            copy.isActive = true
        elseif isEnabled == false then
            copy.isActive = false
        end

        EventManager:EventHandler(copy, self.registry, function(e) self:OnEventEnter(e) end)
    end

    function Initial:OnEventEnter(msg) --From EventManager:EventSender()
        local event = EventManager:StripEventSuffix(msg)
        local mapping = MAPPINGS[event]

        local current_alpha = self.event_alpha or self:GetAlpha()
        local target_alpha = current_alpha

        if self.props[mapping.enabled] then
            if self.props.isEnabled then
                target_alpha = self.props[mapping.amount]
            else
                target_alpha = self.globals[mapping.amount]
            end
        end

        self.event_alpha = target_alpha
        self.current_event_name = msg

        if string.find(msg, "_EXIT") then
            self:OnEventExit(msg, target_alpha)
        else
            self:SelectFade(self.frame, nil, current_alpha, target_alpha)
        end
    end

    function Initial:OnEventExit(msg, current_alpha)
        local SetFadeOut = function()
            local target_alpha = self:GetAlpha()
            self:SelectFade(self.frame, nil, current_alpha, target_alpha)

            self.event_alpha = nil
            self.current_event_name = "NO_STATE"
        end
        -- Comportamiento especial tras salir de combate
        if msg == "PLAYER_COMBAT_STATE_EXIT" then
            C_Timer.After(self.globals.combatEndDelay, function()
                local combat_state = "PLAYER_COMBAT_STATE"
                local combat_priority = EventManager:GetPriority(combat_state)
                local max = EventManager:GetMaxEvent(self.registry)
                for _, event in ipairs(self.registry) do
                    if event.state == combat_state and event.isActive then
                        return -- Si evento sigue activo tras COMBAT_END_DELAY, no llamar a fade
                    elseif max.priority > combat_priority then
                        return
                    end
                end
                SetFadeOut()
            end)
        else
            -- Pueden definirse otros comportamientos aquí -> (elseif...)
            SetFadeOut()
        end
    end

    function Initial:OnMouseover(origin) --From FrameManager:OnLoop()
        local alpha = self.event_alpha or self:GetAlpha()
        local isEnabled = false
        local isMouseover = self:IsOnMouseover()

        if origin == "Custom" then
            isEnabled = self.props.isMouseoverEnabled
        elseif origin == "Global" then
            isEnabled = self.globals.isMouseoverEnabled
        end

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

    -------------------------------------------------------------------------------->>>
    -- Utils
    function Initial:IsActive()
        return self.props.isEnabled
    end

    function Initial:GetAlpha()
        if self.props.isEnabled then
            return self.props.alphaAmount
        else
            return self.globals.alphaAmount
        end
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

    Initial.registry = {}
    Initial.globals  = globals
    Initial.props    = props
    Initial.mouseoverAlpha = MOUSEOVER_REVEAL_ALPHA
    Initial.originalAlpha  = nil
    Initial.event_alpha    = nil
    Initial.enableFirstOut = ENABLE_FIRST_OUT
    Initial.current_event_name = "NO_STATE"
    if frame and type(frame) == "table" then
        Initial.frame = frame
        Initial.name  = frame:GetName()
    end
    return Initial
end