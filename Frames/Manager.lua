local _, ns = ...
local Manager = gUI:NewModule("FrameManager", "AceEvent-3.0", "AceTimer-3.0")
Manager:SetDefaultModuleState(false)

local Database, Wrapper
local SCAN = { interval = 2.0, tries = 5 }

---------------------------------------------------------------------
-- Ciclo de Vida
---------------------------------------------------------------------
function Manager:OnEnable()
    Database = gUI:GetModule("Database")
    Wrapper  = gUI:GetModule("FrameWrapper")

    self:RegisterMessage("GHOSTUI_EVENT_READY", "OnEvent")
    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalChange")
    self:RegisterMessage("GHOSTUI_FRAME_CHANGED", "OnFrameChange")
    
    self:RegisterFrames()
end

function Manager:OnDisable()
    self:UnregisterFrames()
end

---------------------------------------------------------------------
-- Manejadores de Eventos
---------------------------------------------------------------------
function Manager:OnEvent(_, event, state)
    for _, wrapper in pairs(ns.Frames) do
        wrapper:UpdateState(event, state)
    end
end

function Manager:OnGlobalChange(_, field, value)
    print("|cff00ff00gUI:|r Global ->", field, "=", value)
    -- Si cambia algo global, todos los wrappers deben enterarse
    local glb = Database:GetGlobals()
    for _, wrapper in pairs(ns.Frames) do
        wrapper:UpdateConfig(wrapper.config, glb)
    end
end

function Manager:OnFrameChange(_, name, field, value)
    print("|cff00ff00gUI:|r Frame ->", name, ":", field, "=", value)
    local wrapper = ns.Frames[name]
    if wrapper then
        -- Refrescamos la configuración del wrapper específico
        wrapper:UpdateConfig(Database:GetFrameData(name), Database:GetGlobals())
    end
end

---------------------------------------------------------------------
-- Registro de Frames
---------------------------------------------------------------------
function Manager:RegisterFrames()
    ns.Frames = {}
    self:StopScanner()

    local framesToRegister = Database:GetFrames()
    local hasMissing = false

    for name in pairs(framesToRegister) do
        if not self:RegisterFrame(name) then 
            hasMissing = true 
        end
    end

    if hasMissing then self:StartScanner(framesToRegister) end
end

function Manager:UnregisterFrames()
    self:StopScanner()
    for _, wrapper in pairs(ns.Frames) do
        wrapper:Destroy()
    end
    wipe(ns.Frames)
end

function Manager:RegisterFrame(name)
    if ns.Frames[name] then return true end

    local data = Database:GetFrameData(name)
    local isVirtual = data and data.isVirtual
    
    -- Factoría: busca módulo especializado o usa el genérico
    local module = gUI:GetModule(name, true) or Wrapper
    local wrapper = module:Create(name, isVirtual)

    if wrapper then
        ns.Frames[name] = wrapper
        wrapper:UpdateConfig(Database:GetFrameData(name), Database:GetGlobals())
        return true
    end

    return false
end

---------------------------------------------------------------------
-- Escáner de Frames Faltantes
---------------------------------------------------------------------
function Manager:StartScanner(framesList)
    local count = 0
    self.scanTimer = self:ScheduleRepeatingTimer(function()
        count = count + 1
        local pending = 0
        
        for name in pairs(framesList) do
            if not ns.Frames[name] and not self:RegisterFrame(name) then
                pending = pending + 1
            end
        end

        if pending == 0 or count >= SCAN.tries then
            self:StopScanner()
            if pending > 0 then
                print("|cffff0000gUI:|r Scanner detenido. Faltan:", pending)
            end
        end
    end, SCAN.interval)
end

function Manager:StopScanner()
    if self.scanTimer then
        self:CancelTimer(self.scanTimer)
        self.scanTimer = nil
    end
end