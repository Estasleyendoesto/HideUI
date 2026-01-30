local _, ns = ...
local Blizzard = HideUI:NewModule("Blizzard", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

function Blizzard:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function Blizzard:OnEnter(event, panel)
    if panel == "Blizzard" then
        self:Draw()
    end
end

function Blizzard:Refresh()
    local MainFrame = HideUI:GetModule("MainFrame")
    if MainFrame.frame:IsVisible() and self.isOpen then
        self:Draw()
    end
end

function Blizzard:TurnOn()
end

function Blizzard:TurnOff()
end

function Blizzard:Draw()
    local MainFrame   = HideUI:GetModule("MainFrame")
    local Header      = HideUI:GetModule("Header")
    local Builder     = HideUI:GetModule("Builder")
    local Database    = HideUI:GetModule("Database")
    local Popup       = HideUI:GetModule("Popup")
    local Collapsible = HideUI:GetModule("Collapsible")

    local order = ns.FRAME_REGISTRY
    local dbData = Database:GetFrames()

    self.isOpen = true
    MainFrame:ClearAll()

    Utils:RegisterLayout(MainFrame.Content, {
        padding = 15,
        spacing = 8
    })

    Header:Create(MainFrame.TopPanel, "Blizzard Frames", function()
        Popup:Confirm("Are you sure you want to reset every frame`s settings?", function()
            Database:RestoreGlobals()
            self:Draw() -- Redibujamos con los valores de fábrica
        end)
    end)
    Utils:VStack(MainFrame.TopPanel)

    for _, entry in ipairs(order) do
        local isRegistered, frame = Database:IsFrameRegistered(entry.name)
        
        if isRegistered and frame.source == ns.SOURCE.BLIZZARD then
        -- Cada frame es un collapsible
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                headerLeft = 60,
                headerRight = -42,
                spacing = 3
            })
            Builder:RenderSettings(co.Content, "frames", entry.name, {
                left = 28,
                right = -28,
                spacing = 5
            })
            co:Refresh(false) -- Cerrado por defecto
        end
    end

    Utils:VStack(MainFrame.Content)
end
