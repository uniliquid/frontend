local member_id = app.session.member.id

local suggestion_id = param.get("suggestion_id", atom.integer)

local opinion = Opinion:by_pk(member_id, suggestion_id)

local suggestion = Suggestion:by_id(suggestion_id)

if not suggestion then
  slot.put_into("error", _"This suggestion has been meanwhile deleted")
  return false
end

-- TODO important m1 selectors returning result _SET_!
local issue = suggestion.initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.fully_frozen then 
  slot.put_into("error", _"Voting for this issue has already begun.")
  return false
end

if param.get("delete") then
  if opinion then
    if not param.get("confirm", atom.boolean) then

      -- find other opinions to this suggestion
      local opinions_count = Opinion:new_selector()
        :add_where{ "suggestion_id = ?", suggestion.id }
        :add_where{ "member_id != ?", member_id }
        :count()
      if opinions_count == 0 then
        slot.select("warning", function()
          slot.put(_"You are the only one who rated this suggestion. If you rate it neutral now, it will be deleted!")
          slot.put("<br />")
          ui.link{
            text    = _"Rate neutral and delete the suggestion",
            module  = "opinion",
            action  = "update",
            id      = suggestion.initiative_id,
            params  = { suggestion_id = suggestion.id, delete = true, confirm = true },
            routing = {
              default = {
                mode   = "redirect",
                module = "suggestion",
                view   = "show",
                id     = suggestion.id,
                params = { initiative_id = suggestion.initiative_id }
              }
            },
            external = "../../opinion/update" -- workaround for bug in WebMCP
          }
        end )
        return false
      end

    end
    opinion:destroy()
  end
  --slot.put_into("notice", _"Your rating has been deleted")
  return
end

local degree = param.get("degree", atom.number)
local fulfilled = param.get("fulfilled", atom.boolean)

if degree ~= 0 and not app.session.member:has_voting_right_for_unit_id(suggestion.initiative.issue.area.unit_id) then
  error("access denied")
end

if not opinion then
  opinion = Opinion:new()
  opinion.member_id     = member_id
  opinion.suggestion_id = suggestion_id
  opinion.fulfilled     = false
end


if degree ~= nil then
  opinion.degree = degree
end

if fulfilled ~= nil then
  opinion.fulfilled = fulfilled
end

opinion:save()

--slot.put_into("notice", _"Your rating has been updated")
