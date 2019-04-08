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
