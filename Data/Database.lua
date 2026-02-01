-- Documentación de AceDB-3.0
-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0

local _, ns = ...
local Database = gUI:NewModule("Database", "AceEvent-3.0")

-- Constantes internas
local DEFAULT_PROFILE = "Default"

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------
function Database:OnInitialize()
    -- Generamos los valores por defecto dinámicamente
    local DEFAULTS = {
        profile = {
            globals = self:Deepcopy(ns.DEFAULT_GLOBAL_SETTINGS),
            frames  = self:BuildDefaultFrameMap(),
        }
    }

    -- "gUIDB" debe coincidir con el .toc (SavedVariables)
    self.db = LibStub("AceDB-3.0"):New("gUIDB", DEFAULTS, DEFAULT_PROFILE)
    
    -- Sincronizamos el perfil según la configuración guardada
    self:SyncProfile()
end

---------------------------------------------------------------------
-- GESTIÓN DE PERFILES (ACE-DB)
---------------------------------------------------------------------
function Database:GetProfile()
    return self.db.profile
end

function Database:GetCurrentCharKey()
    return string.format("%s@%s", UnitName("player"), GetRealmName())
end

function Database:IsUsingCharProfile()
    return self:GetGlobals().useCharacterProfile
end

--- Cambia el perfil activo (Default o Personaje) según la config global
function Database:SyncProfile()
    local useChar = self:IsUsingCharProfile()
    local charKey = self:GetCurrentCharKey()
    
    if useChar then
        self.db:SetProfile(charKey)
    else
        self.db:SetProfile(DEFAULT_PROFILE)
    end
end

--- Activa/Desactiva el uso de perfil por personaje y clona si es necesario
function Database:ToggleCharacterProfile(enabled)
    self:UpdateGlobal("useCharacterProfile", enabled)
    self:SyncProfile()
    
    -- Si el perfil nuevo está vacío, clonamos los datos del perfil Default
    if enabled and (not self.db.profile.frames or next(self.db.profile.frames) == nil) then
        self.db:CopyProfile(DEFAULT_PROFILE)
    end
end

---------------------------------------------------------------------
-- LECTURA (READ)
---------------------------------------------------------------------
function Database:GetGlobals()
    return self:GetProfile().globals
end

function Database:GetFrames()
    return self:GetProfile().frames
end

function Database:GetFrameData(frameName)
    if not frameName then return nil end
    return self:GetFrames()[frameName]
end

function Database:IsFrameRegistered(frameName)
    local data = self:GetFrameData(frameName)
    return data ~= nil, data
end

---------------------------------------------------------------------
-- ESCRITURA Y ACTUALIZACIÓN (CUD)
---------------------------------------------------------------------
function Database:UpdateGlobal(field, value)
    local globals = self:GetGlobals()
    if globals[field] ~= nil then
        globals[field] = value
    end

    self:SendMessage("GHOSTUI_GLOBAL_CHANGED", field, value)
end

function Database:UpdateFrame(frameName, field, value)
    local data = self:GetFrameData(frameName)
    if data and data[field] ~= nil then
        data[field] = value
    end

    self:SendMessage("GHOSTUI_FRAME_CHANGED", frameName, field, value)
end

--- Registra un frame externo (útil para integración con otros addons)
function Database:RegisterFrame(frameConfig)
    if not frameConfig or not frameConfig.name then 
        return false, "Invalid name" 
    end
    
    local name   = frameConfig.name
    local frames = self:GetFrames()
    local obj    = _G[name]

    -- Validaciones de existencia y tipo
    if not obj then 
        return false, "Frame not found" 
    end
    if type(obj) ~= "table" or not obj.GetObjectType then 
        return false, "Not a UI object" 
    end
    if frames[name] then 
        return false, "Already registered" 
    end

    -- Registro de datos
    local data = self:Deepcopy(ns.DEFAULT_FRAME_SETTINGS)
    for k, v in pairs(frameConfig) do
        data[k] = v
    end
    
    data.source  = frameConfig.source or ns.SOURCE.OTHER
    frames[name] = data

    return true
end

function Database:UnregisterFrame(frameName)
    -- Elimina un frame de la base de datos
    if not frameName then return end
    self:GetFrames()[frameName] = nil
end

---------------------------------------------------------------------
-- RESTAURACIÓN (RESET)
---------------------------------------------------------------------
function Database:RestoreGlobals()
    local profile = self:GetProfile()
    profile.globals = self:Deepcopy(ns.DEFAULT_GLOBAL_SETTINGS)
end

function Database:RestoreBlizzFrames()
    local frames = self:GetFrames()
    local defaults = self:BuildDefaultFrameMap()
    
    for name, config in pairs(defaults) do
        if config.source == ns.SOURCE.BLIZZARD then
            frames[name] = config
        end
    end
end

function Database:RestoreOtherFrames()
    local frames = self:GetFrames()
    local baseTemplate = ns.DEFAULT_FRAME_SETTINGS
    
    for name, data in pairs(frames) do
        if data.source == ns.SOURCE.OTHER then
            local reset = self:Deepcopy(baseTemplate)
            -- Mantenemos la identidad del frame externo
            reset.name   = data.name
            reset.alias  = data.alias
            reset.source = ns.SOURCE.OTHER
            
            frames[name] = reset
        end
    end
end

---------------------------------------------------------------------
-- HELPERS INTERNOS
---------------------------------------------------------------------
function Database:Deepcopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = self:Deepcopy(v)
    end
    return copy
end

--- Genera el mapa inicial de frames basado en el registro (ns.FRAME_REGISTRY)
function Database:BuildDefaultFrameMap()
    local frames = {}
    for _, info in ipairs(ns.FRAME_REGISTRY) do
        local frameTbl = self:Deepcopy(ns.DEFAULT_FRAME_SETTINGS)
        for k, v in pairs(info) do
            frameTbl[k] = v
        end
        frames[info.name] = frameTbl
    end
    return frames
end
