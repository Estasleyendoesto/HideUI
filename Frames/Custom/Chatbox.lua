local _, ns = ...
local Chatbox = gUI:NewModule("Chatbox", "AceHook-3.0")
local Wrapper = gUI:GetModule("FrameWrapper")

Chatbox.__index = Chatbox
setmetatable(Chatbox, { __index = Wrapper })

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------
function Chatbox:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return end

    setmetatable(obj, self)
    obj.childFrames = {}

    -- Recopilación de ventanas de chat y pestañas
    for i = 1, NUM_CHAT_WINDOWS do
        local chat = _G["ChatFrame"..i]
        if chat then
            table.insert(obj.childFrames, chat)
            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then table.insert(obj.childFrames, tab) end
        end
    end

    -- Usamos alpha directo para evitar parpadeos en el texto del chat
    obj.forceAlpha = true

    obj:Refresh()
    return obj
end

function Chatbox:Destroy()
    if self.childFrames then
        for _, frame in ipairs(self.childFrames) do
            if frame then frame:SetAlpha(1.0) end
        end
    end
    self.childFrames = nil
    self.states = nil
end

---------------------------------------------------------------------
-- Lógica Especializada
---------------------------------------------------------------------
function Chatbox:OnUpdate()
    if not self.config or not self.globals or self.config.ignoreFrame then return end

    -- Sincronización de Mouseover grupal
    local over = false
    for _, frame in ipairs(self.childFrames) do
        if frame:IsVisible() and MouseIsOver(frame) then
            over = true
            break
        end
    end

    if over ~= self.isMouseOver then
        self.isMouseOver = over
        self:Refresh()
    end

    -- Corrección de Alpha (Fuerza Bruta)
    local target = self:GetTargetAlpha()
    local refFrame = self.childFrames[1]
    
    if refFrame and math.abs(refFrame:GetAlpha() - target) > 0.01 then
        self:Refresh(true)
    end
end

function Chatbox:Refresh(instant)
    if not self.config or not self.globals then return end

    local targetAlpha = self:GetTargetAlpha()
    if targetAlpha == self.targetAlpha and not instant then return end
    
    self.targetAlpha = targetAlpha

    -- Aplicamos el alpha a todo el grupo de ventanas y pestañas
    for _, frame in ipairs(self.childFrames) do
        if frame then
            frame:SetAlpha(targetAlpha)
        end
    end
end