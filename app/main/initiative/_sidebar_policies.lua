local area = param.get("area", "table")

ui.sidebar ( "tab-whatcanido", function ()
  ui.sidebarHead( function()
    ui.heading { level = 2, content = _"Available policies" }
  end )
  execute.view { module = "policy", view = "_list", params = {
    for_area = area
  } }
end )