print("lua file")

-- set up to help properly space out button mappings
local buttonMappings = {
    {7, 8, 9},
    {4, 5, 6},
    {1, 2, 3},
    {"+/-", 0, "."}
}

local OPERATORSYMBOLS = {"+", "-", "/", "x", "="}

local OPERATORS = {
    ["+"] = function(a,b)
        return a + b
    end,

    ["-"] = function(a,b)
        return a - b
    end,

    ["x"] = function(a,b)
        return a * b
    end,

    ["/"] = function(a,b)
        return a / b
    end
}

function WoWCalc_OnLoad(self)
    -- set this as a global variable that we can use
    WoWCalcFrame = self

    self:SetPropagateKeyboardInput(true) -- so that we dont consume the keyboard input (UI can still use)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    self.numberButtons = {}
    self.operatorButtons = {}

    local spacing = 9
    local buttonSize = 34
    local startX = 40
    local startY = -75

    -- create number buttons
    for rowIndex, row in ipairs(buttonMappings) do
        for colIndex, buttonID in ipairs(row) do
            local offsetX = startX + (colIndex - 1) * (buttonSize + spacing)
            local offsetY = startY - (rowIndex - 1) * (buttonSize + spacing)
            if buttonID then
                local button = CreateFrame("Button", "WoWCalcButton" .. buttonID, self, "UIPanelButtonTemplate")
                button:SetSize(40, 40)
                button:SetText(tostring(buttonID))
                button:SetNormalFontObject("GameFontNormalLarge")
                button:SetHighlightFontObject("GameFontNormalLarge")
                button.type = "Number"
                button:SetScript("OnClick", function(self)
                    WoWCalcFrameValueButton_OnClick(self, buttonID)
                end)
                button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY)
                self.numberButtons[tostring(buttonID)] = button -- store the button
            end
        end
    end

    -- Create operation buttons
    for index, buttonID in ipairs(OPERATORSYMBOLS) do
        local offsetX = startX + 3 * (buttonSize + spacing) + spacing
        local button = CreateFrame("Button", "WoWCalcButton" .. buttonID, self, "UIPanelButtonTemplate")
        local offsetY = startY - (index - 1) * (buttonSize + spacing)
        if buttonID then
            button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY)
            button:SetText(buttonID)
            button:SetSize(37, 37)
            button:SetNormalFontObject("GameFontNormalLarge")
            button:SetHighlightFontObject("GameFontNormalLarge")
            button.type = "Operator"
            button:SetScript("OnClick", function(self)
                WoWCalcFrameOperatorButton_OnClick(self, buttonID)
            end)
            self.numberButtons[buttonID] = button -- store the button
        end
    end

    -- lastly, make a clear button
    do
        local button = CreateFrame("Button", "WoWCalcButtonClear", self, "UIPanelButtonTemplate")
        button:SetSize(90, 34)
        button:SetText("CLEAR")
        button:SetNormalFontObject("GameFontNormalLarge")
        button:SetHighlightFontObject("GameFontNormalLarge")
        local offsetX = startX + 3 * (buttonSize + spacing) + spacing - 115
        local offsetY = startY - (5 - 1) * (buttonSize + spacing) -- make index 6 so it goes below the equals
        button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY)
        button.type = "Clear"

        -- STOPPED HERE
        button:SetScript("OnClick", function(self)
            WoWCalcButtonClear_OnClick(self)
        end)
        -- store the clear button
        self.clearButton = button
    end


    -- self.editBox.SetScript("OnTextChanged")
end

function WoWCalc_OnShow(self)
    -- initialize the edit box properties
    -- self.editBox:SetTextInsets(50, 50, 50, 50)

    self.editBox.firstValue = 0
    self.editBox.secondValue = 0
    self.editBox.lastDigit = ""
    self.editBox.lastOperator = "+"
    self.editBox.currentText = 0
    self.editBox:SetText(0)
    
