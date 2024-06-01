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