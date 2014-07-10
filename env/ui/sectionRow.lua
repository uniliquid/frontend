function ui.sectionRow ( arg1, arg2 )

  local class = "sectionRow"
  local content
  
  if arg2 then
    class = class .. " " .. arg1
    content = arg2
  else
    content = arg1
  end

  ui.container { attr = { class = class }, content = content }

end
