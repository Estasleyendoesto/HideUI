local _, ns = ...
local Others = gUI:NewModule("Others", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Componentes de UI
local MainFrame   = gUI:GetModule("MainFrame")
local Header      = gUI:GetModule("Header")
local Searchbox   = gUI:GetModule("Searchbox")
local Collapsible = gUI:GetModule("Collapsible")
local Popup       = gUI:GetModule("Popup")

local PANEL_NAME = "Others"

function Others:OnEnable()
    self:RegisterMessage("GHOSTUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("GHOSTUI_FRAME_CHANGED", "OnFrameChanged")
end

-- Sincroniza el estado del collapsible si se cambia desde fuera (ej: comandos o base de datos)
function Others:OnFrameChanged(_, frameName, field, value)
    if field == "isEnabled" and self.collapsibles then
        local co = self.collapsibles[frameName]
        if co then co:SetStatus(value) end
    end
end

function Others:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

---------------------------------------------------------------------
-- DIBUJO DE COMPONENTES
---------------------------------------------------------------------

function Others:DrawHeader()
    local header = Header:Create(MainFrame.TopPanel, "Other Frames", function()
        Popup:Confirm("Are you sure you want to reset every frame's settings?", function()
            Database:RestoreOtherFrames()
            self:Draw() 
        end)
    end)
    MainFrame:RegisterHeader(header)
    Utils:VStack(MainFrame.TopPanel)
end

function Others:DrawSearchSection()
    local currentText = self.filterText or ""
    
    self.sb = Searchbox:Create(MainFrame.Content, function(action, value)
        if not value or value == "" then 
            return self.sb:SetFeedback("Enter a frame name", true) 
        end
        
        value = value:trim()

        -- Gestión de alta/baja de frames personalizados
        if action == ns.ACTION.ADD then
            local success, err = Database:RegisterFrame({ 
                name = value, alias = value, source = ns.SOURCE.OTHER 
            })
            self.filterText = success and "" or self.filterText
            self.pendingFeedback = { msg = success and "Added!" or err, isError = not success }
            self:Draw()

        elseif action == ns.ACTION.REMOVE then
            Database:UnregisterFrame(value)
            self.pendingFeedback = { msg = "Removed!", isError = false }
            self:Draw()
        end
    end, nil, "Setup any frame", {
        alignment = "CENTER", x = 5, width = 325, padding = { top = 0, bottom = 35 }
    })

    -- Restaurar feedback y texto tras el redibujado
    if self.pendingFeedback then
        self.sb:SetFeedback(self.pendingFeedback.msg, self.pendingFeedback.isError)
        self.pendingFeedback = nil
    end

    self.sb.EditBox:SetText(currentText)
    self.sb.EditBox:SetScript("OnTextChanged", function(eb)
        SearchBoxTemplate_OnTextChanged(eb)
        self.filterText = eb:GetText():lower()
        self:UpdateList()
    end)
end

function Others:DrawFrameList()
    self.collapsibles, self.orderedList = {}, {}
    local allFrames = Database:GetFrames()

    for frameName, data in pairs(allFrames) do
        if data.source == ns.SOURCE.OTHER then
            local co = Collapsible:Create(MainFrame.Content, data.alias or frameName, {
                margin  = { left = 70, right = 40 },
                padding = { x = 10, top = 10, bottom = 20 },
            }, function()
                Popup:Confirm("Delete " .. frameName .. "?", function()
                    Database:UnregisterFrame(frameName)
                    self:Draw()
                end)
            end)

            co:SetStatus(data.isEnabled)
            co.searchText = (data.alias or frameName):lower()
            
            self.collapsibles[frameName] = co
            table.insert(self.orderedList, co)

            Builder:RenderSettings(co.Content, "frames", frameName, {})
            co:Refresh(false)
        end
    end
end

---------------------------------------------------------------------
-- MÉTODOS DE CONTROL
---------------------------------------------------------------------

function Others:Draw()
    MainFrame:ClearAll()

    Utils:RegisterLayout(MainFrame.Content, { 
        padding = { x = 68, top = 18, bottom = 52 }, 
        spacing = 8 
    })

    self:DrawHeader()
    self:DrawSearchSection()
    self:DrawFrameList()

    -- Aplicar filtro si existe, si no, apilar normalmente
    if self.filterText and self.filterText ~= "" then
        self:UpdateList()
    else
        Utils:VStack(MainFrame.Content)
    end
end

-- Filtra los collapsibles en tiempo real según el texto de búsqueda
function Others:UpdateList()
    local filter = self.filterText or ""

    for _, co in ipairs(self.orderedList) do
        co:SetShown(filter == "" or co.searchText:find(filter, 1, true))
    end

    Utils:VStack(MainFrame.Content)
end