local ChatFrame = HideUI:NewModule("ChatFrame")
local FrameTemplate

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

    function template:ChatFramesUpdate(operator)
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
    end

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
                self:FadeIn(nil, self.globals.mouseoverFadeInAmount, alpha, self.mouseoverAlpha)
                self.fadedIn = true
            end
        else
            if self.fadedIn then
                self:FadeOut(nil, self.globals.mouseoverFadeOutAmount, self.mouseoverAlpha, alpha)
                self.fadedIn = false
            end
        end
    end

    function template:FadeIn(empty, delay, base, target)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if string.find(frame:GetName(), "EditBox") then
                    target = target * self.editBoxFactor
                end
                UIFrameFadeIn(frame, delay, base, target)
            end
        end
        self:BatchBoxes(getFrame)
    end

    function template:FadeOut(empty, delay, base, target)
        local getFrame = function(frame)
            if self:IsVisible(frame) then
                if string.find(frame:GetName(), "EditBox") then
                    target = target * self.editBoxFactor
                end
                UIFrameFadeOut(frame, delay, base, target)
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
        end
    end

    template.name = "Chatbox"
    template.chatboxes = template:GetChatFrames()
    template.socialFrame = _G["QuickJoinToastButton"]
    template.combatLogFrame = _G["CombatLogQuickButtonFrame_Custom"]
    template.editBoxFactor = 0.44

    return template
end