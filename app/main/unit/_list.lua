local for_admin = param.get("for_admin", atom.boolean)
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
          if for_admin then
            ui.link{ text = unit.name, module = "admin", view = "unit_edit", id = unit.id }
          else
            ui.link{ text = unit.name, module = "unit", view = "show", id = unit.id }
          end
        end 
      }
    }
  }
  
end }