local Builder = HideUI:NewModule("Builder")

function Builder:OnInitialize()
end

function Builder:OnEnable()
end

-----------------------------------------------------------------
-- Documentación Importante
-----------------------------------------------------------------
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingControls.xml
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingControls.lua

function Builder:Unpack(tbl)
    local unpack = table.unpack or unpack --Compatibilidad
    return unpack(tbl)
end

function Builder:UnpackTransforms(transform)
    local x, y, w, h = 0, 0, 1, 1
    if transform then
        x, y, w, h = self:Unpack(transform)
    end
    return x, y, w, h
end

function Builder:SetTransform(frame, transform)
    local x, y, w, h = self:UnpackTransforms(transform)
    if w then
        frame:SetWidth(w)
    end
    if h then
        frame:SetHeight(h)
    end
    frame:SetPoint("TOPLEFT", x, y)
end

function Builder:EditTransform(transform, args)
    args = args or {}
    local bindings = {x=1, y=2, w=3, h=4}
    local index
    for k, v in pairs(args) do
        index = bindings[k]
        if index then
            transform[index] = v
        end
    end

    return transform
end

function Builder:CreateTransform(args)
    args = args or {}
    local x = args.x or 0
    local y = args.y or 0
    local w = args.w or 1
    local h = args.h or 1

    return {x, y, w, h}
end

function Builder:FixTo(frame, to, transform)
    local x, y = self:UnpackTransforms(transform)
    frame:SetPoint("TOPLEFT", to, "BOTTOMLEFT", x, y)
end

function Builder:GetLastElement(container)
    local children = {container:GetChildren()}
    local lastChild

    for _, child in ipairs(children) do
        child.index = child.index or 0
        if not lastChild or child.index > lastChild.index then
            lastChild = child
        end
    end

    if lastChild then
        return lastChild.index, lastChild
    else
        return 0
    end
end

function Builder:GetContainerHeight(container)
    local children = {container:GetChildren()}
    local containerHeight = 0
    for _, child in ipairs(children) do
        local _, _, _, _, offsetY = child:GetPoint()
        local height = child:GetHeight()
        
        containerHeight = containerHeight + (math.abs(offsetY) + height)
        -- containerHeight = height - offsetY -- older
    end

    return containerHeight
end

function Builder:GetIndex(frame)
    return frame.index or 0
end

function Builder:SetIndex(frame)
    local parent = frame:GetParent()
    frame.index = self:GetLastElement(parent) + 1
end

function Builder:GetNextChild(frame)
    local container = frame:GetParent()
    local children = {container:GetChildren()}
    local index = self:GetIndex(frame)
    for _, child in ipairs(children) do
        local childIndex = self:GetIndex(child)
        if (index + 1) == childIndex then
            return child
        end
    end

    return nil --No hay siguiente...
end

function Builder:RegisterVariable(tbl, frame, var_name)
    tbl[var_name] = frame
end

function Builder:SetVariableData(tbl, var_name, data)
    local frame = tbl[var_name]
    local name  = frame:GetName()

    if name == "HideUICheckboxSlider" then
        if type(data) == "number" then
            frame.SliderFrame.Slider:SetValue(data)
        elseif type(data) == "boolean" then
            frame.Checkbox:SetChecked(data)
        end
    elseif name == "HideUICheckbox" then
        frame.Checkbox:SetChecked(data)
    elseif name == "HideUISlider" then
        frame.SliderFrame.Slider:SetValue(data)
    end
end

function Builder:GetVariableData(tbl, var_name)
    local frame = tbl[var_name]
    local name  = frame:GetName()

    if name == "HideUICheckbox" then
        return frame.Checkbox:GetChecked()
    elseif name == "HideUISlider" then
        return frame.SliderFrame.Slider:GetValue()
    elseif name == "HideUICheckboxSlider" then
        return frame.Checkbox:GetChecked(), frame.SliderFrame.Slider:GetValue()
    end

    return nil
end

-----------------------------------------------------------------
-- Subcategory
-----------------------------------------------------------------
function Builder:CreateLayoutSubcategory(category, name)
    local frame = CreateFrame("Frame", "HideUI" .. name .. "Frame", UIParent)
    local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, name)
    frame.name = name
    return subcategory, layout, frame
end

