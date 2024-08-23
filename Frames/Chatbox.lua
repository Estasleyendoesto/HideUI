local Chatbox = HideUI:NewModule("Chatbox")

local FOCUS_ALPHA = 1
local EDITBOX_FACTOR = 0.44
local SOCIAL_FRAME = "QuickJoinToastButton"
local COMBAT_LOG = "CombatLogQuickButtonFrame_Custom"
local CHANNEL_BUTTON = "ChatFrameChannelButton"
local MENU_BUTTON = "ChatFrameMenuButton"
local TEXT_MODE_ENABLED = "isTextModeEnabled"

function Chatbox:Create(initializer)
    local Initial = initializer

    function Initial:Initializer()
        self:ChatFramesUpdate("hook")

        if self:IsTextModeEnable() then
            local alpha = self:GetAlpha()
            self:SetAlpha(nil, alpha)
            self:UpdateRegionVisibility()
        end
    end

    function Initial:OnDestroy()
        self:Destroyer()
        self:ChatFramesUpdate("unhook")
        if self:IsTextModeEnable() then
            local alpha = self:GetAlpha()
            self:SetAlpha(nil, self.originalAlpha)
            self:UpdateRegionVisibility(true)
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Hooks
    function Initial:ChatFramesUpdate(operator)
        -- Para la detección de nuevas ventanas de chat
        local methods = {
            "FCF_Close",               --Al cerrar una ventana
            "FCF_OpenNewWindow",       --Si es < NUM_CHAT_WINDOWS, 1 al 10
            "FCF_OpenTemporaryWindow", --Si es > NUM_CHAT_WINDOWS, desde 11+ 
            "FCF_ResetChatWindows",    --Cuando se reducen a 2 (default y combatlog)
            "FCF_NewChatWindow",       --No se lo que hace pero igual lo pongo xD
        }

        local InterceptEditBoxes = function()
            for _, chatbox in ipairs(self.chatFrames) do
                if chatbox.editBox then
                    if operator == "hook" then
                        if not self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                            self:SecureHookScript(chatbox.editBox, "OnEditFocusLost", function() self:EditBoxHandler("FocusLost") end)
                        end
                        if not self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                            self:SecureHookScript(chatbox.editBox, "OnEditFocusGained", function() self:EditBoxHandler("FocusGained") end)
                        end
                    elseif operator == "unhook" then
                        if self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                            self:Unhook(chatbox.editBox, "OnEditFocusLost")
                        end
                        if self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                            self:Unhook(chatbox.editBox, "OnEditFocusGained")
                        end
                    end
                end
            end
        end

        local OnIntercept = function()
            -- Actualiza chatboxes si hay cambios en las ventanas
            self.chatboxes = self:GetChatFrames()
            -- Para los Editboxes
            InterceptEditBoxes()
        end

        -- Window Hooks
        for _, method in ipairs(methods) do
            if operator == "hook" and not self:IsHooked(method) then
                self:SecureHook(method, OnIntercept)
            elseif operator == "unhook" and self:IsHooked(method) then
                self:Unhook(method)
            end
        end

        -- Para los Editboxes
        InterceptEditBoxes()
    end

    -------------------------------------------------------------------------------->>>
    -- Mouseover
    function Initial:OnMouseover()
        local alpha = self:GetAlpha()
        local data = self:GetActiveData()
        local isEnabled = data.isMouseoverEnabled
        local isMouseover

        if not isEnabled then return end
        if self.isOnFocusGained then return end -- Previene que altere al editbox

        for _, chatbox in ipairs(self.chatFrames) do
            if self:IsOnMouseover(chatbox.chatFrame) or
               self:IsOnMouseover(chatbox.tab) or
               self:IsOnMouseover(chatbox.editBox) or
               self:IsOnMouseover(chatbox.buttonFrame) or
               self:IsOnMouseover(self.socialFrame) or
               self:IsOnMouseover(self.combatLog)
            then
                isMouseover = true
                break
            end
        end

        if isMouseover then
            if not self.fadedIn then
                self.fadedIn = true
                self:FadeIn(nil, self.globals.mouseoverFadeInDuration, alpha, self.mouseoverAlpha)
            end
        else
            if self.fadedIn then
                self.fadedIn = false
                self:FadeOut(nil, self.globals.mouseoverFadeOutDuration, self.mouseoverAlpha, alpha)
            end
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Editbox
    function Initial:EditBoxHandler(action)
        local alpha = self:GetAlpha()
        if action == "FocusLost" then
            self.isOnFocusGained = false
            self:FadeOut(nil, self.globals.mouseoverFadeOutDuration, self.focusAlpha, alpha)
        elseif action == "FocusGained" then
            self.isOnFocusGained = true
            self:FadeIn(nil, self.globals.mouseoverFadeInDuration, alpha, self.focusAlpha)
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Extra Updates
    function Initial:SetExtra(field)
        if field == TEXT_MODE_ENABLED then
            local alpha = self:GetAlpha()
            self:SetAlpha(nil, alpha)
            self:UpdateRegionVisibility()
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Text Mode
    function Initial:ModifyTargetAmount(frame, target)
        if not self:IsTextModeEnable() then
            return target
        end

        local name = frame:GetName()
        local tab = name:match("^ChatFrame%d%d?Tab$")
        local editBox = name:match("EditBox")
        local quick = name:match("QuickJoinToastButton")
        local button = name:match("ButtonFrame")
        if tab or editBox or quick or button then
            target = 0
        end

        return target
    end

    function Initial:ModifyRegionVisibility(frame, force_enable)
        if frame:GetName():match("^ChatFrame%d+$") then
            for _, region in ipairs({ frame:GetRegions() }) do
                local regionType  = region:GetObjectType()
                if regionType == "Texture" then
                    if self:IsTextModeEnable() and not force_enable then
                        C_Timer.After(0.12, function()
                            region:Hide()
                        end)
                    else
                        C_Timer.After(0.07, function()
                            region:Show()
                        end)
                    end
                end
            end
        end
    end

    function Initial:UpdateRegionVisibility(force_enable)
        self:BatchBoxes(function(frame)
            if self:IsVisible(frame) then
                self:ModifyRegionVisibility(frame, force_enable)
            end
        end)
    end

    -------------------------------------------------------------------------------->>>
    -- Utils
    function Initial:GetFrames()
        --Busca y empaqueta los chatframes
        local activeChats = {}
        local i = 1
        while true do
            local chatTab = _G["ChatFrame" .. i .. "Tab"]
            if chatTab then --Tab es más preciso para encontrar los chatframes
                if chatTab:IsVisible() then
                    table.insert(
                        activeChats,
                        {
                            id = i,
                            tab = chatTab,
                            chatFrame = _G["ChatFrame" .. i] or  nil,
                            editBox = _G["ChatFrame" .. i .. "EditBox"] or nil,
                            buttonFrame = _G["ChatFrame" .. i .. "ButtonFrame"] or nil,
                        }
                    )
                end
            else
                break
            end
            i = i + 1
        end
        return activeChats
    end

    function Initial:BatchBoxes(func)
        func(self.socialFrame)
        func(self.combatLog)
        for _, chatbox in ipairs(self.chatFrames) do
            func(chatbox.tab)
            func(chatbox.chatFrame)
            func(chatbox.editBox)
            func(chatbox.buttonFrame)
        end
    end

    function Initial:SetAlpha(_, amount)
        self:BatchBoxes(function(frame)
            if self:IsVisible(frame) then
                -- Text Mode
                local _amount = self:ModifyTargetAmount(frame, amount)

                -- Text Mode - Corrección a comportamiento errático
                local active_event = self:GetActiveEvent()
                if active_event.name == "NO_STATE" and self:IsGlobalEnabled() then
                    self:ModifyRegionVisibility(frame)
                end
                -- End

                -- Filters
                if string.find(frame:GetName(), "EditBox") then
                    _amount = _amount * self.editBoxFactor
                end
                frame:SetAlpha(_amount)
            end
        end)
    end

    function Initial:FadeIn(_, delay, base, target)
        self:BatchBoxes(function(frame)
            if self:IsVisible(frame) then
                -- Text Mode
                self:ModifyRegionVisibility(frame, true)

                -- Text Mode - Corrección a comportamiento errático
                local _target = target
                local active_event = self:GetActiveEvent()

                if not self.fadedIn then
                    if active_event.name == "NO_STATE" and self:IsGlobalEnabled() then
                        self:ModifyRegionVisibility(frame)
                        _target = self:ModifyTargetAmount(frame, target)
                    end
                end
                -- End

                -- Filters
                if string.find(frame:GetName(), "EditBox") then
                    _target = _target * self.editBoxFactor
                    if self.isOnFocusGained then
                        _target = 1 -- Previene editbox
                    end
                end
                base = frame:GetAlpha() -- Evita parpadeo
                UIFrameFadeIn(frame, delay, base, _target)
            end
        end)
    end

    function Initial:FadeOut(_, delay, base, target)
        self:BatchBoxes(function(frame)
            if self:IsVisible(frame) then
                -- Text Mode
                local _target = target
                _target = self:ModifyTargetAmount(frame, target)
                self:ModifyRegionVisibility(frame)

                -- Filters
                if string.find(frame:GetName(), "EditBox") then
                    -- Normaliza al verdadero valor escalar
                    base = base * self.editBoxFactor
                    _target = _target * self.editBoxFactor
                end
                if string.find(frame:GetName(), "Tab") then
                    -- Cancela su reaparición tras clic
                    frame.noMouseAlpha = _target
                end
                -- Fade
                UIFrameFadeOut(frame, delay, base, _target)
            end
        end)
    end

    function Initial:IsTextModeEnable()
        return self.props.isTextModeEnabled
    end

    Initial.chatFrames = Initial:GetFrames()
    Initial.socialFrame = _G[SOCIAL_FRAME]
    Initial.combatLog = _G[COMBAT_LOG]
    Initial.channelButton = _G[CHANNEL_BUTTON]
    Initial.menuButton = _G[MENU_BUTTON]
    Initial.editBoxFactor = EDITBOX_FACTOR
    Initial.focusAlpha = FOCUS_ALPHA
    Initial.isOnFocusGained = false --De control

    return Initial
end