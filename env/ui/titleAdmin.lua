function ui.titleAdmin(title)
  ui.title(function()
    ui.link { module = "admin", view = "index", content = _"System administration" }
    if title then
      ui.tag { tag = "span", content = content }
    end
  end)
end