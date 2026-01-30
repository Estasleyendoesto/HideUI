local _, ns = ...
local Others = HideUI:NewModule("Others", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

local MainFrame, Database, Searchbox, Builder, Collapsible

function Others:OnEnable()
    MainFrame   = HideUI:GetModule("MainFrame")
    Database    = HideUI:GetModule("Database")
    Searchbox   = HideUI:GetModule("Searchbox")
    Builder     = HideUI:GetModule("Builder")
    Collapsible = HideUI:GetModule("Collapsible")

    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function Others:OnEnter(event, panel)
    if panel == "Others" then self:Draw() end
end

function Others:Refresh()
    if MainFrame.frame:IsVisible() and self.isOpen then self:Draw() end
end

---------------------------------------------------------------------
-- RENDERERS (BLOQUES DE CONSTRUCCIÓN)
---------------------------------------------------------------------

--- Cabecera con botón de Reset
function Others:DrawHeader()
    local Header = HideUI:GetModule("Header")
    local Popup  = HideUI:GetModule("Popup")

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
    local sb = Searchbox:Create(MainFrame.Content, function(action, value, sbFrame)
        -- Si no hay valor, no hacer nada
        if value == "" then 
            return sbFrame:SetFeedback("Enter a frame name", true) 
        end

        value = value:trim()

        -- Si es ADD
        if action == ns.ACTION.ADD then
            local success, err = Database:RegisterFrame({ 
                name = value, 
                alias = value,
                source = ns.SOURCE.OTHER 
            })

            if success then
                sbFrame:SetFeedback("Success: " .. value .. " added!", false)
                self:Draw()
            else
                sbFrame:SetFeedback(err, true)
            end
        -- Si es REMOVE
        elseif action == ns.ACTION.REMOVE then
            Database:UnregisterFrame(value)
            sbFrame:SetFeedback("Frame removed", false)
            self:Draw()
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
    sb.EditBox:SetScript("OnTextChanged", function(eb)
        SearchBoxTemplate_OnTextChanged(eb)
        self.filterText = eb:GetText():lower()
        self:UpdateList()
    end)
end

function Others:DrawFrameList()
    self.collapsibles = {}
    local order = ns.FRAME_REGISTRY

    for _, entry in ipairs(order) do
        local isRegistered, frame = Database:IsFrameRegistered(entry.name)
        
        if isRegistered and frame.source == ns.SOURCE.OTHER then
            -- Collapsible por frame
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                headerLeft = 60, 
                headerRight = -42, 
                spacing = 3
            })
            
            -- Sections internos
            Builder:RenderSettings(co.Content, "frames", entry.name, {
                left = 28, 
                right = -28, 
                spacing = 5
            })
            
            co:Refresh(false)
            co.searchText = entry.alias:lower()
            table.insert(self.collapsibles, co)
        end
    end
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS
---------------------------------------------------------------------

function Others:Draw()
    self.isOpen = true
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