local id = param.get_id()

local member = Member:by_id(id) or Member:new()

param.update(member, "identification", "notify_email", "admin")

local locked = param.get("locked", atom.boolean)
if locked ~= nil then
  member.locked = locked
end
local deactivate = param.get("deactivate", atom.boolean)
if deactivate then
  member.active = false
  member.activated = nil
  last_activity = nil
  member.password = nil
end
local login = param.get("login")
if login then
  member.login = login
end
local name = param.get("name")
if name then
  member.name = name
end
local identification = param.get("identification")
if identification then
  identification = util.trim(identification)
  if identification == "" then
    identification = nil
  end
end
member.identification = identification

local avatar_delete = param.get("avatar_delete", atom.boolean)
if avatar_delete then
  local member_id = id
  local image_type = "avatar"
  local member_image = MemberImage:by_pk(member_id, image_type, false)
  local member_image_scaled = MemberImage:by_pk(member_id, image_type, true)

  if member_image then
    member_image:destroy()
  end
  if member_image_scaled then
    member_image_scaled:destroy()
  end
end

local photo_delete = param.get("photo_delete", atom.boolean)
if photo_delete then
  local member_id = id
  local image_type = "photo"
  local member_image = MemberImage:by_pk(member_id, image_type, false)
  local member_image_scaled = MemberImage:by_pk(member_id, image_type, true)

  if member_image then
    member_image:destroy()
  end
  if member_image_scaled then
    member_image_scaled:destroy()
  end
end

local err = member:try_save()

if err then
  slot.put_into("error", (_("Error while updating member, database reported:<br /><br /> (#{errormessage})"):gsub("#{errormessage}", tostring(err.message))))
  return false
end

if not id and config.single_unit_id then
  local privilege = Privilege:new()
  privilege.member_id = member.id
  privilege.unit_id = config.single_unit_id
  privilege.voting_right = true
  privilege:save()
end

local units = Unit:new_selector()
  :add_field("privilege.member_id NOTNULL", "privilege_exists")
  :add_field("privilege.voting_right", "voting_right")
  :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
  :exec()

for i, unit in ipairs(units) do
  local value = param.get("unit_" .. unit.id, atom.boolean)
  if value and not unit.privilege_exists then
    privilege = Privilege:new()
    privilege.unit_id = unit.id
    privilege.member_id = member.id
    privilege.voting_right = true
    privilege:save()
  elseif not value and unit.privilege_exists then
    local privilege = Privilege:by_pk(unit.id, member.id)
    privilege:destroy()
  end
end

if not member.activated and param.get("invite_member", atom.boolean) then
  member:send_invitation()
  slot.put_into("notice", _"Member invited")
elseif member.activated and param.get("password_reset", atom.boolean) then
  Member:send_password_reset(member.id)
  slot.put_into("notice", _"Sent password reset link")
elseif not member.activated and param.get("deactivate", atom.boolean) then
  slot.put_into("notice", _"Account deactivated. Email will be copied from admidio on next full hour. Invitation will be send then as well.")
elseif not member.activated and param.get("invite_member", atom.boolean) then
  member:send_invitation()
  slot.put_into("notice", _"Member invited")
elseif id then
  slot.put_into("notice", _"Member successfully updated")
else
  slot.put_into("notice", _"Member successfully registered")
end
