local _, ns = ...
local Searchbox = HideUI:NewModule("Searchbox")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- MÉTODOS PRIVADOS (LÓGICA)
---------------------------------------------------------------------

local function ShowFeedback(frame, text, isError)
    local label = frame.FeedbackText
    label:SetText(text)
    label:SetTextColor(isError and 1 or 0, isError and 0 or 1, 0)
    label:Show()

    if frame.feedbackTimer then frame.feedbackTimer:Cancel() end
    frame.feedbackTimer = C_Timer.NewTimer(3, function() label:Hide() end)
end

local function BindEvents(frame, onAction, tooltip)
    local eb = frame.EditBox
    frame.InsertBtn:SetScript("OnClick", function()
        if onAction then onAction(ns.ACTION.ADD, eb:GetText(), frame) end
    end)
    frame.RemoveBtn:SetScript("OnClick", function()
        if onAction then onAction(ns.ACTION.REMOVE, eb:GetText(), frame) end
    end)

    if tooltip then
        eb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip.name or "Search", 1, 1, 1)
            GameTooltip:AddLine(tooltip.text or "", nil, nil, nil, true)
            GameTooltip:Show()
        end)
        eb:SetScript("OnLeave", GameTooltip_Hide)
    end
end

---------------------------------------------------------------------
-- CONSTRUCTORES DE BLOQUES (PARA VSTACK)
---------------------------------------------------------------------

-- Bloque 1: Título (Encapsulado en un frame para que VStack lo vea)
local function CreateTitleBlock(frame, text)
    if not text then return nil end
    local block = CreateFrame("Frame", nil, frame)
    block:SetSize(1, 15) -- El ancho da igual (VStack lo ajustará), el alto es el espacio del texto
    
    local fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 5, -3)
    fs:SetText(text)
    fs:SetTextColor(0.7, 0.7, 0.7)
    
    frame.Title = fs
    return block
end

-- Bloque 2: Input (EditBox + Feedback)
local function CreateInputBlock(frame, width)
    local eb = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    eb:SetSize(width - 40, 25)
    eb.customAlign = { alignment = "CENTER" } -- Queremos el editbox centrado
    
    -- Texto de Feedback (anclado al EditBox, no al VStack)
    local fs = eb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("LEFT", eb, "RIGHT", 15, 0)
    fs:Hide()
    
    frame.EditBox = eb
    frame.FeedbackText = fs
    return eb
end

-- Bloque 3: Botones (HStack)
local function CreateButtonsBlock(frame)
    local container = CreateFrame("Frame", nil, frame)
    container:SetHeight(22)
    container.customAlign = { alignment = "CENTER" } -- Centramos el grupo de botones
    
    local Button = HideUI:GetModule("Button")
    frame.InsertBtn = Button:Create(container, "Insert", nil, {96, 22})
    frame.RemoveBtn = Button:Create(container, "Remove", nil, {96, 22})

    Utils:HStack(container, 10, 0) -- Alineación horizontal de los botones
    
    frame.BtnContainer = container
    return container
end

---------------------------------------------------------------------
-- MÉTODO PRINCIPAL
---------------------------------------------------------------------

function Searchbox:Create(parent, onAction, tooltip, title, layout)
    -- 1. Configuración de Layout
    local config = Utils:GetLayout(layout, {
        width = 400,
        alignment = "LEFT",
        spacing = 4,
        padding = 5
    })

    -- 2. El Contenedor Base
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(config.width)
    frame.customAlign = config -- Para que el VStack del padre (Others) lo posicione

    -- 3. Crear los hijos (En orden de aparición vertical)
    CreateTitleBlock(frame, title)
    local eb = CreateInputBlock(frame, config.width)
    CreateButtonsBlock(frame)

    -- 4. Aplicar VStack interno
    -- Esto organiza el Título -> EditBox -> Botones y calcula el alto total del frame
    Utils:VStack(frame, config.spacing, config.padding)

    -- 5. Finalizar
    BindEvents(frame, onAction, tooltip)
    
    function frame:SetFeedback(text, isError) ShowFeedback(self, text, isError) end
    function frame:SetButtonState(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        self.EditBox:SetEnabled(enabled)
        self.InsertBtn:SetEnabled(enabled)
        self.RemoveBtn:SetEnabled(enabled)
        if not enabled then self.EditBox:SetText("") end
    end

    return frame
end