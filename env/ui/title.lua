function ui.title ( content )
  
  slot.select ( "title", function ()
    
    -- home link
    ui.link {
      module = "index", view = "index",
      attr = { class = "home", title = _"Home" },
      content = function ()
        ui.image { 
          attr = { class = "icon24", alt = title },
          static = "icons/48/home.png"
        }
      end
    }
  
    if content then
      ui.tag { attr = { class = "spacer" }, content = function()
        slot.put ( " » " )
      end }
      ui.tag { tag = "span", content = content }
    else
      ui.tag { attr = { class = "spacer" }, content = function()
        slot.put ( " " )
      end }
      ui.tag { tag = "span", content = _"Home" }
    end
    
  end )
  
end
