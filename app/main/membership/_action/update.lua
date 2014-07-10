local area_id = assert(param.get("area_id", atom.integer), "no area id given")
local membership = Membership:by_pk(area_id, app.session.member.id)

local area = Area:by_id(area_id)
if param.get("delete", atom.boolean) then
  if membership then
    membership:destroy()
    slot.put_into("notice", _"Subscription removed")
  else
    slot.put_into("notice", _"Subscription already removed")
  end
  return
end

if not app.session.member:has_voting_right_for_unit_id(area.unit_id) then
  slot.put_into("error", _"You are not eligible to participate")
  return false
end

if not membership then
  membership = Membership:new()
  membership.area_id    = area_id
  membership.member_id  = app.session.member_id
  membership:save()
  slot.put_into("notice", _"Subject area subscribed")
end
