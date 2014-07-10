local member = param.get("member", "table")

ui.sidebar( "tab-whatcanido", function()

  if not member.active then
    ui.container{ attr = { class = "sidebarSection" }, content = function()
      slot.put(" &middot; ")
      ui.tag{
        attr = { class = "interest deactivated_member_info" },
        content = _"This member is inactive"
      }
    end }   
  end
  
  if member.locked then
    ui.container{ attr = { class = "sidebarSection" }, content = function()
      slot.put(" &middot; ")
      ui.tag{
        attr = { class = "interest deactivated_member_info" },
        content = _"This member is locked"
      }
    end }   
  end

  
  ui.sidebarHeadWhatCanIDo()

  if member.id == app.session.member_id and not app.session.needs_delegation_check then
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to customize my profile" }
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        ui.tag{ tag = "li", content = function()
          ui.link{
            content = _"edit profile data",
            module  = "member",
            view    = "edit"
          }
        end }
        ui.tag{ tag = "li", content = function()
          ui.link{
            content = _"change avatar/photo",
            module  = "member",
            view    = "edit_images"
          }
        end }
      end }
    end )
    --[[
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to manage my saved contacts" }
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        ui.tag{ tag = "li", content = function()

          ui.link{
            content = _"show saved contacts",
            module = 'contact',
            view   = 'list'
          }

        end }
      end }
    end )
    --]]
    
    ui.sidebarSection( function()

      ui.heading { level = 3, content = _"I want to change account settings" }

      local pages = {}

      pages[#pages+1] = { view = "settings_notification", text = _"notification settings" }
      if not config.locked_profile_fields.notify_email then
        pages[#pages+1] = { view = "settings_email",          text = _"change your notification email address" }
      end
      if not config.locked_profile_fields.name then
        pages[#pages+1] = { view = "settings_name",           text = _"change your screen name" }
      end
      if not config.locked_profile_fields.login then
        pages[#pages+1] = { view = "settings_login",          text = _"change your login" }
      end
      pages[#pages+1] = { view = "settings_password",       text = _"change your password" }
      pages[#pages+1] = { view = "developer_settings",      text = _"developer settings" }

      if config.download_dir then
        pages[#pages+1] = { module = "index", view = "download",      text = _"database download" }
      end

      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        for i, page in ipairs(pages) do
          ui.tag{ tag = "li", content = function()
            ui.link{
              module = page.module or "member",
              view = page.view,
              text = page.text
            }
          end }
        end
      end }
    end )
    
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to logout" }
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        ui.tag{ tag = "li", content = function()
          ui.link{
            text   = _"logout",
            module = 'index',
            action = 'logout',
            routing = {
              default = {
                mode = "redirect",
                module = "index",
                view = "index"
              }
            }
          }
        end }
      end }
    end )
    
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to change the interface language" }
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        for i, lang in ipairs(config.enabled_languages) do
          
          local langcode
          
          locale.do_with({ lang = lang }, function()
            langcode = _("[Name of Language]")
          end)
          
          ui.tag{ tag = "li", content = function()
            ui.link{
              content = _('Select language "#{langcode}"', { langcode = langcode }),
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
          end }
        end
      end }
    end )
  elseif app.session.member_id and not (member.id == app.session.member.id) then
    
    ui.sidebarSection( function ()

      local contact = Contact:by_pk(app.session.member.id, member.id)
      if not contact then
        ui.heading { level = 3, content = _"I want to save this member as contact (i.e. to use as delegatee)" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link{
              text    = _"add to my list of public contacts",
              module  = "contact",
              action  = "add_member",
              id      = member.id,
              params = { public = true },
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
          end }
          ui.tag { tag = "li", content = function ()
            ui.link{
              text    = _"add to my list of private contacts",
              module  = "contact",
              action  = "add_member",
              id      = member.id,
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
          end }
        end }
      elseif contact.public then
        ui.heading { level = 3, content = _"You saved this member as contact (i.e. to use as delegatee) and others can see it" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link{
              text   = _"make this contact private",
              module = "contact",
              action = "add_member",
              id     = contact.other_member_id,
              params = { public = false },
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
          end }
          ui.tag { tag = "li", content = function ()
            ui.link{
              text   = _"remove from my contact list",
              module = "contact",
              action = "remove_member",
              id     = contact.other_member_id,
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
          end }
        end }
      else
        ui.heading { level = 3, content = _"You saved this member as contact (i.e. to use as delegatee)" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link{
              text   = _"make this contact public",
              module = "contact",
              action = "add_member",
              id     = contact.other_member_id,
              params = { public = true },
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
          end }
          ui.tag { tag = "li", content = function ()
            ui.link{
              text   = _"remove from my contact list",
              module = "contact",
              action = "remove_member",
              id     = contact.other_member_id,
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
          end }
        end }
      end
    end )
    
    ui.sidebarSection( function()
      local ignored_member = IgnoredMember:by_pk(app.session.member.id, member.id)
      if not ignored_member then
        ui.heading { level = 3, content = _"I do not like to hear from this member" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link{
              attr = { class = "interest" },
              text    = _"block this member",
              module  = "member",
              action  = "update_ignore_member",
              id      = member.id,
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
          end }
        end }
      else
        ui.heading { level = 3, content = _"You blocked this member (i.e. you will not be notified about this members actions)" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link{
              text   = _"unblock member",
              module = "member",
              action = "update_ignore_member",
              id     = member.id,
              params = { delete = true },
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
          end }
        end }
      end
    end )
  end
end )