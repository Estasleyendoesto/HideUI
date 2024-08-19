
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
-- https://www.townlong-yak.com/framexml/live/Blizzard_SharedXML/SharedUIPanelTemplates.xml#1489

-----------------------------------------------------------------
-- Utils
-----------------------------------------------------------------
function Builder:CreateTransform(args)
    args = args or {}
    local x = args.x or 0
    local y = args.y or 0
    local w = args.w or 1
    local h = args.h or 1

    return {x=x, y=y, w=w, h=h}
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

function Builder:SetIndex(frame)
    local parent = frame:GetParent()
    frame.index = self:GetLastElement(parent) + 1
    return frame.index
end

function Builder:GetIndex(frame)
    return frame.index or 0
end

function Builder:CalculateWidth(frame, noSet)
    local parent = frame:GetParent()
    local width = parent:GetWidth()

    noSet = noSet or false
    if not noSet then
        frame:SetWidth(width)
        if frame.Container then
            frame.Container:SetWidth(width)
        end
    end

    return width
end

function Builder:CalculateHeight(frame, noSet)
    local height = 0
    local extra  = 0
    local total

    if frame.Header then
        local _, _, _, _, offsetY = frame.Header:GetPoint()
        extra = math.abs(offsetY) + frame.Header:GetHeight() + extra
    end
    if frame.Button then
        local _, _, _, _, offsetY = frame.Button:GetPoint()
        extra = math.abs(offsetY) + frame.Button:GetHeight() + extra
    end
    if frame.Container then
        local children = {frame.Container:GetChildren()}
        for _, child in ipairs(children) do
            local _, _, _, _, offsetY = child:GetPoint()
            height = math.abs(offsetY) + child:GetHeight() + height
        end
    end

    total = height + extra

    noSet = noSet or false
    if not noSet then
        frame:SetHeight(total)
        if frame.Container then
            frame.Container:SetHeight(height)
        end
    end

    return total, height, extra
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

function Builder:FixTo(frame, relativeTo, transform)
    frame:ClearAllPoints()
    transform = self:CreateTransform(transform)
    if relativeTo then
        frame:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", transform.x, transform.y)
    else
        frame:SetPoint("TOPLEFT", transform.x, transform.y)
    end
end

function Builder:Debug(frame, channel)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(channel.r or 0, channel.g or 0, channel.b or 0, 0.25)
    frame.bg = bg
end

function Builder:Unpack(tbl)
    local unpack = table.unpack or unpack --Compatibilidad
    return unpack(tbl)
end

function Builder:RegisterVariable(tbl, variable_name, element)
    if tbl and variable_name and element then
        tbl[variable_name] = element
    end
end

function Builder:SetVariableData(tbl, variable_name, data)
    local frame = tbl[variable_name]
    local name  = frame:GetName()

    if name == "HideUICheckboxSlider" then
        if type(data) == "number" then
            frame.Sliderbox.Slider:SetValue(data)
        elseif type(data) == "boolean" then
            frame.Checkbox:SetChecked(data)
            if data then
                frame.Sliderbox:SetEnable()
            else
                frame.Sliderbox:SetDisable()
            end
        end
    elseif name == "HideUICheckbox" then
        frame.Checkbox:SetChecked(data)
    elseif name == "HideUISlider" then
        frame.Sliderbox.Slider:SetValue(data)
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

function Builder:GetElementByVariable(tbl, variable)
    return tbl[variable]
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
function Builder:CreateScrollContainer(parent, transform, fill)
    local scrollFrame = CreateFrame("ScrollFrame", "HideUIScroll", parent, "HideUIScrollFrameTemplate")

    transform = self:CreateTransform(transform)
    scrollFrame:SetPoint("TOPLEFT", transform.x, transform.y)

    fill = fill or true
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
function Builder:CreateCategoryHeader(name, parent, func)
    local headerFrame = CreateFrame("Frame", "HideUIHeader", parent, "HideUIHeaderTemplate")
    headerFrame:SetHeight(50)
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT")

    headerFrame.Header.Title:SetText(name)
    headerFrame.Header.DefaultsButton:SetText("Defaults")
    headerFrame.Header.DefaultsButton:SetScript("OnClick", func)

    headerFrame.SetEnable = function()
        headerFrame.Header.DefaultsButton:Enable()
    end
    headerFrame.SetDisable = function()
        headerFrame.Header.DefaultsButton:Disable()
    end

    return headerFrame
