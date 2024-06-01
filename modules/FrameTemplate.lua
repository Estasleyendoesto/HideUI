local FrameTemplate = HideUI:NewModule("FrameTemplate")

function FrameTemplate:Create(parent, args, globals)
    local template = {}
    self:Embed(template)

    function template:OnDestroy()
        self:UnregisterAllEvents()
    end

    function template:IsCustomEnabled()
        return args.isEnabled
    end

    function template:OnMouseover()
        if not self.globals.isMouseoverEnabled then return end

        if self:IsOnMouseover(self.parent) then
            print("Mouseover en:", self.name)
        end
    end

    function template:IsOnMouseover(frame)
        if frame and frame:IsVisible() and frame:IsShown() and frame:IsMouseOver() then
            return true
        else
            return false
        end
    end

    template.globals = globals
    template.args = args
    if parent then
        template.parent = parent
        template.name = parent:GetName()
    end

    return template
end

function FrameTemplate:Embed(target)
    LibStub("AceEvent-3.0"):Embed(target)
end



--[[
    Este será un template para cada frame (excluyendo los chats)
    FrameManager se encargará solo de gestionar cada template de los frames de manera global, es decir:
        - Enviando eventos como estados
        - Actualizando sus propiedades tras un cambio en la DB
        - Activando o desactivando sus funcionalidades
        - Enviar el evento de mouseover
        - Comprobar el estado de los frames en la escena (si aparecen en escena o son eliminados)(actualiza el registro de frames)

    Cada Frame tendrá insertado una tabla llamada HideUI y su interior será una instancia de este template,
    Para aquellos frames que puedan contener funcionalidades únicas y propias tendrán su propio módulo que heredará de la plantilla FrameTemplate
]]