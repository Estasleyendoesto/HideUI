local _, ns = ...
local Scroll = gUI:NewModule("Scroll")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------
local function ApplyScrollStyles(scrollFrame)
    local bar = scrollFrame.ScrollBar
    if not bar then return end

    if bar.Track then bar.Track:Hide() end
    if bar.ScrollUpButton then bar.ScrollUpButton:Hide() end
    if bar.ScrollDownButton then bar.ScrollDownButton:Hide() end

    if bar.ThumbTexture then
        bar.ThumbTexture:SetAlpha(0.5)
    end
end

---------------------------------------------------------------------
-- LÓGICA DE MOVIMIENTO (INTERNO)
---------------------------------------------------------------------
local function HandleMouseWheel(self, delta)
    -- Obtenemos el rango máximo que se puede scrollear
    -- Es la diferencia entre el alto del contenido y el alto del visor
    local maxScroll = self:GetVerticalScrollRange()
    
    -- Si el contenido cabe entero, no hacemos nada
    if maxScroll <= 0 then return end

    -- Calculamos la nueva posición
    local current = self:GetVerticalScroll()
    local scrollStep = 30
    local newPos = current - (delta * scrollStep)

    -- CLAMP: Bloqueamos entre 0 y el máximo real
    -- Esto evita que el scroll "tire para abajo" en el vacío
    if newPos < 0 then 
        newPos = 0 
    elseif newPos > maxScroll then 
        newPos = maxScroll 
    end

    self:SetVerticalScroll(newPos)
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Scroll:Create(parent)
    -- El ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    ApplyScrollStyles(scrollFrame)

    -- El Content (El lienzo interno)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1) 
    scrollFrame:SetScrollChild(content)

    -- Sincronización de dimensiones
    scrollFrame:SetScript("OnSizeChanged", function(self, width)
        content:SetWidth(width)
    end)

    -- Evento de Rueda
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", HandleMouseWheel)

    return scrollFrame, content
end
