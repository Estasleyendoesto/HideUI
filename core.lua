local Core_mod = HideUI:NewModule("Core_mod")
local UI_mod

function Core_mod:OnInitialize()
    UI_mod = HideUI:GetModule("UI_mod")
end

function Core_mod:OnEnable()
end

-- SCRIPTS
----------------------------------------------------------------------------
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

function Core_mod:GetChatFrames()
    local chatFrames = {}
    local chatTabs = {}
    local chatEditBoxes = {}

    for i = 1, NUM_CHAT_WINDOWS do
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

    return {{QuickJoinToastButton}, chatFrames, chatTabs, chatEditBoxes}
end

function Core_mod:UpdateFramesOpacity(frames, amount)
    for _, frame in pairs(frames) do
        if frame then
            frame:SetAlpha(amount / 100)
        end
    end
end

function Core_mod:UpdateAllFramesOpacity(opacity)
    --To NormalFrames
    Core_mod:UpdateFramesOpacity( Core_mod:GetNormalFrames(),  opacity)
    --To ChatFrames
    for _, frames in pairs( Core_mod:GetChatFrames() ) do
        Core_mod:UpdateFramesOpacity(frames, opacity)
    end
end

function Core_mod:IsActive()
    return self.db.profile.isEnabled
end

-- KEYBINDING EVENT
----------------------------------------------------------------------------
function ToggleMinimalUI() 
    Core_mod:OnActiveToggle()
    --DEBUG PURPOSES
    Core_mod:GetChatFrames()
end

-- UI BEHAVIOUR
----------------------------------------------------------------------------
function Core_mod:OnActiveToggle(checked)
    if checked then
        self.db.profile.isEnabled = checked
    else
        self.db.profile.isEnabled = not self.db.profile.isEnabled
    end
    UI_mod:UpdateUI()
    --Yes
    if Core_mod:IsActive() then
        Core_mod:UpdateAllFramesOpacity(self.db.profile.globalOpacity)
    else
        Core_mod:UpdateAllFramesOpacity(100)
    end
end

function Core_mod:UpdateGlobalTransparency(amount)
    self.db.profile.globalOpacity = amount
    if Core_mod:IsActive() then 
        Core_mod:UpdateAllFramesOpacity(amount)
    end
end