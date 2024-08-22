local Cluster = HideUI:NewModule("Cluster")
local Base

function Cluster:OnInitialize()
    Base = HideUI:GetModule("Base")
end

function Cluster:Create(args, globals)
    -- Contenido que heredará
    local Initial = Base:Create(nil, args, globals)

    function Initial:GetFrames()
    end

    Initial.name = args.name
    Initial.frames = Initial:GetFrames()

    -- Si es un cluster registrado, deriva
    local mod = HideUI:GetModule(args.name, true)
    if mod then
        return mod:Create(Initial)
    else
        return Initial
    end
end