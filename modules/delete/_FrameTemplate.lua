local FrameTemplate = HideUI:NewModule("FrameTemplate")
local StateManager

function FrameTemplate:OnInitialize()
    StateManager = HideUI:GetModule("StateManager")
end

function FrameTemplate:Create(parent, args, globals)
    local template = {}
    self:Embed(template)

    function template:OnCreate()
        self.originalAlpha = self.frame:GetAlpha()
        if self:IsFrameActive() then
            local alpha = self.alpha_target or self:FindAlphaAmount()
            UIFrameFadeIn(self.frame, self.globals.mouseoverFadeInAmount, self.originalAlpha, alpha)
        end
    end

    function template:OnDestroy()
        if self:IsFrameActive() then
            local alpha = self.alpha_target or self:FindAlphaAmount()
            UIFrameFadeOut(self.frame, self.globals.mouseoverFadeOutAmount, alpha, self.originalAlpha)
        end
    end

    -- Calls from FrameManager
    ------------------------------------------------------------>>
    function template:OnMouseover()
        -- Temporizador desde OnLoop()
        if self:IsMouseoverEnabled() and self:IsOnMouseover() then
            if not self.fadedIn then
                local alpha = self.alpha_target or self:FindAlphaAmount()
                UIFrameFadeIn(self.frame, self.globals.mouseoverFadeInAmount, alpha, self.mouseoverAlpha)
                self.fadedIn = true
            end
        else
            if self.fadedIn then
                local alpha = self.alpha_target or self:FindAlphaAmount()
                UIFrameFadeOut(self.frame, self.globals.mouseoverFadeOutAmount, self.mouseoverAlpha, alpha)
                self.fadedIn = false
            end
        end
    end

    function template:OnAlphaUpdate(from)
        -- Solo cuando el jugador manipula el alpha slider
        if self.alpha_target then return end
        if not self:IsFrameActive() then return end

        local origin = self:CheckAlphaOrigin(from)
        if origin == "Global" then
            self.frame:SetAlpha(self.globals.globalAlphaAmount)
        elseif origin == "Custom" then
            self.frame:SetAlpha(self.args.alphaAmount)
        end
    end

    function template:OnAlphaConfig(from)
        -- Cuando el jugador hace clic en los checkboxes de alpha (global, frame y alpha)
        local origin = self:CheckAlphaOrigin(from)
        local alpha = self.alpha_target
        if origin == "Custom" then
            alpha = alpha or self.args.alphaAmount
            self.frame:SetAlpha(alpha)
        else
            alpha = alpha or self.globals.globalAlphaAmount
            self.frame:SetAlpha(alpha)
        end
    end

    function template:OnState(state)
        -- Ejecución final del estado tras filtros
        local states = {
            --AFK
            PLAYER_AFK_STATE_ENTER    = {alphaAmount = 0},
            PLAYER_AFK_STATE_HOLD     = {alphaAmount = 0},
            PLAYER_AFK_STATE_NEXT     = {alphaAmount = 0},
            PLAYER_AFK_STATE_EXIT     = {alphaAmount = 0},
            --Mount
            PLAYER_MOUNT_STATE_ENTER  = {alphaAmount = 0},
            PLAYER_MOUNT_STATE_HOLD   = {alphaAmount = 0},
            PLAYER_MOUNT_STATE_NEXT   = {alphaAmount = 0},
            PLAYER_MOUNT_STATE_EXIT   = {alphaAmount = 0},
            --Combat
            PLAYER_COMBAT_STATE_ENTER = {alphaAmount = 1},
            PLAYER_COMBAT_STATE_HOLD  = {alphaAmount = 1},
            PLAYER_COMBAT_STATE_NEXT  = {alphaAmount = 1},
            PLAYER_COMBAT_STATE_EXIT  = {alphaAmount = 1},
            --Instance
            PLAYER_INSTANCE_STATE_ENTER = {alphaAmount = 1},
            PLAYER_INSTANCE_STATE_HOLD  = {alphaAmount = 1},
            PLAYER_INSTANCE_STATE_NEXT  = {alphaAmount = 1},
            PLAYER_INSTANCE_STATE_EXIT  = {alphaAmount = 1},
        }
        local current_state = states[state]
        if current_state then
            local alpha = self:FindAlphaAmount()
            self.alpha_target = current_state.alphaAmount

            if string.find(state, "EXIT") then
                if self:IsFrameActive() then
                    UIFrameFadeOut(self.frame, self.globals.mouseoverFadeOutAmount, self.alpha_target, alpha)
                end
                self.alpha_target = nil
            else
                if self:IsFrameActive() then
                    UIFrameFadeIn(self.frame, self.globals.mouseoverFadeInAmount, alpha, self.alpha_target)
                end
            end
        end
    end

    function template:OnEventConfig(field, from)
        -- Responde al momento de activar/desactivar estados desde la interfaz
        local bindings = {
            isAFKEnabled = "PLAYER_AFK_STATE",
            isMountEnabled = "PLAYER_MOUNT_STATE",
            isCombatEnabled = "PLAYER_COMBAT_STATE",
            isInstanceEnabled = "PLAYER_INSTANCE_STATE"
        }
        local UpdateEvents = function(state, isActive)
            if isActive then
                StateManager:Recall(state)
            else
                if self.name == "MultiBarBottomLeft" then
                    print("pasa false")
                end
                local event = StateManager:BuildEvent(state, false)
                self:OnEvent(event)
            end
        end

        if from == "Custom" then
            if field == "isEnabled" then
                for fieldname, state in pairs(bindings) do
                    local isActive = self:IsEventEnabled(fieldname)
                    UpdateEvents(state, isActive)
                end
            else
                local isActive = self:IsEventEnabled(field)
                UpdateEvents(bindings[field], isActive)
            end
        elseif from == "Global" then
            local isActive = self:IsEventEnabled(field)
            UpdateEvents(bindings[field], isActive)
        end
    end

    -- State Manager
    ------------------------------------------------------------>>
    function template:OnEvent(event)
        -- Filtra estados activos y desactivados según la base de datos antes del registro
       local bindings = {
            PLAYER_AFK_STATE = "isAFKEnabled",
            PLAYER_MOUNT_STATE = "isMountEnabled",
            PLAYER_COMBAT_STATE = "isCombatEnabled",
            PLAYER_INSTANCE_STATE = "isInstanceEnabled"
        }

        local field = bindings[event.state]
        local isEnabled = self:IsEventEnabled(field)
        if not isEnabled then
            event.isActive = false
        end

        if self.name == "ObjectiveTrackerFrame" then
        -- if self.name == "MultiBarBottomLeft" then
            print("ANTES: ", self.name, event.state .. ":", event.isActive, "registry:", #self.registry, self.args["isMountEnabled"])
        end

        StateManager:EventManager(event, self.registry, function(e) self:OnState(e) end)

        if self.name == "ObjectiveTrackerFrame" then
        -- if self.name == "MultiBarBottomLeft" then
            print("DESPUES:", self.name, event.state .. ":", event.isActive, "registry:", #self.registry, self.args["isMountEnabled"])
        end
    end

    -- Conditions
    ------------------------------------------------------------>>
    function template:IsOnMouseover(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() and frame:IsMouseOver() then
            return true
        else
            return false
        end
    end

    function template:IsMouseoverEnabled()
        if self.args.isEnabled and self.args.isMouseoverEnabled then
            return true
        elseif not self.args.isEnabled and self.globals.isMouseoverEnabled then
            return true
        else
            return false
        end
    end

    function template:CheckAlphaOrigin(origin)
        if not self.args.isEnabled then
            return origin == "Global" and origin or nil
        elseif self.args.isAlphaEnabled then
            return origin == "Custom" and origin or nil
        else
            return origin == "Global" and origin or nil
        end
    end

    function template:IsEventEnabled(state)
        if self.args.isEnabled and self.args[state] then
            return true
        elseif not self.args.isEnabled and self.globals[state] then
            return true
        elseif self.args.isEnabled and not self.args[state] then
            return false
        elseif not self.args.isEnabled and not self.globals[state] then
            return false
        end
    end

    function template:IsFrameActive(frame)
        frame = frame or self.frame
        if frame and frame:IsVisible() and frame:IsShown() then
            return true
        else
            return false
        end
    end

    function template:IsAlphaEnabled()
        if self.args.isEnabled and self.args.isAlphaEnabled then
            return true
        else
            return false
        end
    end

    -- Methods
    ------------------------------------------------------------>>
    function template:FindAlphaAmount()
        if self:IsAlphaEnabled() then
            return self.args.alphaAmount
        else
            return self.globals.globalAlphaAmount
        end
    end

    -- Props
    ------------------------------------------------------------>>
    template.registry = {}
    template.globals = globals
    template.args = args
    if parent then
        template.frame = parent
        template.name = parent:GetName()
    end
    template.originalAlpha = nil
    template.enableFirstOut = false
    template.mouseoverAlpha = 1
    return template
end

function FrameTemplate:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
end