function ui.wikitextarea(name, label)

  -- wiki engine selector
  ui.field.select{
    label = _"Wiki engine",
    name = "formatting_engine",
    foreign_records = {
      { id = "compat",     name = _"Traditional wiki syntax" },
      { id = "rocketwiki", name = "RocketWiki" }
    },
    attr = {
      id = "formatting_engine",
      onChange = "wikiToolbar.switchMode(document.getElementById('formatting_engine').value);"
    },
    foreign_id = "id",
    foreign_name = "name",
    value = param.get("formatting_engine")
  }

  -- wiki syntax help
  ui.tag{
    tag = "div",
    content = function()
      ui.tag{
        tag = "label",
        attr = { class = "ui_field_label" },
        content = function() slot.put("&nbsp;") end,
      }
      ui.tag{
        content = function()
          ui.link{
            text = _"Syntax help",
            module = "help",
            view = "show",
            id = "wikisyntax",
            attr = {
              onClick = "this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)" }
          }
          slot.put(" ")
          ui.link{
            text = _"(new window)",
            module = "help",
            view = "show",
            id = "wikisyntax",
            attr = {
              onClick = "this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)",
              target = "_blank"
            }
          }
        end
      }
    end
  }

  -- textarea
  ui.field.text{
    label = label,
    name = name,
    multiline = true,
    attr = {
      style = "height: 50ex; margin-left: 29%",
      id = "content_text"
    },
    value = param.get(name)
  }

  -- wiki toolbar
  slot.put("\
<script type=\"text/javascript\" src=\"../static/wikitoolbar/prototype.js\"></script>\
<script type=\"text/javascript\" src=\"../static/wikitoolbar/jstoolbar.js\"></script>\
<script type=\"text/javascript\" src=\"../static/wikitoolbar/wikitoolbar.js\"></script>\
<script type=\"text/javascript\">\
//<![CDATA[\
jsToolBar.strings = {};\
jsToolBar.strings['Strong']            = '" .. _"[wikitoolbar] Strong" .. "';\
jsToolBar.strings['Italic']            = '" .. _"[wikitoolbar] Italic" .. "';\
jsToolBar.strings['Heading 1']         = '" .. _"[wikitoolbar] Heading 1" .. "';\
jsToolBar.strings['Heading 2']         = '" .. _"[wikitoolbar] Heading 2" .. "';\
jsToolBar.strings['Heading 3']         = '" .. _"[wikitoolbar] Heading 3" .. "';\
jsToolBar.strings['Unordered list']    = '" .. _"[wikitoolbar] Unordered list" .. "';\
jsToolBar.strings['Ordered list']      = '" .. _"[wikitoolbar] Ordered list" .. "';\
jsToolBar.strings['Link']              = '" .. _"[wikitoolbar] Link" .. "';\
var wikiToolbar = new jsToolBar($('content_text'));\
wikiToolbar.draw(document.getElementById('formatting_engine').value);\
//]]>\
</script>\
")

end
