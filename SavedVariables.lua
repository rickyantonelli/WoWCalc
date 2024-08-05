function GenerateSavedVariableParent(self, name)
    local button = CreateFrame("Button", name, self, "SavedVariablesParentButtonTemplate")
    button.xOffset = 35
    button.yOffset = -75


    button:SetPoint("TOPLEFT", self, "TOPLEFT", button.xOffset, button.yOffset)
    button:SetText("Saved Variables               +")
    button:SetNormalFontObject("GameFontNormalCenter")
    button:SetHighlightFontObject("GameFontNormalCenter")
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

function GenerateSavedVariable(self, variableButton, name)
    local height = 0
    local width = 0
    for index, button in pairs(variableButton.savedVariables) do
        height = height + button:GetHeight()
        width = width + button:GetHeight()
    end

    local savedVariableButton = CreateFrame("Button", name, self, "SavedVariableButtonTemplate")
    savedVariableButton.xOffset = 35
    savedVariableButton.yOffset = -95 - height

    savedVariableButton:SetPoint("TOPLEFT", self, "TOPLEFT", 35, savedVariableButton.yOffset)
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

    local savedVariableButton1 = GenerateSavedVariable(self, button, "SavedVariableButton1")
    local savedVariableButton2 = GenerateSavedVariable(self, button, "SavedVariableButton2")
    local savedVariableButton3 = GenerateSavedVariable(self, button, "SavedVariableButton3")

    -- make a child button generator
    local createsavedVariableButton = CreateFrame("Button", "CreatesavedVariableButton", self, "UIPanelButtonTemplate")
    createsavedVariableButton:SetSize(60, 60)
    createsavedVariableButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 50, 50)
    createsavedVariableButton:SetScript("OnClick", function(self)
        CreatesavedVariableButton_OnClick(self, createsavedVariableButton, button)
    end)

end

function CreatesavedVariableButton_OnClick(self, button, variableButton)
    -- for now this is for testing
    -- but this will become some sort of "Create Variable" button
    local count = 1;

    for index, button in pairs(variableButton.savedVariables) do
        count = count + 1
    end

    local savedVariableButton = GenerateSavedVariable(self:GetParent(), variableButton, "SavedVariableButton" .. count)

    if variableButton.expanded then
        savedVariableButton:Show()
    end
end

function SavedVariablesFrameButton_OnClick(self)
    -- handles text change for the parent button
    -- displays or hides the children buttons
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
            editBox:SetText(self.value)
        end


        -- Move the button back to its original position
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", self:GetParent(), self.xOffset, self.yOffset)

    end
end

-- for later, when we have multiple variable buttons
-- we can just store all of them and then when we open anything up, we loop through 
-- parents (and their children) to replace everything