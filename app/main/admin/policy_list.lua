local show_not_in_use = param.get("show_not_in_use", atom.boolean) or false

local policies = Policy:build_selector{ active = not show_not_in_use }:exec()


ui.titleAdmin(_"Policy list")

ui.section( function()
  ui.sectionHead( function()
    ui.heading { level = 1, content = _"Policy list" }
  end )
  
  ui.sectionRow( function()

    if show_not_in_use then
      ui.link{
        text = _"Show policies in use",
        module = "admin",
        view = "policy_list"
      }

    else
      ui.link{
        text = _"Create new policy",
        module = "admin",
        view = "policy_show"
      }
      slot.put(" &middot; ")
      ui.link{
        text = _"Show policies not in use",
        module = "admin",
        view = "policy_list",
        params = { show_not_in_use = true }
      }

    end

  end )
  
  ui.sectionRow( function()

    ui.list{
      records = policies,
      columns = {

        { content = function(record)
            ui.link{
              text = record.name,
              module = "admin",
              view = "policy_show",
              id = record.id
            }
          end
        }

      }
    }

  end )
end )