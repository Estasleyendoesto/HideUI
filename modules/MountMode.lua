local MountMode = HideUI:NewModule("MountMode", "AceEvent-3.0")

function MountMode:OnEnable()
    self:RegisterEvent("UNIT_AURA", "CheckForMount")
    self.isMounted = false
    self:CheckForMount(nil, "player")
end

function MountMode:OnDisable()
    self:UnregisterEvent("UNIT_AURA")
    self:SendMessage("PLAYER_MOUNT_STATE_CHANGED", false)
end

function MountMode:CheckForMount(msg, unit)
    if unit == "player" then
        if IsMounted() then
            if not self.isMounted then
                self.isMounted = true
                self:SendMessage("PLAYER_MOUNT_STATE_CHANGED", true)
            end
        else
            if self.isMounted then
                self.isMounted = false
                self:SendMessage("PLAYER_MOUNT_STATE_CHANGED", false)
            end
        end
    end
end