execute.view{ module = "index", view = "_lang_chooser" }

ui.title(_"Reset password")

ui.section( function()

  ui.sectionHead( function()
    ui.heading{ level = 1, content = _"Reset password" }
  end )

  ui.sectionRow( function()


    local secret = param.get("secret")

    if not secret then
      ui.tag{
        tag = 'p',
        content = _'Please enter your login name. You will receive an email with a link to reset your password.'
      }
      ui.form{
        attr = { class = "vertical" },
        module = "index",
        action = "reset_password",
        routing = {
          ok = {
            mode = "redirect",
            module = "index",
            view = "index"
          }
        },
        content = function()
          ui.field.text{ 
            label = _"login name",
            name = "login"
          }

          ui.container { attr = { class = "actions" }, content = function()
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "btn btn-default",
                value = _"Request password reset link"
              },
              content = ""
            }
            slot.put("<br /><br />")
            ui.link{ module = "index", view = "send_login", text = _"Forgot login name?" }
            slot.put("&nbsp;&nbsp;")
            ui.link{
              content = function()
                  slot.put(_"Cancel")
              end,
              module = "index",
              view = "login"
            }
          end }
        end
      }

    else

      ui.form{
        attr = { class = "vertical" },
        module = "index",
        action = "reset_password",
        routing = {
          ok = {
            mode = "redirect",
            module = "index",
            view = "index"
          }
        },
        content = function()
          ui.tag{
            tag = 'p',
            content = _'Please enter the email reset code you have received:'
          }
          ui.field.text{
            label = _"Reset code",
            name = "secret",
            value = secret
          }
          ui.tag{
            tag = 'p',
            content = _'Please enter your new password twice.'
          }
          ui.field.password{
            label = "New password",
            name = "password1"
          }
          ui.field.password{
            label = "New password (repeat)",
            name = "password2"
          }
          
          ui.container { attr = { class = "actions" }, content = function()
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "btn btn-default",
                value = _"Save new password"
              },
              content = ""
            }
            slot.put("<br />")
            slot.put("<br />")

            ui.link{
              content = function()
                  slot.put(_"Cancel")
              end,
              module = "index",
              view = "login"
            }
          end }
        end
      }

    end
  end )
end )