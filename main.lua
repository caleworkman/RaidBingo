local icon = LibStub("LibDBIcon-1.0")
local square_text = strings_generic
local buttonHeight = 70
local buttonWidth = 70
local borderThickness = 4
local N = 5 -- number of squares on an edge 

-- Returns a randomized subset of the list that fits the board
function Randomize(list)
	randomized = {}
	copy = list
	
	for i = 0, N*N-2 do
		v = math.random(1, #list)
		removed = table.remove(copy, v)
		table.insert(randomized, removed)
	end
	
	return randomized
end

-- Show/Hide Bingo Frame 
function ToggleVisible(self, button, down)
	if button == "LeftButton" then
		if BingoFrame:IsVisible() then
			BingoFrame:Hide()
		else
			BingoFrame:Show()
		end
	elseif button == "RightButton" then
		--DrawBoard(N, square_text)
		print("Disabled")
	end
end

-- Highlight the border so it's moveable
function HighlightBorder()
	BingoFrame.texture:SetColorTexture(1,1,1,0.2)
end
function DehighlightBorder()
	BingoFrame.texture:SetColorTexture(1,1,1,0)
end

-- Minimap Icon
local bingoLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Raid Bingo", {
	type = "data source",
	text = "Raid Bingo",
	icon = "Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = ToggleVisible,
	OnTooltipShow = function(tt)
		tt:AddLine("Raid Bingo")
		tt:AddLine(" ")
		tt:AddLine("Left Click: Hide")
		tt:AddLine("Right Click: Reset/Randomize")
	end
})
icon:Register("RaidBingo", bingoLDB, RaidBingoDB)
icon:Show()

-- Initialize the whole addon (outer) frame
local BingoFrame = CreateFrame("Frame", "BingoFrame", UIParent)
BingoFrame:SetFrameStrata("BACKGROUND")
BingoFrame:SetWidth(N*(buttonWidth+borderThickness) + 20) 
BingoFrame:SetHeight(N*(buttonHeight+borderThickness) + 20)
BingoFrame:SetMovable(true)
BingoFrame:EnableMouse(true)
BingoFrame:RegisterForDrag("LeftButton")
BingoFrame:SetScript("OnDragStart", BingoFrame.StartMoving)
BingoFrame:SetScript("OnDragStop", BingoFrame.StopMovingOrSizing)
BingoFrame:SetScript("OnEnter", HighlightBorder)
BingoFrame:SetScript("OnLeave", DehighlightBorder)
BingoFrame:SetClampedToScreen(true)

local t = BingoFrame:CreateTexture(nil, "BACKGROUND")
t:SetColorTexture(1.0, 1.0, 1.0, 0)
t:SetAllPoints(BingoFrame)
BingoFrame.texture = t

-- Initialize the playable board
local BoardFrame = CreateFrame("Frame", "BoardFrame", BingoFrame)
BoardFrame:SetFrameStrata("BACKGROUND")
BoardFrame:SetWidth(N*(buttonWidth+borderThickness)+borderThickness) 
BoardFrame:SetHeight(N*(buttonHeight+borderThickness)+borderThickness)
BoardFrame:SetPoint("CENTER")

local t = BoardFrame:CreateTexture(nil, "BACKGROUND")
t:SetColorTexture(0, 0, 0, 1)
t:SetAllPoints(BoardFrame)
BoardFrame.texture = t

-- Draw the board and buttons
function DrawBoard(n, list)

	-- Clear the old board
	local children = BoardFrame:GetChildren()
	if children then
		print(#children)
		for _, child in ipairs(children) do
			child:Hide()
			child:SetParent(nil)
		end
	end
	
	-- Randomize the board
	square_text = Randomize(list)
	local bingo_grid = {}
	for i = 0, n-1 do
		for j = 0, n-1 do
			local k = n*i + j
			bingo_grid[k] = 0
			
			local button = CreateFrame("Button", nil, BoardFrame)
			button:SetFrameStrata("BACKGROUND")
			button:SetWidth(buttonWidth) 
			button:SetHeight(buttonHeight)
			x = j*(buttonWidth + borderThickness) + borderThickness
			y = -i*(buttonHeight + borderThickness) - borderThickness
			button:SetPoint("TOPLEFT", x, y)
			
			local label = CreateFrame("Frame", nil, button)
			label:SetFrameStrata("BACKGROUND")
			label:SetWidth(buttonWidth) 
			label:SetHeight(buttonHeight)
			label:SetAllPoints(button)
			
			label.text = label.text or
			label:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			label.text:SetJustifyH("CENTER")
			label.text:SetJustifyV("CENTER")
			label.text:SetTextColor(1.0, 1.0, 1.0, 1.0)
			label.text:SetAllPoints(true)
			
			local t = button:CreateTexture(nil, "ARTWORK")
			t:SetColorTexture(0, 0, 0)
			t:SetAllPoints(button)
			
			middle = (n*n-1)/2
			if k == middle then
				label.text:SetText("FREE")
			elseif k < middle then
				label.text:SetText(square_text[k+1])
			elseif k > middle then
				label.text:SetText(square_text[k])
			end
			
			local t0 = button:CreateTexture(nil, "ARTWORK")
			t0:SetColorTexture(26/255, 31/255, 40/255)
			t0:SetAllPoints(button)
			
			local t1 = button:CreateTexture(nil, "ARTWORK")
			t1:SetColorTexture(66/255, 134/255, 244/255)
			t1:SetAllPoints(button)

			button:SetNormalTexture(t0)
			button:SetPushedTexture(t1)
			
			button:SetScript("OnClick", function(self)
				if bingo_grid[k] == 0 then
					bingo_grid[k] = 1
					button:SetButtonState("PUSHED", "true")
				else
					bingo_grid[k] = 0
					button:SetButtonState("NORMAL")
				end
			end)
			
			button:SetScript("OnEnter", HighlightBorder)
			button:SetScript("OnLeave", DehighlightBorder)
			
			button:Show()
		end
	end
end

DrawBoard(N, square_text)

-- Display
BingoFrame:SetPoint("CENTER", -400, 0)
BingoFrame:Show()


