local _, ns = ...
local Chatbox = gUI:NewModule("Chatbox", "AceHook-3.0")
local Wrapper = gUI:GetModule("FrameWrapper")

Chatbox.__index = Chatbox
setmetatable(Chatbox, { __index = Wrapper })

-- Configuración y Constantes
local TICK_INTERVAL = 0.1
local DEFAULT_FADE_IN = 0.3
local DEFAULT_FADE_OUT = 0.4
local ALPHA_THRESHOLD = 0.01
local EDITBOX_MAX_ALPHA = 0.4 -- Techo de alpha en reposo/mouseover

-- Registro en Builder
-- local Builder = gUI:GetModule("Builder")
-- local chatboxSchema = {
--     useTextMode = { 
--         type = "checkbox", 
--         label = "Use Text Mode", 
--         tooltip = "ON: Solo texto, sin fondos ni bordes (incluso al escribir).\nOFF: Interfaz estándar con opacidad limitada." 
--     }
-- }
-- local chatboxOrder = { "useTextMode" }
-- Builder:RegisterExtension("Chatbox", chatboxSchema, chatboxOrder)

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------

function Chatbox:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    if not obj then return end

    setmetatable(obj, self)
    
    obj.childFrames = {}
    obj:RegisterChatFrames()
    obj:RegisterExtraFrames()

    obj.forceAlpha = true
    obj:Refresh(true)
    
    return obj
end

function Chatbox:Destroy()
    if self.childFrames then
        for _, frame in ipairs(self.childFrames) do
            -- Restauramos el alpha original (1.0 para chat, 0.4 para EditBox)
            local originalAlpha = self:GetFrameTargetAlpha(frame, 1.0, false)
            if frame then frame:SetAlpha(originalAlpha) end
        end
    end
    self.childFrames = nil
    self.isMouseOver = nil
    self.currentFocus = nil
end

---------------------------------------------------------------------
-- Registro de Elementos
---------------------------------------------------------------------

function Chatbox:RegisterChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local name = "ChatFrame"..i
        local chat = _G[name]
        
        if chat then
            table.insert(self.childFrames, chat)
            
            local tab = _G[name.."Tab"]
            if tab then table.insert(self.childFrames, tab) end
            
            local eb = _G[name.."EditBox"]
            if eb then table.insert(self.childFrames, eb) end
        end
    end
end

function Chatbox:RegisterExtraFrames()
    local extraFrames = { "CombatLogQuickButtonFrame_Custom" }
    for _, fName in ipairs(extraFrames) do
        local f = _G[fName]
        if f then table.insert(self.childFrames, f) end
    end
end

---------------------------------------------------------------------
-- Lógica de Estado y Animación
---------------------------------------------------------------------

function Chatbox:OnUpdate()
    if not self.config or self.config.ignoreFrame then return end

    local isOver, hasFocus = self:CheckIfActive()
    local isActive = isOver or hasFocus

    -- Si cambia el estado de actividad general, refrescamos configuración
    if isActive ~= self.isMouseOver then
        self.isMouseOver = isActive
        self:Refresh()
    end

    self.currentFocus = hasFocus
    self:UpdateAlphaTransition()
end

function Chatbox:CheckIfActive()
    local over, focus = false, false

    for _, frame in ipairs(self.childFrames) do
        if frame:IsVisible() then
            if MouseIsOver(frame) then over = true end
            if frame.HasFocus and frame:HasFocus() then focus = true end
        end
        -- Si ya encontramos ambos estados, no hace falta seguir iterando
        if over and focus then break end
    end
    return over, focus
end

function Chatbox:UpdateAlphaTransition()
    local target = self:GetTargetAlpha()
    local data = self.config.isEnabled and self.config or self.globals
    
    local duration = self.isMouseOver 
        and (data.mouseoverFadeInDuration or DEFAULT_FADE_IN) 
        or (data.mouseoverFadeOutDuration or DEFAULT_FADE_OUT)
    
    local step = TICK_INTERVAL / math.max(0.01, duration)

    self:StepAlphaToTarget(target, step)
end

---------------------------------------------------------------------
-- Cálculo de Alpha y Normalización
---------------------------------------------------------------------

function Chatbox:GetFrameTargetAlpha(frame, globalTarget, hasFocus)
    -- Si es la caja de texto, Blizzard limita su alpha a 0.4, 
    -- excepto cuando el usuario está escribiendo (Focus).
    if frame.IsObjectType and frame:IsObjectType("EditBox") then
        if hasFocus then return 1.0 end
        return math.min(globalTarget, EDITBOX_MAX_ALPHA)
    end

    return globalTarget
end

function Chatbox:StepAlphaToTarget(target, step)
    for _, frame in ipairs(self.childFrames) do
        local frameTarget = self:GetFrameTargetAlpha(frame, target, self.currentFocus)
        local current = frame:GetAlpha()
        
        if math.abs(current - frameTarget) > ALPHA_THRESHOLD then
            local nextAlpha
            if current < frameTarget then
                nextAlpha = math.min(frameTarget, current + step)
            else
                nextAlpha = math.max(frameTarget, current - step)
            end
            frame:SetAlpha(nextAlpha)
        end
    end
