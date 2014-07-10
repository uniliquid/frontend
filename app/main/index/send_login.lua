ui.title(_"Recover login name")

ui.section( function()

  ui.sectionHead( function()
    ui.heading{ level = 1, content = _"Request email with login name" }
  end )

  ui.sectionRow( function()

    ui.tag{
      tag = 'p',
      content = _'Please enter your email address. You will receive an email with your login name.'
    }
    ui.form{
      attr = { class = "vertical" },
      module = "index",
      action = "send_login",
      routing = {
        ok = {
          mode = "redirect",
          module = "index",
          view = "index"
        }
      },
      content = function()
        ui.field.text{ 
          label = _"Email address",
          name = "email"
        }

        ui.container { attr = { class = "actions" }, content = function()
          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              class = "btn btn-default",
              value = _"Request email with login name"
            },
            content = ""
          }
          slot.put("<br /><br />")
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
  end )
end )