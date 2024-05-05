local AFK_mod = HideUI:NewModule("AFK_mod", "AceEvent-3.0")
local Core_mod

function AFK_mod:OnInitialize()
    --Load Modules
    Core_mod = HideUI:GetModule("Core_mod")
end

function AFK_mod:OnEnable()
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnAFKBehaviour")
end

function AFK_mod:OnDisable()
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnAFKBehaviour")
end

function AFK_mod:OnAFKBehaviour(event, unit)
    if UnitIsAFK("player") then
        print("El jugador está AFK.")
    else
        print("El jugador ya no está AFK.")
    end
end