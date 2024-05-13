local ChatManager = HideUI:NewModule("ChatManager", "AceEvent-3.0", "AceHook-3.0")
local Model

local CHATBOXES = {}
local POST_UI_FRAMES_UPDATE_DELAY = 0.8

local CUSTOM_ALPHA_ACTIVE = nil
local CUSTOM_ALPHA = 1

local GLOBAL_ALPHA = 1

local FADE_IN_ALPHA_AMOUNT = 1
local FADE_IN_DURATION = 0.5
local FADE_OUT_DURATION = 0.5

local DEFAULT_ALPHA = 1
local EDITBOX_DEFAULT_ALPHA = 0.44 --0.44 default (10.2.7)

local LAST_STATE_ALPHA_AMOUNT = nil

function ChatManager:OnInitialize()
    Model = HideUI:GetModule("Model")
end

function ChatManager:OnEnable()
    GLOBAL_ALPHA = Model:Find("globalAlphaAmount")
    CUSTOM_ALPHA = Model:Find("chatbox").alphaAmount
    CUSTOM_ALPHA_ACTIVE = Model:Find("chatbox").isAlphaEnabled

    FADE_IN_DURATION = Model:Find("mouseOverFadeInAmount")
    FADE_OUT_DURATION = Model:Find("mouseOverFadeOutAmount")

    self:ChatboxUpdateHook()
    self:InterceptUIFadeHook()

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld")

    self:RegisterMessage("GLOBAL_ALPHA_UPDATED", "GlobalAlphaHandler")

    self:RegisterMessage("CHAT_STATE_UPDATED", "ChatStateHandler")
    self:RegisterMessage("CHAT_ALPHA_UPDATED", "ChatAlphaHandler")

    self:RegisterMessage("MOUSE_IN_CHAT_FRAME", "MouseOverEventHandler")
    self:RegisterMessage("MOUSE_OUT_CHAT_FRAME", "MouseOverEventHandler")

    self:RegisterMessage("PLAYER_STATE_CHANGED", "PlayerStateHandler")
end

function ChatManager:OnDisable()
    LAST_STATE_ALPHA_AMOUNT = nil

    self:ChatboxUpdateUnhook()
    self:InterceptUIFadeUnhook()
    self:InterceptEditBoxUnhook()

    self:ChatboxAlphaUpdate("CHATBOX_DISABLED")

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")

    self:UnregisterMessage("GLOBAL_ALPHA_UPDATED")

    self:UnregisterMessage("CHAT_STATE_UPDATED")
    self:UnregisterMessage("CHAT_ALPHA_UPDATED")

    self:UnregisterMessage("MOUSE_IN_CHAT_FRAME")
    self:UnregisterMessage("MOUSE_OUT_CHAT_FRAME")

    self:UnregisterMessage("PLAYER_STATE_CHANGED")
end

----------------------------------------------------------------
-- Events, messages...
----------------------------------------------------------------
function ChatManager:PlayerEnteringWorld()
    C_Timer.After(POST_UI_FRAMES_UPDATE_DELAY, function() 
        self:FindActiveChats()
        self:ChatboxAlphaUpdate("CHATBOX_ENABLED")
        self:InterceptEditBoxHook()
    end)
end

function ChatManager:GlobalAlphaHandler(msg, amount) --GLOBAL_ALPHA_UPDATED
    if msg == "GLOBAL_ALPHA_UPDATED" then
        GLOBAL_ALPHA = amount
        self:ChatboxAlphaUpdate("CHATBOX_UPDATED")
    end
end

function ChatManager:ChatStateHandler(msg, isActive) --CHAT_STATE_UPDATED
    if msg == "CHAT_STATE_UPDATED" then
        CUSTOM_ALPHA_ACTIVE = isActive
        self:ChatboxAlphaUpdate("CHATBOX_UPDATED")
    end
end

