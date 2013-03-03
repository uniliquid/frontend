--[[--
This function returns a table, which was stored serialized in a GET parameter.
--]]--

function param.get_unserialize(name)
  local params = {}
  for key, value in string.gmatch(param.get(name) or "", "([^=&]+)=([^=&]+)&") do
    params[key] = value
  end
  return params
end
