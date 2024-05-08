
-- Idea original OK, lo debajo cuando tenga ganas, tiempo y si puedo hacerlo
--Al recibir mensajes revelar en el chatframe con fade y ocultarse con fade tras x tiempo (que chats, susuroo, guild, gurpo, etc)
--Decidir cuantos mensajes  se conservan en el tiempo antes de ocultarse
--Por supuesto, se ocultarán uno a uno dsede el más antiguo al más nuevo
--Decidir que canales de chat se verán afectados por esto último (susurros, guild, grupo, comercio, sistema, etc...)
--

local Chat_mod = HideUI:NewModule("Chat_mod", "AceHook-3.0")
local DB_mod
local Timer_mod
local Utils_mod

local UPDATE_INTERVAL = 0.25 -- 0 = Timer_mod interval

function Chat_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    Timer_mod = HideUI:GetModule("Timer_mod")
    Utils_mod = HideUI:GetModule("Utils_mod")

    self.updateInterval = UPDATE_INTERVAL
    self.chatboxes = {} --init

    -- (10.2.6) Default variables
    self.default_alpha = 0.44
end

function Chat_mod:OnEnable()
    self:ChatboxesUpdateTrigger_Hook()
    self:CheckMouseOverState()
    self:UpdateGlobalTransparency()
end

function Chat_mod:OnDisable()
    self:DisableMouseOver()
    self:UpdateGlobalTransparency(1)
    self:RestoreTabFrames(self.default_alpha) --Default (10.2.6)
    self:UnhookAll()
    
    --Reset Fade Out Alpha
    self.isFadedIn = true
    self:FadeOutChats(1)
end

----------------------------------------------------------------------------
function Chat_mod:RunningTimer()
    self:OnMouseOverFadeHandler()
    self:InterceptEditBoxFocusLost_Hook() --Actualiza los editBoxes hooks
end

function Chat_mod:ChatboxesUpdateTrigger_Hook()
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
            self:SecureHook(method, "ChatboxesUpdateTable")
        end
    end
end

function Chat_mod:ChatboxesUpdateTable()
    self.chatboxes = self:FindActiveChats()
    self:UpdateGlobalTransparency(nil, true) --Actualiza el nuevo chat
end

function Chat_mod:FindActiveChats()
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
                        index = i,
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

function Chat_mod:UpdateFixedFrames(alpha)
    --Frames con opacidad inalterable
    --QuickJoinToastButton
    local social = QuickJoinToastButton
    Utils_mod:UpdateAlpha(social, alpha)
    --CombatLogQuickButtonFrame_Custom
    local combatLogMenu = CombatLogQuickButtonFrame_Custom
    Utils_mod:UpdateAlpha(combatLogMenu, alpha)
end

function Chat_mod:UpdateChatFrames(alpha)
    --Frames con opacidad inalterable, salvo si aumentan los chatboxes
    Utils_mod:Batch(self.chatboxes, function(chatbox) 
        Utils_mod:UpdateAlpha(chatbox.chatFrame, alpha)
    end)
end

function Chat_mod:UpdateTabFrames(alpha)
    --Tienen opacidad fija
    Utils_mod:Batch(self.chatboxes, function(chatbox)
        if not Utils_mod:CompareAlpha(chatbox.tab, alpha) then
            chatbox.tab:SetAlpha(alpha)
            chatbox.tab.noMouseAlpha = alpha    --Cuando es mouseOut
            chatbox.tab.mouseOverAlpha = 1      --cuando es mouseIn
        end
    end)    
end

function Chat_mod:RestoreTabFrames(alpha)
    --Devuelve tabs a sus valores originales (10.2.6)
    Utils_mod:Batch(self.chatboxes, function(chatbox)
        if chatbox.tab then
            chatbox.tab:SetAlpha(alpha)         
            chatbox.tab.noMouseAlpha = alpha
            chatbox.tab.mouseOverAlpha = 1 --Original value
        end
    end)
end

function Chat_mod:UpdateEditBoxFrames(alpha)
    local normalized_alpha = alpha * self.default_alpha  --0.44 default (10.2.6)
    Utils_mod:Batch(self.chatboxes, function(chatbox) 
        Utils_mod:UpdateAlpha(chatbox.editBox, normalized_alpha)
    end)
