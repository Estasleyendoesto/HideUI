local Mouseover_mod = HideUI:NewModule("Mouseover_mod")
local Core_mod

function Mouseover_mod:OnInitialize()
    Core_mod = HideUI:GetModule("Core_mod")
    -- self.updateInterval = 12
end

function Mouseover_mod:OnEnable()
end

----------------------------------------------------------------------------
-- function Core_mod:HookNormalFrames()
--     self:SetFramesInteractive()

--     local frames = self:GetNormalFrames()
--     for _, frame in pairs(frames) do
--         self:HookScript(frame, "OnUpdate", "OnFrameUpdate")
--     end
-- end

-- function Core_mod:OnFrameUpdate(frame, elapsed)
--     if not frame.lastUpdate then frame.lastUpdate = 0 end
--     frame.lastUpdate = frame.lastUpdate + elapsed
    
--     if frame.lastUpdate >= self.updateInterval then
--         frame.lastUpdate = 0
--         -- Ejecuta tus operaciones aquí, por ejemplo:
--         self:CheckFrameMouseover(frame)
--     end
-- end

-- function Core_mod:CheckFrameMouseover(frame)
--     print("Mouseover detected on", frame:GetName())
--     -- if frame:IsMouseOver() then
--         -- print("Mouseover detected on", frame:GetName())
--         -- Más lógica puede ir aquí
--     -- end
-- end

-- function Core_mod:SetFramesInteractive()
--     local frames = self:GetNormalFrames()
--     for _, frame in ipairs(frames) do
--         if frame and not frame:IsMouseEnabled() then
--             frame:EnableMouse(true) -- Asegura que el frame es interactivo y puede recibir eventos de mouseover
--         end
--     end
-- end

-- function Core_mod:HandleMouseoverBehaviour()
--     -- Si existe un timer. Cancela el Timer
--     if self.mouseOverTimer then
--         self.mouseOverTimer:Cancel()
--         self.mouseOverTimer = nil
--     end
--     if not self:IsActive() or not self.db.profile.isMouseOver then
--         return
--     end

--     local function DetectMouseover()
--         local frames = self:GetNormalFrames()        
--         for _, frame in ipairs(frames) do
--             if frame:IsMouseOver() then --frame:IsVisible()
--                 --Trato especial para target, focus
--                 if frame:GetName() == "TargetFrame" and not UnitExists("target") then
--                     return
--                 end
--                 if frame:GetName() == "FocusFrame" and not UnitExists("focus") then
--                     return
--                 end

--                 return frame
--             end
--         end
--         return nil
--     end

--     local function ChangeFrameOpacity(frame, targetOpacity)
--         if targetOpacity == 1 then
--             UIFrameFadeIn(frame, self.db.profile.mouseoverFadeIn, frame:GetAlpha(), targetOpacity)
--         else
--             UIFrameFadeOut(frame, self.db.profile.mouseoverFadeOut, frame:GetAlpha(), self.db.profile.globalOpacity / 100)
--         end
--     end

--     --Aux
--     local target_frame = nil
--     local wasMouseOver = false
--     --Tics
--     self.mouseOverTimer = C_Timer.NewTicker(0.25, function()
--         local current_frame = DetectMouseover()
--         if current_frame then
--             if not wasMouseOver or target_frame ~= current_frame then
--                 if target_frame and target_frame ~= current_frame then -- FadeOut del frame anterior al actual
--                     ChangeFrameOpacity(target_frame, self.db.profile.globalOpacity)
--                 end
--                 ChangeFrameOpacity(current_frame, 1)
--                 target_frame = current_frame
--                 wasMouseOver = true
--             end
--         else
--             if wasMouseOver then
--                 ChangeFrameOpacity(target_frame, self.db.profile.globalOpacity)
--                 target_frame = nil
--                 wasMouseOver = false
--             end
--         end
--     end)
-- end