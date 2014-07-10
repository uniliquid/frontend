local unit = param.get("unit", "table")

ui.title ( function ()

  ui.tag{ attr = { class = "unit" }, content = function()
    -- unit link
    ui.link {
      attr = { class = "unit" },
      content = function()
        ui.tag{ attr = { class = "name" }, content = unit.name }
      end,
      module = "unit", view = "show",
      id = unit.id
    }

    execute.view {
      module = "delegation", view = "_info", params = { 
        unit = unit, member = member
      }
    }

    if config.single_unit_id and not app.session.member_id and config.motd_public then
      ui.container{
        attr = { class = "wiki motd" },
        content = function()
          slot.put(config.motd_public)
        end
      }
    end
  end }
  
end )