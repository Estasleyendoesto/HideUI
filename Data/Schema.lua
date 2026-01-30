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
        { isSection = true, label = "Configuración General" },
        "addonEnabled",
        "useCharacterProfile",
        { isSection = true, label = "Alpha Global" },
        "globalAlpha",
        { isSection = true, label = "Detección de Ratón (Mouseover)" },
        "useMouseover",
        "mouseoverFadeInDuration",
        "mouseoverFadeOutDuration",
        { isSection = true, label = "Eventos y Estados" },
        "combatGroup",
        "afkGroup",
        "mountGroup",
        "instanceGroup",
        { isSection = true, label = "Misc" },
        "combatEndDelay"
    },
    globals = {
        addonEnabled = { 
            type = "checkbox", 
            label = "Habilitar Addon", 
            tooltip = "Activa o desactiva por completo las funciones de HideUI." 
        },
        useCharacterProfile = { 
            type = "checkbox", 
            label = "Perfil por Personaje", 
            tooltip = "Si se activa, los cambios solo afectarán a este personaje." 
        },
        useMouseover = { 
            type = "checkbox", 
            label = "Usar Mouseover Global", 
            tooltip = "Habilita la detección de ratón para mostrar marcos ocultos de forma global." 
        },
        globalAlpha = { 
            type = "slider", 
            label = "Opacidad Global", 
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Ajusta la transparencia base de todos los elementos registrados."
        },
        mouseoverFadeInDuration = { 
            type = "slider", 
            label = "Velocidad de Entrada", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Duración de la transición al aparecer el marco." 
        },
        mouseoverFadeOutDuration = { 
            type = "slider", 
            label = "Velocidad de Salida", 
            min = 0, max = 5, step = 0.1, unit = "s",
            tooltip = "Duración de la transición al ocultarse el marco." 
        },
        -- CheckboxSliders para eventos globales
        combatGroup = {
            type = "checkboxslider",
            label = "Opacidad en Combate",
            cbKey = "useCombat",
            sliderKey = "combatAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Activa la opacidad específica cuando entras en combate."
        },
        afkGroup = {
            type = "checkboxslider",
            label = "Opacidad en AFK",
            cbKey = "useAFK",
            sliderKey = "afkAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Activa la opacidad específica cuando estás ausente."
        },
        mountGroup = {
            type = "checkboxslider",
            label = "Opacidad en Montura",
            cbKey = "useMount",
            sliderKey = "mountAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Activa la opacidad específica cuando estás montado."
        },
        instanceGroup = {
            type = "checkboxslider",
            label = "Opacidad en Estancia",
            cbKey = "useInstance",
            sliderKey = "instanceAlpha",
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Activa la opacidad específica dentro de mazmorras o bandas."
        },
        combatEndDelay = { 
            type = "slider", 
            label = "Retraso fin de combate", 
            min = 0, max = 2, step = 0.1, unit = "s",
            tooltip = "Tiempo que tarda en aplicarse la opacidad de reposo tras salir de combate." 
        },
    },

    -- ---------------------------------------------------------------
    -- Ajustes por Frame (Para los paneles Blizzard/Addon)
    -- ---------------------------------------------------------------
    frames = {
        isEnabled = { 
            type = "checkbox", 
            label = "Habilitar Control", 
            tooltip = "Si se desactiva, HideUI dejará de gestionar este marco por completo." 
        },
        useMouseover = { 
            type = "checkbox", 
            label = "Habilitar Mouseover", 
            tooltip = "Permite que el marco se muestre al pasar el ratón por encima." 
        },
        frameAlpha = { 
            type = "slider", 
            label = "Opacidad Normal", 
            min = 0, max = 1, step = 0.05, unit = "%",
            tooltip = "Opacidad del marco cuando no hay ningún evento activo."
        },
        mouseoverFadeInDuration = { 
            type = "slider", 
            label = "Velocidad de Entrada", 
            min = 0, max = 5, step = 0.1, unit = "s" 
        },
        mouseoverFadeOutDuration = { 
            type = "slider", 
            label = "Velocidad de Salida", 
            min = 0, max = 5, step = 0.1, unit = "s" 
        },
        -- CheckboxSliders para eventos del frame
        combatGroup = {
            type = "checkboxslider",
            label = "En Combate",
            cbKey = "useCombat",
            sliderKey = "combatAlpha",
            min = 0, max = 1, step = 0.05, unit = "%"
        },
        afkGroup = {
            type = "checkboxslider",
            label = "Al estar AFK",
            cbKey = "useAFK",
            sliderKey = "afkAlpha",
            min = 0, max = 1, step = 0.05, unit = "%"
        },
        mountGroup = {
            type = "checkboxslider",
            label = "En Montura",
            cbKey = "useMount",
            sliderKey = "mountAlpha",
            min = 0, max = 1, step = 0.05, unit = "%"
        },
        instanceGroup = {
            type = "checkboxslider",
            label = "En Estancia",
            cbKey = "useInstance",
            sliderKey = "instanceAlpha",
            min = 0, max = 1, step = 0.05, unit = "%"
        },
    }
}