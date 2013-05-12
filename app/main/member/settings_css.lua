ui.title(_"Stylesheet settings")

util.help("member.settings.stylesheet", _"Stylesheet settings")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_css",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    local svalue
    if app.session.member then
      local setting_key = "liquidfeedback_frontend_stylesheet_url"
      local setting = Setting:by_pk(app.session.member.id, setting_key)
      svalue = setting and setting.value
    end

    ui.tag{ tag = "p", content = _"I like to use the following Stylesheet:" }
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "css_default",
          type = "radio", name = "css", value = "default",
          checked = svalue == nil and "checked" or svalue == config.absolute_base_url .. '/static/style.css' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "css_default" },
        content = _"Standard"
      }
    end }
     
    slot.put("<br />")
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "friendly",
          type = "radio", name = "css", value = "friendly",
          checked = svalue == config.absolute_base_url .. '/static/friendly.css' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "friendly" },
        content = _"Friendly (by c3o)"
      }
    end }

    slot.put("<br />")

    ui.submit{ value = _"Change stylesheet settings" }
  end
}
 
