local FrameTemplate = HideUI:NewModule("FrameTemplate")
local EventManager

local IS_LOADED = false
local FIRST_LOAD_DELAY = 1
local MOUSEOVER_REVEAL_ALPHA = 1
local STATE_BINDINGS = {
    --AFK
    PLAYER_AFK_STATE_ENTER = {alphaAmount = 0},
    PLAYER_AFK_STATE_HOLD  = {alphaAmount = 0},
    PLAYER_AFK_STATE_NEXT  = {alphaAmount = 0},
    PLAYER_AFK_STATE_EXIT  = {alphaAmount = 0},
    --Mount
    PLAYER_MOUNT_STATE_ENTER = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_HOLD  = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_NEXT  = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_EXIT  = {alphaAmount = 0},
    --Combat
    PLAYER_COMBAT_STATE_ENTER = {alphaAmount = 1},
    PLAYER_COMBAT_STATE_HOLD  = {alphaAmount = 1},
    PLAYER_COMBAT_STATE_NEXT  = {alphaAmount = 1},
    PLAYER_COMBAT_STATE_EXIT  = {alphaAmount = 1},
    --Instance
    PLAYER_INSTANCE_STATE_ENTER = {alphaAmount = 1},
    PLAYER_INSTANCE_STATE_HOLD  = {alphaAmount = 1},
    PLAYER_INSTANCE_STATE_NEXT  = {alphaAmount = 1},
    PLAYER_INSTANCE_STATE_EXIT  = {alphaAmount = 1},
}
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

local CopyStateBindings = function()
    local copy = {}
    for k, v in pairs(STATE_BINDINGS) do
        copy[k] = {alphaAmount = v.alphaAmount}
    end
    return copy
end

function FrameTemplate:OnInitialize()
    EventManager = HideUI:GetModule("EventManager")
end

function FrameTemplate:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
    LibStub("AceHook-3.0"):Embed(target)
end

