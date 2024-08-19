-------------------- VARIABLE GENERATION --------------------
function GenerateSavedVariableParent(variableFrame, name)
    local button = CreateFrame("Button", name, variableFrame, "SavedVariablesParentButtonTemplate")
    button.xOffset = 35
    button.yOffset = -75
    button.name = name

    button:SetPoint("TOPLEFT", variableFrame, "TOPLEFT", button.xOffset, button.yOffset)
    button:SetText(name.."               +")
    button:SetNormalFontObject("GameFontNormalCenter")
    button:SetHighlightFontObject("GameFontNormalCenter")
    if name == "Constant Variables" then
        button:SetParentKey("constantVariablesButton")
    else
        button:SetParentKey("dynamicVariablesButton")
    end
    
    button:SetScript("OnClick", function(self)
        SavedVariablesFrameButton_OnClick(self)
    end)
    variableFrame.savedVariableParentButtons[name] = button
    if not button.savedVariables then
        button.savedVariables = {}
    end
    button.expanded = false


    local buttonBackdrop = CreateFrame("Frame", "VariableFrameBackdrop", button, "BackdropTemplate")
    buttonBackdrop:SetPoint("TOPLEFT", variableFrame, "TOPLEFT", button.xOffset, button.yOffset)
    buttonBackdrop:SetSize(buttonBackdrop:GetParent():GetWidth(), buttonBackdrop:GetParent():GetHeight())
    buttonBackdrop:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    buttonBackdrop:SetBackdropColor(0, 0, 0, 0.2)
    button.buttonBackdrop = buttonBackdrop

    -- get all the saved variables and add them
    for savedName, info in pairs(SavedVariableParents[name]) do
        local value = info[1]
        local description = info[2]
        local savedVariable = GenerateSavedVariable(button, savedName, value, description)
    end

    return button

end

function GenerateSavedVariable(variableButton, name, value, description)
    -- TODO: if name is empty then return
    -- if name already exists then consider this being a change in the existing button
    -- so just change what we need and return the existing button
    local height = 0
    local width = 0
    local variablesFrame = variableButton:GetParent()
    for index, button in pairs(variableButton.savedVariables) do
        height = height + button:GetHeight()
        width = width + button:GetHeight()
    end

    local savedVariableButton = CreateFrame("Button", name, variablesFrame, "SavedVariableButtonTemplate")
    savedVariableButton.xOffset = 35
    savedVariableButton.yOffset = -95 - height

    -- TODO: not a fan of this hierarchy at all, saved variables parent is the main frame but not the parentButton
    -- very confusing
    savedVariableButton.categoryButton = variableButton

    -- savedVariableButton:SetPoint("TOPLEFT", variablesFrame, "TOPLEFT", 35, savedVariableButton.yOffset)
    savedVariableButton:SetText(name)
    savedVariableButton:SetNormalFontObject("GameFontNormalCenter")
    savedVariableButton:SetHighlightFontObject("GameFontNormalCenter")
    savedVariableButton:Hide()

    savedVariableButton.name = name
    savedVariableButton.value = value
    savedVariableButton.description = description
    variableButton.savedVariables[name] = savedVariableButton

    -- Simple tooltip for the button
    savedVariableButton:SetScript("OnEnter", function(self)
        SavedVariable_OnEnter(self, savedVariableButton)
    end)

    savedVariableButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return savedVariableButton
end

function GenerateNewConstantVariable(variableButton, name, value, description)
    local savedVariableButton = GenerateSavedVariable(variableButton, name, value, description)
    SavedVariableParents[variableButton.name][name] = {value, description}
    return savedVariableButton
end

