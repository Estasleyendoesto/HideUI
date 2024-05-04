local Core_mod = HideUI:NewModule("Core_mod", "AceHook-3.0", "AceEvent-3.0")
local UI_mod

function Core_mod:OnInitialize()
    UI_mod = HideUI:GetModule("UI_mod")
end

function Core_mod:OnEnable()
    self:HookPersistentFrames()
    -- self:RegisterChatEvent()
end

-- SCRIPTS
----------------------------------------------------------------------------
function Core_mod:IsActive()
    return self.db.profile.isEnabled
end

function Core_mod:GetNormalFrames()
    --Non persistent frames
    return {
        PlayerFrame,
        TargetFrame,
        FocusFrame,
        PetFrame,
        MinimapCluster,
        ObjectiveTrackerFrame,
        BuffFrame,
        MicroMenuContainer,
        BagsBar,
        MainMenuBar,
        MultiBarBottomLeft,
        MultiBarBottomRight,
        MultiBarRight,
        MultiBarLeft,
        Multibar5,
        Multibar6,
        Multibar7,
        UIWidgetPowerBarContainerFrame, --Dragonflight
    }
end

function Core_mod:GetPersistentFrames()
    --Persistent Frames (los que se autorefrescan)
    return {
        PlayerCastingBarFrame,
        MainStatusTrackingBarContainer,
        -- GameTooltip, --Tiene un problema, no solo necesita OnUpdate sino que también OnShow
    }
end

function Core_mod:GetNumberOfChatFrames()
    local count = 0
    while true do
        local frame = _G["ChatFrame" .. count + 1]
        if frame then
            count = count + 1
        else
            break
        end
    end
    return count
end

function Core_mod:GetChatFrames()
    --Recolecta todos los frames de los chats
    local chatFrames = {}
    local chatTabs = {}
    local chatEditBoxes = {}
    
    for i = 1, self:GetNumberOfChatFrames() do --NUM_CHAT_WINDOWS
        --CHAT FRAME
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame and chatFrame:IsShown() then
            table.insert(chatFrames, chatFrame)
        end
        --CHAT TAB FRAME
        local chatTab = _G["ChatFrame" .. i .. "Tab"]
        if chatTab and chatTab:IsShown() then
            table.insert(chatTabs, chatTab)
        end
        --CHAT EDITBOX FRAME
        local chatEditBox = _G["ChatFrame" .. i .. "EditBox"]
        if chatEditBox and chatEditBox:IsShown() then
            table.insert(chatEditBoxes, chatEditBox)
        end
    end

    return {
        quickJoinButton = {QuickJoinToastButton},
        frames = chatFrames,
        tabs = chatTabs,
        editBoxes = chatEditBoxes
    }
end

function Core_mod:UpdateFrameOpacity(frame, amount)
    --Opacidad a un unico frame
    if frame then
        frame:SetAlpha(amount / 100)
    end
end

function Core_mod:UpdateFramesOpacity(frames, amount)
    --Opacidad a una lista de frames
    for _, frame in pairs(frames) do
        if frame then
            self:UpdateFrameOpacity(frame, amount)
        end
    end
end

function Core_mod:UpdateAllFramesOpacity(opacity)
    --Opacidad a todos los frames (normales, persistentes y chat)
    --To NormalFrames
    self:UpdateFramesOpacity(self:GetNormalFrames(), opacity)
    --To ChatFrames
    for _, frames in pairs(self:GetChatFrames()) do
        self:UpdateFramesOpacity(frames, opacity)
    end
    --To PersistentFrames
    --Como es un hook, se ejecuta en OnHookedFrameUpdate() de forma independiente
end

function Core_mod:HookPersistentFrames()
    local frames = self:GetPersistentFrames()
    for _, frame in pairs(frames) do
        self:HookScript(frame, "OnUpdate", function()
            self:OnHookedFrameUpdate(frame)
        end)
    end

    local editBoxes = self:GetChatFrames().editBoxes
    for _, frame in pairs(editBoxes) do
        --Hook al perder el foco
        self:HookScript(frame, "OnEditFocusLost", function() --"OnEditFocusGained"
            self:OnHookedEditBoxEvent(frame, "OnEditFocusLost")
        end)
        --Hook al enviar el mensaje
        self:HookScript(frame, "OnEnterPressed", function()
            self:OnHookedEditBoxEvent(frame, "OnEnterPressed")
        end)
    end
