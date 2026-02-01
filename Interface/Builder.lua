local _, ns = ...
local Builder  = gUI:NewModule("Builder")
local Database = gUI:GetModule("Database")
local Utils    = gUI:GetModule("Utils")

-- Widgets
local Checkbox = gUI:GetModule("Checkbox")
local Slider   = gUI:GetModule("Slider")
local CBSlider = gUI:GetModule("CheckboxSlider")
local Section  = gUI:GetModule("Section")

---------------------------------------------------------------------
-- PERSISTENCIA
---------------------------------------------------------------------
--- Guardado de cambios del usuario en la DB
local function SaveValue(category, id, key, value)
    if category == "globals" then
        Database:UpdateGlobal(key, value)
    else
        Database:UpdateFrame(id, key, value)
    end
end

---------------------------------------------------------------------
-- GESTOR DE ESTADOS
---------------------------------------------------------------------
-- Activa o desactiva todos los widgets del contenedor 
local function UpdateContainerStates(container, dbData, category)
    if not container.childWidgets then return end

    local masterKey = (category == "globals") and "addonEnabled" or "isEnabled"
    local ignoreKey = "ignoreFrame"

    local isEnabled = dbData[masterKey]
    local isIgnored = dbData[ignoreKey]
    local canEdit = isEnabled and not (isIgnored or false)

    for _, item in ipairs(container.childWidgets) do
        if item.key == masterKey then
            item.widget:SetEnabled(true)
        elseif item.key == ignoreKey then
            item.widget:SetEnabled(isEnabled)
        else
            item.widget:SetEnabled(canEdit)
        end
    end
end

---------------------------------------------------------------------
-- CREADOR DE WIDGETS
---------------------------------------------------------------------
function Builder:CreateWidget(parent, category, id, key, info, dbData, container)
    local widget
    local masterKey = (category == "globals") and "addonEnabled" or "isEnabled"

    -- CHECKBOX
    if info.type == "checkbox" then
        widget = Checkbox:Create(parent, info.label, function(_, value)
            dbData[key] = value

            SaveValue(category, id, key, value)

            -- Si tocamos una llave maestra, actualizamos visuales
            if key == masterKey or key == "ignoreFrame" then
                UpdateContainerStates(container, dbData, category)
            end
        end, info.tooltip, dbData[key])

    -- SLIDER
    elseif info.type == "slider" then
        local settings = {
            min = info.min, max = info.max, step = info.step, 
            default = dbData[key], unit = info.unit
        }
        widget = Slider:Create(parent, info.label, function(_, value)
            dbData[key] = value
            SaveValue(category, id, key, value)
        end, info.tooltip, settings)

    -- CHECKBOX SLIDER
    elseif info.type == "checkboxslider" then
        local settings = {
            min = info.min, max = info.max, step = info.step, unit = info.unit,
            cbDefault = dbData[info.cbKey], sliderDefault = dbData[info.sliderKey]
        }
        widget = CBSlider:Create(parent, info.label, function(checked, val)
            dbData[info.cbKey] = checked
            dbData[info.sliderKey] = val
            SaveValue(category, id, info.cbKey, checked)
            SaveValue(category, id, info.sliderKey, val)
        end, info.tooltip, settings)
    end

    -- REGISTRO PARA AUTO-BLOQUEO
    if widget then
        -- Guardamos la referencia para poder desactivarlo luego
        table.insert(container.childWidgets, { key = key, widget = widget })
        
        -- Estado inicial al dibujar
        local isEnabled = dbData[masterKey]
        if key == "ignoreFrame" then
            widget:SetEnabled(isEnabled)
        elseif key ~= masterKey then
            local canEdit = isEnabled and not (dbData["ignoreFrame"] or false)
            if not canEdit then widget:SetEnabled(false) end
        end
    end

    return widget
end

---------------------------------------------------------------------
-- RENDERIZADO DINÁMICO
---------------------------------------------------------------------
function Builder:RenderSettings(container, category, id, layout)
    local dbData = (category == "globals") and Database:GetGlobals() or Database:GetFrameData(id)
    local schema = ns.UI_SCHEMA[category]
    local order = ns.UI_SCHEMA[category .. "Order"]
    
    if not dbData or not schema or not order then return end

    -- Contenedor de widgets
    container.childWidgets = {}
    local activeSection

    for _, entry in ipairs(order) do
        -- Si es una sección
        if type(entry) == "table" and entry.isSection then
            if activeSection then activeSection:Refresh() end

            activeSection = Section:Create(container, entry.label, layout)
        -- Si es un widget
        elseif activeSection then
            local info = schema[entry]
            if info then
                self:CreateWidget(activeSection.Content, category, id, entry, info, dbData, container)
            end
        end
    end

    if activeSection then activeSection:Refresh() end
    UpdateContainerStates(container, dbData, category)
end