end

function Chatbox:Refresh(instant)
    if not self.config or not self.globals then return end
    
    if instant then
        local target = self:GetTargetAlpha()
        local _, hasFocus = self:CheckIfActive()
        for _, frame in ipairs(self.childFrames) do
            if frame then 
                frame:SetAlpha(self:GetFrameTargetAlpha(frame, target, hasFocus)) 
            end
        end
    end
end

-- local _, ns = ...
-- local Chatbox = gUI:NewModule("Chatbox", "AceHook-3.0")
-- local Wrapper = gUI:GetModule("FrameWrapper")

-- Chatbox.__index = Chatbox
-- setmetatable(Chatbox, { __index = Wrapper })

-- -- Configuración y Constantes
-- local TICK_INTERVAL = 0.1
-- local DEFAULT_FADE_IN = 0.3
-- local DEFAULT_FADE_OUT = 0.4
-- local ALPHA_THRESHOLD = 0.01

-- -- Límites de Opacidad Máxima (Caps)
-- local MAX_EDITBOX_ALPHA = 0.4 
-- local MAX_BG_ALPHA      = 0.15
-- local MAX_BORDER_ALPHA  = 0.2

-- -- Registro en Builder
-- local Builder = gUI:GetModule("Builder")
-- local chatboxSchema = {
--     useTextMode = { 
--         type = "checkbox", 
--         label = "Use Text Mode", 
--         tooltip = "ON: Solo texto, sin fondos ni bordes (incluso al escribir).\nOFF: Interfaz estándar con opacidad limitada." 
--     }
-- }
-- local chatboxOrder = { "useTextMode" }
-- Builder:RegisterExtension("Chatbox", chatboxSchema, chatboxOrder)

-- ---------------------------------------------------------------------
-- -- Registro de Elementos
-- ---------------------------------------------------------------------

-- function Chatbox:RegisterChatFrames()
--     for i = 1, NUM_CHAT_WINDOWS do
--         local name = "ChatFrame"..i
--         local chat = _G[name]
--         if not chat then break end

--         chat.gUIType = "chat"
--         table.insert(self.childFrames, chat)
        
--         -- Fondo del Chat
--         local bg = _G[name.."Background"]
--         if bg then
--             bg.gUIType = "background"
--             table.insert(self.childFrames, bg)
--         end

--         -- Bordes y Botones del Chat
--         local bf = _G[name.."ButtonFrame"]
--         if bf then
--             bf.gUIType = "border"
--             table.insert(self.childFrames, bf)
--         end

--         -- Pestañas
--         local tab = _G[name.."Tab"]
--         if tab then 
--             tab.gUIType = "tab"
--             table.insert(self.childFrames, tab) 
--         end
        
--         -- EditBox
--         local eb = _G[name.."EditBox"]
--         if eb then 
--             eb.gUIType = "editbox"
--             table.insert(self.childFrames, eb)

--             -- Texturas de fondo del EditBox (Bordes/Fondo de la caja de texto)
--             local ebTexs = { "Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight" }
--             for _, suffix in ipairs(ebTexs) do
--                 local tex = _G[name.."EditBox"..suffix]
--                 if tex then
--                     tex.gUIType = "border" -- Las texturas de la caja se tratan como bordes
--                     table.insert(self.childFrames, tex)
--                 end
--             end
--         end
--     end
-- end

-- function Chatbox:RegisterExtraFrames()
--     local extraFrames = { "CombatLogQuickButtonFrame_Custom" }
--     for _, fName in ipairs(extraFrames) do
--         local f = _G[fName]
--         if f then 
--             f.gUIType = "chat"
--             table.insert(self.childFrames, f) 
--         end
--     end
-- end

-- ---------------------------------------------------------------------
-- -- Cálculo de Alpha (Lógica de Modos)
-- ---------------------------------------------------------------------

-- function Chatbox:GetFrameTargetAlpha(frame, globalTarget, hasFocus, isMouseOver)
--     globalTarget = math.max(0, globalTarget or 0)
--     local fType = frame.gUIType
--     local textMode = self.config and self.config.useTextMode

--     ---------------------------------------------------------
--     -- CASO 1: MODO TEXTO (ON)
--     ---------------------------------------------------------
--     if textMode then
--         -- Fondos y Bordes NUNCA se ven en TextMode (Chat y EditBox limpios)
--         if fType == "background" or fType == "border" then
--             return 0
--         end

--         -- Pestañas: Solo visibles si el ratón está encima
--         if fType == "tab" then
--             return isMouseOver and globalTarget or 0
--         end

--         -- EditBox: 1.0 al escribir, 0.4 en hover (solo texto), 0 en reposo
--         if fType == "editbox" then
--             if hasFocus then return 1.0 end
--             return isMouseOver and math.min(globalTarget, MAX_EDITBOX_ALPHA) or 0
--         end

