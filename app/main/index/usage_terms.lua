app.html_title.title = _"Terms of use"

slot.put("<br />")

ui.container{
  attr = { class = "wiki use_terms" },
  content = function()
    slot.put(format.wiki_text(config.use_terms))
  end
}
