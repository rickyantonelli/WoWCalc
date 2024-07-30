print("lua file")

-- set up to help properly space out button mappings
local buttonMappings = {
    {7, 8, 9},
    {4, 5, 6},
    {1, 2, 3},
    {"+/-", 0, "."}
}

local operatorSymbols = {"+", "-", "/", "x", "="}

local operators = {
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

function WoWCalc_OnShow(self)
    self:Show()
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    self.numberButtons = {}
    self.operatorButtons = {}

    local spacing = 30
    local buttonSize = 34
    local startX = 100
    local startY = -150

    for rowIndex, row in ipairs(buttonMappings) do
        for colIndex, buttonID in ipairs(row) do
            --print(buttonID)
            local offsetX = startX + (colIndex - 1) * (buttonSize + spacing)
            local offsetY = startY - (rowIndex - 1) * (buttonSize + spacing)
            if buttonID then
                local button = CreateFrame("Button", "WoWCalcButton" .. buttonID, self, "UIPanelButtonTemplate")
                button:SetSize(34, 34)
                button:SetText(buttonID)
                button.type = "Number"
                button:SetScript("OnClick", function(self)
                    WoWCalcFrameValueButton_OnClick(self, buttonID)
                end)
                button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY)
                self.numberButtons[tostring(buttonID)] = button -- store the button
                print(self.numberButtons["7"]:GetText())
            end
        end
    end

    -- Create operation buttons
    for index, buttonID in ipairs(operatorSymbols) do
        local operatorX = startX + 3 * (buttonSize + spacing) + spacing
        local button = CreateFrame("Button", "WoWCalcButton" .. buttonID, self, "UIPanelButtonTemplate")
        local offsetY = startY - (index - 1) * (buttonSize + spacing)
        button:SetPoint("TOPLEFT", self, "TOPLEFT", operatorX, offsetY)
        button:SetText(buttonID)
        button.type = "Operator"
        button:SetScript("OnClick", function(self)
            WoWCalcFrameOperatorButton_OnClick(self, buttonID)
        end)
        self.numberButtons[buttonID] = button -- store the button
    end

    -- self.editBox.SetScript("OnTextChanged")
    
    -- set the edit box to display 0
    self.editBox.firstValue = 0
    self.editBox.secondValue = 0
    self.editBox.lastDigit = ""
    self.editBox.lastOperator = "+"
    self.editBox.currentText = 0
    self.editBox:SetText(0)
    
end

function WoWCalcFrameValueButton_OnClick(self, buttonID)
    -- print("Button" .. buttonID ..  "clicked!")
    local editBox = self:GetParent().editBox
    local currentText = editBox:GetText()
    if currentText == "0" or editBox.lastDigit.type == "Operator" then
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
        editBox:SetText(currentText .. buttonID)
        editBox.currentText = currentText .. buttonID
    end
    editBox.lastDigit = self
    
end

function WoWCalcFrameOperatorButton_OnClick(self, buttonID)
    local editBox = self:GetParent().editBox
    if editBox.lastDigit.type == "Operator" then
        editBox.lastOperator = buttonID
        editBox.lastDigit = self
    else
        -- store the value currently in the edit box before 
        editBox.secondValue = tonumber(editBox:GetText())

        -- first, calculate the last set of things
        local result = operators[editBox.lastOperator](editBox.firstValue, editBox.secondValue)
        editBox:SetText(result)
        editBox.currentText = result
        editBox.firstValue = result
        -- editBox.secondValue = result
        editBox.lastOperator = buttonID
        editBox.lastDigit = self
    end
end

function WoWCalcEditBox_OnChar(self)
    local char = string.sub(self:GetText(), -1)
    self:SetText(self.currentText)
    print(type(char))
    

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


function Contains(table, element)
    for _, value in pairs(table) do
        print(value)
        if value == element then
            return true
        end
    end
    return false
end




-- /run WoWCalcFrame:Show()