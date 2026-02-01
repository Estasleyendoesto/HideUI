local _, ns = ...
local Button = gUI:NewModule("Button")

---------------------------------------------------------------------
-- BOTÓN ESTÁNDAR (Blizzard Style)
---------------------------------------------------------------------
function Button:Create(parent, text, onClick, size)
    -- Template oficial de Blizzard
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    
    -- Configuración
    btn:SetText(text)
    
    local w, h = unpack(size or {90, 22})
    btn:SetSize(w, h)
    
    if onClick then
        btn:SetScript("OnClick", onClick)
    end

    return btn
end

---------------------------------------------------------------------
-- BOTÓN MODERNO (Custom Backdrop)
---------------------------------------------------------------------
local DEFAULT_STYLE = {
    size = {90, 22},
    fonts = {
        normal = "GameFontNormalSmall",
        highlight = "GameFontHighlightSmall",
        disabled = "GameFontDisableSmall", -- Fuente para cuando está activo/desactivado
    },
    colors = {
        idle      = { bg = {0.05, 0.05, 0.05, 0.8}, border = {0.3, 0.3, 0.4, 1} },
        hover     = { bg = {0.1, 0.1, 0.1, 0.9},    border = {0.5, 0.5, 0.7, 1}, overlay = {1, 1, 1, 0.05} },
        active    = { bg = {0.3, 0.3, 0.4, 0.3},    border = {0.3, 0.3, 0.4, 1}, offset = {1, -1} },
        disabled  = { bg = {0.1, 0.1, 0.15, 1},     border = {0.4, 0.4, 0.8, 1} } 
    }
}

function Button:CreateModern(parent, text, onClick, styles)
    local s = styles or {}
    local size  = s.size or DEFAULT_STYLE.size
    local fonts = s.fonts or DEFAULT_STYLE.fonts
    local c     = s.colors or DEFAULT_STYLE.colors

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(unpack(size))
    btn:SetText(text)
    
    -- Configurar fuentes para cada estado
    btn:SetNormalFontObject(fonts.normal)
    btn:SetHighlightFontObject(fonts.highlight)
    btn:SetDisabledFontObject(fonts.disabled or fonts.normal)

    btn:SetBackdrop({
        bgFile   = [[Interface\ChatFrame\ChatFrameBackground]], 
        edgeFile = [[Interface\ChatFrame\ChatFrameBackground]], 
        edgeSize = 1,
    })

    -- Función de actualización visual
    local function ApplyStateStyle(state)
        local colors = c[state] or c.idle
        btn:SetBackdropColor(unpack(colors.bg))
        btn:SetBackdropBorderColor(unpack(colors.border))
    end

    -- HookScripts: Se disparan automáticamente al hacer btn:Disable() o btn:Enable()
    btn:HookScript("OnEnable", function() ApplyStateStyle("idle") end)
    btn:HookScript("OnDisable", function() ApplyStateStyle("disabled") end)

    -- Scripts de Hover
    btn:SetScript("OnEnter", function(self) 
        if self:IsEnabled() then ApplyStateStyle("hover") end 
    end)
    btn:SetScript("OnLeave", function(self) 
        if self:IsEnabled() then ApplyStateStyle("idle") end 
    end)

    -- Estado inicial
    if btn:IsEnabled() then ApplyStateStyle("idle") else ApplyStateStyle("disabled") end

    -- ACTIVE (Pushed)
    local activeColors = c.active or c.idle
    local pushedTex = btn:CreateTexture()
    pushedTex:SetAllPoints()
    pushedTex:SetColorTexture(unpack(activeColors.bg)) 
    
    btn:SetPushedTexture(pushedTex)
    btn:SetPushedTextOffset(unpack(activeColors.offset or {1, -1}))

    -- 5. Lógica
    if onClick then
        btn:SetScript("OnClick", onClick)
    end

    return btn
end
