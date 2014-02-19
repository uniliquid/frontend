app.html_title.title = _"Datenschutzerklärung"

slot.put("<br />")

ui.container{
  attr = { class = "wiki use_terms" },
  content = function()
    slot.put(config.privacy_terms)
  end
}
