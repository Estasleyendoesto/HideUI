local _, ns = ...

-- -------------------------------------------------------------------
-- UI_SCHEMA
-- Define la representación visual de los datos de la DB
-- -------------------------------------------------------------------
ns.UI_SCHEMA = {
    -- ---------------------------------------------------------------
    -- Ajustes Globales (Para el panel General)
    -- ---------------------------------------------------------------
    globalsOrder = {
        { isSection = true,  label = "General" },
        "addonEnabled",
        "useCharacterProfile",
        { isSection = true,  label = "Global Visibility" },
        "globalAlpha",
        { isSection = true,  label = "Mouseover Behavior" },
        "useMouseover",
        "mouseoverFadeInDuration",
        "mouseoverFadeOutDuration",
        { isSection = true,  label = "Events & Conditions" },
        "combatGroup",
        "afkGroup",
        "mountGroup",
        "instanceGroup",
        { isSection = true,  label = "Additional Options" },
        "combatEndDelay"
    },
    globals = {
        -- General
        addonEnabled = { 
            type = "checkbox", 
            label = "Enable Addon", 
            tooltip = "Turns all Fade features on or off globally." 
        },
        useCharacterProfile = { 
            type = "checkbox", 
            label = "Character Profile", 
            tooltip = "If activated, the changes will only affect this character." 
        },
        globalAlpha = { 
            type = "slider", 
            label = "Global Opacity", 
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Sets the default opacity applied to all frames."
        },
        -- Mouseover
        useMouseover = { 
            type = "checkbox", 
            label = "Enable Mouseover", 
            tooltip = "Allows all frames to appear when hovered by the mouse cursor." 
        },
        mouseoverFadeInDuration = { 
            type = "slider", 
            label = "Fade-In Speed", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Controls how quickly frames fade in when triggered by mouseover." 
        },
        mouseoverFadeOutDuration = { 
            type = "slider", 
            label = "Fade-Out Speed", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Controls how quickly frames fade out after the mouse leaves." 
        },
        -- CheckboxSliders para eventos globales
        combatGroup = {
            type = "checkboxslider",
            label = "In Combat",
            cbKey = "useCOMBAT",
            sliderKey = "COMBATAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Adjusts frame opacity while your character is in combat."
        },
        afkGroup = {
            type = "checkboxslider",
            label = "When AFK",
            cbKey = "useAFK",
            sliderKey = "AFKAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Controls frame opacity when your character is marked as AFK."
        },
        mountGroup = {
            type = "checkboxslider",
            label = "On Mount",
            cbKey = "useMOUNT",
            sliderKey = "MOUNTAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Changes frame opacity while your character is mounted."
        },
        instanceGroup = {
            type = "checkboxslider",
            label = "In Instance",
            cbKey = "useINSTANCE",
            sliderKey = "INSTANCEAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Adjusts frame opacity inside dungeons, raids, or other instances."
        },
        combatEndDelay = { 
            type = "slider", 
            label = "Combat End Delay", 
            min = 0, max = 2, step = 0.1, unit = "s",
            tooltip = "Time before the default opacity is restored after leaving combat." 
        },
    },

    -- ---------------------------------------------------------------
    -- Ajustes por Frame (Para los paneles Blizzard/Addon)
    -- ---------------------------------------------------------------
    framesOrder = {
        { isSection = true, label = "General" },
        "isEnabled",
        "ignoreFrame",
        { isSection = true, label = "Frame Visibility" },
        "frameAlpha",
        { isSection = true, label = "Mouseover Behavior" },
        "useMouseover",
        "mouseoverFadeInDuration",
        "mouseoverFadeOutDuration",
        { isSection = true, label = "Events & Conditions" },
        "combatGroup",
        "afkGroup",
        "mountGroup",
        "instanceGroup"
    },
    frames = {
        -- General
        isEnabled = { 
            type = "checkbox", 
            label = "Enable", 
            tooltip = "Enable custom settings for this frame." 
        },
        ignoreFrame = {
            type = "checkbox", 
            label = "Ignore", 
            tooltip = "Fade will completely ignore this frame." 
        },
        frameAlpha = { 
            type = "slider", 
            label = "Base Opacity", 
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Default frame opacity when no visibility conditions are active."
        },
        -- Mouseover
        useMouseover = { 
            type = "checkbox", 
            label = "Show on Mouseover", 
            tooltip = "Displays the frame when the mouse cursor hovers over it." 
        },
        mouseoverFadeInDuration = { 
            type = "slider", 
            label = "Fade-In Speed", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Controls how quickly the frame fades in when shown by mouseover." 
        },
        mouseoverFadeOutDuration = { 
            type = "slider", 
            label = "Fade-Out Speed", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Controls how quickly the frame fades out after the mouse leaves." 
        },
        -- Events and States
        combatGroup = {
            type = "checkboxslider",
            label = "In Combat",
            cbKey = "useCOMBAT",
            sliderKey = "COMBATAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Adjusts the frame`s visibility while your character is in combat."
        },
        afkGroup = {
            type = "checkboxslider",
            label = "When AFK",
            cbKey = "useAFK",
            sliderKey = "AFKAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Controls the frame`s visibility when your character is marked as AFK."
        },
        mountGroup = {
            type = "checkboxslider",
            label = "On Mount",
            cbKey = "useMOUNT",
            sliderKey = "MOUNTAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Changes the frame`s visibility while your character is mounted."
        },
        instanceGroup = {
            type = "checkboxslider",
            label = "In Instance",
            cbKey = "useINSTANCE",
            sliderKey = "INSTANCEAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Adjusts the frame`s visibility when inside dungeons, raids, or other instances."
        },
    }
}