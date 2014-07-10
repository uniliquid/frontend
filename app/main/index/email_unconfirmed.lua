if app.session.member.notify_email_unconfirmed then

  local current = Member:new_selector()
    :add_where{ "id = ?", app.session.member_id }
    :add_where("notify_email_unconfirmed NOTNULL")
    :add_where("notify_email_secret_expiry > now()")
    :optional_object_mode()
    :exec()

  ui.title(_"Confirm notification address")

  ui.section( function()
    ui.sectionHead( function()
      ui.heading{ level = 1, content = _"Notification address unconfirmed" }
    end )
    
    ui.sectionRow( function()
      if current then
        ui.tag{
          tag = "div",
          content = _("You didn't confirm your email address '#{email}'. You have received an email with an activation link.", { email = app.session.member.notify_email_unconfirmed })
        }
      else
        ui.tag{
          tag = "div",
          content = _("You didn't confirm your email address '#{email}' within 7 days.", { email = app.session.member.notify_email_unconfirmed })
        }
      end
      slot.put("<br />")

      ui.link{
        text = _"Change email address",
        module = "member",
        view = "settings_email",
      }
      slot.put("<br />")
      slot.put("<br />")

      ui.link{
        text = _("Resend activation email to '#{email}'", { email = app.session.member.notify_email_unconfirmed }),
        module = "member",
        action = "update_email",
        params = {
          resend = true
        },
        routing = {
          default = {
            mode = "redirect",
            module = "index",
            view = "index"
          }
        }
      }
    end )
  end )
end
