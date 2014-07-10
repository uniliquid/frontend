ui.titleMember(_"login name")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  attr = { class = "wide" },
  module = "member",
  action = "update_login",
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
        ui.heading { level = 1, content = _"Login name" }
      end )

      ui.sectionRow( function()
        ui.heading { level = 2, content = _"Enter a new login name" }
        ui.field.text{ name = "login", value = app.session.member.login }
        
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

