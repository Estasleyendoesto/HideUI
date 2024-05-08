local Utils_mod = HideUI:NewModule("Utils_mod")

function Utils_mod:OnInitialize()
end

function Utils_mod:FrameExists(frame)
    --Si frame = string o tabla
    if frame then
        if type(frame) == "string" then
            local _frame = _G[frame]
            if _frame then
                return _frame
            end
        else
            return frame
        end
    else
        return nil --No existe
    end
end

function Utils_mod:Batch(dic, func)
    if not func then return end
    if not dic or #dic == 0 then return end
    local finishMsg = nil
    for _, elem in ipairs(dic) do
        if elem then
            local success, error = pcall(func, elem)
            if not success then
                print("Error applying function to element:", error) -- Error handling
            elseif error then
                finishMsg = "break"
                break
            end
        end
    end
    return finishMsg or "end"
end

function Utils_mod:CompareAlpha(frame, alpha)
    if frame and frame:GetAlpha() == alpha then
        return true
    else
        return false
    end
end

function Utils_mod:UpdateAlpha(frame, alpha)
    --Solo realiza el cambio si no son iguales
    if not self:CompareAlpha(frame, alpha) then
        frame:SetAlpha(alpha)
    end
end

function Utils_mod:IsMouseEnter(frame)
    --Cuando el puntero entra al frame
    frame.hideUI = frame.hideUI or {}
    if frame:IsMouseOver() then
        if not frame.hideUI.isMouseEnter then
            frame.hideUI.isMouseEnter = true
        end
    else
        if frame.hideUI.isMouseEnter then
            frame.hideUI.isMouseEnter = false
        end
    end

    return frame.hideUI.isMouseEnter
end

function Utils_mod:IsMouseOut(frame, delay)
    --Cuando el puntero sale del frame, devuelve true hasta "delay"
    frame.hideUI = frame.hideUI or {}
    if frame.hideUI.isMouseEnter then
        frame.hideUI.isMouseOut = false    --Reset
        frame.hideUI.mouseOutTime = nil
    else --Si está fuera
        frame.hideUI.mouseOutTime = frame.hideUI.mouseOutTime or GetTime()
        local elapsedTime = GetTime() - frame.hideUI.mouseOutTime
        if elapsedTime >= delay then --Diferencia de tiempo
            frame.hideUI.isMouseOut = false
        else
            frame.hideUI.isMouseOut = true
        end
    end

    return frame.hideUI.isMouseOut
end

function Utils_mod:InspectFrame(frame)
    if type(frame) ~= "table" then
        print("No es un frame, no es una tabla!")
        return
    end

    for key, value in pairs(frame) do
        local valueType = type(value)
        if valueType == "table" then
            print(key, ": Table")
        elseif valueType == "function" then
            print(key, ": Function")
        else
            print(key, ": " .. tostring(value))
        end
    end
end