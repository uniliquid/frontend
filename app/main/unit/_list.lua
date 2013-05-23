local units = Unit:get_flattened_tree{ active = true }

ui.container{ attr = { class = "box" }, content = function()

  ui.list{
    attr = { class = "unit_list" },
    records = units,
    columns = {
      {
        content = function(unit)
          for i = 1, unit.depth - 1 do
            slot.put("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
          end
          ui.link{ text = function()
              ui.image{ attr = { class = "spaceicon", style = "width: 16px; height: 16px;" }, static = "icons/units/" .. unit.name .. ".ico" }
              ui.tag{ content = unit.name }
            end,
            module = "unit", view = "show", id = unit.id }
        end 
      }
    }
  }
  
end }
