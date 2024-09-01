local Cluster = HideUI:NewModule("Cluster")
local Base

function Cluster:OnInitialize()
    Base = HideUI:GetModule("Base")
end

function Cluster:Create(props, globals)
    -- Contenido que heredará
    local Initial = Base:Create(nil, props, globals)

    function Initial:GetFrames()
    end

    Initial.name = props.name
    Initial.frames = Initial:GetFrames()

    -- Si es un cluster registrado, deriva a su modulo ubicado siempre en /Frames si existe
    local mod = HideUI:GetModule(props.name, true)
    if mod then
        return mod:Create(Initial)
    else
        return Initial
    end
end