local ChatFrame = HideUI:NewModule("ChatFrame")
local FrameTemplate

-- local IMMERSIVE_ON = true

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
        self.ready = true
        self:OnReady()
        self:ChatFramesUpdate("hook")
    end

    function template:OnDestroy()
        self.ready = nil
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

        local InterceptEditBoxes = function()
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
    function template:OnImmersive(frame, delay, base, target)
        local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")

        if string.find(frame:GetName(), "Tab") then
            frame.noMouseAlpha = 0
        end
        
        UIFrameFadeRemoveFrame(frame)
        if chatFrame and frame:GetName() == chatFrame then
            --[[
            print("INFO-----------------------------------------------")
            for _, region in ipairs({ChatFrame1:GetRegions()}) do
                local regionType = region:GetObjectType()
                local info = "Tipo de región: " .. regionType
                if regionType == "Texture" then
                    info = info .. ", Nombre de la textura: " .. (region:GetName() or "nil") .. ", Layer: " .. region:GetDrawLayer()
                end
                print(info)
            end
            ]]
            for _, region in ipairs({frame:GetRegions()}) do
                local regionType  = region:GetObjectType()
                local regionLayer = region:GetDrawLayer()

                if regionType == "Texture" then
                    region.old_alpha = region:GetAlpha()
                    region:SetAlpha(0)
                    region:Hide()

                    --[[
                    if regionLayer == "BACKGROUND" then
                        region:SetAlpha(0)
                    elseif regionLayer == "BORDER" then
                        region:SetAlpha(0)
                    end
                    ]]
                end
            end
            UIFrameFadeOut(frame, delay, base, target)
            return
        end

        UIFrameFadeOut(frame, delay, base, target * 0)
    end

    function template:OnImmersiveOff(frame, delay, base, target)
        local chatFrame = string.match(frame:GetName(), "^ChatFrame%d+$")
        UIFrameFadeRemoveFrame(frame)
        if chatFrame and frame:GetName() == chatFrame then
            for _, region in ipairs({frame:GetRegions()}) do
                local regionType  = region:GetObjectType()
                local regionLayer = region:GetDrawLayer()
    
                if regionType == "Texture" then
                    if region.old_alpha then
                        region:SetAlpha(region.old_alpha)
                        region.old_alpha = nil
                        region:Show()
                    end
                end
            end
        end
    end

    -------------------------------------------------------------------------------->>>
    -- Extra Updates
    function template:OnExtraUpdate(field)
        local alpha = self.event_alpha or self:GetAlpha()
        if field == "isTextModeEnabled" then
            if self.props.isTextModeEnabled then
                self:FadeOut(nil, self.globals.mouseoverFadeOutAmount, alpha, alpha)
            else
                self:FadeIn(nil, self.globals.mouseoverFadeInAmount, alpha, alpha)
            end
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
                base = frame:GetAlpha() -- Evita parpadeo
                
                -- Si modo immersivo activo, solo modifica ChatFrame#
                if self.props.isTextModeEnabled then
                    self:OnImmersiveOff(frame, delay, base, target)
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
                    -- Normaliza al verdadero valor escalar
                    base = base * self.editBoxFactor
                    target = target * self.editBoxFactor
                end
                if string.find(frame:GetName(), "Tab") then
                    -- Cancela su reaparición tras clic
                    frame.noMouseAlpha = target
                end

                -- Si modo immersivo está activo, sino default
                -- Puesto separado para fácil desacoplamiento
                if self.props.isTextModeEnabled and self.ready then
                    self:OnImmersive(frame, delay, base, target)
                    return
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