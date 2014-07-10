local initiative = param.get("initiative", "table")
local member = param.get("member", "table") or app.session.member

-- TODO performance
local initiator
if member then
  initiator = Initiator:by_pk(initiative.id, member.id)
end

local initiators_members_selector = initiative:get_reference_selector("initiating_members")
  :add_field("initiator.accepted", "accepted")
  :add_order_by("member.name")
if initiator and initiator.accepted then
  initiators_members_selector:add_where("initiator.accepted ISNULL OR initiator.accepted")
else
  initiators_members_selector:add_where("initiator.accepted")
end

local initiators = initiators_members_selector:exec()


ui.sectionHead( "initiativeInfo", function ()

    ui.heading { 
      level = 1,
      content = initiative.display_name
    }

    ui.container { attr = { class = "support" }, content = function ()
      if initiative.supporter_count == nil then
        ui.tag { 
          attr = { class = "supporterCount" },
          content = _"[calculating]"
        }
      elseif initiative.issue.closed == nil then
        ui.tag { 
          attr = { class = "satisfiedSupporterCount" },
          content = _("#{count} supporter", { count = initiative.satisfied_supporter_count })
        }
        if initiative.potential_supporter_count and
            initiative.potential_supporter_count > 0 
        then
          slot.put ( " " )
          ui.tag { 
            attr = { class = "potentialSupporterCount" },
            content = _("(+ #{count} potential)", { count = initiative.potential_supporter_count })
          }
        end
      
      end 
      
      slot.put ( "<br />" )
      
      execute.view {
        module = "initiative", view = "_bargraph", params = {
          initiative = initiative
        }
      }
    end }
    
    if member then
      ui.container { attr = { class = "mySupport right" }, content = function ()
        if initiative.issue.fully_frozen then
          if initiative.issue.member_info.direct_voted then
            --ui.image { attr = { class = "icon48 right" }, static = "icons/48/voted_ok.png" }
            ui.tag { content = _"You have voted" }
            slot.put("<br />")
            if not initiative.issue.closed then
              ui.link {
                module = "vote", view = "list", 
                params = { issue_id = initiative.issue.id },
                text = _"change vote"
              }
            else
              ui.link {
                module = "vote", view = "list", 
                params = { issue_id = initiative.issue.id },
                text = _"show vote"
              }
            end
            slot.put(" ")
          elseif active_trustee_id then
            ui.tag { content = _"You have voted via delegation" }
            ui.link {
              content = _"Show voting ballot",
              module = "vote", view = "list", params = {
                issue_id = initiative.issue.id, member_id = active_trustee_id
              }
            }
          elseif not initiative.issue.closed then
            ui.link {
              attr = { class = "btn btn-default" },
              module = "vote", view = "list", 
              params = { issue_id = initiative.issue.id },
              text = _"vote now"
            }
          end
        elseif initiative.member_info.supported then
          if initiative.member_info.satisfied then
            ui.image { attr = { class = "icon48 right" }, static = "icons/32/support_satisfied.png" }
          else
            ui.image { attr = { class = "icon48 right" }, static = "icons/32/support_unsatisfied.png" }
          end           
          ui.container { content = _"You are supporter" }

          if initiative.issue.member_info.own_participation then
            ui.link {
              attr = { class = "btn-link" },
              module = "initiative", action = "remove_support", 
              routing = { default = {
                mode = "redirect", module = "initiative", view = "show", id = initiative.id
              } },
              id = initiative.id,
              text = "remove my support"
            }
            
          else
            
            ui.link {
              module = "delegation", view = "show", params = {
                issue_id = initiative.issue_id,
                initiative_id = initiative.id
              },
              content = _"via delegation" 
            }
            
          end
          
          slot.put(" ")
      

        else
          ui.link {
            attr = { class = "btn btn-default" },
            module = "initiative", action = "add_support", 
            routing = { default = {
              mode = "redirect", module = "initiative", view = "show", id = initiative.id
            } },
            id = initiative.id,
            text = _"add my support"
          }
            
        end
      end }
      
    end
    
    slot.put("<br style='clear: both;'/>")

    ui.container {
      attr = { class = "initiators" },
      content = function ()
      
        if app.session:has_access("authors_pseudonymous") then
          for i, member in ipairs(initiators) do
            if i > 1 then
              slot.put(" ")
            end
            util.micro_avatar(member)
            if member.accepted == nil then
              slot.put ( " " )
              ui.tag { content = _"(invited)" }
            end
          end -- for i, member
          
        end
          
      end
    } -- ui.container "initiators"

    ui.container {
      attr = { class = "links" },
      content = function ()
        
        local drafts_count = initiative:get_reference_selector("drafts"):count()
        ui.link {
          content = _("suggestions (#{count}) ↓", {
            count = # ( initiative.suggestions )
          }),
          external = "#suggestions"
        }

        slot.put ( " | " )
          
        ui.link{
          module = "initiative", view = "history", id = initiative.id,
          content = _("draft history (#{count})", { count = drafts_count })
        }
        
      end
    } -- ui.containers "links"
  end )
 
  execute.view {
    module = "initiative", view = "_sidebar_state",
    params = { initiative = initiative }
  }

