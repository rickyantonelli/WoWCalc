function GenerateSavedVariableParent(self, name)
    local button = CreateFrame("Button", name, self, "SavedVariablesParentButtonTemplate")
    button.xOffset = 35
    button.yOffset = -75


    button:SetPoint("TOPLEFT", self, "TOPLEFT", button.xOffset, button.yOffset)
    button:SetText("Saved Variables               +")
    button:SetNormalFontObject("GameFontNormalCenter")
    button:SetHighlightFontObject("GameFontNormalCenter")
    button:SetParentKey("savedVariablesButton")
    button:SetScript("OnClick", function(self)
        SavedVariablesFrameButton_OnClick(self)
    end)
    button.savedVariables = {}
    button.expanded = false


    local buttonBackdrop = CreateFrame("Frame", "VariableFrameBackdrop", button, "BackdropTemplate")
    buttonBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", button.xOffset, button.yOffset)
    buttonBackdrop:SetSize(buttonBackdrop:GetParent():GetWidth(), buttonBackdrop:GetParent():GetHeight())
    buttonBackdrop:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    buttonBackdrop:SetBackdropColor(0, 0, 0, 0.2)

    self:GetParent().savedVariableParentButtons["name"] = button

    return button

end

function GenerateSavedVariable(variableButton, name)
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

    savedVariableButton:SetPoint("TOPLEFT", variablesFrame, "TOPLEFT", 35, savedVariableButton.yOffset)
    savedVariableButton:SetText(name)
    savedVariableButton:SetNormalFontObject("GameFontNormalCenter")
    savedVariableButton:SetHighlightFontObject("GameFontNormalCenter")
    savedVariableButton:Hide()

    savedVariableButton.value = 10
    variableButton.savedVariables[name] = savedVariableButton

    return savedVariableButton
end

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
    
    local button = GenerateSavedVariableParent(self, "SavedVariablesButton")

    local savedVariableButton1 = GenerateSavedVariable(button, "SavedVariableButton1")
    local savedVariableButton2 = GenerateSavedVariable(button, "SavedVariableButton2")
    local savedVariableButton3 = GenerateSavedVariable(button, "SavedVariableButton3")

    -- make a child button generator
    local createsavedVariableButton = CreateFrame("Button", "CreatesavedVariableButton", self, "UIPanelButtonTemplate")
    createsavedVariableButton:SetSize(140, 30)
    createsavedVariableButton:SetText("Create New Variable")
    createsavedVariableButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -35)
    createsavedVariableButton:SetScript("OnClick", function(self)
        CreatesavedVariableButton_OnClick(self, createsavedVariableButton, button)
    end)

end

function CreatesavedVariableButton_OnClick(self, button, variableButton)
    -- opens the create variable frame
    local createVariableFrame = self:GetParent():GetParent().saveVariableFrame
    createVariableFrame:Show()

    -- for convenience, focus the first edit box
    createVariableFrame.variableNameEditBox:SetFocus(true)
end

function SavedVariablesFrameButton_OnClick(self)
    -- handles text change for the parent button
    -- displays or hides the children buttons
    -- text needs to be updated in the future to be more robust
    local currentText = self:GetText()
    if self.expanded then
        self.expanded = false
        self:SetText(string.gsub(currentText, "%-", "+"))
    else
        self.expanded = true
        self:SetText(string.gsub(currentText, "%+", "-"))
    end

    if self.expanded then
        for index, child in pairs(self.savedVariables) do
            child:Show()
        end
    else
        for index, child in pairs(self.savedVariables) do
            child:Hide()
        end
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
            -- TODO: need to properly set text with FormatEditBox()
            -- also ensure that just setting text is ok, and that we dont need to reset anything
            -- button doesnt move with parent until clicked
            editBox:SetText(self.value)
        end


        -- Move the button back to its original position
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self:GetParent(), self.xOffset, self.yOffset)

    end
end

function SavedVariableButton_OnUpdate(self)
    -- ensures that the button moves with the frame whenever we drag the frame
    if not self.isMoving then
        self:SetPoint("TOPLEFT", self:GetParent(), self.xOffset, self.yOffset)
    end
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

    local titleFrame = CreateFrame("Frame", "SaveVariableFrameTitle", self:GetParent())
    titleFrame:SetSize(self:GetParent():GetWidth(), 30)
    titleFrame:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, 0)
    local titleText = titleFrame:CreateFontString("$parentTitle", "OVERLAY", "GameFontNormal")
    titleText:SetPoint("CENTER")
    titleText:SetText("Save a New Variable")

    local nameLabel = self:GetParent().variableNameEditBox:CreateFontString("$parentLabel", "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("LEFT",  self:GetParent().variableNameEditBox, "LEFT", -self:GetParent().variableNameEditBox:GetWidth() - 50, 0)
    nameLabel:SetText("Enter variable name here:")

    local valueLabel = self:GetParent().variableValueEditBox:CreateFontString("$parentLabel", "OVERLAY", "GameFontNormal")
    valueLabel:SetPoint("LEFT", self:GetParent().variableValueEditBox, "LEFT", -self:GetParent().variableValueEditBox:GetWidth() - 50, 0)
    valueLabel:SetText("Enter variable value here:")
end

function SaveVariableFrameButton_OnClick(self)
    -- saves the variable with the frame's edit boxes as
    -- TODO: Clicking this button multiple times has weird behavior with displaying
    -- seems to make the first button fine, but then the rest of the buttons overlap
    -- oh it's because we are naming it the same thing, we should stop that from happening
    local name = self:GetParent().variableNameEditBox:GetText()
    local value = self:GetParent().variableValueEditBox:GetText()
    local variablesFrame = self:GetParent():GetParent().variableFrame
    local variableButton = variablesFrame.savedVariablesButton
    local savedVariableButton = GenerateSavedVariable(variableButton, name)
    savedVariableButton.value = value

    if variableButton.expanded then
        savedVariableButton:Show()
    end

end

function SaveVariableFrameEditBoxName_OnKeyDown(self, key)
    if key == "TAB" then
        -- for convenience - pressing tab will focus the next editBox
        self:GetParent().variableValueEditBox:SetFocus(true)
    end
end

-- for later, when we have multiple variable buttons
-- we can just store all of them and then when we open anything up, we loop through 
-- parents (and their children) to replace everything

-- need to add tooltips to the variables