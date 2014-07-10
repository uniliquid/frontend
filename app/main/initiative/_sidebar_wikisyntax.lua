if config.enforce_formatting_engine ~= 'markdown2' then
  return
end

ui.sidebar( "tab-whatcanido", function()
  ui.sidebarHead( function()
    ui.heading { level = 2, content = _"Formatting help" }
  end )
  ui.sidebarSection( function ()
    ui.heading { level = 3, content = _"Paragraphs" }
    ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Separate each paragraph with at least one blank line" }
      end }
    end }

    ui.heading { level = 3, content = _"Headlines" }
    ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Underline main headlines with ===" }
      end }
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Underline sub headlines with ---" }
      end }
    end }

    ui.heading { level = 3, content = _"Emphasis" }
    ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Put *asterisks* or around a phrase to make it italic" }
      end }
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Put **double asterisks** around a phrase to make it bold" }
      end }
    end }

    ui.heading { level = 3, content = _"Lists" }
    ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Lists must be preceeded and followed by at least one blank line" }
      end }
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Put a hypen (-) or asterisk (*) followed by a space in front of each item" }
      end }
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"For numbered items use a digit (e.g. 1) followed by a dot (.) and a space" }
      end }
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Indent sub items with spaces" }
      end }
    end }

    ui.heading { level = 3, content = _"Links" }
    ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
      ui.tag { tag = "li", content = function ()
        ui.tag { content = _"Use [Text](http://example.com/) for links" }
      end }
    end }

  end )
end )
