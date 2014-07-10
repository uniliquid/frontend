local return_to = param.get("return_to")

ui.titleMember("notification settings")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_notify_level",
  routing = {
    ok = {
      mode = "redirect",
      module = return_to == "home" and "index" or "member",
      view = return_to == "home" and "index" or "show",
      id = return_to ~= "home" and app.session.member_id or nil
    }
  },
  content = function()

    ui.section( function()

      ui.sectionHead( function()
        ui.heading { level = 1, content = _"For which issue phases do you like to receive notification emails?" }
      end )

    
      ui.sectionRow( function()
      
        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_all",
              type = "radio", name = "notify_level", value = "all",
              checked = app.session.member.notify_level == 'all' and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_all" },
            content = _"I like to receive notifications"
          }
        end }
        
        slot.put("<br />")

        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_discussion",
              type = "radio", name = "notify_level", value = "discussion",
              checked = app.session.member.notify_level == 'discussion' and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_discussion" },
            content = _"Only for issues reaching the discussion phase"
          }
        end }

        slot.put("<br />")

        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_verification",
              type = "radio", name = "notify_level", value = "verification",
              checked = app.session.member.notify_level == 'verification' and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_verification" },
            content = _"Only for issues reaching the verification phase"
          }
        end }
        
        slot.put("<br />")

        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_voting",
              type = "radio", name = "notify_level", value = "voting",
              checked = app.session.member.notify_level == 'voting' and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_voting" },
            content = _"Only for issues reaching the voting phase"
          }
        end }

        slot.put("<br />")

        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_none",
              type = "radio", name = "notify_level", value = "none",
              checked = app.session.member.notify_level == 'none' and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_none" },
            content = _"I do not like to receive notifications by email"
          }
        end }
        
        slot.put("<br />")
      
        ui.container { content = _"Notifications are only send to you about events in the subject areas you subscribed, the issues you are interested in and the initiatives you are supporting." }


        slot.put("<br />")
        
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "btn btn-default",
            value = _"Save"
          },
          content = ""
        }
        slot.put("<br /><br /><br />")
        
        slot.put(" ")
        if return_to == "home" then
          ui.link {
            module = "index", view = "index",
            content = _"cancel"
          }
        else
          ui.link {
            module = "member", view = "show", id = app.session.member_id, 
            content = _"cancel"
          }
        end
      end ) 
    end )
    
  end
}
 
