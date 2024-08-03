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

    -- create the save variable button
    -- local button = CreateFrame("Button", "SavedVariablesButton", self, "SavedVariablesButtonTemplate")
    
    -- TODO: All of this needs to move into a template, including the backdrop
    local name = "SavedVariablesButton"
    local button = CreateFrame("Button", name, self)
    button:SetSize(200, 20)
    button:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -75)
    button:SetText("Test Button                 +")
    button:SetNormalFontObject("GameFontNormalCenter")
    button:SetHighlightFontObject("GameFontNormalCenter")


    local buttonBackdrop = CreateFrame("Frame", "VariableFrameBackdrop", button, "BackdropTemplate")
    buttonBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -75)
    buttonBackdrop:SetSize(195, 25)
    buttonBackdrop:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    buttonBackdrop:SetBackdropColor(0, 0, 0, 0.2)

    local childButton = CreateFrame("Button", "ChildTestButton", button)
    childButton:SetSize(200, 20)
    childButton:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -95)
    childButton:SetText("ChildTestButton")
    childButton:SetNormalFontObject("GameFontNormalCenter")
    childButton:SetHighlightFontObject("GameFontNormalCenter")

end


function GenerateButtons(self)
    local variableButtons = self:GetParent().variableButtons
end


-- bgFile = "Interface/Tooltips/UI-Tooltip-Background",
-- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",

-- for later, when we have multiple variable buttons
-- we can just store all of them and then when we open anything up, we loop through 
-- parents (and their children) to replace everything