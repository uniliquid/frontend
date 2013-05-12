local secret = param.get("secret")
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

local locked = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_locked_" .. found_unit.id)
local mail = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_" .. found_unit.id)
local stored_secret = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_secret_" .. found_unit.id)
local matn = Rights:by_pk(app.session.member.id, "matn")

if matn and found_unit and not found_unit.voting_right and stored_secret and secret == stored_secret.value then

if not locked then
  slot.put_into("error", _"Verification link too old. Please request a new one.")
  return false
end

locked.value = nil
locked:save()
stored_secret.value = nil
stored_secret:save()

local unit_id = 1
local privilege = Privilege:by_pk(unit_id, member.id)
if privilege and not privilege.voting_right then
  privilege.voting_right = true
  privilege:save()
elseif not privilege then
  privilege = Privilege:new()
  privilege.unit_id = unit_id
  privilege.member_id = member.id
  privilege.voting_right = true
  privilege:save()
end

unit_id = found_unit.id

local privilege = Privilege:by_pk(unit_id, member.id)
if privilege and not privilege.voting_right then
  privilege.voting_right = true
  privilege:save()
elseif not privilege then
  privilege = Privilege:new()
  privilege.unit_id = unit_id
  privilege.member_id = member.id
  privilege.voting_right = true
  privilege:save()
end

slot.put_into("notice", _"Email address is confirmed now")
return true
else
  slot.put_into("error", _"Confirmation code invalid!" .. secret .. " " .. stored_secret)
  return false
end
