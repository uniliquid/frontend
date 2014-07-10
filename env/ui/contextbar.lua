function ui.contextbar ( arg1, arg2 )

  local class = "sidebarSection"
  local content
  
  if arg2 then
    class = class .. " " .. arg1
    content = arg2
  else
    content = arg1
  end

  slot.select ( "contextbar", function ()
    ui.container { attr = { class = class }, content = content }
  end )

end
