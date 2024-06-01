local AmigableUI = HideUI:NewModule("AmigableUI")

-- AmigableUI
----------------------------------------------------------------------------
function AmigableUI:ScrollBox(name, panel, isBarVisible)
    --Es lo primero a crear al usar un panel
    local scrollFrame = CreateFrame("ScrollFrame", "HideUIScrollBox", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
    
    if isBarVisible then
        scrollFrame.ScrollBar:Show()
    else
        scrollFrame.ScrollBar:Hide()
    end
    
    local scrollContainer = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollContainer)
    scrollContainer:SetWidth(1)     -- 1 = ancho auto
    scrollContainer:SetHeight(1)    -- 1 = alto auto

    scrollContainer.panel = panel
    scrollContainer.type = "Scroll"
    self.lastElement = scrollContainer
    panel[name] = scrollContainer
end

function AmigableUI:Header(name, text)
    --Solo hay un header por panel, y siempre uno después del scroll
    local parent = self.lastElement

    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 12,-26)
    title:SetText(text)

    --Separator
    local separator = parent:CreateTexture(nil, "BACKGROUND")
    separator:SetColorTexture(0.8, 0.8, 0.8, 0.3)
    separator:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    separator:SetHeight(1)
    separator:SetWidth(9999) --No queda de otra

    title.type = "Title"
    separator.type = "Separator"
    title.parent = parent
    separator.parent = parent
    parent["header_title"] = title
    parent["Header_separator"] = separator
    parent[name] = separator
    self.lastElement = separator
end

function AmigableUI:Title(name, text)
    local before = self.lastElement
    local parent = before.parent

    local title = parent:CreateFontString("HideUITitle", "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", parent, "LEFT")
    title:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, -25)
    title:SetText(text)

    title.type = "Title"
    title.parent = parent
    self.lastElement = title
    parent.panel[name] = title
end

function AmigableUI:Checkbox(name, text, state, func)
    local before = self.lastElement
    local parent = before.parent

    local margin_top = -12
    if before.type == "Checkbox" then
        margin_top = 0
    end

    -- Box
    local checkbox = CreateFrame("CheckButton", "HideUICheckbox", parent, "UICheckButtonTemplate")
    checkbox:SetPoint("LEFT", parent, "LEFT")
    checkbox:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, margin_top)

    -- Text
    checkbox.text:SetPoint("TOPLEFT", checkbox, "TOPLEFT", 48, -8.5)
    checkbox.text:SetText(text)
    checkbox.text:SetFont("Fonts\\FRIZQT__.TTF", 12.5)
    checkbox.text:SetTextColor(1, 1, 1, 0.8)
    checkbox:SetChecked(state or false) --SetChecked() para UpdateUI o RestoreUI
    
    --Attach event
    checkbox:SetScript("OnClick", function(self)
        if func then
            func(self:GetChecked())
        end
    end)

    checkbox.type = "Checkbox"
    checkbox.parent = parent
    parent.panel[name] = checkbox
    self.lastElement = checkbox
end

function AmigableUI:Slider(name, text, min, max, default, step, func)
    local before = self.lastElement
    local parent = before.parent
    max = max or 100
    min = min or 0
    default = default or (min + max) / 2
    step = step or 1

    local margin_top = -32
    if before.type == "Title" then
        margin_top = -42
    end

    local slider = CreateFrame("Slider", "HideUISlider", parent, "OptionsSliderTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetWidth(340)    -- Ancho del slider
    slider:SetHeight(20)    -- Alto...

    slider:SetPoint("LEFT", parent, "LEFT")
    slider:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, margin_top)

    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(default) --Invocar para restoreUI

    slider.Low:Hide() --Esconde low/high
    slider.High:Hide()

    --Stilize text
    slider.title = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slider.title:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 7)
    slider.title:SetText(text)

    --Stilize text (max)
    slider.highText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.highText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    slider.highText:SetText(max)

    --Stilize text (slider value)
    slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)

    --Attach event
    slider:SetScript("OnValueChanged", function(self, amount)
        if step % 1 == 0 then
            self.valueText:SetText(format("%.0f", amount))
        else
            self.valueText:SetText(format("%.2f", amount))
        end
        if func then
            func(amount)
        end
    end)

    slider.type = "Slider"
    slider.parent = parent
    parent.panel[name] = slider
    self.lastElement = slider
end

function AmigableUI:Separator(name, height, alpha)
    local parent = self.lastElement
    local separator = parent:CreateTexture("HideUISeparator", "BACKGROUND")
    separator:SetColorTexture(0.8, 0.8, 0.8, alpha or 0.3)
    separator:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -10)
    separator:SetHeight(height or 1)
    separator:SetWidth(9999) --No queda de otra
    separator.type = "Separator"
    separator.parent = parent
    self.lastElement = separator
    parent.panel[name] = separator
end

function AmigableUI:Pool(name, title)
    local before = self.lastElement
    local parent = before.parent

    -- Dropdown Frame
    local frame = CreateFrame("Frame", "HiudeUIPool", parent.panel ,"BackdropTemplate")
    local offset = -3
    if before.type == "Title" or before.type == "Separator" then
        offset = -24
    end
    frame:SetPoint("LEFT", 0, 0)
    frame:SetPoint("RIGHT", -30, 0)
    frame:SetPoint("TOPLEFT", before, "BOTTOMLEFT", 0, offset)
    frame:SetSize(1, 32)
    -- Dropdown Frame Style
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropBorderColor(1, 1, 1, 0.5) --141011
    frame:SetBackdropColor(0.5, 0.5, 0.5, 0.98)
    -- Dropdown Text
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    header:SetPoint("LEFT", 22, 0)
    header:SetText(title)
    header:SetTextColor(1, 1, 1, 0.85)
    -- Dropdown Icon
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(18, 18)
    icon:SetPoint("RIGHT", -16, 0)
    icon:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")

    -- Contenido del panel (oculto inicialmente)
    local content = CreateFrame("Frame", nil, parent.panel, "BackdropTemplate")
    content:SetPoint("LEFT", 0, 0)
    content:SetPoint("RIGHT", -30, 0)
    content:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
    content:SetSize(1, 1) --OJO
    content:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    content:SetBackdropBorderColor(1, 1, 1, 1)
    content:SetBackdropColor(0, 0, 0, 0.5)
    content:Hide()

    -- Función para expandir y contraer el panel
    function ToggleAccordion()
        if content:IsShown() then
            content:Hide()
            icon:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
            if frame.after then
                frame.after:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
            end
        else
            content:Show()
            icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
            if frame.after then
                frame.after:SetPoint("TOPLEFT", frame.content, "BOTTOMLEFT", 0, -3)
            end
        end
    end
    -- Evento al hacer clic en el marco
    frame:SetScript("OnMouseDown", ToggleAccordion)

    -- Store
    content.type = "PoolContent"
    content.parent = frame
    frame.type = "Pool"
    frame.parent = parent
    frame.content = content
    parent.panel[name] = frame
    before.after = frame
    self.lastElement = frame
end

function AmigableUI:Comment(name, text)
    --Se supone que es para acompañar los checkboxes debajo
    --Letra pequeña y muy pegados a estos para describir su funcionamiento
end

function AmigableUI:Tooltip(name, title, text)
    --Pues eso, al pasar el cursor por encima y el típico comentario
end

function AmigableUI:Button(name, text, state, func)
    --Próximamente
end

function AmigableUI:EditBox(name, func)
    --Próximamente (es un cuadro para introducir texto)
end