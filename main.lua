local icon = LibStub("LibDBIcon-1.0")
local square_text = strings_generic
local buttonHeight = 70
local buttonWidth = 70
local borderThickness = 4
local N = 5 -- number of squares on an edge

-- Show/Hide Bingo Frame 
function ClickMinimapIcon(self, button, down)
	if button == "LeftButton" then
		if BingoFrame:IsVisible() then
			showBoard = false
			BingoFrame:Hide()
		else
			showBoard = true
			BingoFrame:Show()
		end
	elseif button == "RightButton" then
		boardState = {}
		for i = 1, N*N do
			boardState[i] = false
		end
		FillBoard(N, Randomize(square_text, N), boardState)
	end
end

-- Highlight the border so it's moveable
function HighlightBorder()
	BingoFrame.texture:SetColorTexture(1,1,1,0.2)
end
function DehighlightBorder()
	BingoFrame.texture:SetColorTexture(1,1,1,0)
end

function SetBoardState(k, v)
	boardState[k] = v
	if v then
		if HasBingo(boardState) then
			print('BINGO')
		end
	end
end

-- Event Handler
function eventHandler(self, event)

	-- Combat handling
	if event == "PLAYER_REGEN_DISABLED" then -- enter/in combat
		BingoFrame:Hide()
	elseif event == "PLAYER_REGEN_ENABLED" then -- left/out of combat
		if showBoard then
			BingoFrame:Show()
		end
		
	-- Addon Initialize
	elseif event == "ADDON_LOADED" then

		if isEmpty(boardState) or isEmpty(boardArrangement) then
			boardState = {}
			for i = 0, N*N-1 do
				table.insert(boardState, false)
			end
			InitBoard(N)
			FillBoard(N, Randomize(square_text, N), boardState)
		else
			InitBoard(N)
			FillBoard(N, boardArrangement, boardState)
		end
		
		-- Board Display
		if showBoard or showBoard == nil then
			BingoFrame:Show()
		else
			BingoFrame:Hide()
		end
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

-- Minimap Icon
local bingoLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Raid Bingo", {
	type = "data source",
	text = "Raid Bingo",
	icon = "Interface\\Icons\\classicon_demonhunter",--"Interface\\Icons\\INV_Chest_Cloth_17",
	OnClick = ClickMinimapIcon,
	OnTooltipShow = function(tt)
		tt:AddLine(string.format('%s v%s', "Raid Bingo", "0.1.2"))
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
BingoFrame:SetScript("OnEvent", eventHandler)
BingoFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
BingoFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
BingoFrame:RegisterEvent("ADDON_LOADED")
BingoFrame:SetClampedToScreen(true)
BingoFrame:SetPoint("CENTER", -400, 0)

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

-- Initialize the Board 
function InitBoard(n)
	local grid = {}
	for i = 1, n do
		for j = 1, n do
			local k = n*(i-1) + j
			local button = CreateFrame("Button", nil, BoardFrame)
			button:SetFrameStrata("BACKGROUND")
			button:SetWidth(buttonWidth) 
			button:SetHeight(buttonHeight)
			x = (j-1)*(buttonWidth + borderThickness) + borderThickness
			y = -(i-1)*(buttonHeight + borderThickness) - borderThickness
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
			
			local t0 = button:CreateTexture(nil, "ARTWORK")
			t0:SetColorTexture(26/255, 31/255, 40/255)
			t0:SetAllPoints(button)
			
			local t1 = button:CreateTexture(nil, "ARTWORK")
			t1:SetColorTexture(66/255, 134/255, 244/255)
			t1:SetAllPoints(button)

			button:SetNormalTexture(t0)
			button:SetPushedTexture(t1)
			
			button:SetScript("OnClick", function(self)
				if boardState[k] then
					boardState[k] = false
					self:SetButtonState("NORMAL")
				else
					--boardState[k] = true
					SetBoardState(k, true)
					self:SetButtonState("PUSHED", "true")
				end
			end)
			
			button:SetScript("OnEnter", HighlightBorder)
			button:SetScript("OnLeave", DehighlightBorder)
			
			button:Show()
		end
	end
end

-- Draw a new board
function FillBoard(n, list, state)
	local buttons = { BoardFrame:GetChildren() }
	local i = 1
	boardArrangement = {}
	local copied = copy(list)
	for _, button in ipairs(buttons) do

		if state[i] then
			button:SetButtonState("PUSHED", true)
		else
			button:SetButtonState("NORMAL", false)
		end
		
		label = button:GetChildren()
		if i == (#buttons+1)/2 then
			label.text:SetText("FREE")
		else
			text = table.remove(copied, 1)
			label.text:SetText(text)
			table.insert(boardArrangement, text)
		end
		i = i+1
	end
end