function SavedVariable_OnEnter(self, savedVariableButton)
    -- basic tooltip setup

    -- for prototyping, this will be where we update the dynamic variables
    -- long term will have a much cleaner implementation
    if savedVariableButton.name == "My HP" then
        savedVariableButton.value = UnitHealth("player")
    elseif savedVariableButton.name == "Target HP" then
        savedVariableButton.value = UnitHealth("target")
    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(savedVariableButton.name)
    GameTooltip:AddLine("Value: " .. FormatToolTipValue(savedVariableButton.value), 1, 1, 1)
    if savedVariableButton.description then GameTooltip:AddLine(savedVariableButton.description, 1, 1, 1) end
    GameTooltip:Show()
end

function FormatToolTipValue(value)
    if (type(value) == "string") then
        value = tonumber(value)
    end
    if value < 10 then
        return string.format("%.2f", value)
    elseif value < 1000 then
        return string.format("%.1f", value)
    else
        -- Over 1000, so format with commas
        local formattedValue = string.format("%d", value)
        local k
        while true do
            formattedValue, k = string.gsub(formattedValue, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formattedValue
    end
end

-------------------- SAVED VARIABLES FRAME --------------------

function WoWCalcVariableFrame_OnLoad(self)
    local backdrop = CreateFrame("Frame", "VariableFrameBackdrop", self, "BackdropTemplate")
    backdrop:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -73)
    backdrop:SetSize(200, 250)
    backdrop:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    backdrop:SetBackdropColor(0, 0, 0, 0)

    self.savedVariableParentButtons = {}

    -- make a child button generator
    local createsavedVariableButton = CreateFrame("Button", "CreatesavedVariableButton", self, "UIPanelButtonTemplate")
    createsavedVariableButton:SetSize(140, 30)
    createsavedVariableButton:SetText("Create New Variable")
    createsavedVariableButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 5, -35)
    createsavedVariableButton:SetScript("OnClick", function(self)
        CreateSavedVariableButton_OnClick(self)
    end)
end

function WoWCalcVariableFrame_OnShow(self)
    -- here lets create two dynamic variables
    -- this is not the long term solution, more of a showcase on dynamic variables
    local dynamic1 = GenerateSavedVariable(self.dynamicVariablesButton, "My HP", UnitHealth("player"), "My character's current health")
    local dynamic2 = GenerateSavedVariable(self.dynamicVariablesButton, "Target HP", UnitHealth("target"), "Health of the current target")
end

function CreateSavedVariableButton_OnClick(self)
    -- opens the create variable frame
    local createVariableFrame = self:GetParent():GetParent().saveVariableFrame
    createVariableFrame:Show()

    -- for convenience, focus the first edit box
    createVariableFrame.variableNameEditBox:SetFocus(true)
end

function SavedVariableButton_OnUpdate(self)
    -- ensures that the button moves with the frame whenever we drag the frame
    -- TODO: lets find out what the overhead on this is, it gets called very often
    if not self.isMoving then
        self:SetPoint("TOPLEFT", self:GetParent(), self.xOffset, self.yOffset)
    end
end

function SavedVariablesFrameButton_OnClick(self)
    -- handles text change for the parent button
    -- displays or hides the children buttons
    -- text needs to be updated in the future to be more robust
    local currentText = self:GetText()
    if self.expanded then
        self.expanded = false
        self:SetText(string.gsub(currentText, "%-", "+"))
        for index, child in pairs(self.savedVariables) do
            child:Hide()
        end
        UpdateButtonLocations(self:GetParent())
    else
        self.expanded = true
        self:SetText(string.gsub(currentText, "%+", "-"))
        for index, child in pairs(self.savedVariables) do
            child:Show()
        end
        UpdateButtonLocations(self:GetParent())
    end
end

function SavedVariableButton_OnDragStart(self, button)
    if button == "LeftButton" then
        self:StartMoving()
        self.isMoving = true
    end
end

