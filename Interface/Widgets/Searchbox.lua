local _, ns = ...
local Searchbox = HideUI:NewModule("Searchbox")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- FEEDBACK VISUAL (INTERNO)
---------------------------------------------------------------------
local function ShowFeedback(frame, text, isError)
    local label = frame.FeedbackText
    label:SetText(text)
    label:SetTextColor(isError and 1 or 1, isError and 0 or 1, isError and 0 or 1)
    label:Show()

    -- Cancelamos timer previo si existe para evitar parpadeos
    if frame.feedbackTimer then frame.feedbackTimer:Cancel() end
    
    frame.feedbackTimer = C_Timer.NewTimer(3, function() 
        label:Hide() 
    end)
end

---------------------------------------------------------------------
-- EVENTOS (INTERNO)
---------------------------------------------------------------------
local function BindEvents(frame, onAction, tooltip)
    local box = frame.EditBox

    -- Botón Insertar
    frame.InsertBtn:SetScript("OnClick", function()
        if onAction then onAction("add", box:GetText(), frame) end
    end)

    -- Botón Eliminar
    frame.RemoveBtn:SetScript("OnClick", function()
        if onAction then onAction("remove", box:GetText(), frame) end
    end)

    -- Tooltip
    if tooltip then
        box:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip.name or "Búsqueda", 1, 1, 1)
            GameTooltip:AddLine(tooltip.text or "", nil, nil, nil, true)
            GameTooltip:Show()
        end)
        box:SetScript("OnLeave", GameTooltip_Hide)
    end
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Searchbox:Create(parent, onAction, tooltip)
    -- 1. Contenedor
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(400, 85)

    -- 2. EditBox (Usamos la plantilla de Blizzard para la lupa y el look)
    local eb = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    eb:SetSize(320, 25)
    eb:SetPoint("TOPLEFT", 20, -15)
    eb:SetAutoFocus(false)
    frame.EditBox = eb

    -- 3. Botones (Usando el módulo de botones para ser consistentes)
    local Button = HideUI:GetModule("Button")
    
    frame.InsertBtn = Button:Create(frame, "Insert", nil, {96, 22})
    frame.InsertBtn:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 0, -10)

    frame.RemoveBtn = Button:Create(frame, "Remove", nil, {96, 22})
    frame.RemoveBtn:SetPoint("LEFT", frame.InsertBtn, "RIGHT", 10, 0)

    -- 4. Texto de Feedback (Éxito/Error)
    frame.FeedbackText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.FeedbackText:SetPoint("LEFT", eb, "RIGHT", 15, 0)
    frame.FeedbackText:Hide()

    -- 5. Inicializar
    BindEvents(frame, onAction, tooltip)

    -- API Pública para el "yo del futuro"
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