local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local member = param.get ( "member", "table" )


ui.title ( function ()

  ui.tag {
    attr = { class = "unit" },
    content = function()
      ui.link {
        content = function()
          ui.tag{ attr = { class = "name" }, content = issue.area.unit.name }
        end,
        module = "unit", view = "show",
        id = issue.area.unit.id
      }
    end
  }
  ui.tag { attr = { class = "spacer" }, content = function()
    slot.put ( " » " )
  end }

  ui.tag {
    attr = { class = "area" },
    content = function()
      ui.link {
        content = function()
          ui.tag{ attr = { class = "name" }, content = issue.area.name }
        end,
        module = "area", view = "show",
        id = issue.area.id
      }
    end
  }

  ui.tag { attr = { class = "spacer" }, content = function()
    slot.put ( " » " )
  end }
  
  ui.tag {
    attr = { class = "issue" },
    content = function()
      -- issue link
      ui.link {
        text = _("#{policy_name} ##{issue_id}", { 
          policy_name = issue.policy.name,
          issue_id = issue.id
        } ),
        module = "issue", view = "show",
        id = issue.id
      }

      slot.put ( " " )
      
      if member then
        execute.view {
          module = "delegation", view = "_info", params = { 
            issue = issue, member = member, for_title = true
          }
        }
      end
    end
  }
  
  if initiative then
    ui.tag{
      attr = { class = "initiative" },
      content = initiative.display_name
    }
  end
  
end ) -- ui.title
