local _, ns = ...

---------------------------------------------------------------------
-- INITIAL RECOGNIZED FRAMES
---------------------------------------------------------------------
ns.SOURCE = {
    BLIZZARD = "blizzard",
    OTHER    = "other",
    CUSTOM   = "custom"
}

ns.PANEL_STATE = {
    ENABLE  = "TurnOn",
    DISABLE = "TurnOff",
}

ns.ACTION = {
    ADD    = "add",
    REMOVE = "remove",
}

ns.PRIORITIES = {
    COMBAT   = 100,
    INSTANCE = 80,
    AFK      = 50,
    MOUNT    = 10,
}

ns.UI_EXTENSIONS = {
    schemas = {},
    orders = {}
}

ns.FRAME_REGISTRY = {
    -- Chatbox
    {name = "Chatbox",                             alias = "Chat", isVirtual = true, useTextMode = false},
    {name = "QuickJoinToastButton",                alias = "Quick Join"},
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
    {name = "MainActionBar",                         alias = "Action Bar 1"},
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
    ignoreFrame = false,
    useMouseover = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    frameAlpha = 0.5,
    COMBATAlpha   = 1,
    AFKAlpha      = 0,
    MOUNTAlpha    = 0,
    INSTANCEAlpha = 1,
    --Events
    useCOMBAT   = true,
    useAFK      = true,
    useMOUNT    = true,
    useINSTANCE = true,
    --Group of frames as one
    isVirtual = false,
}

ns.DEFAULT_GLOBAL_SETTINGS = {
    addonEnabled = true,
    useCharacterProfile = false,
    useMouseover = true,
    mouseoverFadeInDuration = 0.3,
    mouseoverFadeOutDuration = 0.4,
    --Alpha amount
    globalAlpha = 0.5,
    COMBATAlpha   = 1,
    AFKAlpha      = 0,
    MOUNTAlpha    = 0,
    INSTANCEAlpha = 1,
    --Events
    useCOMBAT   = true,
    useAFK      = true,
    useMOUNT    = true,
    useINSTANCE = true,
    -- Combat
    combatEndDelay = 1,
    -- Minimap button angle
    minimapAngle = 45,
}
