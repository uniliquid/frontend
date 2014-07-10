ui.title(_"Developer settings")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

local setting_key = "liquidfeedback_frontend_developer_features"
local setting = Setting:by_pk(app.session.member.id, setting_key)

if true or setting then
  ui.section( function()
    ui.sectionHead( function ()
      ui.heading{ content = "CSS development settings" }
    end )

    ui.sectionRow( function()
      ui.form{
        attr = { class = "vertical" },
        module = "member",
        action = "update_stylesheet_url",
        routing = {
          ok = {
            mode = "redirect",
            module = "member",
            view = "show",
            id = app.session.member_id
          }
        },
        content = function()
          local setting_key = "liquidfeedback_frontend_stylesheet_url"
          local setting = Setting:by_pk(app.session.member.id, setting_key)
          local value = setting and setting.value
          ui.field.text{ 
            label = "stylesheet URL",
            name = "stylesheet_url",
            value = value
          }
          ui.submit{ value = _"Set URL" }
        end
      }
    end )
  end )
end

ui.section( function()
  ui.sectionHead( function ()
    ui.heading{ content = "API keys" }
  end )

  ui.sectionRow( function()
    local member_applications = MemberApplication:new_selector()
      :add_where{ "member_id = ?", app.session.member.id }
      :add_order_by("name, id")
      :exec()
      
    if #member_applications > 0 then

      ui.list{
        records = member_applications,
        columns = {
          {
            name = "name",
            label = "Name"
          },
          {
            name = "access_level",
            label = "Access level"
          },
          {
            name = "key",
            label = "API Key"
          },
          {
            name = "last_usage",
            label = "Last usage"
          },
          {
            content = function(member_application)
              ui.link{
                text = "delete",
                module = "member", action = "update_api_key", id = member_application.id,
                params = { delete = true },
                routing = {
                  default = {
                    mode = "redirect",
                    module = "member",
                    view = "developer_settings"
                  }
                }
              }
            end
          },
        }
      }

    else
      
      slot.put(_"Currently no API key is set.")
      slot.put(" ")
      ui.link{
        text = _"Generate API key",
        module = "member",
        action = "update_api_key",
        routing = {
          default = {
            mode = "redirect",
            module = "member",
            view = "developer_settings"
          }
        }
      }
    end
  end )
end )