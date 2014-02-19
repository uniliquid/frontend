local secret = param.get("secret")

local member = Member:new_selector()
  :add_where{ "notify_email_secret = ?", secret }
  :add_where("notify_email_secret_expiry > now()")
  :optional_object_mode()
  :exec()

if member then
  member.notify_email = member.notify_email_unconfirmed
  member.notify_email_unconfirmed   = nil
  member.notify_email_secret        = nil
  member.notify_email_secret_expiry = nil
  member.notify_email_lock_expiry   = nil
  member:save()

if config.default_privilege_after_verification then
  if config.default_privilege_for_unit > 0 then
    local privilege = Privilege:by_pk(config.default_privilege_for_unit, member.id)
    if privilege and not privilege.voting_right then
      privilege.voting_right = true
      privilege:save()
    elseif not privilege then
      privilege = Privilege:new()
      privilege.unit_id = config.default_privilege_for_unit
      privilege.member_id = member.id
      privilege.voting_right = true
      privilege:save()
    end
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
        local membership = Membership:by_pk(area.id, member.id)
        if not membership then
          membership = Membership:new()
          membership.area_id    = area.id
          membership.member_id  = member.id
          membership:save()
        end
      end
    end
  end
end
  slot.put_into("notice", _"Email address is confirmed now")
else
  slot.put_into("error", _"Confirmation code invalid!")
  return false
end