end

function Chat_mod:UpdateGlobalTransparency(alpha, fromUpdate)
    if not fromUpdate then --Si es otra fuente
        self.new_globalAlpha = alpha --Conversa bandera alpha
        self:ChatboxesUpdateTable()
    else
        --Actualiza el alpha de todos los frames
        local new_alpha = self.new_globalAlpha or DB_mod:Find("globalOpacity")

        self:UpdateFixedFrames(new_alpha)
        self:UpdateChatFrames(new_alpha)
        self:UpdateTabFrames(new_alpha)
        self:UpdateEditBoxFrames(new_alpha)

        self.new_globalAlpha = nil --reset
    end
end

function Chat_mod:InterceptChatsEffects_Hook()
    --Fade
    if not self:IsHooked("UIFrameFadeOut") then
        self:RawHook("UIFrameFadeOut", "OnInterceptedFadeOut", true)
    end
    if not self:IsHooked("UIFrameFadeIn") then
        self:RawHook("UIFrameFadeIn", "OnInterceptedFadeIn", true)
    end
end

function Chat_mod:OnInterceptedFadeIn(frame, ...)
    local args = {...}
    local frame_name = frame:GetName() or ""
    if string.find(frame_name, "ChatFrame") then --Solo para los chatframes
        if self.fadeInEnabled then
            self.hooks.UIFrameFadeIn(frame, unpack(args)) --lua 5.1
        else
            --OFF
        end
    else
        self.hooks.UIFrameFadeIn(frame, unpack(args)) --lua 5.1
    end
end

function Chat_mod:OnInterceptedFadeOut(frame, ...)
    local args = {...}
    local frame_name = frame:GetName() or ""
    if string.find(frame_name, "ChatFrame") then --Solo para los chatframes
        if self.fadeOutEnabled then
            self.hooks.UIFrameFadeOut(frame, unpack(args)) --lua 5.1
        else
            --OFF
        end
    else
        self.hooks.UIFrameFadeOut(frame, unpack(args)) --lua 5.1
    end
end

function Chat_mod:OnMouseOverFadeHandler()
    local social = Utils_mod:FrameExists("QuickJoinToastButton")
    local combatLogMenu = Utils_mod:FrameExists("CombatLogQuickButtonFrame_Custom")

    local result = Utils_mod:Batch(self.chatboxes, function(chatbox) 
        if chatbox.chatFrame:IsMouseOver() or 
           chatbox.tab:IsMouseOver() or 
           chatbox.editBox:IsMouseOver() or
           chatbox.buttonFrame:IsMouseOver() or
           --Frames fijos
           (social and social:IsMouseOver()) or
           (combatLogMenu and combatLogMenu:IsMouseOver())
        then
            self:FadeInChats()
            self.isFadedIn = true
            return true --break for
        end
        return false
    end)
    -- Si cursor no apunta ningún frame del chat
    if result == "end" then
        self:FadeOutChats()
    end
end

function Chat_mod:FadeInChats(alpha)
    self.fadeInEnabled = true

    local max_alpha = alpha or 1
    local normalized_alpha = max_alpha * self.default_alpha
    local fadeInDuration = DB_mod:Find("mouseoverFadeIn")

    local social = Utils_mod:FrameExists("QuickJoinToastButton")
    local combatLogMenu = Utils_mod:FrameExists("CombatLogQuickButtonFrame_Custom")

    if social:IsShown() then
        UIFrameFadeIn(social, fadeInDuration, social:GetAlpha(), max_alpha)
    end
    if combatLogMenu:IsShown() then
        UIFrameFadeIn(combatLogMenu, fadeInDuration, combatLogMenu:GetAlpha(), max_alpha)
    end

    Utils_mod:Batch(self.chatboxes, function(chatbox)
        if chatbox.tab:IsShown() then
            UIFrameFadeIn(chatbox.tab, fadeInDuration, chatbox.tab:GetAlpha(), max_alpha)
        end
        if chatbox.chatFrame:IsShown() then
            UIFrameFadeIn(chatbox.chatFrame, fadeInDuration, chatbox.chatFrame:GetAlpha(), max_alpha) --Primer 1 = duracion, Segundo 1 = alpha final
        end
        if chatbox.editBox:IsShown() then
            if self.isEditBoxFocus then
                normalized_alpha = 1
            end
            UIFrameFadeIn(chatbox.editBox, fadeInDuration, chatbox.editBox:GetAlpha(), normalized_alpha) --Valor original
        end
    end)

    self.fadeInEnabled = false
