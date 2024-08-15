local Welcome = HideUI:NewModule("Welcome")
local Menu



function Welcome:OnInitialize()
    Menu = HideUI:GetModule("Menu")
end

function Welcome:OnEnable()
    self:Draw()
end

function Welcome:Draw()
    local parent = Menu
    -- Bienvenida del addon, su versión, autor, fecha, breve descripción y tutorial.
    -- Si hay patreon o donaciones, los nombres y reino de todos los colaboradores.
end