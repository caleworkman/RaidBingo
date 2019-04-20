N = 5 -- number of squares on an edge

local icon = LibStub("LibDBIcon-1.0")
local AceComm = LibStub('AceComm-3.0')
local square_text = strings_generic
local borderThickness = 4
local defaultButtonSize = 70

local otherPlayers = {}


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
	elseif button == "MiddleButton" then
		boardState = {}
		for i = 1, N*N do
			boardState[i] = false
		end
		FillBoard(N, Randomize(square_text, N), boardState)
	elseif button == "RightButton" then
		if ConfigFrame:IsVisible() then
			ConfigFrame:Hide()
		else
			ConfigFrame:Show()
		end
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
	
		-- Layout customizations
		if buttonSize == nil then
			buttonSize = 70
		end
		
		-- Set all the configuration input boxes to their values
		ConfigFrameEditBox:SetText(buttonSize)
		
		if isEmpty(boardState) or isEmpty(boardArrangement) then
			boardState = {}
			for i = 0, N*N-1 do
				table.insert(boardState, false)
			end
			InitBoard(N)
			ResizeBoard()
			FillBoard(N, Randomize(square_text, N), boardState)
		else
			InitBoard(N)
			ResizeBoard(N)
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
		tt:AddLine(string.format('%s v%s', "Raid Bingo", "0.1.3"))
		tt:AddLine(" ")
		tt:AddLine("Left Click: Hide")
		tt:AddLine("Middle Click: Reset/Randomize")
		tt:AddLine("Right Click: Config")
	end
})
icon:Register("RaidBingo", bingoLDB, RaidBingoDB)
icon:Show()

-- Addon Communication
function OnCommReceived(prefix, text)
	local player, arrangement, state = string.match(text, '(.*)|(.*)|(.*)')
	otherPlayers[player] = {}
	otherPlayers[player].arrangement = arrangement
	otherPlayers[player].state = state
	
	for player, board in pairs(otherPlayers) do
		UIDropDownMenu_AddButton(player)
	end
end
AceComm:RegisterComm('RaidBingo', OnCommReceived)

-- Initialize the whole addon (outer) frame
local BingoFrame = CreateFrame("Frame", "BingoFrame", UIParent)
BingoFrame:SetFrameStrata("BACKGROUND")
BingoFrame:SetWidth(N*(defaultButtonSize+borderThickness) + 20) 
BingoFrame:SetHeight(N*(defaultButtonSize+borderThickness) + 20)
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
BoardFrame:SetWidth(N*(defaultButtonSize+borderThickness)+borderThickness) 
BoardFrame:SetHeight(N*(defaultButtonSize+borderThickness)+borderThickness)
BoardFrame:SetPoint("CENTER")

local t = BoardFrame:CreateTexture(nil, "BACKGROUND")
t:SetColorTexture(0, 0, 0, 1)
t:SetAllPoints(BoardFrame)
BoardFrame.texture = t


-- Other Players menu
local RaidBingoPlayers = CreateFrame('Frame', 'RaidBingoPlayers', UIParent, 'UIDropDownMenuTemplate')
RaidBingoPlayers:SetPoint('TOPRIGHT', BoardFrame, 'BOTTOMRIGHT', -110, 0)
UIDropDownMenu_SetText(RaidBingoPlayers, 'Players')
UIDropDownMenu_Initialize(RaidBingoPlayers, function(self, level)
	local info = UIDropDownMenu_CreateInfo()
	for player, board in pairs(otherPlayers) do
		info.text, info.arg1 = player, player
		info.func = self.SetValue
		UIDropDownMenu_AddButton(info)
	end
end)

function RaidBingoPlayers:SetValue(player)
	UIDropDownMenu_SetText(RaidBingoPlayers, player)
	CloseDropDownMenus()
end

-- Initialize the Board 
function InitBoard(n)
	local grid = {}
	for i = 1, n do
		for j = 1, n do
			local k = n*(i-1) + j
			local button = CreateFrame("Button", nil, BoardFrame)
			button:SetFrameStrata("BACKGROUND")
			button:SetWidth(buttonSize) 
			button:SetHeight(buttonSize)
			x = (j-1)*(buttonSize + borderThickness) + borderThickness
			y = -(i-1)*(buttonSize + borderThickness) - borderThickness
			button:SetPoint("TOPLEFT", x, y)
			
			local label = CreateFrame("Frame", nil, button)
			label:SetFrameStrata("BACKGROUND")
			label:SetWidth(buttonSize) 
			label:SetHeight(buttonSize)
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
				-- Build the comm message to send
				player = UnitName('player')
				data = player .. '|' .. ToString(boardArrangement) .. '|' .. ToString(boardState)
				AceComm:SendCommMessage('RaidBingo', data, 'GUILD')
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

-- Resize a board
function ResizeBoard(n)
	BingoFrame:SetWidth(n*(buttonSize+borderThickness) + 20) 
	BingoFrame:SetHeight(n*(buttonSize+borderThickness) + 20)
	BoardFrame:SetWidth(n*(buttonSize+borderThickness)+borderThickness) 
	BoardFrame:SetHeight(n*(buttonSize+borderThickness)+borderThickness)

	-- Resize all the squares
	squares = { BoardFrame:GetChildren() }
	for k,square in ipairs(squares) do
		local i = math.floor((k-1)/n) + 1
		local j = math.fmod((k-1),n) + 1
	
		square:SetWidth(buttonSize) 
		square:SetHeight(buttonSize)
		
		children = { square:GetChildren() } 
		for _, child in ipairs(children) do

			x = (j-1)*(buttonSize + borderThickness) + borderThickness
			y = -(i-1)*(buttonSize + borderThickness) - borderThickness
			square:SetPoint("TOPLEFT", x, y)
				
			child:SetWidth(buttonSize) 
			child:SetHeight(buttonSize)
			child:SetAllPoints(square)
		end
	end
end



