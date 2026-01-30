local Welcome = HideUI:NewModule("Welcome")
local UIManager

function Welcome:OnInitialize()
    UIManager = HideUI:GetModule("UIManager")
end

function Welcome:OnEnable()
    self:Draw()
end

function Welcome:Draw()
    local parent = UIManager
    -- Bienvenida del addon, su versión, autor, fecha, breve descripción y tutorial.
    -- Si hay patreon o donaciones, los nombres y reino de todos los colaboradores.
end