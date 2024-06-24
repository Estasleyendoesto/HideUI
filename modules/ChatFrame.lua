local ChatFrame = HideUI:NewModule("ChatFrame")
local FrameTemplate

local IMMERSIVE_ON = false

function ChatFrame:OnInitialize()
    FrameTemplate = HideUI:GetModule("FrameTemplate")
end

function ChatFrame:Embed(target)
    LibStub("AceHook-3.0"):Embed(target)
end

function ChatFrame:Create(args, globals)
    local template = FrameTemplate:Create(nil, args, globals)
    self:Embed(template)

    function template:OnChatReady()
        self:OnReady()
        self:ChatFramesUpdate("hook")
    end

    function template:OnDestroy()
        local alpha = self:GetAlpha()
        self:FadeOut(nil, self.globals.mouseoverFadeOutAmount, alpha, self.originalAlpha)
        self:ChatFramesUpdate("unhook")
    end

    -------------------------------------------------------------------------------->>>
    -- Hooks
    function template:ChatFramesUpdate(operator)
        -- Para la detección de nuevas ventanas de chat
        local methods = {
            "FCF_Close",               --Al cerrar una ventana
            "FCF_OpenNewWindow",       --Si es < NUM_CHAT_WINDOWS, 1 al 10
            "FCF_OpenTemporaryWindow", --Si es > NUM_CHAT_WINDOWS, desde 11+ 
            "FCF_ResetChatWindows",    --Cuando se reducen a 2 (default y combatlog)
            "FCF_NewChatWindow",       --No se lo que hace pero igual lo pongo xD
        }

        local OnIntercept = function()
            self.chatboxes = self:GetChatFrames()
        end

        for _, method in ipairs(methods) do
            if operator == "hook" and not self:IsHooked(method) then
                self:SecureHook(method, OnIntercept)
            elseif operator == "unhook" and self:IsHooked(method) then
                self:Unhook(method)
            end
        end

        -- Para los Editboxes
        for _, chatbox in ipairs(self.chatboxes) do
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

    -------------------------------------------------------------------------------->>>
    -- Mouseover
    function template:OnMouseover(origin)
        local alpha = self.event_alpha or self:GetAlpha()
        local isEnabled = false
        local isMouseover = false
        if origin == "Custom" then
            isEnabled = self.props.isMouseoverEnabled
        elseif origin == "Global" then
            isEnabled = self.globals.isMouseoverEnabled
        end

        if not isEnabled then return end
        if self.isOnFocusGained then return end -- Previene que altere al editbox

        for _, chatbox in ipairs(self.chatboxes) do
            if self:IsOnMouseover(chatbox.chatFrame) or
               self:IsOnMouseover(chatbox.tab) or
               self:IsOnMouseover(chatbox.editBox) or
               self:IsOnMouseover(chatbox.buttonFrame) or
               self:IsOnMouseover(self.socialFrame) or
               self:IsOnMouseover(self.combatLogFrame)
            then
                isMouseover = true
                break
            end
        end

        if isMouseover then
            if not self.fadedIn then
                self.fadedIn = true
                self:FadeIn(nil, self.globals.mouseoverFadeInAmount, alpha, self.mouseoverAlpha)
            end
        else
            if self.fadedIn then
                self.fadedIn = false
                self:FadeOut(nil, self.globals.mouseoverFadeOutAmount, self.mouseoverAlpha, alpha)
            end
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Editbox
    function template:EditBoxHandler(action)
        local alpha = self.event_alpha or self:GetAlpha()
        if action == "FocusLost" then
            self.isOnFocusGained = false
            self:FadeOut(nil, self.globals.mouseoverFadeOutAmount, self.focusAlpha, alpha)
        elseif action == "FocusGained" then
            self.isOnFocusGained = true
            self:FadeIn(nil, self.globals.mouseoverFadeInAmount, alpha, self.focusAlpha)
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Inmersive Mode
    --[[
    function template:OnMinimalMode(type, delay, base, target)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if type == "fadeIn" then
                    if string.find(frame:GetName(), "EditBox") then
                        target = target * self.editBoxFactor
                        if self.isOnFocusGained then target = 1 end -- Previene editbox
                    end
                    base = frame:GetAlpha()
                    UIFrameFadeIn(frame, delay, base, target)
                elseif type == "fadeOut" then
                    if string.find(frame:GetName(), "Tab") then
                        frame.noMouseAlpha = target
                    end
                    base = frame:GetAlpha()
                    local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")
                    if chatFrame and frame:GetName() == chatFrame then
                        UIFrameFadeRemoveFrame(frame)
                        UIFrameFadeOut(frame, delay, base, target)
                    else
                        -- target = 0
                        UIFrameFadeRemoveFrame(frame)
                        UIFrameFadeOut(frame, delay, base, target * 0)
                    end

                end
            end
        end
        self:BatchBoxes(getFrame)

            -- Si inmmersion ON
            local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")
            if chatFrame and frame:GetName() == chatFrame then
                local alpha = self.event_alpha or self:GetAlpha()
                target = alpha
                UIFrameFadeOut(frame, delay, base, target)
                return
            else
                target = 0
                UIFrameFadeOut(frame, delay, base, target)
                return
            end
        --]]
    --[[
    function template:OnMinimalChatter(from)
        if from == "MouseIn" then
        elseif from == "MouseOut" then
        elseif from == "FocusGained" then
        elseif from == "FocusLost" then
        else
            ConsoleAddMessage("pepito")
        end
    end

    function template:OnFocus(fade_type, amount, base, target, method)
        IMMERSIVE_ON = false
        if IMMERSIVE_ON then
            self:OnMinimal(amount, base, target, method)
        else
            if fade_type == "FadeIn" then
                self:FadeIn(nil, amount, base, target)
            elseif fade_type == "FadeOut" then
                self:FadeOut(nil, amount, base, target)
            end
        end
    end

    function template:OnMinimal(amount, base, target, method)
        local hideAll = function(frame)
            -- ChatFrame#
            local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")
            if chatFrame and frame:GetName() == chatFrame then
                for i = 1, select("#", frame:GetRegions()) do
                    local region = select(i, frame:GetRegions())
                    if region:GetObjectType() == "Texture" then
                        if string.find(region:GetName(), "Background") then
                            region:SetColorTexture(0, 0, 0, 0)
                        else
                            region:SetColorTexture(0, 0, 0, 0)
                        end
                    end
                end

                return
            end

            -- Editboxes
            if string.find(frame:GetName(), "EditBox") then
                if not frame:IsShown() then return end
                UIFrameFadeOut(frame, amount, self.focusAlpha * 0.92, 0)
                C_Timer.After(amount, function()
                    frame:Hide()
                end)

                return
            end

            -- ButtonFrame (Buttons + CombatLog)
            if string.find(frame:GetName(), "ButtonFrame") then
                for i = 1, select("#", frame:GetRegions()) do
                    local region = select(i, frame:GetRegions())
                    if region:GetObjectType() == "Texture" then
                        if string.find(region:GetName(), "Background") then
                            region:SetColorTexture(0, 0, 0, 0)
                        else
                            region:SetColorTexture(0, 0, 0, 0)
                        end
                    end
                end

                return
            end

            -- Tabs
            if string.find(frame:GetName(), "Tab") then
                if not frame:IsShown() then return end

                if not frame.old_show then
                    frame.old_show = frame.Show
                    frame.Show = function() end
                end

                UIFrameFadeOut(frame, amount, base , 0)
                C_Timer.After(amount, function()
                    frame:Hide()
                end)

                return
            end
        end

        local showAll = function(frame)
            -- if string.find(frame:GetName(), "ButtonFrame") then
            --     if self:IsVisible(frame) then
            --         frame:Show()
            --     end
            --     return
            -- end

            -- if string.find(frame:GetName(), "ButtonFrame") then
            --     for i = 1, select("#", frame:GetRegions()) do
            --         local region = select(i, frame:GetRegions())
            --         if region:GetObjectType() == "Texture" then
            --             if string.find(region:GetName(), "Background") then
            --                 region:SetColorTexture(0, 0, 0, 1)
            --             else
            --                 region:SetColorTexture(0, 0, 0, 0.5)
            --             end
            --         end
            --     end

            --     return
            -- end

            if string.find(frame:GetName(), "Tab") then
                if frame.old_show then
                    frame.Show = frame.old_show
                    frame.old_show = nil
                end

                UIFrameFadeIn(frame, amount, 0, self.mouseoverAlpha * 0.6)
                frame:Show()
                return
            end


        end

        local getFrame = function(frame)
            if frame then
                if method == "FocusGained" then
                    if string.find(frame:GetName(), "EditBox") then
                        UIFrameFadeIn(frame, amount, 0, self.focusAlpha * 0.92)
                    end
                elseif method == "FocusLost" then
                    if string.find(frame:GetName(), "EditBox") then
                        UIFrameFadeOut(frame, amount,self.focusAlpha * 0.92, 0)
                    end
                elseif method == "MouseIn" then
                    showAll(frame)

                    UIFrameFadeIn(self.frameChannel, amount, 0, self.mouseoverAlpha)
                    self.frameChannel:Show()

                    UIFrameFadeIn(self.frameMenu, amount, 0, self.mouseoverAlpha)
                    self.frameMenu:Show()

                    UIFrameFadeIn(self.socialFrame, amount, 0, self.mouseoverAlpha)
                    self.socialFrame:Show()
                elseif method == "MouseOut" then
                    hideAll(frame)

                    UIFrameFadeOut(self.frameChannel, amount, self.mouseoverAlpha, 0)
                    C_Timer.After(amount, function()
                        self.frameChannel:Hide()
                    end)

                    UIFrameFadeOut(self.frameMenu, amount, self.mouseoverAlpha, 0)
                    C_Timer.After(amount, function()
                        self.frameMenu:Hide()
                    end)

                    UIFrameFadeOut(self.socialFrame, amount, self.mouseoverAlpha, 0)
                    C_Timer.After(amount, function()
                        self.socialFrame:Hide()
                    end)
                end
            end
        end
        self:BatchBoxes(getFrame)
    end
    ]]

    function template:OnImmersive(frame, delay, base, target)
        local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")

        if string.find(frame:GetName(), "Tab") then
            frame.noMouseAlpha = 0
        end
        
        UIFrameFadeRemoveFrame(frame)
        if chatFrame and frame:GetName() == chatFrame then



            --[[
            local topGradient = ChatFrame1:CreateTexture(nil, "BACKGROUND")
            topGradient:SetTexture("Interface\\Buttons\\WHITE8X8") -- Usa una textura blanca
            topGradient:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT")
            topGradient:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT")
            topGradient:SetHeight(100) -- Ajusta la altura del degradado

            -- Aplica un degradado al color de la textura
            topGradient:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 0)) -- De negro a transparente

            -- Asegúrate de que el texto del ChatFrame1 se vea afectado por el degradado
            for _, region in ipairs({ChatFrame1:GetRegions()}) do
                if region:GetObjectType() == "FontString" then
                    region:SetDrawLayer("OVERLAY")
                end
            end
            ]]
            UIFrameFadeOut(frame, delay, base, target)
        else
            UIFrameFadeOut(frame, delay, base, target * 0)
        end
    end

    -------------------------------------------------------------------------------->>>
    -- ...
    function template:GetChatFrames()
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

    function template:FadeIn(empty, delay, base, target)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if string.find(frame:GetName(), "EditBox") then
                    target = target * self.editBoxFactor
                    if self.isOnFocusGained then target = 1 end -- Previene editbox
                end
                base = frame:GetAlpha()
                UIFrameFadeIn(frame, delay, base, target)
            end
        end
        self:BatchBoxes(getFrame)
    end

    function template:FadeOut(empty, delay, base, target)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if string.find(frame:GetName(), "EditBox") then
                    base = base * self.editBoxFactor
                    target = target * self.editBoxFactor
                end
                if string.find(frame:GetName(), "Tab") then
                    frame.noMouseAlpha = target
                end

                if IMMERSIVE_ON then
                    self:OnImmersive(frame, delay, base, target)
                else
                    UIFrameFadeOut(frame, delay, base, target)
                end
            end
        end
        self:BatchBoxes(getFrame)
    end

    function template:SetAlpha(empty, amount)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if string.find(frame:GetName(), "EditBox") then
                    amount = amount * self.editBoxFactor
                end
                frame:SetAlpha(amount)
            end
        end
        self:BatchBoxes(getFrame)
    end

    function template:BatchBoxes(func)
        func(self.socialFrame)
        func(self.combatLogFrame)
        for _, chatbox in ipairs(self.chatboxes) do
            func(chatbox.tab)
            func(chatbox.chatFrame)
            func(chatbox.editBox)
            func(chatbox.buttonFrame)
        end
    end

    template.name = "Chatbox"
    template.chatboxes = template:GetChatFrames()
    template.socialFrame = _G["QuickJoinToastButton"]
    template.combatLogFrame = _G["CombatLogQuickButtonFrame_Custom"]
    template.frameChannel = _G["ChatFrameChannelButton"]
    template.frameMenu = _G["ChatFrameMenuButton"]
    template.editBoxFactor = 0.44
    template.focusAlpha = 1

    return template
end