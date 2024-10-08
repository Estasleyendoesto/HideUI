local Cluster = HideUI:NewModule("Cluster")

function Cluster:Create(initializer)
    -- Contenido que heredará
    local Initial = initializer

    function Initial:GetFrames()
        return {}
    end

    Initial.frames = Initial:GetFrames()

    -- Si es un cluster registrado, deriva a su modulo ubicado siempre en /Frames si existe
    local mod = HideUI:GetModule(initializer.props.name, true)
    if mod then
        return mod:Create(Initial)
    else
        return Initial
    end
end