function SavedVariableButton_OnDragStop(self, button)
    if self.isMoving then
        self:StopMovingOrSizing()
        self.isMoving = false

        local cursorX, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        cursorX = cursorX / scale
        cursorY = cursorY / scale

        local calcFrame = self:GetParent():GetParent().calcFrame
        local editBox = calcFrame.editBox
        local left, bottom, width, height = calcFrame:GetLeft(), calcFrame:GetBottom(), calcFrame:GetWidth(), calcFrame:GetHeight()
        if cursorX >= left and cursorX <= (left + width) and cursorY >= bottom and cursorY <= (bottom + height) then
            local currentText = editBox:GetText()
            if currentText == "0" or editBox.lastDigit.type == "Operator" then
                -- clear the editbox when we need to (when starting or after an operator)
                currentText = ""
                if editBox.lastOperator == "=" then
                    editBox.firstValue = 0
                    editBox.secondValue = 0
                    editBox.lastDigit = nil
                    editBox.lastOperator = "+"
                end
            end
            editBox:SetText(FormatEditBox(self.value))
            editBox.currentText = self.value
            -- just set the lastDigit to 1, this only matters to check the type so setting to 1 is fine, we just need a number button
            editBox.lastDigit = editBox:GetParent().numberButtons["1"]
        end


        -- Move the button back to its original position
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self:GetParent(), self.xOffset, self.yOffset)

    end
end

function SavedVariableButton_OnClick(self, button)
    if button == "RightButton" then
        -- show right click context menu
        SavedVariableButton_ShowContextMenu(self)
    end
end