end

function Core_mod:OnHookedFrameUpdate(frame)
    if self:IsActive() then
        self:UpdateFrameOpacity(frame, self.db.profile.globalOpacity)
    else
        self:UpdateFrameOpacity(frame, 100)
    end
end

function Core_mod:OnHookedEditBoxEvent(frame, action)
    if self:IsActive() then
        UIFrameFadeOut(frame, 0.5, frame:GetAlpha(), self.db.profile.globalOpacity / 100)
    end
end

function Core_mod:HandleMouseoverBehaviour()
    -- Si existe un timer. Cancela el Timer
    if self.mouseOverTimer then
        self.mouseOverTimer:Cancel()
        self.mouseOverTimer = nil
    end
    if not self:IsActive() or not self.db.profile.isMouseOver then
        return
    end
    -- Los frames a evaluar
    local frames = self:GetNormalFrames()
    --
    --Aux
    local target_frame = nil
    local wasMouseOver = false
    --
    local function DetectMouseover()
        for _, frame in pairs(frames) do
            if frame and frame:IsMouseOver() then
                return frame
            end
        end
        return nil
    end
    --
    local function ChangeFrameOpacity(frame, targetOpacity)
        if targetOpacity == 1 then
            UIFrameFadeIn(frame, self.db.profile.mouseoverFadeIn, frame:GetAlpha(), targetOpacity)
        else
            UIFrameFadeOut(frame, self.db.profile.mouseoverFadeOut, frame:GetAlpha(), self.db.profile.globalOpacity / 100)
        end
    end

    --Timer
    self.mouseOverTimer = C_Timer.NewTicker(0.25, function()
        local current_frame = DetectMouseover()
        if current_frame then
            if not wasMouseOver or target_frame ~= current_frame then
                if target_frame and target_frame ~= current_frame then -- FadeOut del frame anterior al actual
                    ChangeFrameOpacity(target_frame, self.db.profile.globalOpacity)
                end
                ChangeFrameOpacity(current_frame, 1)
                target_frame = current_frame
                wasMouseOver = true
            end
        else
            if wasMouseOver then
                ChangeFrameOpacity(target_frame, self.db.profile.globalOpacity)
                target_frame = nil
                wasMouseOver = false
            end
        end
    end)
end

-- KEYBINDING EVENT
----------------------------------------------------------------------------
function ToggleMinimalUI() 
    Core_mod:OnActiveToggle()
end

-- UI BEHAVIOUR
----------------------------------------------------------------------------
function Core_mod:OnActiveToggle(checked)
    if checked then
        self.db.profile.isEnabled = checked
    else
        self.db.profile.isEnabled = not self.db.profile.isEnabled
    end
    --UI Refresh
    UI_mod:UpdateUI()
    --Funcionalidades afectadas por isActive()
    if self:IsActive() then
        self:UpdateAllFramesOpacity(self.db.profile.globalOpacity)
        self:HandleMouseoverBehaviour() --Mouseover
    else
        self:UpdateAllFramesOpacity(100)
        self:HandleMouseoverBehaviour() --Mouseover
    end
end

function Core_mod:UpdateGlobalTransparency(amount)
    self.db.profile.globalOpacity = amount
    if self:IsActive() then 
        self:UpdateAllFramesOpacity(amount)
    end
end

function Core_mod:OnMouseoverToggle(checked)
    self.db.profile.isMouseOver = checked
    self:HandleMouseoverBehaviour()
end

function Core_mod:UpdateMouseoverFadeInAmount(amount)
    self.db.profile.mouseoverFadeIn = amount
end

function Core_mod:UpdateMouseoverFadeOutAmount(amount)
    self.db.profile.mouseoverFadeOut = amount
end