--         -- Texto del Chat: Sigue el fade normal
--         return globalTarget
--     end

--     ---------------------------------------------------------
--     -- CASO 2: MODO NORMAL (OFF)
--     ---------------------------------------------------------
--     -- Fondos
--     if fType == "background" then
--         return math.min(globalTarget, MAX_BG_ALPHA)
--     end

--     -- Bordes (Incluye las texturas de la caja del EditBox)
--     if fType == "border" then
--         -- Si estamos escribiendo, forzamos la visibilidad de la caja del EditBox
--         if hasFocus then return MAX_BORDER_ALPHA end
--         return math.min(globalTarget, MAX_BORDER_ALPHA)
--     end

--     -- Caja de Texto (El cursor y lo que escribes)
--     if fType == "editbox" then
--         if hasFocus then return 1.0 end
--         return math.min(globalTarget, MAX_EDITBOX_ALPHA)
--     end

--     -- Pestañas y Texto del Chat
--     return globalTarget
-- end

-- ---------------------------------------------------------------------
-- -- Motores y Updates
-- ---------------------------------------------------------------------

-- function Chatbox:OnUpdate()
--     if not self.config or self.config.ignoreFrame or not self.childFrames then return end

--     local isOver, hasFocus = self:CheckIfActive()
--     -- El chat se considera "activo" si hay ratón encima O si se está escribiendo (Enter)
--     local isActive = isOver or hasFocus

--     if isActive ~= self.isMouseOver then
--         self.isMouseOver = isActive
--         self:Refresh()
--     end

--     self.currentFocus = hasFocus
    
--     local data = self.config.isEnabled and self.config or self.globals
--     local duration = self.isMouseOver 
--         and (data.mouseoverFadeInDuration or DEFAULT_FADE_IN) 
--         or (data.mouseoverFadeOutDuration or DEFAULT_FADE_OUT)
    
--     local step = TICK_INTERVAL / math.max(0.01, duration)
--     local target = self:GetTargetAlpha() or 0
    
--     self:StepAlphaToTarget(target, step)
-- end

-- function Chatbox:StepAlphaToTarget(target, step)
--     if not self.childFrames then return end
--     for _, frame in ipairs(self.childFrames) do
--         local frameTarget = self:GetFrameTargetAlpha(frame, target, self.currentFocus, self.isMouseOver)
--         local current = frame:GetAlpha() or 0
        
--         if math.abs(current - frameTarget) > ALPHA_THRESHOLD then
--             local nextAlpha = (current < frameTarget) 
--                 and math.min(frameTarget, current + step) 
--                 or  math.max(frameTarget, current - step)
            
--             frame:SetAlpha(nextAlpha)
--         end
--     end
-- end

-- ---------------------------------------------------------------------
-- -- Inicialización y Utilidades
-- ---------------------------------------------------------------------

-- function Chatbox:Create(name, isVirtual)
--     local obj = Wrapper:Create(name, isVirtual)
--     if not obj then return end
--     setmetatable(obj, self)
--     obj.childFrames = {}
--     obj:RegisterChatFrames()
--     obj:RegisterExtraFrames()
--     obj.forceAlpha = true
--     obj:Refresh(true)
--     return obj
-- end

-- function Chatbox:CheckIfActive()
--     local over, focus = false, false
--     if not self.childFrames then return over, focus end

--     for _, frame in ipairs(self.childFrames) do
--         -- Solo frames de contenido real activan el estado
--         if frame:IsVisible() and (frame.gUIType == "chat" or frame.gUIType == "tab" or frame.gUIType == "editbox") then
--             if MouseIsOver(frame) then over = true end
--             if frame.HasFocus and frame:HasFocus() then focus = true end
--         end
--         if over and focus then break end
--     end
--     return over, focus
-- end

-- function Chatbox:Refresh(instant)
--     if not self.config or not self.globals then return end
--     if instant then
--         local target = self:GetTargetAlpha() or 0
--         local isOver, focus = self:CheckIfActive()
--         if not self.childFrames then return end
--         for _, frame in ipairs(self.childFrames) do
--             if frame then 
--                 frame:SetAlpha(self:GetFrameTargetAlpha(frame, target, focus, isOver)) 
--             end
--         end
--     end
-- end

-- function Chatbox:Destroy()
--     if self.childFrames then
--         for _, frame in ipairs(self.childFrames) do
--             local fType = frame.gUIType
--             local alpha = 1.0
--             if fType == "background" then alpha = MAX_BG_ALPHA
--             elseif fType == "border" then alpha = MAX_BORDER_ALPHA
--             elseif fType == "editbox" then alpha = MAX_EDITBOX_ALPHA
--             end
--             if frame.SetAlpha then frame:SetAlpha(alpha) end
--         end
--     end
--     self.childFrames = nil
--     self.isMouseOver = nil
--     self.currentFocus = nil
-- end