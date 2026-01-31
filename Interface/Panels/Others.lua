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
    if field == "isEnabled" and self.collapsibles then
        local co = self.collapsibles[frameName]
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
    
    -- 1. Recuperamos el diseño original (alignment, width, padding)
    self.sb = Searchbox:Create(MainFrame.Content, function(action, value)
        if value == "" then 
            return self.sb:SetFeedback("Enter a frame name", true) 
        end
        
        value = value:trim()

        if action == ns.ACTION.ADD then
            local success, err = Database:RegisterFrame({ 
                name = value, alias = value, source = ns.SOURCE.OTHER 
            })
            
            if success then
                self.filterText = "" -- Limpiamos búsqueda
                self.pendingFeedback = { msg = "Added!", isError = false }
            else
                self.pendingFeedback = { msg = err, isError = true }
            end
            self:Draw() -- Redibuja todo el panel

        elseif action == ns.ACTION.REMOVE then
            Database:UnregisterFrame(value)
            self.pendingFeedback = { msg = "Removed!", isError = false }
            self:Draw()
        end
    end, nil, "Setup any frame", {
        alignment = "CENTER",
        x = 10,
        width = 325,
        padding = { top = 0, bottom = 20 }
    })

    -- 2. Aplicamos feedback pendiente (si existe después del Draw)
    if self.pendingFeedback then
        self.sb:SetFeedback(self.pendingFeedback.msg, self.pendingFeedback.isError)
        self.pendingFeedback = nil
    end

    -- 3. Restaurar texto y lógica de filtrado
    self.sb.EditBox:SetText(currentText)
    self.sb.EditBox:SetScript("OnTextChanged", function(eb)
        SearchBoxTemplate_OnTextChanged(eb)
        self.filterText = eb:GetText():lower()
        self:UpdateList()
    end)
end

function Others:DrawFrameList()
    self.collapsibles = {}
    self.orderedList = {}
    
    local allFrames = Database:GetFrames()

    for frameName, data in pairs(allFrames) do
        if data.source == ns.SOURCE.OTHER then
            local co = Collapsible:Create(MainFrame.Content, data.alias or frameName, {
                headerLeft = 60, spacing = 3
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

            Builder:RenderSettings(co.Content, "frames", frameName, {
                -- Espaciados de cada Content dentro del collapsible
                left = 28, 
                right = -28, 
                spacing = 5
            })
            co:Refresh(false)
        end
    end
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS
---------------------------------------------------------------------
function Others:Draw()
    MainFrame:ClearAll()

    -- Espaciados del Content (searchbox y cada collapsible)
    Utils:RegisterLayout(MainFrame.Content, { 
        padding = { top = 15, bottom = 25, left = 22, right = 45 }, 
        spacing = 8 
    })

    self:DrawHeader()
    self:DrawSearchSection()
    self:DrawFrameList()

    -- Actualizar altura del Content
    -- Utils:VStack(MainFrame.Content)
    if self.filterText and self.filterText ~= "" then
        self:UpdateList()
    else
        Utils:VStack(MainFrame.Content)
    end
end

function Others:UpdateList()
    local filter = self.filterText or ""

    for _, co in ipairs(self.orderedList) do
        co:SetShown(filter == "" or co.searchText:find(filter, 1, true))
    end

    Utils:VStack(MainFrame.Content)
end