local _, ns = ...
local About = gUI:NewModule("About", "AceEvent-3.0")

local MainFrame = gUI:GetModule("MainFrame")
local Utils     = gUI:GetModule("Utils")
local Text      = gUI:GetModule("Text")
local Link      = gUI:GetModule("Link")

local PANEL_NAME = "About"

function About:OnEnable()
    self:RegisterMessage("GHOSTUI_PANEL_CHANGED", "OnEnter")
end

function About:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

function About:Draw()
    -- Ocultamos el scrollbar
    -- Si la lista de traductores crece o se redimensiona el MainFrame
    -- Eliminar o comentar esta linea
    MainFrame.ScrollFrame.ScrollBar:Hide()

    MainFrame:ClearAll()
    local container = MainFrame.Content

    -- Branding y Versión
    Text:CreateHeadLine(container, "GhostUI", "gUI - 1.1.0")

    -- Autoría
    local authConfig = { centered = true, suffix = "", spacing = 10, xOffset = -18 }
    Text:CreateDoubleLine(container, "Author", "Aeioux", authConfig)
    Text:CreateDoubleLine(container, "Reign", "Sanguino (EU)", authConfig)

    CreateFrame("Frame", nil, container):SetHeight(25)

    -- Enlaces Oficiales
    local links = {
        { "Wago.io:", "wago.io/gUI" },
        { "CurseForge:", "curseforge.com/wow/addons/gUI" },
        { "WoWInterface:", "wowinterface.com/downloads/infoXXXX" },
        { "GitHub:", "github.com/Estasleyendoesto/gUI" }
    }
    for _, l in ipairs(links) do 
        Link:Create(container, l[1], l[2]) 
    end

    CreateFrame("Frame", nil, container):SetHeight(35)

    -- Traductores (Ahora no hay ninguna)
    --[[
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
    --]]

    -- Configuración Final del Layout
    Utils:RegisterLayout(container, {
        padding = {left = 110, right = 90, top = 48, bottom = 60}, -- top = 8, si se descomenta los traductores
        spacing = 8
    })
    Utils:VStack(container)
end
