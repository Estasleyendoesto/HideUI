local _, ns = ...
local Wrapper = gUI:GetModule("FrameWrapper")

ns.StatusTrackingBars = {}

function ns.StatusTrackingBars:OnSetAlpha(obj, frame, alpha)
    local nextState = obj:GetNextState()
    local targetAlpha = nextState and 0.2 or 1.0

    if alpha ~= targetAlpha then
        -- Los responsables de dedicarle tres jodidos modulos a esto
        if frame.FadeInAnimation and frame.FadeInAnimation:IsPlaying() then frame.FadeInAnimation:Stop() end
        if frame.FadeOutAnimation and frame.FadeOutAnimation:IsPlaying() then frame.FadeOutAnimation:Stop() end

        obj.hooks[frame].SetAlpha(frame, targetAlpha)
    end
end

function ns.StatusTrackingBars:Create(name, isVirtual)
    local obj = Wrapper:Create(name, isVirtual)
    
    if obj and obj.frame then
        obj:RawHook(obj.frame, "SetAlpha", function(f, a) 
            ns.StatusTrackingBars:OnSetAlpha(obj, f, a) 
        end, true)

        obj:Refresh()
    end
    
    return obj
end