end

-----------------------------------------------------------------
-- Sections
-----------------------------------------------------------------
function Builder:CreateSection(name, type, parent, relativeTo, transform)
    local section
    
    if type == "empty" then
        section = self:CreateEmptySection(parent, relativeTo, transform)
    elseif type == "header" then
        section = self:CreateHeaderSection(name, parent, relativeTo, transform)
    elseif type == "expandable" then
        section = self:CreateExpandableSection(name, parent, relativeTo, transform)
    end

    return section
end

function Builder:CreateEmptySection(parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUIEmptySection", parent, "HideUIEmptySectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    if transform and transform.h then
        section:SetHeight(transform.h)
    end

    -- Toggle
    section.SetEnable = function() end
    section.SetDisable = function() end

    return section
end

function Builder:CreateHeaderSection(name, parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUISection", parent, "HideUISectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    -- Toggle
    section.SetEnable = function() end
    section.SetDisable = function() end

    section.Header.Title:SetText(name)

    return section
end

function Builder:CreateExpandableSection(name, parent, relativeTo, transform)
    local section = CreateFrame("Frame", "HideUIExpandableSection", parent, "HideUIExpandableSectionTemplate")
    self:CalculateWidth(section)
    self:CalculateHeight(section)
    self:SetIndex(section)
    self:FixTo(section, relativeTo, transform)

    -- Container Visibility
    section.HideContainer = function()
        local height = section:GetHeight() - section.Container:GetHeight()
        section:SetHeight(height)
        section.Container:SetHeight(0)
        section.Container:Hide()
    end
    section.ShowContainer = function()
        self:CalculateHeight(section)
        section.Container:Show()
    end

    -- Toggle
    section.SetEnable = function()
        section.Button:Enable()
    end
    section.SetDisable = function()
        section.Button:Disable()
        Builder:OnExpandedChange(section, false)
    end

    section.Button.Text:SetText(name)
    -- Text Flag
    section.Shutdown = function()
        section.Button.Text:SetTextColor(1, 1, 1, 0.7)
        section:SetAlpha(0.8)
    end
    section.SwitchOn = function()
        section.Button.Text:SetTextColor(1, 0.84, 0, 1)
        section:SetAlpha(1)
    end

    -- Expanded function
    section.Button.expanded = false
    section.Button:SetScript("OnClick", function(button)
        button.expanded = not button.expanded
        self:OnExpandedChange(section, button.expanded)
    end)

    return section
end

function Builder:OnExpandedChange(section, expanded)
    local button = section.Button
    if expanded then
        section:ShowContainer()
        button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize)
    else
        section:HideContainer()
        button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize)
    end
end

function Builder:SetExpandableState(registry, variable, enabled)
    local element = self:GetElementByVariable(registry, variable)
    local container = element:GetParent()
    local section = container:GetParent()

    if enabled then
        section:SwitchOn()
    else
        section:Shutdown()
    end

    local elements = {container:GetChildren()}
    for _, child_element in ipairs(elements) do
        if child_element ~= element then
            if enabled then
                child_element:SetEnable()
            else
                child_element:SetDisable()
            end
        end
    end
end

function Builder:ClearSection(section)
    local elements = {section:GetChildren()}
    for _, child_element in ipairs(elements) do
        child_element:Hide()
        child_element:SetParent(nil)
        child_element = nil
    end
end

-----------------------------------------------------------------
-- Quick Elements
-----------------------------------------------------------------
function Builder:RegisterSettings(args, defaults)
    local settings = {}
    for k, v in pairs(defaults or {}) do
        settings[k] = v
    end
    for k, v in pairs(args) do
        settings[k] = v
    end

    return settings
end

