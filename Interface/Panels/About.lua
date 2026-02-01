local _, ns = ...
local About = HideUI:NewModule("About", "AceEvent-3.0")

local MainFrame = HideUI:GetModule("MainFrame")
local Utils     = HideUI:GetModule("Utils")
local Text      = HideUI:GetModule("Text")
local Link      = HideUI:GetModule("Link")

local PANEL_NAME = "About"

function About:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function About:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

function About:Draw()
    MainFrame:ClearAll()
    local container = MainFrame.Content

    -- Branding y Versión
    Text:CreateHeadLine(container, "HideUI", "1.1.0")

    -- Autoría
    local authConfig = { centered = true, suffix = "", spacing = 10, xOffset = -18 }
    Text:CreateDoubleLine(container, "Author", "Astroboy", authConfig)
    Text:CreateDoubleLine(container, "Reign", "Sanguino (EU)", authConfig)

    CreateFrame("Frame", nil, container):SetHeight(25)

    -- Enlaces Oficiales
    local links = {
        { "Wago.io:", "wago.io/hideui" },
        { "CurseForge:", "curseforge.com/wow/addons/hideui" },
        { "WoWInterface:", "wowinterface.com/downloads/infoXXXX" },
        { "GitHub:", "github.com/astroboy/hideui" }
    }
    for _, l in ipairs(links) do 
        Link:Create(container, l[1], l[2]) 
    end

    CreateFrame("Frame", nil, container):SetHeight(35)

    -- Traductores
    local sharedOffset = 18
    Text:CreateSingleLine(container, "SPECIAL THANKS TO OUR TRANSLATORS", {
        align = "LEFT", 
        xOffset = sharedOffset, 
        color = {1, 0.82, 0}, 
        font = "GameFontNormalSmall"
    })

    local translators = {
        { "deDE", "SlayerEGT, maylisdalan" },
        { "esES", "neolynx_zero, maylisdalan, xNumb97" },
        { "frFR", "PhantomLord, maylisdalan" },
        { "koKR", "drixwow, Hayan, netaras" }
    }

    for _, t in ipairs(translators) do
        Text:CreateDoubleLine(container, t[1], t[2], { 
            offset = sharedOffset - 15, 
            labelWidth = 50, 
            spacing = 10 
        })
    end

    -- Configuración Final del Layout
    Utils:RegisterLayout(container, {
        padding = {left = 110, right = 90, top = 8, bottom = 60},
        spacing = 8
    })
    Utils:VStack(container)
end