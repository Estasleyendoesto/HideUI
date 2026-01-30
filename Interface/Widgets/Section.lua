local _, ns = ...
local Section = HideUI:NewModule("Section")
local Utils = HideUI:GetModule("Utils")

function Section:Create(parent, title)
    -- Contenedor maestro
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(1, 1)

    -- 2. Título de la sección (minimalista)
    if title then
        frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.Title:SetPoint("TOPLEFT", 72, 0)
        frame.Title:SetText(title:upper())
        frame.Title:SetAlpha(0.5)
    end

    -- 3. El Contenedor de Contenido (donde irán los widgets)
    local content = CreateFrame("Frame", nil, frame)
    -- Bajamos el contenido si hay título
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 72, title and -15 or 5)
    content:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -48, title and -15 or 5)

    -- 4. Registro de Layout (Aquí definimos tus paddings)
    Utils:RegisterLayout(content, {
        padding = 10,
        spacing = 10
    })

    frame.Content = content

    -- 5. Método Refresh (Calcula el alto total)
    function frame:Refresh()
        -- Apilamos los widgets internos
        Utils:VStack(self.Content)
        -- Ajustamos el alto del frame raíz al del contenido + título
        local h = self.Content:GetHeight()
        self:SetHeight(h + (title and 20 or 0))
    end

    return frame
end