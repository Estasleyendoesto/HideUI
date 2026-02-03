local _, ns = ...
local Text = gUI:NewModule("Text")
local Utils = gUI:GetModule("Utils")

---------------------------------------------------------------------
-- HELPERS INTERNOS
---------------------------------------------------------------------

local function CreateTextWrapper(parent, font, text, config, isTitle)
    local f = CreateFrame("Frame", nil, parent)
    local fs = f:CreateFontString(nil, "OVERLAY", font)
    local scale = isTitle and config.titleScale or config.subScale
    
    fs:SetPoint("CENTER")
    fs:SetScale(scale)
    fs:SetText(text)
    
    if not isTitle then
        fs:SetAlpha(config.subAlpha)
        fs:SetTextColor(1, 0.82, 0) 
    end

    f:SetHeight(fs:GetStringHeight() * scale)
    f.text = fs
    return f
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS
---------------------------------------------------------------------

-- Título grande con subtítulo dorado inferior
function Text:CreateHeadLine(parent, title, subtitle, layout)
    local config = Utils:GetLayout(layout, {
        spacing = 5,
        titleScale = 2,
        subScale = 1,
        subAlpha = 0.6,
        padding = { top = 20, bottom = 20 },
    })

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(parent:GetWidth())

    CreateTextWrapper(frame, "GameFontHighlightHuge", title, config, true)
    CreateTextWrapper(frame, "GameFontHighlight", subtitle, config, false)

    Utils:RegisterLayout(frame, config)
    Utils:VStack(frame)

    return frame
end

-- Par Etiqueta: Valor (ej. "Versión: 1.0")
function Text:CreateDoubleLine(parent, leftText, rightText, layout)
    local config = Utils:GetLayout(layout, {
        spacing = 8,
        suffix = ":",
        centered = false,
        xOffset = 0,
        offset = 120,
        labelWidth = 80
    })

    local f = CreateFrame("Frame", nil, parent)
    f:SetWidth(parent:GetWidth())

    f.Left = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.Left:SetTextColor(1, 0.82, 0)
    f.Left:SetJustifyH("RIGHT")
    f.Left:SetText(leftText .. config.suffix)

    f.Right = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.Right:SetJustifyH("LEFT")
    f.Right:SetText(rightText)

    if config.centered then
        local pivot = config.xOffset
        f.Left:SetPoint("RIGHT", f, "CENTER", (-config.spacing / 2) + pivot, 0)
        f.Right:SetPoint("LEFT", f, "CENTER", (config.spacing / 2) + pivot, 0)
    else
        f.Left:SetPoint("TOPLEFT", config.offset, 0)
        f.Left:SetWidth(config.labelWidth)
        f.Right:SetPoint("TOPLEFT", f.Left, "TOPRIGHT", config.spacing, 0)
        f.Right:SetPoint("RIGHT", -config.offset, 0)
    end

    f:SetHeight(math.max(f.Left:GetStringHeight(), f.Right:GetStringHeight()) + 2)
    return f
end

-- Bloque de texto simple o descriptivo
function Text:CreateSingleLine(parent, content, layout)
    local config = Utils:GetLayout(layout, {
        align = "LEFT",
        xOffset = 0,
        scale = 1,
        alpha = 1,
        color = {1, 1, 1},
        font = "GameFontHighlightSmall",
        wrap = true,
    })

    local f = CreateFrame("Frame", nil, parent)
    f:SetWidth(parent:GetWidth())

    local fs = f:CreateFontString(nil, "OVERLAY", config.font)
    fs:SetPoint("TOPLEFT", config.xOffset, 0)
    fs:SetPoint("TOPRIGHT", -config.xOffset, 0)
    fs:SetJustifyH(config.align)
    fs:SetScale(config.scale)
    fs:SetAlpha(config.alpha)
    fs:SetTextColor(unpack(config.color))
    fs:SetText(content)
    fs:SetWordWrap(config.wrap)
    
    f:SetHeight((fs:GetStringHeight() * config.scale) + 2)
    f.Text = fs

    return f
end