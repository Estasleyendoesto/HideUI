local _, ns = ...

local Others   = HideUI:NewModule("Others", "AceEvent-3.0")

local Database = HideUI:GetModule("Database")
local Builder  = HideUI:GetModule("Builder")
local Utils    = HideUI:GetModule("Utils")

-- Widgets
local MainFrame   = HideUI:GetModule("MainFrame")
local Header      = HideUI:GetModule("Header")
local Searchbox   = HideUI:GetModule("Searchbox")
local Collapsible = HideUI:GetModule("Collapsible")
local Popup       = HideUI:GetModule("Popup")

-- Panel Name
local PANEL_NAME = "Others"

function Others:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("HIDEUI_FRAME_CHANGED", "OnFrameChanged")
end

function Others:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

function Others:OnFrameChanged(_, frameName, field, value)
    -- Necesario obtener el cambio de estado de un frame
    -- Para actualizar el collapsible
    if field == "isEnabled" then
        local co = self.collapsibles and self.collapsibles[frameName]
        if co then
            co:SetStatus(value)
        end
    end
end

---------------------------------------------------------------------
-- DRAWERS
---------------------------------------------------------------------

--- Cabecera con botón de Reset
function Others:DrawHeader()
    Header:Create(MainFrame.TopPanel, "Other Frames", function()
        Popup:Confirm("Are you sure you want to reset every frame's settings?", function()
            Database:RestoreGlobals()
            self:Draw() 
        end)
    end)
    Utils:VStack(MainFrame.TopPanel)
end

--- Sección de búsqueda y gestión (Add/Remove)
function Others:DrawSearchSection()
    self.sb = Searchbox:Create(MainFrame.Content, function(action, value, sbFrame)
        -- Si no hay valor, mostrar feedback
        if value == "" then 
            return sbFrame:SetFeedback("Enter a frame name", true) 
        end

        value = value:trim()

        -- Si hizo clic en ADD
        if action == ns.ACTION.ADD then
            local success, err = Database:RegisterFrame({ 
                name = value, 
                alias = value,
                source = ns.SOURCE.OTHER 
            })

            self:Draw()

            if success then
                self.sb:SetFeedback("Added!", false)
            else
                self.sb:SetFeedback(err, true)
            end

        -- Si hizo clic en REMOVE
        elseif action == ns.ACTION.REMOVE then
            Database:UnregisterFrame(value)
            self:Draw()
            self.sb:SetFeedback("Removed!", false)
        end
    end, nil, "Setup any frame", {
        alignment = "CENTER",
        x = 10,
        width = 325,
        padding = {
            top = 0,
            bottom = 20,
        }
    })

    -- Lógica de filtrado en tiempo real
    self.sb.EditBox:SetScript("OnTextChanged", function(eb)
        SearchBoxTemplate_OnTextChanged(eb)
        self.filterText = eb:GetText():lower()
        self:UpdateList()
    end)
end

function Others:DrawFrameList()
    self.collapsibles = {}
    local allFrames = Database:GetFrames()

    for frameName, data in pairs(allFrames) do
        if data.source == ns.SOURCE.OTHER then
            -- Función de eliminación
            local deleteFunc = function()
                Popup:Confirm("¿Eliminar " .. frameName .. " de la lista?", function()
                    Database:UnregisterFrame(frameName)
                    self:Draw() -- Redibujamos para que desaparezca
                end)
            end

            -- Collapsible por frame
            local alias = data.alias or frameName
            local co = Collapsible:Create(MainFrame.Content, alias, {
                headerLeft = 60, 
                headerRight = -42, 
                spacing = 3
            }, deleteFunc)

            -- Seteamos el estado del collapsible
            co:SetStatus(data.isEnabled)
            self.collapsibles[frameName] = co
            
            -- Sections internos
            Builder:RenderSettings(co.Content, "frames", frameName, {
                left = 28, 
                right = -28, 
                spacing = 5
            })
            
            co:Refresh(false)
            co.searchText = alias:lower()
            table.insert(self.collapsibles, co)
        end
    end
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS
---------------------------------------------------------------------
function Others:Draw()
    MainFrame:ClearAll()

    -- Configuración base del layout
    Utils:RegisterLayout(MainFrame.Content, { 
        padding = 15, 
        spacing = 8 
    })

    -- Ejecución de la "receta"
    self:DrawHeader()
    self:DrawSearchSection()
    self:DrawFrameList()

    -- Al finalizar, apilamos todo verticalmente
    Utils:VStack(MainFrame.Content)
end

function Others:UpdateList()
    local filter = self.filterText or ""

    for _, co in ipairs(self.collapsibles) do
        local matches = (filter == "" or co.searchText:find(filter, 1, true))
        co:SetShown(matches)
    end

    -- Re-calculamos el layout solo de los que quedaron visibles
    Utils:VStack(MainFrame.Content)
end