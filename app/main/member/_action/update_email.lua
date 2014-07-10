local resend = param.get("resend", atom.boolean)

if not resend and config.locked_profile_fields.notify_email then
  error("access denied")
end

if app.session.member.notify_email_locked then
  if resend then
    slot.put_into("error", _"We have sent an email with activation link already in the last hour. Please try again later.")
  else
    slot.put_into("error", _"You can change your email address only once per hour. Please try again later.")
  end
  return false
end

local email
if resend then
  email = app.session.member.notify_email_unconfirmed
else
  email = param.get("email")
end

email = util.trim(email)

if not email or not email:match('^[^@%s]+@[^@%s]+$') then
  slot.put_into("error", _"This email address is not valid!")
  return false
end

if #email < 5 then
  slot.put_into("error", _"Email address too short!")
  return false
end

if config.email_require_host ~= nil and email:sub(-string.len(config.email_require_host)) ~= config.email_require_host then
  slot.put_into("error", _"Email address is invalid! " .. config.email_requirement_text)
  return false
end

local success = app.session.member:set_notify_email(email)

if not success then
  slot.put_into("error", _"We couldn't deliver a confirmation mail to this address. Please check entered email address.")
  return false
end

slot.put_into("notice", _"Your email address has been changed, please check for confirmation email with activation link!")
