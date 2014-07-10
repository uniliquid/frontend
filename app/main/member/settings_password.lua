ui.titleMember(_"Password")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  attr = { class = "wide" },
  module = "member",
  action = "update_password",
  routing = {
    ok = {
      mode = "redirect",
      module = "member",
      view = "show",
      id = app.session.member_id
    }
  },
  content = function()
    ui.section( function()
      ui.sectionHead( function()
        ui.heading { level = 1, content = _"Password" }
      end )

      ui.sectionRow( function()
        ui.heading { level = 2, content = _"Enter your current password:" }
        ui.field.password{ name = "old_password" }

        slot.put("<br />")
        
        ui.heading { level = 2, content = _"Enter a new password:" }
        ui.field.password{ name = "new_password1" }

        ui.heading { level = 2, content = _"Enter your new password again please:" }
        ui.field.password{ name = "new_password2" }

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
        ui.link {
          module = "member", view = "show", id = app.session.member_id, 
          content = _"Cancel"
        }
      end )
    end )
  end
}