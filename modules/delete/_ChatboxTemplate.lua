local ChatboxTemplate = HideUI:NewModule("ChatboxTemplate")
local FrameTemplate

function ChatboxTemplate:OnInitialize()
    FrameTemplate = HideUI:GetModule("FrameTemplate")
end

function ChatboxTemplate:Create(args, globals)
    local template = FrameTemplate:Create(nil, args, globals)
    self:Embed(template)

    function template:OnCreate()
        self:ChatFramesUpdate("hook")
    end

    function template:OnDestroy()
        self:ChatFramesUpdate("unhook")
    end

    -- Calls from FrameManager
    ------------------------------------------------------------>>
    function template:OnMouseover()
        if not self:IsMouseoverEnabled() then return end

        for _, chatbox in ipairs(self.chatboxes) do
            if self:IsOnMouseover(chatbox.chatFrame) or
               self:IsOnMouseover(chatbox.tab) or
               self:IsOnMouseover(chatbox.editBox) or
               self:IsOnMouseover(chatbox.buttonFrame) or
               self:IsOnMouseover(self.socialFrame) or
               self:IsOnMouseover(self.combatLogFrame)
            then
                print("Mouseover en Chatbox")
                return
            end
        end
    end

    function template:OnAlphaUpdate(from)
    end

    function template:OnAlphaEvent(from)
    end

    function template:OnState(state)
        -- Ejecución final del estado tras filtros
        if self.name == "MinimapCluster" then
            print(state, self.name)
        end
    end

    -- Methods
    ------------------------------------------------------------>>
    function template:GetChatFrames()
        --Busca y empaqueta los chatframes
        local activeChats = {}
        local i = 1
        while true do
            local chatTab = _G["ChatFrame" .. i .. "Tab"]
            if chatTab then --Tab es más preciso para encontrar los chatframes
                if chatTab:IsVisible() then
                    table.insert(
                        activeChats,
                        {
                            id = i,
                            tab = chatTab,
                            chatFrame = _G["ChatFrame" .. i] or  nil,
                            editBox = _G["ChatFrame" .. i .. "EditBox"] or nil,
                            buttonFrame = _G["ChatFrame" .. i .. "ButtonFrame"] or nil,
                        }
                    )
                end
            else
                break
            end
            i = i + 1
        end
        return activeChats
    end

    function template:ChatFramesUpdate(operator)
        local methods = {
            "FCF_Close",               --Al cerrar una ventana
            "FCF_OpenNewWindow",       --Si es < NUM_CHAT_WINDOWS, 1 al 10
            "FCF_OpenTemporaryWindow", --Si es > NUM_CHAT_WINDOWS, desde 11+ 
            "FCF_ResetChatWindows",    --Cuando se reducen a 2 (default y combatlog)
            "FCF_NewChatWindow",       --No se lo que hace pero igual lo pongo xD
        }

        function OnIntercept()
            self.chatboxes = self:GetChatFrames()
        end

        for _, method in ipairs(methods) do
            if operator == "hook" and not self:IsHooked(method) then
                self:SecureHook(method, OnIntercept)
            elseif operator == "unhook" and self:IsHooked(method) then
                self:Unhook(method)
            end
        end
    end

    -- Props
    ------------------------------------------------------------>>
    template.name = "Chatbox"
    template.chatboxes = template:GetChatFrames()
    template.socialFrame = _G["QuickJoinToastButton"]
    template.combatLogFrame = _G["CombatLogQuickButtonFrame_Custom"]

    return template
end

function ChatboxTemplate:Embed(target)
    LibStub("AceHook-3.0"):Embed(target)
end