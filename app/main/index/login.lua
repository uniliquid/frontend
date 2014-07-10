ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available.")
  end
}

ui.title(_"Login")
app.html_title.title = _"Login"

execute.view{ module = "index", view = "_sidebar_motd_public" }

ui.section(function() 

ui.sectionHead(function()
  ui.heading{ level = 1, content = _"Login" }
  ui.container { attr = { class = "right" }, content = function()
    for i, lang in ipairs(config.enabled_languages) do

      locale.do_with({ lang = lang }, function()
        langcode = _("[Name of Language]")
      end)
      
      if i > 1 then
        slot.put(" | ")
      end
      
      ui.link{
        content = function()
          ui.tag{ content = langcode }
        end,
        module = "index",
        action = "set_lang",
        params = { lang = lang },
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    end
  end }
end)
ui.form{
  module = 'index',
  action = 'login',
  routing = {
    ok = {
      mode   = 'redirect',
      module = param.get("redirect_module") or "index",
      view = param.get("redirect_view") or "index",
      id = param.get("redirect_id"),
    },
    error = {
      mode   = 'forward',
      module = 'index',
      view   = 'login',
    }
  },
  content = function()
    ui.sectionRow(function()
      ui.field.text{
        attr = { id = "username_field" },
        label     = _'Login name',
        name = 'login',
        value     = ''
      }
      ui.script{ script = 'document.getElementById("username_field").focus();' }
      ui.field.password{
        label     = _'Password',
        name = 'password',
        value     = ''
      }
      ui.container { attr = { class = "actions" }, content = function()
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "btn btn-default",
            value = _'Login'
          },
          content = ""
        }
        slot.put("<br />")
        slot.put("<br />")
        ui.link{ module = "index", view = "reset_password", text = _"Forgot password?" }
        slot.put("&nbsp;&nbsp;")
        ui.link{ module = "index", view = "send_login", text = _"Forgot login name?" }
      end }
    end )
  end
}
end )