function FrameTemplate:Create(frame, props, globals)
    local template = {}
    self:Embed(template)

    function template:OnReady()
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

            -- self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.originalAlpha, alpha)
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

    function template:OnDestroy()
        local alpha = self:GetAlpha()
        -- self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, alpha, 1)
        self:SelectFade(self.frame, nil, alpha, 1)

        if self.frame then
            if self:IsHooked(self.frame, "OnShow") then self:Unhook(self.frame, "OnShow") end
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Hooks
    function template:OnShowHandler()
        local alpha = self:GetAlpha()
        self:SetAlpha(self.frame, self.event_alpha or alpha)
    end

    -- Toggles (From Interface)
    -------------------------------------------------------------------------------->>>
    function template:OnAlphaUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
        if origin == "Global" then
            local IsAlphaModifiable = function(isGlobalEvent, isFrameEnabled, isFrameEvent)
                local function tonumber(bool)
                    return bool == true and 1 or 0
                end
            
                local globalEvent = tonumber(isGlobalEvent)
                local enabledFrame = tonumber(isFrameEnabled)
                local frameEvent = tonumber(isFrameEvent)
            
                local result = enabledFrame * (1 - frameEvent)
                result = globalEvent * result + globalEvent * (1 - result)
            
                return result
            end

            local FormatEventName = function(event)
                if event == "NO_STATE" then
                    return "NO_STATE"
                end
                local patterns = {"_EXIT$", "_NEXT$", "_HOLD$", "_ENTER$"}
                for _, pattern in ipairs(patterns) do
                    event = string.gsub(event, pattern, "")
                end
                return event
            end

            local args = MAPPINGS[field]
            local global_alpha  = (args.event == "NO_STATE")
            local alpha_enabled = global_alpha or self.globals[args.enabled]
            if IsAlphaModifiable(alpha_enabled, self.props.isEnabled, self.props[args.enabled]) then
                local formatted = FormatEventName(self.current_event_name)
                if formatted == args.event then
                    self:SetAlpha(self.frame, self.globals[field])
                    self:UpdateStateBindings(args.event, self.globals[field])
                end
            end
        elseif origin == "Custom" then
            if field == "alphaAmount" and self.props.isAlphaEnabled then
                self:SetAlpha(self.frame, self.event_alpha or self.props.alphaAmount)
            elseif field == "isAlphaEnabled" then
                if self.event_alpha then return end -- Si en evento, no hay fade
                if self.props.isAlphaEnabled then
                    self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.globals.alphaAmount, self.props.alphaAmount)
                else
                    self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, self.props.alphaAmount, self.globals.alphaAmount)
                end
            end
        end
    end

    function template:OnFrameToggle(origin) --From FrameManager:FrameSettingsUpdate()
        if origin == "Custom" then
            --Event
            for _, field in ipairs(MAPPINGS.fields) do
                self:OnEventUpdate(field, "Custom")
            end
            --Alpha
            if self.event_alpha then return end
            if self.props.isAlphaEnabled then
                -- self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.globals.alphaAmount, self.props.alphaAmount)
                self:SelectFade(self.frame, nil, self.globals.alphaAmount, self.props.alphaAmount)
            end
        elseif origin == "Global" then
            --Event
            for _, field in ipairs(MAPPINGS.fields) do
                self:OnEventUpdate(field, "Global")
            end
            --Alpha
            if self.event_alpha then return end
            -- self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, self.props.alphaAmount, self.globals.alphaAmount)
            self:SelectFade(self.frame, nil, self.globals.alphaAmount, self.props.alphaAmount)
        end
    end

    function template:OnEventUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
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
                event = EventManager:CreateEvent(MAPPINGS[field_name].event, isEnabled)
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

    function template:OnExtraUpdate(field) --From FrameManager:FrameSettingsUpdate()
        -- Aquí llegan todos los fields actualizados desde la interfaz
        -- Solo para aquellos frames con fields adicionales y únicos, ejemplo: ChatFrame.lua
    end

    -- Calls
    -------------------------------------------------------------------------------->>>
    function template:OnEvent(event, origin) --From FrameManager:EventReceiver()  
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

    function template:OnEventExit(msg, current_alpha)
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

    function template:OnEventEnter(msg) --From EventManager:EventSender()
        local binding = self.state_bindings[msg]
        if binding then
            local current_alpha = self.event_alpha or self:GetAlpha()
            local target_alpha  = binding.alphaAmount

            self.event_alpha = target_alpha
            self.current_event_name = msg
            if string.find(msg, "_EXIT") then
                self:OnEventExit(msg, target_alpha)
            else
                self:SelectFade(self.frame, nil, current_alpha, target_alpha)
            end
        end
    end

    function template:OnMouseover(origin) --From FrameManager:OnLoop()
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
    function template:IsActive()
        return self.props.isEnabled
    end

    function template:GetAlpha()
        if self.props.isEnabled then
            return self.props.alphaAmount
        else
            return self.globals.alphaAmount
        end
    end

    function template:IsVisible(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() then
            return true
        else
            return false
        end
    end

    function template:IsOnMouseover(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() and frame:IsMouseOver() then
            return true
        else
            return false
        end
    end

    function template:FadeIn(frame, delay, base, target)
        if self:IsVisible(frame) then
            UIFrameFadeIn(frame, delay, base, target)
        end
    end

    function template:FadeOut(frame, delay, base, target)
        if self:IsVisible(frame) then
            UIFrameFadeOut(frame, delay, base, target)
        end
    end

    function template:SelectFade(frame, delay, base, target)
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

    function template:SetAlpha(frame, amount)
        if self:IsVisible(frame) then
            frame:SetAlpha(amount)
        end
    end

    function template:UpdateStateBindings(event, input, update_all)
        local Bind = function(event_name, amount)
            local patterns = {"_EXIT", "_NEXT", "_HOLD", "_ENTER"}
            for _, pattern in ipairs(patterns) do
                local name = event_name .. pattern
                self.state_bindings[name].alphaAmount = amount
            end
        end
        if update_all then
            local mapping
            local alpha_amount
            for _, field_name in ipairs(MAPPINGS.fields) do
                mapping = MAPPINGS[field_name]
                if self.props.isEnabled and self.props[field_name] then
                    alpha_amount = self.props[mapping.amount]
                else
                    alpha_amount = self.globals[mapping.amount]
                end
                Bind(mapping.event, alpha_amount)
            end
        else
            if event == "NO_STATE" then return end
            Bind(event, input)
        end
    end

    template.registry = {}
    template.globals  = globals
    template.props    = props
    template.mouseoverAlpha = MOUSEOVER_REVEAL_ALPHA
    template.originalAlpha  = nil
    template.event_alpha    = nil
    template.enableFirstOut = false
    template.current_event_name = "NO_STATE"
    template.state_bindings = CopyStateBindings()
    template:UpdateStateBindings(nil, nil, true)
    if frame and type(frame) == "table" then
        template.frame = frame
        template.name  = frame:GetName()
    end
    return template
end