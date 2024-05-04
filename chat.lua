local Chat_mod = HideUI:NewModule("Chad_mod")

function Chat_mod:OnInitialize()
end

function Chat_mod:OnEnable()
end

----------------------------------------------------------------------------
        -- for _, frame in ipairs(chatInfo.frames) do
        --     table.insert(allFrames, frame)
        -- end
        -- for _, tab in ipairs(chatInfo.tabs) do
        --     table.insert(allFrames, tab)
        -- end
        -- for _, editBox in ipairs(chatInfo.editBoxes) do
        --     table.insert(allFrames, editBox)
        -- end
        -- for _, frame in ipairs(chatInfo.quickJoinButton) do
        --     table.insert(allFrames, frame)
        -- end
----------------------------------------------------------------------------
-- local editBoxes = self:GetChatFrames().editBoxes
    -- for _, frame in pairs(editBoxes) do
    --     --Hook al perder el foco
    --     self:HookScript(frame, "OnEditFocusLost", function() --"OnEditFocusGained"
    --         self:OnHookedEditBoxEvent(frame, "OnEditFocusLost")
    --     end)
    --     --Hook al enviar el mensaje
    --     self:HookScript(frame, "OnEnterPressed", function()
    --         self:OnHookedEditBoxEvent(frame, "OnEnterPressed")
    --     end)
    -- end
--
----------------------------------------------------------------------------
-- function Core_mod:OnHookedEditBoxEvent(frame, action)
--     if self:IsActive() then
--         UIFrameFadeOut(frame, 0.5, frame:GetAlpha(), self.db.profile.globalOpacity / 100)
--     end
-- end

-- function Core_mod:KeepTabButtonVisible(chatFrame)
--     local tabButton = _G[chatFrame:GetName() .. "Tab"]
--     if not tabButton then
--         print(chatFrame:GetName())
--         return
--     end
--     tabButton:SetAlpha(1)
--     tabButton.noMouseAlpha = 1
--     tabButton.mouseAlpha = 1

--     -- local activealpha = 1
--     -- local notactivealpha = 1 --aqui aqui
--     UIFrameFadeRemoveFrame(tabButton)
--     return function()
--         if chatFrame.hasBeenFaded then
--             tabButton.noMouseAlpha = self.activealpha or 1
--             tabButton.mouseAlpha = self.activealpha or 1
--         else
--             tabButton.noMouseAlpha = self.notactivealpha or 1
--             tabButton.mouseAlpha = self.notactivealpha or 1
--             UIFrameFadeOut(tabButton, 0, tabButton:GetAlpha(), tabButton.mouseAlpha)
--         end
--     end
-- end
----------------------------------------------------------------------------
-- function Core_mod:GetNumberOfChatFrames()
--     local count = 0
--     while true do
--         local frame = _G["ChatFrame" .. count + 1]
--         if frame then
--             count = count + 1
--         else
--             break
--         end
--     end
--     return count
-- end

-- function Core_mod:GetChatFrames()
--     --Recolecta todos los frames de los chats
--     local chatFrames = {}
--     local chatTabs = {}
--     local chatEditBoxes = {}
    
--     for i = 1, self:GetNumberOfChatFrames() do --NUM_CHAT_WINDOWS
--         --CHAT FRAME
--         local chatFrame = _G["ChatFrame" .. i]
--         if chatFrame and chatFrame:IsShown() then
--             table.insert(chatFrames, chatFrame)
--         end
--         --CHAT TAB FRAME
--         local chatTab = _G["ChatFrame" .. i .. "Tab"]
--         if chatTab and chatTab:IsShown() then
--             table.insert(chatTabs, chatTab)
--         end
--         --CHAT EDITBOX FRAME
--         local chatEditBox = _G["ChatFrame" .. i .. "EditBox"]
--         if chatEditBox and chatEditBox:IsShown() then
--             table.insert(chatEditBoxes, chatEditBox)
--         end
--     end

--     return {
--         quickJoinButton = {QuickJoinToastButton},
--         frames = chatFrames,
--         tabs = chatTabs,
--         editBoxes = chatEditBoxes
--     }
-- end
