local _, ns = ...
local Others   = gUI:NewModule("Others", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Widgets
local MainFrame   = gUI:GetModule("MainFrame")
local Header      = gUI:GetModule("Header")
local Searchbox   = gUI:GetModule("Searchbox")
local Collapsible = gUI:GetModule("Collapsible")
local Popup       = gUI:GetModule("Popup")

-- Panel Name
local PANEL_NAME = "Others"

function Others:OnEnable()
    self:RegisterMessage("gUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("gUI_FRAME_CHANGED", "OnFrameChanged")
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
        x = 5,
        width = 325,
        padding = { top = 0, bottom = 35 }
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
                -- Layout de cada collapsible
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

            Builder:RenderSettings(co.Content, "frames", frameName, {
                -- Layout de cada section dentro del collapsible
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

    Utils:RegisterLayout(MainFrame.Content, { 
        -- Layout del MainFrame.Content
        -- Padre del searchbox y los collapsibles
        padding = { x = 68, top = 18, bottom = 52 }, 
        spacing = 8 
    })

    self:DrawHeader()
    self:DrawSearchSection()
    self:DrawFrameList()

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
