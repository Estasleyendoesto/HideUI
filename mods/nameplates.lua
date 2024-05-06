local Nameplates_mod = HideUI:NewModule("Nameplates_mod", "AceEvent-3.0")
local Core_mod

--La idea de este mod es la de ocultar todos los nameplates
--Con ciertas condiciones:
--1. ocultar solo los nombres
--2. ocultar todos los nombres, excepto el target, los jugadores dentro del grupo, o los amigos (este ultimo puede que no)
--3. ocultar todos los nameplates(la barrita de vida, etc) de todos, excepto del target, grupo o banda, o amigos (igual que el anterior)
--4. Estando todo oculto, solo mostrar el del target
--5. Estando todo oculto, solo mostrar el del mouseover

function Nameplates_mod:OnInitialize()
    --Load Modules
    Core_mod = HideUI:GetModule("Core_mod")
end

function Nameplates_mod:OnEnable()
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnMouseoverUnit")
end

function Nameplates_mod:OnDisable()
    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
end

function Nameplates_mod:OnTargetChanged()
    -- Evento: Jugador cambia de objetivo
    if UnitExists("target") then
        local nameplate = C_NamePlate.GetNamePlateForUnit("target")
        local name = UnitName("target")
        local health = UnitHealth("target")
        local maxHealth = UnitHealthMax("target")
        print("Target cambiado a: " .. name)
        print("Salud: " .. health .. "/" .. maxHealth)
        if nameplate then
            print("Nameplate visible para: " .. name)
        end
        -- Opcional: Listar los buffs/debuffs, si necesario.
    else
        print("No hay objetivo actualmente.")
    end
end

function Nameplates_mod:OnMouseoverUnit()
    -- Evento: Jugador mueve el ratón sobre una nueva unidad
    if UnitExists("mouseover") then
        local nameplate = C_NamePlate.GetNamePlateForUnit("mouseover")
        local name = UnitName("mouseover")
        local health = UnitHealth("mouseover")
        local maxHealth = UnitHealthMax("mouseover")
        print("Mouseover en: " .. name)
        print("Salud: " .. health .. "/" .. maxHealth)
        if nameplate then
            print("Nameplate visible para: " .. name)
        end
    else
        print("No hay unidad bajo el mouseover.")
    end
end


-- Ejemplo de cómo obtener y trabajar con todos los nameplates visibles
-- local visibleNameplates = C_NamePlate.GetNamePlates()

-- for i, nameplate in ipairs(visibleNameplates) do
--     local unitID = nameplate.namePlateUnitToken -- Obtiene el token de unidad asociado con la nameplate
--     if unitID and UnitExists(unitID) then
--         print("Nameplate " .. i .. ": " .. UnitName(unitID))
--     end
-- end