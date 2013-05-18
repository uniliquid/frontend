local id = app.session.member_id
local for_unit = param.get("for_unit", atom.integer)

local member = Member:by_id(id)

local units_selector = Unit:new_selector()

if member then
  units_selector
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :add_field("privilege.voting_right", "voting_right")
end

local units = units_selector:exec()

local found_unit
for i, unit in ipairs(units) do
  if unit.id == for_unit then
    found_unit = unit
  end
end

if not found_unit then
  slot.put_into("error", _"No such unit!")
  return false
end

local expiry = db:query("SELECT now() + '1 days'::interval as expiry", "object").expiry
local locked = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_locked_" .. found_unit.id)
local mail = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_" .. found_unit.id)
local secret = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_secret_" .. found_unit.id)

if found_unit and not found_unit.voting_right then
if found_unit.mail and string.find(found_unit.mail, 'XXXXXXX') then
local matn = Rights:by_pk(app.session.member.id, "matn")
local param_matn = param.get("matn", atom.string)
if not (matn or (param_matn and string.len(param_matn) == 7)) and not (string.sub(found_unit.mail,1,1) == "^") then
  slot.put_into("error", _"Your matriculation number is invalid.")
  return false
elseif not matn then
  local matn_db = Rights:by_kv("matn", param_matn)
  if matn_db and not matn_db.member_id == app.session.member.id then
    slot.put_into("error", _"Your matriculation number is already taken.")
    return false
  end
end

if not matn then
  matn = Rights:new()
  matn.member_id = app.session.member.id
  matn.key = "matn"
  matn.value = param.get("matn")
  matn:save()
end
local email = string.gsub(found_unit.mail, "XXXXXXX", matn.value)

if locked then
  slot.put_into("error", _"You can request verification mails only once per hour. Please try again later.")
  return false
end
trace.disable()
if not secret then
  secret = Rights:new()
  secret.member_id = app.session.member.id
  secret.key = "mail_ack_unit_mail_secret_" .. found_unit.id
end
secret.value = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
secret:save()

local success = app.session.member:send_mail_verification(email, secret.value, found_unit.id)

if not success then
  slot.put_into("error", _"We couldn't deliver a confirmation mail to this address. Please check entered email address.")
  return false
end

if not locked then
  locked = Rights:new()
  locked.member_id = app.session.member.id
  locked.key = "mail_ack_unit_mail_locked_" .. found_unit.id
end
locked.value = expiry
locked:save()

if not mail then
  mail = Rights:new()
  mail.member_id = app.session.member.id
  mail.key = "mail_ack_unit_mail_" .. found_unit.id
end
mail.value = email
mail:save()

slot.put_into("notice", _"Verification mail sent!")

return true
elseif found_unit.mail and string.len(found_unit.mail) > 5 and string.sub(found_unit.mail,1,1) == "^" then
  local host = ""
  local mask = ""
  for w in string.gmatch(found_unit.mail, "@.*") do
    host = w
  end
  local email = param.get("email", atom.string)
  local valid = true
  for w in string.gmatch(found_unit.mail, ".") do
    mask = w
    if w ~= '^' then
      if string.find(email, w) then
        invalid = false
        break
      end
    end
    if w == '@' then
      break
    end
  end
  if valid and not (email and string.sub(email,-string.len(host))==host) then
    slot.put_into("error", _"Your student mail address is not valid for this university." .. valid)
    return false
  end
  
  local email_db = Rights:by_kv("email", email)
  if email_db and not matn_db.member_id == app.session.member.id then
    slot.put_into("error", _"Your student mail address is already taken.")
    return false
  end
  
  if locked then
    slot.put_into("error", _"You can request verification mails only once per hour. Please try again later.")
    return false
  end
  trace.disable()
  if not secret then
    secret = Rights:new()
    secret.member_id = app.session.member.id
    secret.key = "mail_ack_unit_mail_secret_" .. found_unit.id
  end
  secret.value = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
  secret:save()
  
  local success = app.session.member:send_mail_verification(email, secret.value, found_unit.id)
  
  if not success then
    slot.put_into("error", _"We couldn't deliver a confirmation mail to this address. Please check entered email address.")
    return false
  end
  
  if not locked then
    locked = Rights:new()
    locked.member_id = app.session.member.id
    locked.key = "mail_ack_unit_mail_locked_" .. found_unit.id
  end
  locked.value = expiry
  locked:save()
  
  if not mail then
    mail = Rights:new()
    mail.member_id = app.session.member.id
    mail.key = "mail_ack_unit_mail_" .. found_unit.id
  end
  mail.value = email
  mail:save()
  
  slot.put_into("notice", _"Verification mail sent!")
  return true
elseif found_unit.mail and string.len(found_unit.mail) > 5 then
  local email = param.get("email", atom.string)
  if not (email and string.sub(email,-string.len(found_unit.mail))==found_unit.mail) then
    slot.put_into("error", _"Your student mail address is not valid for this university.")
    return false
  end

  local email_db = Rights:by_kv("email", email)
  if email_db and not matn_db.member_id == app.session.member.id then
    slot.put_into("error", _"Your student mail address is already taken.")
    return false
  end

  if locked then
    slot.put_into("error", _"You can request verification mails only once per hour. Please try again later.")
    return false
  end
  trace.disable()
  if not secret then
    secret = Rights:new()
    secret.member_id = app.session.member.id
    secret.key = "mail_ack_unit_mail_secret_" .. found_unit.id
  end
  secret.value = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
  secret:save()

  local success = app.session.member:send_mail_verification(email, secret.value, found_unit.id)

  if not success then
    slot.put_into("error", _"We couldn't deliver a confirmation mail to this address. Please check entered email address.")
    return false
  end

  if not locked then
    locked = Rights:new()
    locked.member_id = app.session.member.id
    locked.key = "mail_ack_unit_mail_locked_" .. found_unit.id
  end
  locked.value = expiry
  locked:save()

  if not mail then
    mail = Rights:new()
    mail.member_id = app.session.member.id
    mail.key = "mail_ack_unit_mail_" .. found_unit.id
  end
  mail.value = email
  mail:save()

  slot.put_into("notice", _"Verification mail sent!")
  return true
end
end 

slot.put_into("error", _"You recently tried to get voting rights for this unit. Please try again later.")
return false
