local secret = param.get("secret", atom.secret)
local id = app.session.member_id
local for_unit = param.get("for_unit", atom.integer)

local member = Member:by_id(id)

if not member then
  slot.put_into("error", _"Not logged in!")
  return false
end

local units_selector = Unit:new_selector()

units_selector
  :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
  :add_field("privilege.voting_right", "voting_right")
  :add_field("unit.mail", "mail")

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

trace.disable()

local locked = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_locked_" .. found_unit.id)
local mail = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_" .. found_unit.id)
local stored_secret = Rights:by_pk(app.session.member.id, "mail_ack_unit_mail_secret_" .. found_unit.id)
local matn = Rights:by_pk(app.session.member.id, "matn")

if stored_secret and secret == stored_secret.value then
if matn and not (string.sub(found_unit.mail,1,1) == "@") and not (string.sub(found_unit.mail,1,1) == "^") and not (string.sub(found_unit.mail,1,1) == "!") then

if not locked then
  slot.put_into("error", _"Verification link too old. Please request a new one.")
  return false
end

locked:destroy()
stored_secret:destroy()

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
  local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
  for i, area in ipairs(areas_selector:exec()) do      
    membership = Membership:new()        
    membership.area_id    = area.id
    membership.member_id  = member.id            
    membership:save() 
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

  local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
  for i, area in ipairs(areas_selector:exec()) do      
    local membership = Membership:by_pk(area.id, member.id)
    if not membership then
      membership = Membership:new()
      membership.area_id    = area.id
      membership.member_id  = member.id
      membership:save()
    end
  end

slot.put_into("notice", _"Email address is confirmed now")
return true
elseif string.sub(found_unit.mail,1,1) == "^" or string.sub(found_unit.mail,1,1) == "!" or string.sub(found_unit.mail,1,1) == "@" then
  if not locked then
    slot.put_into("error", _"Verification link too old. Please request a new one.")
    return false
  end
  
  locked:destroy()
  stored_secret:destroy()
  
  local unit_id = found_unit.id
  
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
 
  local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
  for i, area in ipairs(areas_selector:exec()) do
    local membership = Membership:by_pk(area.id, member.id)
    if not membership then
      membership = Membership:new()
      membership.area_id    = area.id
      membership.member_id  = member.id
      membership:save()
    end
  end

  slot.put_into("notice", _"Email address is confirmed now")
  return true
else
  slot.put_into("error", _"Something went wrong...")
  return false
end
else
  slot.put_into("error", _"Confirmation code invalid!")
  return false
end