function SavedVariableButton_ShowContextMenu(savedVariable)
    -- display the context menu
    
    if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
        UIParentLoadAddOn("Blizzard_DebugTools")
    end

    -- Initialize the dropdown menu
    local function InitializeMenu(self, level)
        local info1 = UIDropDownMenu_CreateInfo()

        -- Menu item 1
        info1.text = "Delete"
        info1.func = function() 
            DeleteSavedVariable(savedVariable)
        end
        UIDropDownMenu_AddButton(info1, level)
        
        local info2 = UIDropDownMenu_CreateInfo()

        -- Cancel item
        info2.text = "Cancel"
        info2.func = function() end  -- No action, just closes the menu
        UIDropDownMenu_AddButton(info2, level)
    end

    local contextMenuFrame = CreateFrame("Frame", "SavedVariableContextMenu", savedVariable:GetParent(), "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(contextMenuFrame, InitializeMenu, "MENU")
    ToggleDropDownMenu(1, nil, contextMenuFrame, "cursor", 0, 0)
end

function DeleteSavedVariable(self)
    print("Deleting variable: " .. self.name)
    -- to delete, we need to do the following:
    -- remove the entry from the parent button's savedVariables
    -- remove the entry from the SavedVariableParents table
    -- call UpdateButtonLocations()
    -- final thing - do self:Destroy()

    -- remove self from the parent button's table
    self.categoryButton.savedVariables[self.name] = nil
    -- remove self from the SavedVariables table
    SavedVariableParents[self.categoryButton:GetName()][self.name] = nil
    -- update all button locations
    self:Hide()
    UpdateButtonLocations(self:GetParent())
end

function UpdateButtonLocations(self)
    -- first, need to loop through all the parent vars
    -- in those parent vars, loop through all children
    -- check expanded to see if we need to loop through the children though
    -- need some local yOffset value tracker, dont care about xOffset 
    -- set this up for when we have multiple parent buttons (which will become categories)

    local yOffset = -55
    for parentName, parentButton in pairs(self.savedVariableParentButtons) do
        -- want to put the first one at -75, height is 20
        yOffset = yOffset - parentButton:GetHeight()
        parentButton.yOffset = yOffset
        parentButton:SetPoint("TOPLEFT", self, "TOPLEFT", parentButton.xOffset, parentButton.yOffset)
        parentButton.buttonBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", parentButton.xOffset, parentButton.yOffset)
        if parentButton.expanded then
            for childName, childButton in pairs(parentButton.savedVariables) do
                yOffset = yOffset - childButton:GetHeight()
                childButton.yOffset = yOffset
                childButton:SetPoint("TOPLEFT", self, "TOPLEFT", childButton.xOffset, childButton.yOffset)
            end
        end
    end


end

-------------------- CREATE NEW VARIABLE FRAME --------------------
function SaveVariableFrame_OnLoad(self)
    --TODO: Third editBox for an optional description that will display in the tooltip
    self.TitleContainer.TitleText:SetText("Save a New Variable")

    local nameLabel = self.variableNameEditBox:CreateFontString("$parentLabel", "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("LEFT",  self.variableNameEditBox, "LEFT", -self.variableNameEditBox:GetWidth() - 50, 0)
    nameLabel:SetText("Enter variable name here:")

    local valueLabel = self.variableValueEditBox:CreateFontString("$parentLabel", "OVERLAY", "GameFontNormal")
    valueLabel:SetPoint("LEFT", self.variableValueEditBox, "LEFT", -self.variableValueEditBox:GetWidth() - 50, 0)
    valueLabel:SetText("Enter variable value here:")

    local descriptionLabel = self.variableDescriptionEditBox:CreateFontString("$parentLabel", "OVERLAY", "GameFontNormal")
    descriptionLabel:SetPoint("LEFT", self.variableDescriptionEditBox, "LEFT", -self.variableDescriptionEditBox:GetWidth() - 50, 0)
    descriptionLabel:SetText("Enter description here:")
end

function SaveVariableFrameButton_OnLoad(self)
    -- ensures we still pass along key commands to the game while wehave the window open
    self:SetPropagateKeyboardInput(true)
    self:SetClampedToScreen(true)

    -- allows for dragging
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    self:SetText("Create Variable")
    
end

function SaveVariableFrameButton_OnClick(self)
    -- saves the variable with the frame's edit boxes as
    -- TODO: Clicking this button multiple times has weird behavior with displaying
    -- seems to make the first button fine, but then the rest of the buttons overlap
    -- oh it's because we are naming it the same thing, we should stop that from happening
    -- TODO: variables currently do not save between sessions
    local name = self:GetParent().variableNameEditBox:GetText()
    local value = tonumber(self:GetParent().variableValueEditBox:GetText())
    local description = self:GetParent().variableDescriptionEditBox:GetText()
    local variablesFrame = self:GetParent():GetParent().variableFrame
    local variableButton = variablesFrame.constantVariablesButton
    local savedVariableButton = GenerateNewConstantVariable(variableButton, name, value, description)

    if variableButton.expanded then
        savedVariableButton:Show()
    end
    UpdateButtonLocations(variablesFrame)
    self:GetParent().variableNameEditBox:SetText("")
    self:GetParent().variableValueEditBox:SetText("")
    self:GetParent().variableDescriptionEditBox:SetText("")

    -- TODO: Clear the edit box lines

end

-- TODO: no need for 3 functions doing the same thing only being differentiated by the frame calling it
function SaveVariableFrameEditBoxName_OnKeyDown(self, key)
    if key == "TAB" then
        -- for convenience - pressing tab will focus the next editBox
        self:GetParent().variableValueEditBox:SetFocus(true)
    end
end

function SaveVariableFrameEditBoxValue_OnKeyDown(self, key)
    if key == "TAB" then
        -- for convenience - pressing tab will focus the next editBox
        self:GetParent().variableDescriptionEditBox:SetFocus(true)
    end
end

function SaveVariableFrameEditBoxDescription_OnKeyDown(self, key)
    if key == "TAB" then
        -- for convenience - pressing tab will focus the next editBox
        self:GetParent().variableNameEditBox:SetFocus(true)
    end
end

function SaveVariableFrame_OnShow(self)
    -- reset all the edit boxes
    self.variableNameEditBox:SetText("")
    self.variableValueEditBox:SetText("")
    self.variableDescriptionEditBox:SetText("")
end

-- for later, when we have multiple variable buttons
-- we can just store all of them and then when we open anything up, we loop through 
-- parents (and their children) to replace everything

-- need to add tooltips to the variables