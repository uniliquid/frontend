trace.disable()
    
local secret = param.get("secret")

if not secret then

  local member = Member:new_selector()
    :add_where{ "login = ? OR notify_email = ?", param.get("login"), param.get("login") }
    :optional_object_mode()
    :exec()

  if not member then
    slot.put_into("error", _"Sorry, aber ein Account mit diesem Anmeldenamen oder mit dieser Email-Adresse existiert nicht. Bitte wende Dich an den Administrator oder den Support.")
    return false
  end
  if member.password_reset_secret then
    slot.put_into("error", _"Sorry, aber für diesen Account wurde bereits ein Passwort angefordert. Bitte wende Dich an den Administrator oder den Support.")
    return false
  end
  if member then
    if not member.notify_email then
      slot.put_into("error", _"Sorry, but there is not confirmed email address for your account. Please contact the administrator or support.")
      return false
    end
    member.password_reset_secret = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
    local expiry = db:query("SELECT now() + '1 days'::interval as expiry", "object").expiry
    member.password_reset_secret_expiry = expiry
    member:save()
    local content = slot.use_temporary(function()
      slot.put(_"Hello " .. member.name .. ",\n\n")
      slot.put(_"your login name is: " .. member.login .. "\n\n")
      slot.put(_"To reset your password please click on the following link:\n\n")
      slot.put(request.get_absolute_baseurl() .. "index/reset_password.html?secret=" .. member.password_reset_secret .. "\n\n")
      slot.put(_"If this link is not working, please open following url in your web browser:\n\n")
      slot.put(request.get_absolute_baseurl() .. "index/reset_password.html\n\n")
      slot.put(_"On that page please enter the reset code:\n\n")
      slot.put(member.password_reset_secret .. "\n\n")
      slot.put(_"The reset code is only valid for one day.\n\n")
    end)
    local success = net.send_mail{
      envelope_from = config.mail_envelope_from,
      from          = config.mail_from,
      reply_to      = config.mail_reply_to,
      to            = member.notify_email,
      subject       = config.mail_subject_prefix .. _"Password reset request",
      content_type  = "text/plain; charset=UTF-8",
      content       = content
    }
  end

  slot.put_into("notice", _"Reset link has been send for this member")

else
  local member = Member:new_selector()
    :add_where{ "password_reset_secret = ?", secret }
    :add_where{ "password_reset_secret_expiry > now()" }
    :optional_object_mode()
    :exec()

  if not member then
    slot.put_into("error", _"Reset code is invalid!")
    return false
  end

  local password1 = param.get("password1")
  local password2 = param.get("password2")

  if password1 ~= password2 then
    slot.put_into("error", _"Passwords don't match!")
    return false
  end

  if #password1 < 8 then
    slot.put_into("error", _"Passwords must consist of at least 8 characters!")
    return false
  end

  member:set_password(password1)
  member.password_reset_secret = nil
  member.password_reset_secret_expiry = nil
  member:save()

  slot.put_into("notice", _"Password has been reset successfully")

end