-----------------------------------------------------------------
-- Scroll
-----------------------------------------------------------------
function Builder:CreateScrollContainer(parent_frame, transform, fill)
    local scrollFrame = CreateFrame("ScrollFrame", "HideUIScroll", parent_frame, "HideUIScrollFrameTemplate")
    self:SetTransform(scrollFrame, transform)

    if fill then
        scrollFrame:SetPoint("BOTTOMRIGHT")
    end

    local scrollChild = scrollFrame:GetScrollChild()

    --Lo único que se me ocurre para este calvario...
    local width = UIParent:GetWidth() * 0.344

    scrollChild:SetSize(width, 1)
    scrollChild:SetPoint("TOPLEFT")
    scrollChild:SetPoint("BOTTOMRIGHT")

    return scrollChild, scrollFrame
end

-----------------------------------------------------------------
-- Header
-----------------------------------------------------------------
function Builder:CreateCategoryHeader(parent_frame, name, func)
    local headerFrame = CreateFrame("Frame", "HideUIHeader", parent_frame, "HideUIHeaderTemplate")
    headerFrame:SetHeight(50)
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT")

    headerFrame.Header.Title:SetText(name)
    headerFrame.Header.DefaultsButton:SetText("Defaults")
    headerFrame.Header.DefaultsButton:SetScript("OnClick", func)
end

-----------------------------------------------------------------
-- Empty Section
-----------------------------------------------------------------
function Builder:CreateEmptySection(parent_frame, transform, relativeTo)
    local sectionFrame = CreateFrame("Frame", "HideUIEmptySection", parent_frame, "HideUIEmptySectionTemplate")
    self:SetTransform(sectionFrame, transform)
    self:SetIndex(sectionFrame)

    self:CalculateWidth(sectionFrame, parent_frame)

    if relativeTo then
        transform = self:CreateTransform(transform)
        self:FixTo(sectionFrame, relativeTo, transform)
    end

    return sectionFrame
end

-----------------------------------------------------------------
-- Default Section
-----------------------------------------------------------------
function Builder:CreateSection(parent_frame, name, transform, relativeTo)
    local sectionFrame = CreateFrame("Frame", "HideUISection", parent_frame, "HideUISectionTemplate")
    self:SetTransform(sectionFrame, transform)
    self:SetIndex(sectionFrame)
    sectionFrame.Header.Title:SetText(name)
    
    self:CalculateWidth(sectionFrame, parent_frame)

    if relativeTo then
        transform = self:CreateTransform(transform)
        self:FixTo(sectionFrame, relativeTo, transform)
    end

    return sectionFrame
end

-----------------------------------------------------------------
-- Expandable Section
-----------------------------------------------------------------
function Builder:CreateExpandableSection(parent_frame, name, transform, relativeTo)
    local sectionFrame = CreateFrame("Frame", "HideUIExpandableSection", parent_frame, "HideUIExpandableSectionTemplate")
    local xOffset = 10 --Mueve un poco hacia la derecha

    transform = self:CreateTransform(transform)
    transform = self:EditTransform(transform, {x = xOffset})

    self:SetTransform(sectionFrame, transform)
    self:SetIndex(sectionFrame)

    sectionFrame.Container:SetHeight(0) --Default Hide

    sectionFrame.Button.Text:SetText(name)
    sectionFrame.Button.expanded = false

    sectionFrame.Button:SetScript("OnClick", function(button, buttonName, down)
        button.expanded = not button.expanded
        self:OnExpandedChange(sectionFrame, button.expanded)
    end)

    self:CalculateWidth(sectionFrame, parent_frame)

    if relativeTo then
        self:FixTo(sectionFrame, relativeTo, transform)
    end

    return sectionFrame
end

function Builder:OnExpandedChange(sectionFrame, expanded)
    local button = sectionFrame.Button
    local container = sectionFrame.Container
    local nextFrame = self:GetNextChild(sectionFrame)

    if expanded then
        button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize)
        self:CalculateHeight(sectionFrame)
        if nextFrame then
            local offset = -28
            self:FixTo(nextFrame, sectionFrame, {0, offset})
        end
    else
        button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize)
        if nextFrame then
            local parentHeight = sectionFrame:GetHeight() - container:GetHeight()
            sectionFrame:SetHeight(parentHeight)
            self:FixTo(nextFrame, sectionFrame)
        end
        container:SetHeight(0)
    end
end

-----------------------------------------------------------------
-- Section Utils
-----------------------------------------------------------------
function Builder:InsertElementToSection(section, frame, transform)
    frame:SetParent(section.Container)
    frame:ClearAllPoints()

    local x, y = self:UnpackTransforms(transform)
    frame:SetPoint("TOPLEFT", section.Container, x, y)

    frame.index = self:GetLastElement(section.Container) + 1
end

