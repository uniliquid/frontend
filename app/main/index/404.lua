ui.title("404 Not found")

ui.section(function()
  ui.sectionHead(function()
    ui.heading{ level = 1, content = _"Page not found" }
  end)
  ui.sectionRow(function()
    ui.link{
      content = _"Go back to home page",
      module = "index", view = "index"
    }
  end)
end)