local issue = param.get("issue", "table")
local hide_initiatives = param.get("hide_initiatives", atom.boolean)
local highlight_initiative_id = param.get ( "highlight_initiative_id", "number" )

ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHead( function()
    ui.heading {
      level = 2,
      content = _"Competing initiatives"
    }
  end )
  
  execute.view {
    module = "initiative", view = "_list",
    params = {
      issue = issue,
      initiatives = issue.initiatives,
      highlight_initiative_id = highlight_initiative_id
    }
  }
  if #issue.initiatives == 1 then
    ui.sidebarSection( function ()
    
      if not issue.closed and not (issue.state == "voting") then
        ui.container { content = function()
        ui.tag { content = _"Currently this is the only initiative in this issue, because nobody started a competing initiative (yet)." }
          if app.session.member and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
            slot.put(" ")
            ui.tag { content = _"To create a competing initiative see below." }
          end
        end }
      else
        ui.container { content = _"This is the only initiative in this issue, because nobody started a competing initiative." }
      end
    end )
  end

end ) -- ui.sidebar
