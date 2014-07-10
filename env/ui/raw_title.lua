function ui.raw_title ( content )
  
  slot.select ( "title", function ()
  
    -- home link
    ui.link {
      module = "index", view = "index",
      attr = { class = "home" },
      content = function ()
        ui.image { static = "icons/16/house.png" }
      end
    }
    
    slot.put ( " " )
    
    slot.put ( content )
    
  end )
  
end
