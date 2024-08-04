function GenerateSavedVariable(self, name)
    local button = CreateFrame("Button", name, self, "SavedVariablesButtonTemplate")
    button.xOffset = 35
    button.yOffset = -75


    button:SetPoint("TOPLEFT", self, "TOPLEFT", button.xOffset, button.yOffset)
    button:SetText("Saved Variables               +")
    button:SetNormalFontObject("GameFontNormalCenter")
    button:SetHighlightFontObject("GameFontNormalCenter")
    button:SetScript("OnClick", function(self)
        SavedVariablesFrameButton_OnClick(self)
    end)
    button.childrenVariables = {}
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

    self:GetParent().savedVariableButtons["name"] = button

    return button

end

function GenerateChildVariable(self, variableButton, name)
    local height = 0
    local width = 0
    for index, button in pairs(variableButton.childrenVariables) do
        height = height + button:GetHeight()
        width = width + button:GetHeight()
    end

    print(name .. "has height of " .. height)

    local childButton = CreateFrame("Button", name, self, "ChildVariablesButtonTemplate")
    childButton.xOffset = 35
    childButton.yOffset = -95 - height

    childButton:SetPoint("TOPLEFT", self, "TOPLEFT", 35, childButton.yOffset)
    childButton:SetText(name)
    childButton:SetNormalFontObject("GameFontNormalCenter")
    childButton:SetHighlightFontObject("GameFontNormalCenter")
    childButton:Hide()
    variableButton.childrenVariables[name] = childButton
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
    
    local button = GenerateSavedVariable(self, "SavedVariablesButton")

    local childButton1 = GenerateChildVariable(self, button, "ChildTestButton1")
    local childButton2 = GenerateChildVariable(self, button, "ChildTestButton2")
    local childButton3 = GenerateChildVariable(self, button, "ChildTestButton3")

end


function GenerateButtons(self)
    local variableButtons = self:GetParent().variableButtons
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
        for index, child in pairs(self.childrenVariables) do
            child:Show()
        end
    else
        for index, child in pairs(self.childrenVariables) do
            child:Hide()
        end
    end
end

-- for later, when we have multiple variable buttons
-- we can just store all of them and then when we open anything up, we loop through 
-- parents (and their children) to replace everything