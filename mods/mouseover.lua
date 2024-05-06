local Mouseover_mod = HideUI:NewModule("Mouseover_mod", "AceHook-3.0")
local Core_mod

function Mouseover_mod:OnInitialize()
    --Load Modules
    Core_mod = HideUI:GetModule("Core_mod")
    --Init core variables
    self.updateInterval = 0.12 --Para OnUpdate, lectura de frames (Razon:Rendimiento)
    self.ticInterval = 2.5 --Para FrameIsRunning, check if frame exists
    self.mouseOutDelay = 0.25 --Delay para la variable frame.isMouseOut, (otro uso, tiempo visible hasta empezar el fadeout)
    self.activeFrames = {}
end

function Mouseover_mod:OnEnable()
    self:StartTimer()
end

function Mouseover_mod:OnDisable()
    self:EndTimer()
end

----------------------------------------------------------------------------
function Mouseover_mod:GetTargetFrames()
    --Inserta nombres a la lista si que tengan mouseover
    return {
        "PlayerFrame",
        "TargetFrame",
        "FocusFrame",
        "PetFrame",
        "MinimapCluster",
        "BuffFrame",
        "ObjectiveTrackerFrame",    --quests
        "MicroMenuContainer",       --minimenu
        "BagsBar",                  --bags
        "MainStatusTrackingBarContainer",
        --Spell bars
        "MainMenuBar",
        "MultiBarBottomLeft",
        "MultiBarBottomRight",
        "MultiBarRight",
        "MultiBarLeft",
        "Multibar5",
        "Multibar6",
        "Multibar7",
        --Dragonflight
        "EncounterBar",
        -- "UIWidgetPowerBarContainerFrame",
    }
end

function Mouseover_mod:StartTimer()
    self:FrameIsRunning()
    self.frameCheckTimer = C_Timer.NewTicker(self.ticInterval, function()
        self:FrameIsRunning()
    end)
end

function Mouseover_mod:EndTimer()
    self:UnhookFrames()
    self.frameCheckTimer:Cancel()
end

function Mouseover_mod:HookFrame(frame)
    if not self:IsHooked(frame, "OnUpdate") then
        self:HookScript(frame, "OnUpdate", "OnFrameUpdate")
    end
end

function Mouseover_mod:UnhookFrames()
    local frames = self.activeFrames
    for _, frame in ipairs(frames) do
        if self:IsHooked(frame, "OnUpdate") then
            self:Unhook(frame, "OnUpdate")
        end
    end
end

function Mouseover_mod:InsertToActiveFrames(active_frames, target_frame)
    local isInside = false
    for _, frame in ipairs(active_frames) do
        if frame:GetName() == target_frame:GetName() then
            isInside = true
            break
        else
            isInside = false
        end
    end
    if not isInside then
        table.insert(active_frames, target_frame)
    end
end

function Mouseover_mod:FrameIsRunning()
    local targetFrames = self:GetTargetFrames()
    local new_activeFrames = {} --Para la limpieza
    self.activeFrames = self.activeFrames or {}
    for _, frameName in ipairs(targetFrames) do
        local frame = _G[frameName] --Get frame obj by name
        if frame then
            if frame:IsVisible() then
                self:HookFrame(frame)
                self:InsertToActiveFrames(new_activeFrames, frame)
            end
        end
    end
    self.active_frames = new_activeFrames
end

function Mouseover_mod:OnFrameUpdate(frame, elapsed)
    if not frame.lastUpdate then frame.lastUpdate = 0 end
    frame.lastUpdate = frame.lastUpdate + elapsed
    
    if frame.lastUpdate >= self.updateInterval then
        frame.lastUpdate = 0
        self:OnFrameMouseover(frame)
    end
end

function Mouseover_mod:OnFrameMouseover(frame)
    self:IsMouseEnter(frame)
    self:IsMouseOut(frame)

    if frame.isMouseEnter then
        UIFrameFadeIn(frame, self.db.profile.mouseoverFadeIn, frame:GetAlpha(), 1)
    end
    if frame.isMouseOut then
        UIFrameFadeOut(frame, self.db.profile.mouseoverFadeOut, frame:GetAlpha(), self.db.profile.globalOpacity / 100)
    end
end

function Mouseover_mod:IsMouseEnter(frame)
    if frame:IsMouseOver() then
        if not frame.isMouseEnter then
            frame.isMouseEnter = true
        end
    else
        if frame.isMouseEnter then
            frame.isMouseEnter = false
        end
    end

    return frame.isMouseEnter
end

function Mouseover_mod:IsMouseOut(frame)
    if frame.isMouseEnter then
        frame.isMouseOut = false    --Reset
        frame.mouseOutTime = nil
    else --Si está fuera
        frame.mouseOutTime = frame.mouseOutTime or GetTime()
        local elapsedTime = GetTime() - frame.mouseOutTime
        if elapsedTime >= self.mouseOutDelay then --Diferencia de tiempo
            frame.isMouseOut = false
        else
            frame.isMouseOut = true
        end
    end

    return frame.isMouseOut
end