function ChatManager:ChatAlphaHandler(msg, amount) --CHAT_ALPHA_UPDATED
    if msg == "CHAT_ALPHA_UPDATED" then
        CUSTOM_ALPHA = amount
        self:ChatboxAlphaUpdate("CHATBOX_UPDATED")
    end
end

----------------------------------------------------------------
-- Hooks
----------------------------------------------------------------
function ChatManager:ChatboxUpdateHook() --CHAT Events
    --Detecta cambios en los chats
    local methods = {
        "FCF_Close",               --Al cerrar una ventana
        "FCF_OpenNewWindow",       --Si es < NUM_CHAT_WINDOWS, 1 al 10
        "FCF_OpenTemporaryWindow", --Si es > NUM_CHAT_WINDOWS, desde 11+ 
        "FCF_ResetChatWindows",    --Cuando se reducen a 2 (default y combatlog)
        "FCF_NewChatWindow",       --No se lo que hace pero igual lo pongo xD
    }
    for _, method in ipairs(methods) do
        if not self:IsHooked(method) then
            self:SecureHook(method, "ChatboxUpdateHandler")
        end
    end
end

function ChatManager:ChatboxUpdateUnhook()
    local methods = {"FCF_Close", "FCF_OpenNewWindow", "FCF_OpenTemporaryWindow", "FCF_ResetChatWindows", "FCF_NewChatWindow"}
    for _, method in ipairs(methods) do
        if self:IsHooked(method) then
            self:Unhook(method)
        end
    end
end

function ChatManager:InterceptUIFadeHook() --FADE Animation
    if not self:IsHooked("UIFrameFadeOut") then
        self:RawHook("UIFrameFadeOut", "InterceptedFadeOUT", true)
    end
    if not self:IsHooked("UIFrameFadeIn") then
        self:RawHook("UIFrameFadeIn", "InterceptedFadeIN", true)
    end
end

function ChatManager:InterceptUIFadeUnhook()
    if self:IsHooked("UIFrameFadeOut") then
        self:Unhook("UIFrameFadeOut")
    end
    if self:IsHooked("UIFrameFadeIn") then
        self:Unhook("UIFrameFadeIn")
    end
end

function ChatManager:InterceptedFadeOUT(frame, ...) --FADE IN
    local args = {...}
    local frame_name = frame:GetName() or ""
    if string.find(frame_name, "ChatFrame") then -- Only ChatFrames      
        if self.fadeOutEnabled then --Can faded flag
            self.hooks.UIFrameFadeOut(frame, unpack(args))
        end
    else
        self.hooks.UIFrameFadeOut(frame, unpack(args))
    end
end

function ChatManager:InterceptedFadeIN(frame, ...) --FADE OUT
    local args = {...}
    local frame_name = frame:GetName() or ""
    if string.find(frame_name, "ChatFrame") then -- Only ChatFrames
        if self.fadeInEnabled then --Can faded flag
            self.hooks.UIFrameFadeIn(frame, unpack(args))
        end
    else
        self.hooks.UIFrameFadeIn(frame, unpack(args))
    end
end

function ChatManager:ChatboxUpdateHandler() --CHAT Events
    self:FindActiveChats()
    self:ChatboxAlphaUpdate("CHATBOX_UPDATED")
    self:InterceptEditBoxHook()
end

function ChatManager:InterceptEditBoxHook() --EDITBOX FOCUS LOST/GAINED
    for _, chatbox in ipairs(CHATBOXES) do
        if chatbox.editBox then
            if not self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                self:HookScript(chatbox.editBox, "OnEditFocusLost", "InterceptedEditBoxFocusLost")
            end
            if not self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                self:HookScript(chatbox.editBox, "OnEditFocusGained", "InterceptedEditBoxFocusGained")
            end
        end
    end
end

function ChatManager:InterceptEditBoxUnhook()
    for _, chatbox in ipairs(CHATBOXES) do
        if chatbox.editBox then
            if self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                self:Unhook(chatbox.editBox, "OnEditFocusLost")
            end
            if self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                self:Unhook(chatbox.editBox, "OnEditFocusGained")
            end
        end
    end