function Builder:CalculateHeight(sectionFrame)
    local type = sectionFrame:GetName()
    if type == "HideUISection" then
        self:CalculateSectionHeight(sectionFrame)
    elseif type == "HideUIEmptySection" then
        self:CalculateEmptySectionHeight(sectionFrame)
    elseif type == "HideUIExpandableSection" then
        self:CalculateExpandableSectionHeight(sectionFrame)
    end
end

function Builder:CalculateSectionHeight(sectionFrame)
    local headerHeight = sectionFrame.Header:GetHeight()
    local containerHeight = self:GetContainerHeight(sectionFrame.Container)
    local total = headerHeight + containerHeight
    sectionFrame.Container:SetHeight(containerHeight)
    sectionFrame:SetHeight(total)
end

function Builder:CalculateEmptySectionHeight(sectionFrame)
    local containerHeight = self:GetContainerHeight(sectionFrame.Container)
    sectionFrame.Container:SetHeight(containerHeight)
    sectionFrame:SetHeight(containerHeight)
end

function Builder:CalculateExpandableSectionHeight(sectionFrame)
    local buttonHeight = sectionFrame.Button:GetHeight()
    local containerHeight = self:GetContainerHeight(sectionFrame.Container)
    local total = buttonHeight + containerHeight
    sectionFrame.Container:SetHeight(containerHeight)
    sectionFrame:SetHeight(total)
end

function Builder:CalculateWidth(frame, parent)
    local parent_width = parent:GetWidth()
    frame:SetWidth(parent_width)
    frame.Container:SetWidth(parent_width)
end

-----------------------------------------------------------------
-- Tooltip
-----------------------------------------------------------------
function Builder:CreateTooltip(frame, name, text)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(name)

        if text then
            GameTooltip:AddLine(text, 1, 1, 1, true)
        end

        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-----------------------------------------------------------------
-- Checkbox
-----------------------------------------------------------------
function Builder:CreateCheckbox(parent_frame, name, transform, update, tooltip, default, frame_name)
    transform = transform or {0, 0}
    default = default or false
    update  = update or function() end
    frame_name = frame_name or "HideUICheckbox"

    -- Checkbox Container
    local checkboxControl = CreateFrame("Frame", frame_name, parent_frame, "HideUICheckboxControlTemplate")
    self:SetTransform(checkboxControl, transform)
    self:SetIndex(checkboxControl)

    -- Checkbox name
    checkboxControl.Text:SetText(name)
    checkboxControl.Text:SetPoint("LEFT", checkboxControl, "LEFT", 45, -3)
    checkboxControl.Text:SetWidth(200)
    checkboxControl.Text:SetMaxLines(1)
    checkboxControl.Text:SetNonSpaceWrap(false)

    -- Checkbox button
    local checkbox = CreateFrame("CheckButton", nil, checkboxControl, "HideUICheckboxTemplate")
    checkbox:SetPoint("LEFT", parent_frame, "CENTER", -85, 0)
    checkbox:SetPoint("TOP", checkboxControl, "TOP", 0, 0)
    checkbox:SetChecked(default)
    checkbox:SetScript("OnClick", function()
        update(checkbox, checkbox:GetChecked())
    end)

    -- Tooltip
    self:CreateTooltip(checkboxControl, name, tooltip)

    checkboxControl.Checkbox = checkbox
    return checkboxControl
end

-----------------------------------------------------------------
-- Slider
-----------------------------------------------------------------
function Builder:SliderSettingsInitializer(default, step, min, max)
    default = default or 0.5
    step = step or 0.01
    min = min or 0
    max = max or 1

    return {default, step, min, max}
end

function Builder:CreateSliderFrame(sliderControl, update, default, step, min, max)
    local parent_frame = sliderControl:GetParent()

    --Slider frame
    local sliderFrame = CreateFrame("Frame", nil, sliderControl, "HideUISliderTemplate")
    sliderFrame:SetPoint("LEFT", parent_frame, "CENTER", -85, 0)
    sliderFrame:SetPoint("TOP", sliderControl, "TOP", 0, 0)

    local rightText = sliderFrame.RightText
    if rightText then
        rightText:SetText(tostring(max * 100) .. "%")
        rightText:Show()
    end

    --Slider
    local slider = sliderFrame.Slider
    if slider then
        slider:SetMinMaxValues(min, max)
        slider:SetValue(default) --Usar esto para actualizar su valor
        slider:SetValueStep(step)
        slider:SetScript("OnValueChanged", update)
    end

    --Slider Arrows
    local backButton = sliderFrame.Back
    if backButton then
        backButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue - step)
        end)
    end

    local forwardButton = sliderFrame.Forward
    if forwardButton then
        forwardButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue + step)
        end)
    end

    return sliderFrame
