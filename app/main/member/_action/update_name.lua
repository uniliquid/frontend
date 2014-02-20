if config.locked_profile_fields.name then
  error("access denied")
end

local name = param.get("name")

name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"This name is too short!")
  return false
end

if #name > config.max_nick_length then
  slot.put_into("error", _"This name is too long!")
  return false
end

local member = app.session.member

--local entries = member:get_reference_selector("history_entries"):add_where("until + '30 days'::interval > NOW()"):add_order_by("id DESC"):exec()
local entries = db:query({ "SELECT DISTINCT name FROM member_history WHERE member_id = ? AND until + '30 days'::interval > NOW() GROUP BY name;", member.id }, "opt_object")

local name_changed = false
local name_error = false
local db_error = nil
local check_member = Member:by_name(name)
if check_member then
  if check_member.id ~= app.session.member.id then
    name_error = true
  else
    slot.put_into("notice", _"Your name has not changed")
    return true
  end
end

if entries ~= nil and #entries >= 2 then
  slot.put_into("error", _"You already changed your name 2 times in the last 30 days.")
  return false
end

if not name_error then
  app.session.member.name = name

  db_error = app.session.member:try_save()
end
if name_error then
  slot.put_into("error", _"This name is too similar to the name of someone else, please choose a different one!")
  return false
elseif db_error then
  if db_error:is_kind_of("IntegrityConstraintViolation.UniqueViolation") then
    slot.put_into("error", _"This name is too similar to the name of someone else, please choose a different one!")
    return false
  end
  db_error:escalate()
end

slot.put_into("notice", _"Your name has been changed")