end

----------------------------------------------------------------
-- Support
----------------------------------------------------------------
function ChatManager:FindActiveChats()
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
    
    CHATBOXES = activeChats
    self:SendMessage("CHATBOXES_UPDATED", CHATBOXES)
end

function ChatManager:FrameExists(frame)
    if frame and frame:IsVisible() and frame:IsShown() then
        return frame
    else
        return nil
    end
end

function ChatManager:ChatboxAlphaUpdate(msg)
    if msg == "CHATBOX_ENABLED" then
        local alpha = LAST_STATE_ALPHA_AMOUNT or self:GetCustomAlpha() or GLOBAL_ALPHA
        self:FadeOutChat(alpha, FADE_OUT_DURATION, true)
    elseif msg == "CHATBOX_UPDATED" then --slider
        self:SetChatAlpha(self:GetCustomAlpha() or GLOBAL_ALPHA)
    elseif msg == "CHATBOX_DISABLED" then
        self:FadeInChat(DEFAULT_ALPHA, FADE_IN_DURATION)
    else
        -- STATE MANAGER
        local state_alpha = self:GetCustomAlpha() or LAST_STATE_ALPHA_AMOUNT
        self:FadeOutChat(state_alpha, FADE_OUT_DURATION, true)
    end
end

function ChatManager:GetCustomAlpha()
    if CUSTOM_ALPHA_ACTIVE then
        return CUSTOM_ALPHA
    else
        return nil
    end
end

----------------------------------------------------------------
-- Alpha, Fade In, Fade Out
----------------------------------------------------------------
function ChatManager:SetChatAlpha(alpha)
    local clamp_alpha = alpha * EDITBOX_DEFAULT_ALPHA

    local social = self:FrameExists(QuickJoinToastButton)
    local combatLog = self:FrameExists(CombatLogQuickButtonFrame_Custom)
    if social then social:SetAlpha(alpha) end
    if combatLog then combatLog:SetAlpha(alpha) end

    for _, chatbox in ipairs(CHATBOXES) do
        if self:FrameExists(chatbox.tab) then
            chatbox.tab:SetAlpha(alpha)
            chatbox.tab.noMouseAlpha = alpha -- Cuando es mouseOut
            chatbox.tab.mouseOverAlpha = 1   -- cuando es mouseIn
        end
        if self:FrameExists(chatbox.chatFrame) then
            chatbox.chatFrame:SetAlpha(alpha)
        end
        if self:FrameExists(chatbox.editBox) then
            chatbox.editBox:SetAlpha(clamp_alpha)
        end
    end
end

function ChatManager:FadeInChat(alpha, fade_duration)
    self.fadeInEnabled = true

    local clamp_alpha = alpha * EDITBOX_DEFAULT_ALPHA

    local social = self:FrameExists(QuickJoinToastButton)
    if social then
        UIFrameFadeIn(social, fade_duration, social:GetAlpha(), alpha)
    end
    local combatLog = self:FrameExists(CombatLogQuickButtonFrame_Custom)
    if combatLog then
        UIFrameFadeIn(combatLog, fade_duration, combatLog:GetAlpha(), alpha)
    end

    for _, chatbox in ipairs(CHATBOXES) do
        if self:FrameExists(chatbox.tab) then
            UIFrameFadeIn(chatbox.tab, fade_duration, chatbox.tab:GetAlpha(), alpha)
        end
        if self:FrameExists(chatbox.chatFrame) then
            UIFrameFadeIn(chatbox.chatFrame, fade_duration, chatbox.chatFrame:GetAlpha(), alpha)
        end
        if self:FrameExists(chatbox.editBox) then
            if self.editBoxFocusActive then clamp_alpha = 1 end --edit box focus flag
            UIFrameFadeIn(chatbox.editBox, fade_duration, chatbox.editBox:GetAlpha(), clamp_alpha)
        end
    end

    self.fadeInEnabled = false
    self.isFadedIn = true
