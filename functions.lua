-- Generic Functions

-- Copy a table, not the reference
function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

-- Tests for nil or empty table
function isEmpty(s)
	if s == nil then
		return true
	elseif s == {} then
		return true
	else
		return false
	end
end

-- Returns a randomized subset of the list with length n^2
function Randomize(list, n)
	randomized = {}
	copied = copy(list)
	
	for i = 0, n*n-2 do
		v = math.random(1, #copied)
		removed = table.remove(copied, v)
		table.insert(randomized, removed)
	end
	
	return randomized
end

--Functions to check if a list is a winning bingo pattern
function HasBingo(list)
	return IsWinningColumn(list) or IsWinningRow(list) or IsWinningDiagonal(list)
end

function IsWinningColumn(list)
	local n = math.sqrt(#list)
	for i = 1, n do	 -- columns
		local wins = 0
		for j = 1, n do	-- rows
			if list[(j-1)*n + i] then
				wins = wins + 1
			else
				break
			end
		end
		if wins == n then
			return true
		end
	end	
end

function IsWinningRow(list)
	local n = math.sqrt(#list)
	for i = 1, n do	 -- rows
		local wins = 0
		for j = 1, n do	-- columns
			if list[(i-1)*n + j] then
				wins = wins + 1
			else
				break
			end
		end
		if wins == n then
			return true
		end
	end	
end

function IsWinningDiagonal(list)
	local n = math.sqrt(#list)
	local winsSE = 0
	local winsNE = 0
	
	for i = 1, n do
		local k = (i-1)*n + i
		if list[k] then
			winsSE = winsSE + 1
		else
			break
		end
	end
	
	for i = 1, n do
		local k = (n-i)*n + i
		if list[k] then
			winsNE = winsNE + 1
		else
			break
		end
	end
	
	if winsSE == n or winsNE == n then
		return true
	else
		return false
	end
end