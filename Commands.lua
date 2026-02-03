local _, ns = ...
local Commands = gUI:NewModule("Commands", "AceConsole-3.0")

function Commands:OnEnable()
    self:RegisterChatCommand("gui", "HandleCommand")
    self:RegisterChatCommand("ghostui", "HandleCommand")
end

function Commands:HandleCommand(input)
    local arg1 = self:GetArgs(input, 1)
    arg1 = arg1 and arg1:lower() or ""

    if arg1 == "status" then
        self:ShowStatusReport()
    elseif arg1 == "enable" or arg1 == "on" then
        self:SetAddonState(true)
    elseif arg1 == "disable" or arg1 == "off" then
        self:SetAddonState(false)
    elseif arg1 == "" then
        local mainFrame = gUI:GetModule("MainFrame", true)
        if mainFrame then mainFrame:Toggle() end
    else
        self:PrintHelp()
    end
end

function Commands:SetAddonState(enabled)
    local db = gUI:GetModule("Database", true)
    if not db or db:GetGlobals().addonEnabled == enabled then return end

    ns.forceSync = enabled or nil
    db:UpdateGlobal("addonEnabled", enabled)
    
    local stateMsg = enabled and "|cff00ff00ACTIVE|r" or "|cffff0000SUSPENDED|r"
    print(string.format("|cff00ff00GhostUI:|r System status: %s", stateMsg))
end

function Commands:ShowStatusReport()
    print("|cff00ff00[ GhostUI - Diagnostic Report ]|r")
    
    -- 1. Estados Activos
    local activeStates = {}
    for ev, info in pairs(ns.States or {}) do
        if info.state then table.insert(activeStates, ev) end
    end
    local envStatus = #activeStates > 0 and ("|cffffff00" .. table.concat(activeStates, ", ") .. "|r") or "|cff888888IDLE|r"
    print(string.format("|cffaaaaaaActive States:|r %s", envStatus))
    print("|cff444444--------------------------------------------------|r")

    -- 2. Registro de Frames (Alineación corregida)
    if ns.Frames and next(ns.Frames) then
        print("|cffaaaaaaTYP MODE  ALPHA  MOUSE  NAME|r")
        for name, obj in pairs(ns.Frames) do
            local typeTag = obj.isVirtual and "|cffcccccc[V]|r" or "|cff444444[R]|r"
            local modeTag = obj.forceAlpha and "|cffffaa00[F]|r" or "|cff00aaff[L]|r"
            
            local curAlpha = obj.frame and string.format("%.2f", obj.frame:GetAlpha()) or "......"
            local tarAlpha = string.format("%.2f", obj.targetAlpha or 0)
            local mouseStat = obj.isMouseOver and "|cff00ff00OVER|r" or "|cffff0000 OUT|r"

            print(string.format(" %s   %s    %s/%s  %s  |cffffffff%s|r", 
                typeTag, modeTag, curAlpha, tarAlpha, mouseStat, name))
        end
    else
        print("|cffff0000[!] No frames registered.|r")
    end

    -- 3. Legend (Restaurada)
    print("|cff444444--------------------------------------------------|r")
    print("|cff888888LEGEND: [V] Virtual [R] Real [F] Forced Alpha [L] Linear Fade|r")
end

function Commands:PrintHelp()
    print("|cff00ff00GhostUI Commands:|r")
    print(" - |cffffff00/gui|r : Configuración")
    print(" - |cffffff00/gui status|r : Diagnóstico")
    print(" - |cffffff00/gui on/off|r : Activar/Desactivar")
end