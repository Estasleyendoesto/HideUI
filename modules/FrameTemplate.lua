local FrameTemplate = HideUI:NewModule("FrameTemplate")
local StateManager

function FrameTemplate:OnInitialize()
    StateManager = HideUI:GetModule("StateManager")
end

function FrameTemplate:Create(parent, args, globals)
    local template = {}
    self:Embed(template)

    function template:OnDestroy()
        -- Para desvincular mensajes, eventos o unhooks
    end

    -- Calls from FrameManager
    ------------------------------------------------------------>>
    function template:OnMouseover()
        -- Temporizador desde OnLoop()
        if self:IsMouseoverEnabled() and self:IsOnMouseover(self.frame) then
            print("Mouseover en:", self.name)
        end
    end

    function template:OnAlphaUpdate(from)
        -- Solo cuando el jugador manipula el alpha slider
        local origin = self:CheckAlphaOrigin(from)
        if origin == "Global" then
            if self.name == "MinimapCluster" then
                print("Me estás tocando el global alpha, te vas a enterar!", self.name)
            end
        elseif origin == "Custom" then
            print("Me estás tocando el custom alpha, te vas a enterar!", self.name)
        end
    end

    function template:OnState(state)
        -- Ejecución final del estado tras filtros
        if self.name == "MinimapCluster" then
            print(state, self.name)
        end
    end

    function template:OnStateConfig(field, from)
        -- Responde al momento de activar/desactivar estados desde la interfaz
        local bindings = {
            isAFKEnabled = "PLAYER_AFK_STATE",
            isMountEnabled = "PLAYER_MOUNT_STATE",
            isCombatEnabled = "PLAYER_COMBAT_STATE",
            isInstanceEnabled = "PLAYER_INSTANCE_STATE"
        }

        function UpdateEvents(state, isActive)
            if isActive then
                StateManager:Recall(state)
            else
                local event = StateManager:BuildEvent(state, isActive)
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
        local isDisabled = not self:IsEventEnabled(field)
        if isDisabled then
            event.isActive = false
        end
        StateManager:EventManager(event, self.registry, function(e) self:OnState(e) end)
    end

    -- Conditions
    ------------------------------------------------------------>>
    function template:IsOnMouseover(frame)
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
        else
            return false
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
    template.enableFirstOut = false
    return template
end

function FrameTemplate:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
end