end

function WoWCalc_OnKeyDown(self, key)
    if key == "ESCAPE" then
        self:Hide()
    elseif key == "ENTER" then
        -- need to think about if we want to keep this
        -- the current functionality is that it will calculate but also open the normal wow console
        local button = self.numberButtons["="]
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    end
end

function WoWCalcFrameValueButton_OnClick(self, buttonID)
    -- handles all of the logic regarding pressing number buttons
    local editBox = self:GetParent().editBox
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

    if buttonID == "+/-" then
        -- flip the value 
        local newValue = tonumber(currentText) * -1
        editBox:SetText(newValue)
        editBox.currentText = newValue
    elseif buttonID == "." then
        -- need to check that there hasnt been a decimal used, if there has just ignore
        if string.find(currentText, "%.") then
            return
        else
            editBox:SetText(currentText .. buttonID)
            editBox.currentText = currentText .. buttonID
        end
    else
        -- normal procedure, add to the edit box
        editBox:SetText(currentText .. buttonID)
        editBox.currentText = currentText .. buttonID
    end
    -- store the last digit we pressed 
    editBox.lastDigit = self
    
end

function WoWCalcFrameOperatorButton_OnClick(self, buttonID)
    -- handles all of the logic regarding pressing operator buttons
    -- also handles all computation logic
    local editBox = self:GetParent().editBox
    if editBox.lastDigit.type == "Operator" then
        -- if we had last hit an operator, then we dont want to do anything except change
        -- what the operation will be
        editBox.lastOperator = buttonID
        editBox.lastDigit = self
    else
        -- store the value currently in the edit box before 
        editBox.secondValue = tonumber(editBox:GetText())

        -- first, calculate the last set of things
        local result = OPERATORS[editBox.lastOperator](editBox.firstValue, editBox.secondValue)
        editBox:SetText(result)
        editBox.currentText = result
        editBox.firstValue = result
        -- editBox.secondValue = result
        editBox.lastOperator = buttonID
        editBox.lastDigit = self
    end
end

function WoWCalcEditBox_OnChar(self)
    -- we obviously want to let the user type straight into the edit box, but we want to do it in a controlled way
    -- instead of doubling up on the same logic/code as when clicking, we can just "ignore" the char that was pressed
    -- and pass that in through a click event, but only if it matches a clickable button
    -- this allows us to control everything better, and play button animations when typing
    local char = string.sub(self:GetText(), -1)
    self:SetText(self.currentText)

    local button = self:GetParent().numberButtons[char]
    if button ~= nil then
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
        print("we good")
    else
        print("not there")
    end
end

function WoWCalcEditBox_OnKeyDown(self, key)
    -- all of the other key pressing handling lives in WoWCalcEditBox_OnChar
    -- so we just handle the enter key here
    -- no need to check for focus, since this lives in the edit box
    if key == "ENTER" then
        local button = self:GetParent().numberButtons["="]
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    end
end


function WoWCalcButtonClear_OnClick(self)
    -- clear button pressed, reset everything
    local editBox = self:GetParent().editBox
    editBox.firstValue = 0
    editBox.secondValue = 0
    editBox.lastDigit = ""
    editBox.lastOperator = "+"
    editBox.currentText = 0
    editBox:SetText(0)
end

function WoWCalc_SlashCommandHandler(msg)
    -- only command we have for now is to show the frame
    if WoWCalcFrame:IsShown() then
        print("Calculator is already opened!")
        return
    else
        WoWCalcFrame:Show()
    end
end

SLASH_WOWCALC1 = "/wc"
SLASH_WOWCALC2 = "/WowCalc"
SlashCmdList["WOWCALC"] = function(msg, editbox)
    WoWCalc_SlashCommandHandler(msg)
  end

function Contains(table, element)
    for _, value in pairs(table) do
        print(value)
        if value == element then
            return true
        end
    end
    return false
end