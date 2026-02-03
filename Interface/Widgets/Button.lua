local _, ns = ...
local Button = gUI:NewModule("Button")

-- Configuración estética por defecto para el estilo Moderno
local MODERN_DEFAULTS = {
    size = {90, 22},
    fonts = {
        normal = "GameFontNormalSmall",
        highlight = "GameFontHighlightSmall",
        disabled = "GameFontDisableSmall",
    },
    colors = {
        idle      = { bg = {0.05, 0.05, 0.05, 0.8}, border = {0.3, 0.3, 0.4, 1} },
        hover     = { bg = {0.1, 0.1, 0.1, 0.9},    border = {0.5, 0.5, 0.7, 1} },
        active    = { bg = {0.3, 0.3, 0.4, 0.3},    border = {0.3, 0.3, 0.4, 1}, offset = {1, -1} },
        disabled  = { bg = {0.1, 0.1, 0.15, 1},     border = {0.4, 0.4, 0.8, 1} } 
    }
}

---------------------------------------------------------------------
-- BOTÓN ESTÁNDAR (Estilo Blizzard)
---------------------------------------------------------------------
function Button:Create(parent, text, onClick, size)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    
    btn:SetText(text)
    btn:SetSize(unpack(size or {90, 22}))
    
    if onClick then btn:SetScript("OnClick", onClick) end

    return btn
end

---------------------------------------------------------------------
-- BOTÓN MODERNO (Custom Backdrop)
---------------------------------------------------------------------
function Button:CreateModern(parent, text, onClick, styles)
    local s = styles or {}
    local size  = s.size or MODERN_DEFAULTS.size
    local fonts = s.fonts or MODERN_DEFAULTS.fonts
    local c     = s.colors or MODERN_DEFAULTS.colors

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(unpack(size))
    btn:SetText(text)
    
    -- Configuración de fuentes y fondo
    btn:SetNormalFontObject(fonts.normal)
    btn:SetHighlightFontObject(fonts.highlight)
    btn:SetDisabledFontObject(fonts.disabled or fonts.normal)

    btn:SetBackdrop({
        bgFile   = [[Interface\ChatFrame\ChatFrameBackground]], 
        edgeFile = [[Interface\ChatFrame\ChatFrameBackground]], 
        edgeSize = 1,
    })

    -- Gestión de estados visuales
    local function ApplyStyle(state)
        local colors = c[state] or c.idle
        btn:SetBackdropColor(unpack(colors.bg))
        btn:SetBackdropBorderColor(unpack(colors.border))
    end

    -- Scripts de interacción y estado
    btn:HookScript("OnEnable", function() ApplyStyle("idle") end)
    btn:HookScript("OnDisable", function() ApplyStyle("disabled") end)
    
    btn:SetScript("OnEnter", function(self) 
        if self:IsEnabled() then ApplyStyle("hover") end 
    end)
    btn:SetScript("OnLeave", function(self) 
        if self:IsEnabled() then ApplyStyle("idle") end 
    end)

    -- Capa visual para el estado presionado (Pushed)
    local active = c.active or c.idle
    local pushedTex = btn:CreateTexture()
    pushedTex:SetAllPoints()
    pushedTex:SetColorTexture(unpack(active.bg)) 
    
    btn:SetPushedTexture(pushedTex)
    btn:SetPushedTextOffset(unpack(active.offset or {1, -1}))

    -- Inicialización de estado y lógica
    if btn:IsEnabled() then ApplyStyle("idle") else ApplyStyle("disabled") end
    if onClick then btn:SetScript("OnClick", onClick) end

    return btn
end