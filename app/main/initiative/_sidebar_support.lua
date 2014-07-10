if not app.session.member then
  return
end

local initiative = param.get("initiative", "table")

local initiative_info = initiative.member_info
local issue_info = initiative.issue.member_info

local active_trustee_id
if not issue_info.own_participation then
  if issue_info.first_trustee_participation then
    active_trustee_id = issue_info.first_trustee_id
  elseif issue_info.other_trustee_participation then
    active_trustee_id = issue_info.other_trustee_id
  end
end


slot.select ( "sidebar", function ()
  
  if 
    not initiative.issue.fully_frozen
    and not initiative.issue.closed
    and (issue_info.own_participation or active_trustee_id)
  then
    ui.container {
      attr = { class = "tab-whatcanido sidebarSection" },
      content = function ()

        
        if initiative_info.supported then
          ui.heading { level = 1, content = function ()
            ui.tag { content = _"I'm supporting this initiative" }
            if issue_info.weight then
              slot.put ( " " )
              ui.link {
                module = "delegation", view = "show_incoming", params = {
                  issue_id = initiative.issue_id,
                  member_id = app.session.member_id
                },
                content = "+" .. issue_info.weight
              }
            end
          end }
          
        else
          ui.heading { level = 1, content = function ()
            ui.tag { content = _"I'm interested in this issue" }
            if issue_info.weight then
              slot.put ( " " )
              ui.link {
                module = "delegation", view = "show_incoming", params = {
                  issue_id = initiative.issue_id,
                  member_id = app.session.member_id
                },
                content = "+" .. issue_info.weight
              }
            end
          end }
        end

        if active_trustee_id then
          ui.tag { content = _"via delegation" }
        elseif issue_info.first_trustee_id then
          ui.tag { content = _"delegation suspended during discussion" }
        end
      end
    }
  end
      
  if 
    initiative.issue.fully_frozen and
    (issue_info.direct_voted or active_trustee_id)
  then
    ui.container {
      attr = { class = "tab-whatcanido sidebarSection" },
      content = function ()
      
        if issue_info.direct_voted then
          ui.heading { level = 1, content = _"You have been voted" }
          ui.link {
            content = _"Show my voting ballot",
            module = "vote", view = "list", params = {
              issue_id = initiative.issue.id
            }
          }
        else
          
          
          if active_trustee_id then
            ui.heading { level = 1, content = _"You have been voted" }
            ui.container { 
              content = _"via delegation"
            }
            ui.link {
              content = _"Show voting ballot",
              module = "vote", view = "list", params = {
                issue_id = initiative.issue.id, member_id = active_trustee_id
              }
            }
          end
        end
      end
    }
  end
end )
        