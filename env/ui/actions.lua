function ui.actions(content)
  slot.select("actions", function()
    ui.container{ attr = { class = "actions" }, content = content }
  end)
end