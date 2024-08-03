
-- set up to help properly space out button mappings
local BUTTONMAPPINGS = {
    {7, 8, 9},
    {4, 5, 6},
    {1, 2, 3},
    {"+/-", 0, "."}
}

local OPERATORSYMBOLS = {"+", "-", "/", "*", "="}

local OPERATORS = {
    ["+"] = function(a,b)
        return a + b
    end,

    ["-"] = function(a,b)
        return a - b
    end,

    ["*"] = function(a,b)
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

    local backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
    backdrop:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -73)
    backdrop:SetSize(190, 220)
    backdrop:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    backdrop:SetBackdropColor(0, 0, 0, 0)

    self.numberButtons = {}
    self.savedVariableButtons = {}

    local spacing = 9
    local buttonSize = 34
    local startX = 40
    local startY = -75

    -- create number buttons
    for rowIndex, row in ipairs(BUTTONMAPPINGS) do
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
            
            if buttonID == "*" then
                button:SetText("x")
            else
                button:SetText(buttonID)
            end
            if buttonID == "=" then
                button:SetSize(80, 40)
                button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX - 39, offsetY)
            else
                button:SetSize(40, 40)
                button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY)
            end
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
        local button = CreateFrame("Button", "WoWCalcButtonClear", self)
        button:SetSize(90, 40)
        button:SetText("CLEAR")
        button:SetNormalFontObject("GameFontNormalLarge")
        button:SetHighlightFontObject("GameFontNormalLarge")
        local offsetX = startX + 3 * (buttonSize + spacing) + spacing - 137
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

    --self.editBox.SetPoint()


    -- self.editBox.SetScript("OnTextChanged")
end

function WoWCalc_OnShow(self)
    -- initialize the edit box properties

    self.editBox.firstValue = 0
    self.editBox.secondValue = 0
    self.editBox.lastDigit = ""
    self.editBox.lastOperator = "+"
    self.editBox.currentText = 0
    self.editBox:SetText(FormatEditBox(0))
    
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
        editBox:SetText(FormatEditBox(newValue))
        editBox.currentText = newValue
    elseif buttonID == "." then
        -- need to check that there hasnt been a decimal used, if there has just ignore
        if string.find(currentText, "%.") then
            return
        else
            editBox:SetText(FormatEditBox(currentText .. buttonID))
            editBox.currentText = currentText .. buttonID
        end
    else
        -- normal procedure, add to the edit box
        editBox:SetText(FormatEditBox(currentText .. buttonID))
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
        editBox:SetText(FormatEditBox(result))
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
    self:SetText(FormatEditBox(self.currentText))

    local button = self:GetParent().numberButtons[char]
    if button ~= nil then
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    end
end

function WoWCalcEditBox_OnKeyDown(self, key)
    -- most of the other key pressing handling lives in WoWCalcEditBox_OnChar
    -- so here we just handle enter, escape, and the asterisk (since multiply is bound to x)
    -- no need to check for focus, since this lives in the edit box
    if key == "ENTER" then
        local button = self:GetParent().numberButtons["="]
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    elseif key == "ESCAPE" then
        local button = self:GetParent().clearButton
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    elseif key == "X" then
        local button = self:GetParent().numberButtons["*"]
        button:Click()
        button:GetScript("OnMouseDown")(button)
        C_Timer.After(0.1, function()
            button:GetScript("OnMouseUp")(button)
        end)
    end
end

function FormatEditBox(number)
    -- adding some light formatting to the edit box
    -- having this will also allow us to give the user freedom
    -- to format as they like 
    local formattedNumber = string.format("%.5f", number)
    formattedNumber = formattedNumber:gsub("0+$", "") -- Remove trailing zeros
    formattedNumber = formattedNumber:gsub("%.$", "") -- Remove trailing decimal point if no decimals
    return formattedNumber
end


function WoWCalcButtonClear_OnClick(self)
    -- clear button pressed, reset everything
    local editBox = self:GetParent().editBox
    editBox.firstValue = 0
    editBox.secondValue = 0
    editBox.lastDigit = ""
    editBox.lastOperator = "+"
    editBox.currentText = 0
    editBox:SetText(FormatEditBox(0))
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
