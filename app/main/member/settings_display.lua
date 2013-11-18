ui.title(_"Display settings")

util.help("member.settings.display", _"Display settings")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_display",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    local hvalue
    if app.session.member then
      local setting_key = "liquidfeedback_frontend_hide_new_issues"
      local setting = Setting:by_pk(app.session.member.id, setting_key)
      hvalue = setting and setting.value
    end
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "hide_new_issues",
          type = "checkbox", name = "new_issues", value = "default",
          checked = hvalue ~= nil and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "hide_new_issues" },
        content = _"Hide new issues per default"
      }
    end }

    local dvalue
    if app.session.member then
      local setting_key = "liquidfeedback_frontend_show_only_direct"
      local setting = Setting:by_pk(app.session.member.id, setting_key)
      dvalue = setting and setting.value
    end
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "show_only_direct",
          type = "checkbox", name = "only_direct", value = "default",
          checked = dvalue ~= nil and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "show_only_direct" },
        content = _"Show only issues in direct policies in 'Not yet voted'-tab"
      }
    end }

    local mvalue
    if app.session.member then
      local setting_key = "liquidfeedback_frontend_show_only_membership"
      local setting = Setting:by_pk(app.session.member.id, setting_key)
      mvalue = setting and setting.value
    end

    slot.put("<br />")
    
    ui.container{ content = function()
      ui.tag{
        tag = "input",
        attr = {
          id = "show_only_membership",
          type = "checkbox", name = "only_membership", value = "default",
          checked = mvalue ~= nil and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "show_only_membership" },
        content = _"Show only issues i am interested in in 'Not yet voted'-tab"
      }
    end }
     
    slot.put("<br />")

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
          checked = svalue == nil and "checked" or svalue == config.absolute_base_url .. 'static/style.css' and "checked" or nil
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
          checked = svalue == config.absolute_base_url .. 'static/friendly.css' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "friendly" },
        content = _"Friendly (by c3o)"
      }
    end }

    slot.put("<br />")

    ui.submit{ value = _"Change display settings" }
  end
}
 
