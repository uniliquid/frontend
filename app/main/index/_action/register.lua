local code = util.trim(param.get("code"))

local step = param.get("step", atom.integer)

if app.session.member and step == 4 then
  for i, checkbox in ipairs(config.use_terms_checkboxes) do
    local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
    if not accepted then
      slot.put_into("error", checkbox.not_accepted_error)
      return false
    end
  end  
  
  member = app.session.member
  local now = db:query("SELECT now() AS now", "object").now

  for i, checkbox in ipairs(config.use_terms_checkboxes) do
    local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
    member:set_setting("use_terms_checkbox_" .. checkbox.name, "accepted at " .. tostring(now))
  end

  member:save()

  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "index",
  }
  return
end

local member = nil
if config.register_without_invite_code then
  member = Member:new()
else
  member = Member:new_selector()
    :add_where{ "invite_code = ?", code }
    :add_where{ "activated ISNULL" }
    :add_where{ "NOT locked" }
    :optional_object_mode()
    :for_update()
    :exec()
end
  
if not member then
  slot.put_into("error", _"The code you've entered is invalid")
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register"
  }
  return false
end

local notify_email = param.get("notify_email")

if not config.locked_profile_fields.notify_email and notify_email then
  local success = true
  if #notify_email < 5 then
    slot.put_into("error", _"Email address too short!")
    success = false
  elseif config.email_require_host ~= nil and notify_email:sub(-string.len(config.email_require_host)) ~= config.email_require_host then
    slot.put_into("error", _"Email address is invalid! " .. config.email_requirement_text)
    success = false
  end
  if not success then
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = { code = member.invite_code }
    }
    return false
  end
end

if member and not notify_email then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { code = member.invite_code, step = 1 }
  }
  return false
end


local name = util.trim(param.get("name"))

if not config.locked_profile_fields.name and name then

  if #name < 3 then
    slot.put_into("error", _"This screen name is too short!")
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = {
        code = member.invite_code,
        notify_email = notify_email,
        step = 1
      }
    }
    return false
  end
  
  if #name > config.max_nick_length then
    slot.put_into("error", _"This screen name is too long!")
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = {
        code = member.invite_code,
        notify_email = notify_email,
        step = 1
      }
    }
    return false
  end

  local check_member = Member:by_name(name)
  if check_member and check_member.id ~= member.id then
    slot.put_into("error", _"This name is already taken, please choose another one!")
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = {
        code = member.invite_code,
        notify_email = notify_email,
        step = 1
      }
    }
    return false
  end

  member.name = name

end

if notify_email and not member.name then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = {
      code = member.invite_code,
      notify_email = notify_email,
      step = 1
    }
  }
  return false
end


local login = util.trim(param.get("login"))

if not config.locked_profile_fields.login and login then
  if #login < 3 then 
    slot.put_into("error", _"This login is too short!")
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = { 
        code = member.invite_code,
        notify_email = notify_email,
        name = member.name,
        step = 1
      }
    }
    return false
  end

  local check_member = Member:by_login(login)
  if check_member and check_member.id ~= member.id then 
    slot.put_into("error", _"This login is already taken, please choose another one!")
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = { 
        code = member.invite_code,
        notify_email = notify_email,
        name = member.name,
        step = 1
      }
    }
    return false
  end
  member.login = login
end

if member.name and not member.login then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = member.invite_code,
      notify_email = notify_email,
      name = member.name,
      step = 1
    }
  }
  return false
end

if step > 2 then

  for i, checkbox in ipairs(config.use_terms_checkboxes) do
    local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
    if not accepted then
      slot.put_into("error", checkbox.not_accepted_error)
      return false
    end
  end  

  local password1 = param.get("password1")
  local password2 = param.get("password2")

  if login and not password1 then
    request.redirect{
      mode   = "redirect",
      module = "index",
      view   = "register",
      params = { 
        code = member.invite_code,
        notify_email = notify_email,
        name = member.name,
        login = member.login
      }
    }
  --]]
    return false
  end

  if password1 ~= password2 then
    slot.put_into("error", _"Passwords don't match!")
    return false
  end

  if #password1 < 8 then
    slot.put_into("error", _"Passwords must consist of at least 8 characters!")
    return false
  end

  if not config.locked_profile_fields.login then
    member.login = login
  end

  if not config.locked_profile_fields.name then
    member.name = name
  end

  if notify_email ~= member.notify_email then
    local success = member:set_notify_email(notify_email)
    if not success then
      slot.put_into("error", _"Can't send confirmation email")
      return
    end
  end
  
  member:set_password(password1)

  local now = db:query("SELECT now() AS now", "object").now

  for i, checkbox in ipairs(config.use_terms_checkboxes) do
    local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
    member:set_setting("use_terms_checkbox_" .. checkbox.name, "accepted at " .. tostring(now))
  end

  member.activated = 'now'
  member.active = true
  member.last_activity = 'now'
  member.last_login = "now"
  if config.register_without_invite_code and member.identification == nil then
    member.identification = member.notify_email
  end
  if member.lang == nil then
    member.lang = app.session.lang
  else
    app.session.lang = member.lang
  end
  member:save()

  app.session.member = member
  app.session:save()
if not config.default_privilege_after_verification then
  if config.default_privilege_for_unit > 0 then
    privilege = Privilege:new()
    privilege.unit_id = config.default_privilege_for_unit
    privilege.member_id = member.id
    privilege.voting_right = true
    privilege:save()
  end

  local units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
  
  if member then
    units:load_delegation_info_once_for_member_id(member.id)
  end

  for i, unit in ipairs(units) do
    if member:has_voting_right_for_unit_id(unit.id) then
      local areas_selector = Area:new_selector()
        :reset_fields()
        :add_field("area.id", nil, { "grouped" })
        :add_where{ "area.unit_id = ?", unit.id }
        :add_where{ "area.active" }
        :add_where{ "area.name NOT LIKE '%Sandkasten%'" }
      for i, area in ipairs(areas_selector:exec()) do
        membership = Membership:by_pk(area.id,member.id)
        if membership == nil then
          membership = Membership:new()
          membership.area_id    = area.id
          membership.member_id  = member.id
          membership:save()
        end
      end
    end
  end
end
  slot.put_into("notice", _"You've successfully registered!")

  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "index",
  }
end
  
