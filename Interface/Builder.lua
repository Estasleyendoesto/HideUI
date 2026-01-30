local _, ns = ...
local Builder = HideUI:NewModule("Builder")

---------------------------------------------------------------------
-- LÓGICA DE PERSISTENCIA (INTERNA)
---------------------------------------------------------------------
--- Guardado de cambios del usuario en la DB
local function SaveValue(category, id, key, value)
    local Database = HideUI:GetModule("Database")
    if category == "globals" then
        Database:UpdateGlobal(key, value)
    else
        Database:UpdateFrame(id, key, value)
    end
end

---------------------------------------------------------------------
-- RENDERIZADO DINÁMICO
---------------------------------------------------------------------
function Builder:RenderSettings(container, category, id, layout)
    local Database    = HideUI:GetModule("Database")
    local Checkbox    = HideUI:GetModule("Checkbox")
    local Slider      = HideUI:GetModule("Slider")
    local CBSlider    = HideUI:GetModule("CheckboxSlider")
    local Section     = HideUI:GetModule("Section")
    
    local dbData = (category == "globals") and Database:GetGlobals() or Database:GetFrameData(id)
    local schema = ns.UI_SCHEMA[category]
    local order = ns.UI_SCHEMA[category .. "Order"]
    
    if not dbData or not schema or not order then return end

    local activeSection

    for _, entry in ipairs(order) do
        -- SI ES UNA SECCIÓN
        if type(entry) == "table" and entry.isSection then
            -- Refrescamos la sección anterior antes de empezar la nueva
            if activeSection then activeSection:Refresh() end
            -- Creamos la nueva section
            activeSection = Section:Create(container, entry.label, layout)
        
        -- SI ES UN Field (String)
        elseif activeSection then -- Solo dibujamos si existe una sección activa
            local key = entry
            local info = schema[key]
            
            if info then
                if info.type == "checkbox" then
                    Checkbox:Create(activeSection.Content, info.label, function(_, value)
                        SaveValue(category, id, key, value)
                    end, info.tooltip, dbData[key])

                elseif info.type == "slider" then
                    local settings = {
                        min = info.min, max = info.max, step = info.step, 
                        default = dbData[key], unit = info.unit
                    }
                    Slider:Create(activeSection.Content, info.label, function(_, value)
                        SaveValue(category, id, key, value)
                    end, info.tooltip, settings)

                elseif info.type == "checkboxslider" then
                    local settings = {
                        min = info.min, max = info.max, step = info.step, unit = info.unit,
                        cbDefault     = dbData[info.cbKey],
                        sliderDefault = dbData[info.sliderKey]
                    }
                    CBSlider:Create(activeSection.Content, info.label, function(checked, val)
                        SaveValue(category, id, info.cbKey, checked)
                        SaveValue(category, id, info.sliderKey, val)
                    end, info.tooltip, settings)
                end
            end
        end
    end

    -- Refrescar la última sección al terminar el bucle
    if activeSection then
        activeSection:Refresh()
    end
end