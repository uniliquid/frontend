--[[--
Limits a string to a maximum length and avoids cutting within a UTF-8 multibyte character
--]]--


function util.ellipsis(string, length)
  if #string > length then
    local byte = string.byte(string:sub(length, length))
    if byte >= 240 then
      string = string:sub(1, length + 3)
    elseif byte >= 224 then
      string = string:sub(1, length + 2)
    elseif byte >= 192 then
      string = string:sub(1, length + 1)
    else
      string = string:sub(1, length)
    end
    string = string .. "..."
  end
  return string
end
