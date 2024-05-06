local DB_mod = HideUI:NewModule("DB_mod")

function DB_mod:Update(name, value)
    self.db.profile[name] = value
end

function DB_mod:Find(name)
    local data = self.db.profile[name]
    if data then
        return data
    else
        print("La variable " .. name .. " no existe")
        return nil
    end
end