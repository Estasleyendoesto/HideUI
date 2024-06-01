local FrameInterface = HideUI:NewModule("FrameInterface")
local Model
local Controller
local AmigableUI

local FRAME_SETTINGS_PANEL

function FrameInterface:OnInitialize()
    Model      = HideUI:GetModule("Model")
    Controller = HideUI:GetModule("Controller")
    AmigableUI = HideUI:GetModule("AmigableUI")
end

function FrameInterface:UpdateUI()
    local panel = FRAME_SETTINGS_PANEL
end

function FrameInterface:Menu_Build(panel)
    FRAME_SETTINGS_PANEL = panel

    -- Panel
    AmigableUI:ScrollBox("panel_scroll", FRAME_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "Frame Settings")

    -- Frames
    AmigableUI:Pool("a", "titulo")
    AmigableUI:Pool("a", "titulo2")
    AmigableUI:Pool("a", "titulo3")

end