end

function ChatManager:FadeOutChat(alpha, fade_duration, force_fade)
    if force_fade or self.isFadedIn then
        self.fadeOutEnabled = true

        local clamp_alpha = alpha * EDITBOX_DEFAULT_ALPHA
        
        local social = self:FrameExists(QuickJoinToastButton)
        if social then
            UIFrameFadeOut(social, fade_duration, social:GetAlpha(), alpha)
        end
        local combatLog = self:FrameExists(CombatLogQuickButtonFrame_Custom)
        if combatLog then
            UIFrameFadeOut(combatLog, fade_duration, combatLog:GetAlpha(), alpha)
        end

        for _, chatbox in ipairs(CHATBOXES) do
            if self:FrameExists(chatbox.tab) then
                UIFrameFadeOut(chatbox.tab, fade_duration, chatbox.tab:GetAlpha(), alpha)
            end
            if self:FrameExists(chatbox.chatFrame) then
                UIFrameFadeOut(chatbox.chatFrame, fade_duration, chatbox.chatFrame:GetAlpha(), alpha)
            end
            if self:FrameExists(chatbox.editBox) then
                UIFrameFadeOut(chatbox.editBox, fade_duration, chatbox.editBox:GetAlpha(), clamp_alpha)
            end
        end

        self.fadeOutEnabled = false
        self.isFadedIn = false
    end
end

----------------------------------------------------------------
-- Mouseover
----------------------------------------------------------------
function ChatManager:MouseOverEventHandler(msg, fade_duration)
    if self.editBoxFocusActive then return end -- Edit box focus flag

    if msg == "MOUSE_IN_CHAT_FRAME" then
        FADE_IN_DURATION = fade_duration    
        self:FadeInChat(FADE_IN_ALPHA_AMOUNT, FADE_IN_DURATION)
    elseif msg == "MOUSE_OUT_CHAT_FRAME" then
        -- STATE MANAGER
        local alpha = LAST_STATE_ALPHA_AMOUNT or self:GetCustomAlpha() or GLOBAL_ALPHA
        FADE_OUT_DURATION = fade_duration
        self:FadeOutChat(alpha, FADE_OUT_DURATION)
    end
end

----------------------------------------------------------------
-- State Manager
----------------------------------------------------------------
function ChatManager:PlayerStateHandler(msg, state)
    local states = {
        --AFK
        PLAYER_AFK_STATE_ENTERED     = {alphaAmount = 0},
        PLAYER_AFK_STATE_RETURNED    = {alphaAmount = 0},
        PLAYER_AFK_STATE_EXITED      = {alphaAmount = GLOBAL_ALPHA},
        --Mount
        PLAYER_MOUNT_STATE_ENTERED   = {alphaAmount = 0},
        PLAYER_MOUNT_STATE_RETURNED  = {alphaAmount = 0},
        PLAYER_MOUNT_STATE_EXITED    = {alphaAmount = GLOBAL_ALPHA},
        --Combat
        PLAYER_COMBAT_STATE_ENTERED  = {alphaAmount = 1},
        PLAYER_COMBAT_STATE_RETURNED = {alphaAmount = 1},
        PLAYER_COMBAT_STATE_EXITED   = {alphaAmount = GLOBAL_ALPHA},
    }

    local current_state = states[state]
    if current_state then
        LAST_STATE_ALPHA_AMOUNT = current_state.alphaAmount
        self:ChatboxAlphaUpdate()
        if string.find(state, "_EXITED") then
            LAST_STATE_ALPHA_AMOUNT = nil
        end
    end
end

----------------------------------------------------------------
-- Edit Box Focus
----------------------------------------------------------------
function ChatManager:InterceptedEditBoxFocusGained()
    self.editBoxFocusActive = true
    self:FadeInChat(FADE_IN_ALPHA_AMOUNT, FADE_IN_DURATION)
end

function ChatManager:InterceptedEditBoxFocusLost()
    self.editBoxFocusActive = false
end