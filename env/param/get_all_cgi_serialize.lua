--[[--
This function returns a string, which contains a serialized table of all GET parameters.
--]]--

function param.get_all_cgi_serialize()
  local params = ''
  for key, value in pairs(param.get_all_cgi()) do
    if key ~= "tempstore" then
      params = params .. key .. "=" .. value .. "&"
    end
  end
  return params
end