end

function Builder:CreateSlider(parent_frame, name, transform, update, tooltip, slider_settings)
    transform = transform or {0, 0}
    update = update or function() end
    slider_settings = slider_settings or self:SliderSettingsInitializer()
    local default, step, min, max = self:Unpack(slider_settings)

    --Slider Container
    local sliderControl = CreateFrame("Frame", "HideUISlider", parent_frame, "HideUISliderControlTemplate")
    self:SetTransform(sliderControl, transform)
    self:SetIndex(sliderControl)

    --Slider Text
    sliderControl.Text:SetText(name)
    sliderControl.Text:SetPoint("LEFT", sliderControl, "LEFT", 45, -9)
    sliderControl.Text:SetWidth(201)
    sliderControl.Text:SetMaxLines(1)
    sliderControl.Text:SetNonSpaceWrap(false)

    --Slider Controller
    sliderControl.SliderFrame = self:CreateSliderFrame(sliderControl, update, default, step, min, max)

    -- Tooltip
    self:CreateTooltip(sliderControl, name, tooltip)

    return sliderControl
end

-----------------------------------------------------------------
-- Checkbox Slider
-----------------------------------------------------------------
function Builder:CreateCheckboxSlider(parent_frame, name, transform, update, tooltip, checkbox_default, slider_settings)
    checkbox_default = checkbox_default or false
    transform = transform or {0, 0}
    update = update or function() end
    slider_settings = slider_settings or self:SliderSettingsInitializer()
    local slider_default, step, min, max = self:Unpack(slider_settings)
    local frame_name = "HideUICheckboxSlider"

    local checkbox_update = function(checkbox, checked)
        local sliderFrame = checkbox:GetParent().SliderFrame
        if checked then
            sliderFrame:SetEnable()
        else
            sliderFrame:SetDisable()
        end
        update(checkbox, checked)
    end

    local checkboxControl = self:CreateCheckbox(parent_frame, name, transform, checkbox_update, tooltip, checkbox_default, frame_name)
    local sliderFrame = self:CreateSliderFrame(checkboxControl, update, slider_default, step, min, max)

    sliderFrame:ClearAllPoints()
    sliderFrame:SetPoint("LEFT", parent_frame, "CENTER", -50, 0)
    sliderFrame:SetPoint("TOP", checkboxControl, "TOP", 0, 5)
    sliderFrame:SetWidth(215)

    sliderFrame.SetEnable = function(self)
        self:SetAlpha(1)
        self.Slider:Enable()
        self.Slider:SetAlpha(1)
    end

    sliderFrame.SetDisable = function(self)
        self:SetAlpha(0.4)
        self.Slider:Disable()
        self.Slider:SetAlpha(0.4)
    end

    if checkbox_default then
        sliderFrame:SetEnable()
    else
        sliderFrame:SetDisable()
    end

    checkboxControl.SliderFrame = sliderFrame
    return checkboxControl
end

-----------------------------------------------------------------
-- Quick Add
-----------------------------------------------------------------
function Builder:RegisterSettings(args)
    return {
        data = args.data,
        func = args.func,
        type = args.type,
        name = args.name,
        variable = args.variable,
        tooltip = args.tooltip,
        default = args.default,
        slider_default = args.slider_default,
        step = args.step,
        min = args.min,
        max = args.max
    }
end

function Builder:AddElementToSection(section, settings, relativeTo, transform)
    local element
    local slider_settings

    local update = function(element, data)
        self:SetVariableData(settings.data, settings.variable, data)
        settings.func(settings.variable, data)
    end

    if settings.type == "slider" then
        local default = settings.default or settings.slider_default
        slider_settings = self:SliderSettingsInitializer(default, settings.step, settings.min, settings.max)
        element = self:CreateSlider(section, settings.name, nil, update, settings.tooltip, slider_settings)
    elseif settings.type == "checkbox" then
        element = self:CreateCheckbox(section, settings.name, nil, update, settings.tooltip, settings.default)
    elseif settings.type == "checkboxSlider" then
        slider_settings = self:SliderSettingsInitializer(settings.slider_default, settings.step, settings.min, settings.max)
        element = self:CreateCheckboxSlider(section, settings.name, nil, update, settings.tooltip, settings.default, slider_settings)
    end

    transform = self:CreateTransform(transform)

    if relativeTo then
        self:InsertElementToSection(section, element)
        self:FixTo(element, relativeTo, transform)
    else
        self:InsertElementToSection(section, element, transform)
    end

    self:RegisterVariable(settings.data, element, settings.variable)

    return element
end