function Builder:AddElementToSection(section, settings, relativeTo, transform)
    local element
    local container = section.Container
    local slider_settings = {
        default = settings.slider_default,
        step = settings.step,
        min = settings.min,
        max = settings.max,
        unit = settings.unit
    }
    
    local checkbox_slider
    if settings.type == "checkbox_slider" then
        local base_name = settings.variable:match("^(.+)_checkbox_slider$")
        if base_name then
            checkbox_slider = {base_name .. "_checkbox", base_name .. "_slider"}
        end
    end
    
    local update = function(element, data)
        if checkbox_slider then
            local select
            if type(data) == "boolean" then
                select = checkbox_slider[1]
            else
                select = checkbox_slider[2]
            end
            self:SetVariableData(settings.data, select, data)
            settings.update(nil, select, data)
        else
            self:SetVariableData(settings.data, settings.variable, data)
            settings.update(nil, settings.variable, data) --nil -> evita el self
        end
    end

    -- Offset extra
    local yOffset = -5
    transform = transform or {}
    transform = {y = (transform.y or 0) + yOffset}
    
    if settings.type == "checkbox" then
        element = self:CreateCheckbox(settings.name, container, relativeTo, transform, update, settings.tooltip, settings.default)
    elseif settings.type == "slider" then
        element = self:CreateSlider(settings.name, container, relativeTo, transform, update, settings.tooltip, slider_settings)
    elseif settings.type == "checkbox_slider" then
        element = self:CreateCheckboxSlider(settings.name, container, relativeTo, transform, update, settings.tooltip, settings.default, slider_settings)
    elseif settings.type == "separator" then
        element = self:CreateSeparator(container, relativeTo, transform)
    end

    self:CalculateHeight(section)

    if checkbox_slider then
        self:RegisterVariable(settings.data, checkbox_slider[1], element)
        self:RegisterVariable(settings.data, checkbox_slider[2], element)
    else
        self:RegisterVariable(settings.data, settings.variable, element)
    end

    if section:GetName() == "HideUIExpandableSection" then
        Builder:OnExpandedChange(section, expanded)
    end

    return element
end

-----------------------------------------------------------------
-- Tooltip
-----------------------------------------------------------------
function Builder:CreateTooltip(frame, name, text)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(name, 1, 1, 1)

        if text then
            GameTooltip:AddLine(text, 1, 0.84, 0, true)
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
function Builder:CreateCheckbox(name, parent, relativeTo, transform, update, tooltip, default, frame_name)
    default = default or false
    update  = update or function() end
    frame_name = frame_name or "HideUICheckbox"

    -- Checkbox Container
    local control = CreateFrame("Frame", frame_name, parent, "HideUICheckboxControlTemplate")
    self:SetIndex(control)
    self:FixTo(control, relativeTo, transform)

    -- Checkbox text
    control.Text:SetText(name)
    control.Text:SetPoint("LEFT", control, "LEFT", 45, 0)
    control.Text:SetWidth(180)
    control.Text:SetMaxLines(1)
    control.Text:SetNonSpaceWrap(false)

    -- Checkbox button
    local checkbox = CreateFrame("CheckButton", nil, control, "HideUICheckboxTemplate")
    checkbox:SetPoint("LEFT", parent, "CENTER", -85, 0)
    checkbox:SetPoint("TOP", control, "TOP", 0, 0)
    checkbox:SetChecked(default)
    checkbox:SetScript("OnClick", function() update(checkbox, checkbox:GetChecked()) end)

    control.SetEnable = function()
        control:SetAlpha(1)
        control.Checkbox:SetAlpha(1)
        control.Checkbox:Enable()
    end
    control.SetDisable = function()
        control:SetAlpha(0.4)
        control.Checkbox:SetAlpha(0.4)
        control.Checkbox:Disable()
    end

    -- Tooltip
    self:CreateTooltip(control.Text, name, tooltip)

    control.Checkbox = checkbox
    return control
end

