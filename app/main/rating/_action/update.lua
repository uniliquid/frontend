local member_id = app.session.member.id

local argument_id = param.get("argument_id", atom.integer)

local rating = Rating:by_pk(member_id, argument_id)

local argument = Argument:by_id(argument_id)

if not argument then
  slot.put_into("error", _"This argument does not exist!")
  return false
end

-- TODO important m1 selectors returning result _SET_!
local issue = argument.initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed!")
  return false
elseif issue.fully_frozen then
  slot.put_into("error", _"Voting for this issue has already begun!")
  return false
end

if param.get("delete", atom.boolean) then
  if rating then
    rating:destroy()
  end
  slot.put_into("notice", _"Your rating has been deleted.")
  return
end

if not app.session.member:has_voting_right_for_unit_id(argument.initiative.issue.area.unit_id) then
  error("access denied")
end

if not rating then
  rating = Rating:new()
  rating.issue_id      = argument.initiative.issue_id
  rating.initiative_id = argument.initiative_id
  rating.member_id     = member_id
  rating.argument_id   = argument_id
end

rating.negative = param.get("negative", atom.boolean)

rating:save()

--slot.put_into("notice", _"Your rating has been updated.")
