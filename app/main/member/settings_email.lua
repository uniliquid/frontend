ui.titleMember(_"Email address")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_email",
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
        ui.heading { level = 1, content = _"Email address for notifications" }
      end )

      ui.sectionRow( function()
        if app.session.member.notify_email then
          ui.field.text{ label = _"confirmed address", value = app.session.member.notify_email, readonly = true }
        end
        if app.session.member.notify_email_unconfirmed then
          ui.field.text{ label = _"unconfirmed address", value = app.session.member.notify_email_unconfirmed, readonly = true }
        end
        if app.session.member.notify_email or app.session.member.notify_email_unconfirmed then
          slot.put("<br />")
        end
        ui.heading { level = 2, content = _"Enter a new email address:" }
        ui.field.text{ name = "email" }
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
        ui.link{
          content = _"Cancel",
          module = "member", view = "show", id = app.session.member.id
        }
      end )
    end )
  end
}

