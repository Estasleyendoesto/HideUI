local _, ns = ...
local Chatbox = gUI:NewModule("Chatbox", "AceHook-3.0")
local Wrapper = gUI:GetModule("FrameWrapper")

Chatbox.__index = Chatbox
setmetatable(Chatbox, {__index = Wrapper})

function Chatbox:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return nil end

    setmetatable(obj, self)
    obj.childFrames = {}

    -- NUM_CHAT_WINDOWS suele ser 10
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            table.insert(obj.childFrames, chatFrame)

            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then table.insert(obj.childFrames, tab) end
        end
    end

    print("|cff00ff00gUI:|r Chatbox virtual creado con", #obj.childFrames, "ventanas.")

    obj:Refresh()
    return obj
end

function Chatbox:Destroy()
    self:StopFade()
    self.frame = nil
    self.states = nil
end

function Chatbox:Refresh()
    local isGhost = false
    for _, isActive in pairs(self.states) do
        if isActive then isGhost = true; break end
    end

    local targetAlpha = isGhost and 0.2 or 1.0

    for _, frame in ipairs(self.childFrames) do
        if frame then
            -- Usamos SetAlpha directo para el chat, ya que UIFrameFade 
            -- a veces da problemas con el texto del chat
            frame:SetAlpha(targetAlpha)
        end
    end
end