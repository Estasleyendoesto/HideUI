local _, ns = ...
local Builder  = gUI:NewModule("Builder")
local Database = gUI:GetModule("Database")

-- Registro de tipos de widgets para evitar condicionales largos
local WIDGET_TYPES = {
    checkbox = "Checkbox",
    slider = "Slider",
    checkboxslider = "CheckboxSlider"
}

---------------------------------------------------------------------
-- PERSISTENCIA Y ESTADOS
---------------------------------------------------------------------

local function SaveValue(category, id, key, value)
    if category == "globals" then
        Database:UpdateGlobal(key, value)
    else
        Database:UpdateFrame(id, key, value)
    end
end

-- Gestiona el bloqueo visual de opciones según el estado maestro (Enabled/Ignored)
local function UpdateContainerStates(container, dbData, category)
    if not container.childWidgets then return end

    local masterKey = (category == "globals") and "addonEnabled" or "isEnabled"
    local isEnabled = dbData[masterKey]
    local isIgnored = dbData.ignoreFrame
    local canEdit   = isEnabled and not isIgnored

    for _, item in ipairs(container.childWidgets) do
        if item.key == masterKey then
            item.widget:SetEnabled(true)
        elseif item.key == "ignoreFrame" then
            item.widget:SetEnabled(isEnabled)
        else
            item.widget:SetEnabled(canEdit)
        end
    end
end

---------------------------------------------------------------------
-- CONSTRUCTOR DE COMPONENTES
---------------------------------------------------------------------

function Builder:CreateWidget(parent, category, id, key, info, dbData, container)
    local moduleName = WIDGET_TYPES[info.type]
    if not moduleName then return end

    local widget
    local masterKey = (category == "globals") and "addonEnabled" or "isEnabled"
    local module = gUI:GetModule(moduleName)

    -- Configuración específica por tipo
    if info.type == "checkbox" then
        widget = module:Create(parent, info.label, function(_, value)
            dbData[key] = value
            SaveValue(category, id, key, value)
            if key == masterKey or key == "ignoreFrame" then
                UpdateContainerStates(container, dbData, category)
            end
        end, info.tooltip, dbData[key])

    elseif info.type == "slider" then
        local s = { min = info.min, max = info.max, step = info.step, default = dbData[key], unit = info.unit }
        widget = module:Create(parent, info.label, function(_, value)
            dbData[key] = value
            SaveValue(category, id, key, value)
        end, info.tooltip, s)

    elseif info.type == "checkboxslider" then
        local s = { min = info.min, max = info.max, step = info.step, unit = info.unit,
                    cbDefault = dbData[info.cbKey], sliderDefault = dbData[info.sliderKey] }
        widget = module:Create(parent, info.label, function(checked, val)
            dbData[info.cbKey], dbData[info.sliderKey] = checked, val
            SaveValue(category, id, info.cbKey, checked)
            SaveValue(category, id, info.sliderKey, val)
        end, info.tooltip, s)
    end

    if widget then
        table.insert(container.childWidgets, { key = key, widget = widget })
    end

    return widget
end

---------------------------------------------------------------------
-- RENDERIZADO
---------------------------------------------------------------------

function Builder:RenderSettings(container, category, id, layout)
    local dbData = (category == "globals") and Database:GetGlobals() or Database:GetFrameData(id)
    local schema = ns.UI_SCHEMA[category]
    local order  = ns.UI_SCHEMA[category .. "Order"]
    
    if not dbData or not schema or not order then return end

    --- Extensión del Schema
    local finalOrder = {}
    for _, v in ipairs(order) do table.insert(finalOrder, v) end

    local extraSchema = ns.UI_EXTENSIONS.schemas[id]
    local extraOrder = ns.UI_EXTENSIONS.orders[id]

    if extraOrder and extraSchema then
        table.insert(finalOrder, { isSection = true, label = "Module Specific" })
        for _, fieldName in ipairs(extraOrder) do
            table.insert(finalOrder, fieldName)
        end
    end
    ---

    container.childWidgets = {}
    local activeSection
    local Section = gUI:GetModule("Section")

    for _, entry in ipairs(finalOrder) do
        -- Manejo de secciones
        if type(entry) == "table" and entry.isSection then
            if activeSection then activeSection:Refresh() end
            activeSection = Section:Create(container, entry.label, layout)
        
        -- Manejo de widgets dentro de secciones
        elseif activeSection then
            local info = (extraSchema and extraSchema[entry]) or schema[entry]
            if info then
                self:CreateWidget(activeSection.Content, category, id, entry, info, dbData, container)
            end
        end
    end

    if activeSection then activeSection:Refresh() end
    UpdateContainerStates(container, dbData, category)
end

function Builder:RegisterExtension(id, schema, order)
    ns.UI_EXTENSIONS.schemas[id] = schema
    ns.UI_EXTENSIONS.orders[id] = order
end