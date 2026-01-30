local _, ns = ...

---------------------------------------------------------------------
-- INITIAL RECOGNIZED FRAMES
---------------------------------------------------------------------
ns.SOURCE = {
    BLIZZARD = "blizzard",
    ADDON    = "addon",
    CUSTOM   = "custom"
}

ns.PANEL_STATE = {
    ENABLE  = "TurnOn",
    DISABLE = "TurnOff",
}

ns.FRAME_REGISTRY = {
    -- Chatbox
    {name = "Chatbox",                             alias = "Chat", isGroup = true, useTextMode = false},
    -- Frames
    {name = "PlayerFrame",                         alias = "Player"},
    {name = "TargetFrame",                         alias = "Target"},
    {name = "FocusFrame",                          alias = "Focus"},
    {name = "PetFrame",                            alias = "Pet Frame"},
    -- Misc
    {name = "MinimapCluster",                      alias = "Minimap"},
    {name = "ObjectiveTrackerFrame",               alias = "Quests"},
    {name = "BuffFrame",                           alias = "Buffs"},
    {name = "MicroMenuContainer",                  alias = "Menu"},
    {name = "BagsBar",                             alias = "Bags"},
    {name = "BattlefieldMapFrame",                 alias = "Zone Map"},
    {name = "EncounterBar",                        alias = "Dragonriding Bar"},
    {name = "PlayerCastingBarFrame",               alias = "Casting Bar"},
    {name = "MainStatusTrackingBarContainer",      alias = "Tracking Bar"},
    {name = "SecondaryStatusTrackingBarContainer", alias = "Secondary Tracking Bar"},
    {name = "StanceBar",                           alias = "Stance Bar"},
    {name = "PartyFrame",                          alias = "Party Frame"},
    -- Spell Bars
    {name = "MainMenuBar",                         alias = "Action Bar 1"},
    {name = "MultiBarBottomLeft",                  alias = "Action Bar 2"},
    {name = "MultiBarBottomRight",                 alias = "Action Bar 3"},
    {name = "MultiBarRight",                       alias = "Action Bar 4"},
    {name = "MultiBarLeft",                        alias = "Action Bar 5"},
    {name = "MultiBar5",                           alias = "Action Bar 6"},
    {name = "MultiBar6",                           alias = "Action Bar 7"},
    {name = "MultiBar7",                           alias = "Action Bar 8"},
    {name = "PetActionBar",                        alias = "Pet Action Bar"},
    {name = "ZoneAbilityFrame",                    alias = "Zone Action Bar"},
}

---------------------------------------------------------------------
-- INITIAL VALUES
---------------------------------------------------------------------
ns.DEFAULT_FRAME_SETTINGS = {
    name = "",
    alias = "",
    source = ns.SOURCE.BLIZZARD,
    isEnabled = false,
    useMouseover = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    frameAlpha = 0.5,
    combatAlpha = 1,
    afkAlpha = 0,
    mountAlpha = 0,
    instanceAlpha = 1,
    --Events
    useCombat = true,
    useAFK = true,
    useMount = true,
    useInstance = true,
    --Group of frames as one
    isGroup = false,
}

ns.DEFAULT_GLOBAL_SETTINGS = {
    addonEnabled = true,
    useCharacterProfile = false,
    useMouseover = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    globalAlpha = 0.5,
    combatAlpha = 1,
    afkAlpha = 0,
    mountAlpha = 0,
    instanceAlpha = 1,
    --Events
    useCombat = true,
    useAFK = true,
    useMount = true,
    useInstance = true,
    -- Combat
    combatEndDelay = 1,
    -- Minimap button angle
    minimapAngle = 45,
}