-----------------------------------------------------------------
-- Slider
-----------------------------------------------------------------
function Builder:SliderSettingsInitializer(args)
    local default = args.default or 1
    local step = args.step or 0.01
    local min = args.min or 0
    local max = args.max or 1
    local unit = args.unit or "%"

    return {default, step, min, max, unit}
end

function Builder:CreateSliderbox(control, update, default, step, min, max, unit)
    local parent = control:GetParent()

    --Slider frame
    local sliderbox = CreateFrame("Frame", nil, control, "HideUISliderTemplate")
    sliderbox:SetPoint("LEFT", parent, "CENTER", -85, 0)
    sliderbox:SetPoint("TOP", control, "TOP", 0, 0)

    sliderbox.DefineText = function(text, value)
        if text == "%" then
            value = value * 100
            text = string.format("%.0f", value) .. text
        else
            text = string.format("%.1f", value) .. text
        end
        sliderbox.RightText:SetText(text)
        return text
    end
        
    local text = sliderbox.RightText
    if text then
        sliderbox.DefineText(unit, default)
        text:Show()
    end

    --Slider
    local slider = sliderbox.Slider
    if slider then
        slider:SetMinMaxValues(min, max)
        slider:SetValue(default) --Usar esto para actualizar su valor
        slider:SetValueStep(step)
        slider:SetScript("OnValueChanged", function(slider, value)
            sliderbox.DefineText(unit, value)

            local minimum = min + step
            local maximum = max - step

            if value > min and value < max then
                value = tonumber(string.format("%.2f", value))
                update(slider, value)
            end
        end)
    end

    --Slider Arrows
    local backButton = sliderbox.Back
    if backButton then
        backButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue - step)
            sliderbox.DefineText(unit, slider:GetValue())
        end)
    end

    local forwardButton = sliderbox.Forward
    if forwardButton then
        forwardButton:SetScript("OnClick", function()
            local currentValue = slider:GetValue()
            slider:SetValue(currentValue + step)
            sliderbox.DefineText(unit, slider:GetValue())
        end)
    end

    sliderbox.SetEnable = function()
        sliderbox:SetAlpha(1)
        sliderbox.Slider:Enable()
        sliderbox.Back:Enable()
        sliderbox.Forward:Enable()
    end
    sliderbox.SetDisable = function()
        sliderbox:SetAlpha(0.4)
        sliderbox.Slider:Disable()
        sliderbox.Back:Disable()
        sliderbox.Forward:Disable()
    end

    return sliderbox
end

function Builder:CreateSlider(name, parent, relativeTo, transform, update, tooltip, slider_settings)
    update = update or function() end
    slider_settings = self:SliderSettingsInitializer(slider_settings)

    --Slider Container
    local control = CreateFrame("Frame", "HideUISlider", parent, "HideUISliderControlTemplate")
    self:SetIndex(control)
    self:FixTo(control, relativeTo, transform)

    --Slider Text
    control.Text:SetText(name)
    control.Text:SetPoint("LEFT", control, "LEFT", 45, 0)
    control.Text:SetWidth(201)
    control.Text:SetMaxLines(1)
    control.Text:SetNonSpaceWrap(false)

    --Slider Controller
    local sliderbox = self:CreateSliderbox(
        control,
        update,
        self:Unpack(slider_settings)
    )

    control.SetEnable = function()
        control:SetAlpha(1)
        control.Sliderbox.SetEnable()
    end
    control.SetDisable = function()
        control:SetAlpha(0.4)
        control.Sliderbox.SetDisable()
    end

    -- Tooltip
    self:CreateTooltip(control.Text, name, tooltip)

    control.Sliderbox = sliderbox
    return control
end

