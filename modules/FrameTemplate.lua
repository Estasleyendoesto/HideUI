local FrameTemplate = HideUI:NewModule("FrameTemplate")
local EventManager

local IS_LOADED = false
local FIRST_LOAD_DELAY = 1
local COMBAT_END_DELAY = 1
local STATE_BINDINGS = {
    --AFK
    PLAYER_AFK_STATE_ENTER    = {alphaAmount = 0},
    PLAYER_AFK_STATE_HOLD     = {alphaAmount = 0},
    PLAYER_AFK_STATE_NEXT     = {alphaAmount = 0},
    PLAYER_AFK_STATE_EXIT     = {alphaAmount = 0},
    --Mount
    PLAYER_MOUNT_STATE_ENTER  = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_HOLD   = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_NEXT   = {alphaAmount = 0},
    PLAYER_MOUNT_STATE_EXIT   = {alphaAmount = 0},
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
            self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.originalAlpha, alpha)
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
        self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, alpha, 1)

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

    -------------------------------------------------------------------------------->>>
    -- Toggles (From Interface)
    function template:OnAlphaUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
        if origin == "Global" and field == "globalAlphaAmount" then
            if not self.props.isAlphaEnabled then
                self:SetAlpha(self.frame, self.event_alpha or self.globals.globalAlphaAmount)
            end
        elseif origin == "Custom" then
            if field == "alphaAmount" and self.props.isAlphaEnabled then
                self:SetAlpha(self.frame, self.event_alpha or self.props.alphaAmount)
            elseif field == "isAlphaEnabled" then
                if self.event_alpha then return end -- Si en evento, no hay fade
                if self.props.isAlphaEnabled then
                    self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.globals.globalAlphaAmount, self.props.alphaAmount)
                else
                    self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, self.props.alphaAmount, self.globals.globalAlphaAmount)
                end
            end
        end
    end

    function template:OnFrameToggle(origin) --From FrameManager:FrameSettingsUpdate()
        local fields = {"isAFKEnabled", "isMountEnabled", "isCombatEnabled", "isInstanceEnabled"}
        if origin == "Custom" then
            --Event
            for _, field in ipairs(fields) do
                self:OnEventUpdate(field, "Custom")
            end
            --Alpha
            if self.event_alpha then return end
            if self.props.isAlphaEnabled then
                self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, self.globals.globalAlphaAmount, self.props.alphaAmount)
            end
        elseif origin == "Global" then
            --Event
            for _, field in ipairs(fields) do
                self:OnEventUpdate(field, "Global")
            end
            --Alpha
            if self.event_alpha then return end
            self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, self.props.alphaAmount, self.globals.globalAlphaAmount)
        end
    end

    function template:OnEventUpdate(field, origin) --From FrameManager:FrameSettingsUpdate(), :GlobalSettingsUpdate()
        local EventHandler = function(_field, isEnabled)
            local bindings = {
                isAFKEnabled = "PLAYER_AFK_STATE",
                isMountEnabled = "PLAYER_MOUNT_STATE",
                isCombatEnabled = "PLAYER_COMBAT_STATE",
                isInstanceEnabled = "PLAYER_INSTANCE_STATE"
            }
            local eventLog = EventManager:GetLog()
            local event
            if isEnabled then
                for _, log in ipairs(eventLog) do
                    if log.state == bindings[_field] then
                        -- Para un evento reactivado, si está en log copia el evento a su registro
                        event = EventManager:CreateEvent(log.state, log.isActive)
                        break
                    end
                end
            else
                event = EventManager:CreateEvent(bindings[_field], isEnabled)
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

    function template:OnExtraUpdate(field)
    end

     -------------------------------------------------------------------------------->>>
    -- Calls
    function template:OnEvent(event, origin) --From FrameManager:EventReceiver()  
        local bindings = {
            PLAYER_AFK_STATE = "isAFKEnabled",
            PLAYER_MOUNT_STATE = "isMountEnabled",
            PLAYER_COMBAT_STATE = "isCombatEnabled",
            PLAYER_INSTANCE_STATE = "isInstanceEnabled"
        }
        local field = bindings[event.state]
        local isEnabled

        if origin == "Custom" then
            isEnabled = self.props[field]
        elseif origin == "Global" then
            isEnabled = self.globals[field]
        end

        -- Copia el evento compartido por todos los frames
        local copy = EventManager:CreateEvent(event.state, event.isActive)

        if isEnabled and event.isActive then
            copy.isActive = true
        elseif isEnabled == false then
            copy.isActive = false
        end

        EventManager:EventHandler(copy, self.registry, function(e) self:OnEventEnter(e) end)
    end

    function template:OnEventExit(msg, alpha, event_alpha)
        local SetFadeOut = function()
            self:FadeOut(self.frame, self.globals.mouseoverFadeOutDuration, event_alpha, alpha)
            self.event_alpha = nil
        end

        if msg == "PLAYER_COMBAT_STATE_EXIT" then
            C_Timer.After(COMBAT_END_DELAY, function()
                local max = EventManager:GetMaxEvent(self.registry)
                for _, event in ipairs(self.registry) do 
                    if event.state == "PLAYER_COMBAT_STATE" and event.isActive then
                        return -- Si evento sigue activo tras COMBAT_END_DELAY, no llamar a fade
                    elseif max.priority > 3 then
                        --Mucho cuidado aquí, si funciona crear un getPriority en eventmanager
                        return
                    end
                end
                SetFadeOut()
            end)
        else
            SetFadeOut()
        end
    end

    function template:OnEventEnter(msg) --From EventManager:EventSender()
        local binding = STATE_BINDINGS[msg]
        if binding then
            local alpha = self:GetAlpha()
            self.event_alpha = binding.alphaAmount
            if string.find(msg, "_EXIT") then
                self:OnEventExit(msg, alpha, self.event_alpha)
            else
                self:FadeIn(self.frame, self.globals.mouseoverFadeInDuration, alpha, self.event_alpha)
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
            return self.globals.globalAlphaAmount
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

    function template:SetAlpha(frame, amount)
        if self:IsVisible(frame) then
            frame:SetAlpha(amount)
        end
    end

    template.registry = {}
    template.globals  = globals
    template.props    = props
    template.mouseoverAlpha = 1
    template.originalAlpha  = nil
    template.event_alpha    = nil
    template.enableFirstOut = false
    if frame and type(frame) == "table" then
        template.frame = frame
        template.name = frame:GetName()
    end
    return template
end