end

function Chat_mod:FadeOutChats(original_alpha)
    if self.isFadedIn then
        self.fadeOutEnabled = true

        local alpha = original_alpha or DB_mod:Find("globalOpacity")
        local normalized_alpha = alpha * self.default_alpha
        local fadeOutDuration = DB_mod:Find("mouseoverFadeOut")

        local social = Utils_mod:FrameExists("QuickJoinToastButton")
        local combatLogMenu = Utils_mod:FrameExists("CombatLogQuickButtonFrame_Custom")
    
        if social:IsShown() then
            UIFrameFadeOut(social, fadeOutDuration, social:GetAlpha(), alpha)
        end
        if combatLogMenu:IsShown() then
            UIFrameFadeOut(combatLogMenu, fadeOutDuration, combatLogMenu:GetAlpha(), alpha)
        end
    
        Utils_mod:Batch(self.chatboxes, function(chatbox)
            if chatbox.tab:IsShown() then
                UIFrameFadeOut(chatbox.tab, fadeOutDuration, chatbox.tab:GetAlpha(), alpha)
            end
            if chatbox.chatFrame:IsShown() then
                UIFrameFadeOut(chatbox.chatFrame, fadeOutDuration, chatbox.chatFrame:GetAlpha(), alpha)
            end
            if chatbox.editBox:IsShown() then
                UIFrameFadeOut(chatbox.editBox, fadeOutDuration, chatbox.editBox:GetAlpha(), normalized_alpha)
            end
        end)

        self.fadeOutEnabled = false
        self.isFadedIn = false
    end
end

function Chat_mod:InterceptEditBoxFocusLost_Hook()
    Utils_mod:Batch(self.chatboxes, function(chatbox) 
        if chatbox.editBox then
            if not self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                self:HookScript(chatbox.editBox, "OnEditFocusLost", "OnInterceptedEditBoxFocusLost")
            end
            if not self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                self:HookScript(chatbox.editBox, "OnEditFocusGained", "OnInterceptedEditBoxFocusGained")
            end
        end
    end)
end

function Chat_mod:OnInterceptedEditBoxFocusGained()
    if not self.isFadedIn then
        self:FadeInChats()
    end

    self.isEditBoxFocus = true
end

function Chat_mod:OnInterceptedEditBoxFocusLost()
    if not self.isFadedIn then
        self.isFadedIn = true
        self:FadeOutChats()
    end

    self.isEditBoxFocus = false
end

----------------------------------------------------------------------------
function Chat_mod:CheckMouseOverState()
    if DB_mod:Find("isMouseover") then
        self:EnableMouseOver()
    else
        self:DisableMouseOver()
    end
end

function Chat_mod:EnableMouseOver()
    self:InterceptChatsEffects_Hook()
    if not Timer_mod:IsBinded(self) then
        Timer_mod:Bind(self, "RunningTimer")
    end
end

function Chat_mod:DisableMouseOver()
    if Timer_mod:IsBinded(self) then
        Timer_mod:Unbind(self)
    end

    --Unhook Fade
    if self:IsHooked("UIFrameFadeOut") then
        self:Unhook("UIFrameFadeOut")
    end
    if self:IsHooked("UIFrameFadeIn") then
        self:Unhook("UIFrameFadeIn")
    end

    --Unhook editBox
    Utils_mod:Batch(self.chatboxes, function(chatbox) 
        if chatbox.editBox then
            if self:IsHooked(chatbox.editBox, "OnEditFocusLost") then
                self:Unhook(chatbox.editBox, "OnEditFocusLost")
            end
            if self:IsHooked(chatbox.editBox, "OnEditFocusGained") then
                self:Unhook(chatbox.editBox, "OnEditFocusGained")
            end
        end
    end)
end