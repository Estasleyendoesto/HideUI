local _, ns = ...
local Scroll = HideUI:NewModule("Scroll")

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
    -- 1. Obtenemos el rango máximo que se puede scrollear
    -- Es la diferencia entre el alto del contenido y el alto del visor
    local maxScroll = self:GetVerticalScrollRange()
    
    -- 2. Si el contenido cabe entero, no hacemos nada
    if maxScroll <= 0 then return end

    -- 3. Calculamos la nueva posición
    local current = self:GetVerticalScroll()
    local scrollStep = 30
    local newPos = current - (delta * scrollStep)

    -- 4. CLAMP: Bloqueamos entre 0 y el máximo real
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
    -- 1. El ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    ApplyScrollStyles(scrollFrame)

    -- 2. El Content (El lienzo interno)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1) 
    scrollFrame:SetScrollChild(content)

    -- 3. Sincronización de dimensiones
    scrollFrame:SetScript("OnSizeChanged", function(self, width)
        content:SetWidth(width)
    end)

    -- 4. Evento de Rueda (Corregido con clamping)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", HandleMouseWheel)

    return scrollFrame, content
end