local Model = HideUI:NewModule("Model")

local frame_names = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PetActionBar", "MinimapCluster", "ObjectiveTrackerFrame",
"BuffFrame", "MicroMenuContainer", "BagsBar", "MainMenuBar", "BattlefieldMapFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
"MultiBarRight", "MultiBarLeft", "Multibar5", "Multibar6", "Multibar7", "PlayerCastingBarFrame", "MainStatusTrackingBarContainer",
"EncounterBar", "StanceBar", "ZoneAbilityFrame", "Chatbox",
}
local frames_table = {}
for _, frame_name in ipairs(frame_names) do
    frames_table[frame_name] = {
        name = frame_name,
        alphaAmount = 0.5,
        isEnabled = true,
        isAlphaEnabled = false,
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isMouseoverEnabled = true,
        isInstanceEnabled = true,
    }
end
local defaults = {
    profile = {
        isAccountWide = true,
        isEnabled = true,
        globalAlphaAmount = 0.5,
        isMouseoverEnabled = true,
        mouseoverFadeInAmount = 0.3,
        mouseoverFadeOutAmount = 0.4,
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isInstanceEnabled = true,
        frames = frames_table,
    }
}

function Model:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HideUIDB", defaults, true)
    -- self.db:ResetProfile() --DEBUG
end

function Model:Find(field_name)
    if field_name then
        return self.db.profile[field_name]
    else
        print("HideUI: No se encuentra" .. field_name .. "en el registro.")
    end
end

function Model:Update(field_name, field_value)
    if field_name then
        self.db.profile[field_name] = field_value
    else
        print("HideUI: No puede actualizar " .. field_name .. " en el registro.")
    end
end

function Model:UpdateFrame(frame_name, field_name, field_value)
    if frame_name and field_name then
        self.db.profile["frames"][frame_name][field_name] = field_value
    else
        print("HideUI: No puede actualizar ".. frame_name ..", ".. field_name .." en el registro.")
    end
end