local Cluster = Fade:NewModule("Cluster")

function Cluster:Create(Initializer)
    function Initializer:GetFrames()
        return {}
    end

    Initializer.frames = Initializer:GetFrames()

    -- Si es un cluster registrado, deriva a su modulo ubicado siempre en /Frames si existe
    local mod = Fade:GetModule(Initializer.props.name, true)
    if mod then
        return mod:Create(Initializer)
    else
        return Initializer
    end
end
