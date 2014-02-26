execute.view{ module = "index", view = "_lang_chooser" }

local step = param.get("step", atom.integer)
local code = param.get("code")
if code == nil then
  code = param.get("invite")
end
if config.register_without_invite_code then
  code = "123"
end
local notify_email = param.get("notify_email")
local name = param.get("name")
local login = param.get("login")
local member = nil

ui.form{
  attr = { class = "vertical" },
  module = 'index',
  action = 'register',
  params = {
    code = code,
    notify_email = notify_email,
    name = name,
    login = login
  },
  content = function()

    if step ~= 4 and not code then
      ui.title(_"Registration (step 1 of 3: Invite code)")
      ui.actions(function()
        ui.link{
          content = function()
              slot.put(_"Cancel registration")
          end,
          module = "index",
          view = "index"
        }
      end)
      ui.field.hidden{ name = "step", value = 1 }
      ui.tag{
        tag = "p",
        content = function()
	  slot.put(_"Please enter the invite code you've received.")
        end
      }
      ui.field.text{
        label = _'Invite code',
        name  = 'code',
        value = param.get("invite")
      }
      ui.submit{
        text = _'Proceed with registration'
      }
    end
    if step ~= 4 and not code and config.register_without_invite_code then
      member = Member:new()
    end
    if step ~= 4 and code and not config.register_without_invite_code then
      member = Member:new_selector()
        :add_where{ "invite_code = ?", code }
        :add_where{ "activated ISNULL" }
        :optional_object_mode()
        :exec()
    end

      if step ~= 4 and ((not member or not member.notify_email) and not notify_email or (not member or not member.name) and not name or (not member or not member.login and not login) or step == 1) then
        if config.register_without_invite_code then
          ui.title(_"Registration (step 1 of 2: Personal information)")
        else
          ui.title(_"Registration (step 2 of 3: Personal information)")
        end
        ui.field.hidden{ name = "step", value = 2 }
        ui.actions(function()
         if config.register_without_invite_code and not step == 2 then
          ui.link{
            content = function()
                slot.put(_"One step back")
            end,
            module = "index",
            view = "register",
            params = {
              invite = code
            }
          }
          slot.put(" &middot; ")
         end
          ui.link{
            content = function()
                slot.put(_"Cancel registration")
            end,
            module = "index",
            view = "index"
          }
        end)

       if not config.register_without_invite_code then
        ui.tag{
          tag = "p",
          content = _"This invite key is connected with the following information:"
        }
       end
        
       if not config.register_without_invite_code then
        execute.view{ module = "member", view = "_profile", params = { member = member, include_private_data = true } }
       end

        if not config.locked_profile_fields.notify_email then
          ui.tag{
            tag = "p",
            content = _"Please enter your email address. This address will be used for automatic notifications (if you request them) and in case you've lost your password. This address will not be published. After registration you will receive an email with a confirmation link."
          }
          if config.email_requirement_text ~= nil then
            ui.tag{
              tag = "p",
              content = config.email_requirement_text
            }
          end
          if config.register_without_invite_code and member.notify_email then
            member.notify_email = param.get("notify_email")
          end
          ui.field.text{
            label     = _'Email address',
            name      = 'notify_email',
            value     = param.get("notify_email") or member.notify_email
          }
        end
        if not config.locked_profile_fields.name then
          ui.tag{
            tag = "p",
            content = _"Please choose a name. This name will be PUBLICLY shown to others to identify you. We recommend using a pseudonym."
          }
          if config.register_without_invite_code then
            member.name = param.get("name")
          end
          ui.field.text{
            label     = _'Screen name',
            name      = 'name',
            value     = param.get("name") or member and member.name
          }
        end
        if not config.locked_profile_fields.login then
          ui.tag{
            tag = "p",
            content = _"Please choose a login name. This name will not be shown to others and is used only by you to login into the system. Anyway - we recommend using a pseudonym, so that you do not tell us your real name - we prefer not knowing your real name. The login name is case sensitive."
          }
          if config.register_without_invite_code then
            member.login = param.get("login")
          end
          ui.field.text{
            label     = _'Login name',
            name      = 'login',
            value     = param.get("login")-- or member.login
          }
        end
        ui.submit{
          text = _'Proceed with registration'
        }
      elseif step ~= 4 then
        member = Member:new()
        ui.field.hidden{ name = "step", value = "3" }
        if config.register_without_invite_code then
          ui.title(_"Registration (step 2 of 2: Terms of use and password)")
        else
          ui.title(_"Registration (step 3 of 3: Terms of use and password)")
        end
        ui.actions(function()
          ui.link{
            content = function()
                slot.put(_"One step back")
            end,
            module = "index",
            view = "register",
            params = {
              code = code,
              notify_email = notify_email,
              name = name,
              login = login, 
              step = 1
            }
          }
          slot.put(" &middot; ")
          ui.link{
            content = function()
                slot.put(_"Cancel registration")
            end,
            module = "index",
            view = "index"
          }
        end)
        ui.container{
          attr = { class = "wiki use_terms" },
          content = function()
            if config.use_terms_html then
              slot.put(config.use_terms_html)
            else
              slot.put(format.wiki_text(config.use_terms))
            end
          end
        }

        member.notify_email = notify_email or member.notify_email
        member.name = name or member.name
        member.login = login or member.login
        
        execute.view{ module = "member", view = "_profile", params = {
          member = member, include_private_data = true
        } }
        
        for i, checkbox in ipairs(config.use_terms_checkboxes) do
          slot.put("<br />")
          ui.tag{
            tag = "div",
            content = function()
              ui.tag{
                tag = "input",
                attr = {
                  type = "checkbox",
                  id = "use_terms_checkbox_" .. checkbox.name,
                  name = "use_terms_checkbox_" .. checkbox.name,
                  value = "1",
                  style = "float: left;",
                  checked = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean) and "checked" or nil
                }
              }
              slot.put("&nbsp;")
              ui.tag{
                tag = "label",
                attr = { ['for'] = "use_terms_checkbox_" .. checkbox.name },
                content = function() slot.put(checkbox.html) end
              }
            end
          }
        end

        slot.put("<br />")

        ui.tag{
          tag = "p",
          content = _"Please choose a password and enter it twice. The password is case sensitive."
        }
        ui.field.text{
          readonly  = true,
          label     = _'Login name',
          name      = 'login',
          value     = member.login
        }
        ui.field.password{
          label     = _'Password',
          name      = 'password1',
        }
        ui.field.password{
          label     = _'Password (repeat)',
          name      = 'password2',
        }
        ui.submit{
          text = _'Activate account'
        }
      else
        member = app.session.member
        ui.field.hidden{ name = "step", value = "4" }
        ui.title(_"Accept new Terms of use")
        ui.container{
          attr = { class = "wiki use_terms" },
          content = function()
            if config.use_terms_html then
              slot.put(config.use_terms_html)
            else
              slot.put(format.wiki_text(config.use_terms))
            end
          end
        }
        
        for i, checkbox in ipairs(config.use_terms_checkboxes) do
          slot.put("<br />")
          ui.tag{
            tag = "div",
            content = function()
              ui.tag{
                tag = "input",
                attr = {
                  type = "checkbox",
                  id = "use_terms_checkbox_" .. checkbox.name,
                  name = "use_terms_checkbox_" .. checkbox.name,
                  value = "1",
                  style = "float: left;",
                  checked = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean) and "checked" or nil
                }
              }
              slot.put("&nbsp;")
              ui.tag{
                tag = "label",
                attr = { ['for'] = "use_terms_checkbox_" .. checkbox.name },
                content = function() slot.put(checkbox.html) end
              }
            end
          }
        end

        slot.put("<br />")

        ui.submit{
          text = _'Confirm'
        }
      end
    end
}