-----------------------------------------------------------------
-- Checkbox Slider
-----------------------------------------------------------------
function Builder:CreateCheckboxSlider(name, parent, relativeTo, transform, update, tooltip, checkbox_default, slider_settings)
    local frame_name = "HideUICheckboxSlider"
    update = update or function() end
    slider_settings = self:SliderSettingsInitializer(slider_settings)
    
    local checkbox_update = function(checkbox, checked)
        local sliderbox = checkbox:GetParent().Sliderbox
        if checked then
            sliderbox:SetEnable()
        else
            sliderbox:SetDisable()
        end
        update(checkbox, checked)
    end

    local control = self:CreateCheckbox(name, parent, relativeTo, transform, checkbox_update, tooltip, checkbox_default, frame_name)
    control:SetWidth(545)

    local sliderbox = self:CreateSliderbox(control, update, self:Unpack(slider_settings))
    sliderbox:ClearAllPoints()
    sliderbox:SetPoint("LEFT", parent, "CENTER", -50, 0)
    sliderbox:SetPoint("TOP", control, "TOP", 0, 0)
    sliderbox:SetWidth(215)

    local originalEnable = control.SetEnable
    local originalDisable = control.SetDisable
    control.SetEnable = function()
        originalEnable()

        if control.Checkbox:GetChecked() then
            control.Sliderbox:SetEnable()
        end
    end
    control.SetDisable = function()
        originalDisable()
        if control.Checkbox:GetChecked() then
            control.Sliderbox:SetDisable()
        end
    end

    if checkbox_default then
        sliderbox:SetEnable()
    else
        sliderbox:SetDisable()
    end

    control.Sliderbox = sliderbox
    return control
end

-----------------------------------------------------------------
-- Popup Dialog
-----------------------------------------------------------------
function Builder:CreatePopupDialog(func)
    func = func or function() end
    StaticPopupDialogs["HIDEUI_CONFIRM_DIALOG"] = {
        text = "Are you sure you want to proceed?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function() func(true) end,
        OnCancel = function() func(false) end,
        timeout = 0,
        whileDead = false,
        hideOnEscape = true,
    }
    StaticPopup_Show("HIDEUI_CONFIRM_DIALOG")
end

-----------------------------------------------------------------
-- Separator
-----------------------------------------------------------------
function Builder:CreateSeparator(parent, relativeTo, transform)
    local separator = CreateFrame("Frame", "HideUISeparator", parent)
    separator:SetHeight(1)
    self:CalculateWidth(separator, true)
    self:SetIndex(separator)
    self:FixTo(separator, relativeTo, transform)

    separator.SetEnable = function() end
    separator.SetDisable = function() end

    return separator
end

-----------------------------------------------------------------
-- SearchBox
-----------------------------------------------------------------
function Builder:CreateSearchBox(parent, transform, func, tooltip)
    local control = CreateFrame("Frame", "HideUISearchBox", parent, "HideUISearchBoxTemplate")
    self:SetIndex(control)
    self:FixTo(control, nil, transform)

    Builder:CalculateWidth(control)

    local rightTextDelay = 3

    control.InsertButton:SetText("Insert")
    control.RemoveButton:SetText("Remove")

    control.SetTextError = function(text)
        control.RightText:SetText(text)
        control.RightText:SetTextColor(1, 0, 0)
        control.RightText:Show()

        C_Timer.After(rightTextDelay, function()
            control.RightText:Hide()
        end)
    end
    control.SetTextSuccessful = function(text)
        control.RightText:SetText(text)
        control.RightText:SetTextColor(1, 1, 1)
        control.RightText:Show()

        C_Timer.After(rightTextDelay, function()
            control.RightText:Hide()
        end)
    end

    control.InsertButton:SetScript("OnClick", function()
        local input = control.SearchBox:GetText()
        if func then
            func(nil, "add", input, control)
        end
    end)
    control.RemoveButton:SetScript("OnClick", function()
        local input = control.SearchBox:GetText()
        if func then
            func(nil, "remove", input, control)
        end
    end)

    -- Toggle
    control.SetEnable = function()
        control.SearchBox:Enable()
        control.InsertButton:Enable()
        control.RemoveButton:Enable()
    end
    control.SetDisable = function()
        control.RightText:Hide()
        control.SearchBox:Disable()
        control.SearchBox:SetText("")
        control.InsertButton:Disable()
        control.RemoveButton:Disable()
    end

    -- Tooltip
    if tooltip then
        self:CreateTooltip(control.SearchBox, tooltip.name, tooltip.text)
    end

    return control
end