local issue_id = assert(param.get("issue_id", atom.integer), "no issue id given")

local interest = Interest:by_pk(issue_id, app.session.member.id)

local issue = Issue:new_selector():add_where{ "id = ?", issue_id }:for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.fully_frozen then 
  slot.put_into("error", _"Voting for this issue has already begun.")
  return false
end

local member = app.session.member

if not param.get("confirm", atom.boolean) then

  -- find suggestions, which have opinions only by this member
  local suggestions_count = Suggestion:new_selector()
    :join("initiative", nil, "suggestion.initiative_id = initiative.id")
    :add_where{ "initiative.issue_id = ?", issue.id }
    :join("opinion", nil, "opinion.suggestion_id = suggestion.id")
    :add_where{ "opinion.member_id = ?", member.id }
   :left_join("opinion", "opinion_others", { "opinion_others.suggestion_id = suggestion.id AND opinion_others.member_id != ?", member.id })
    :add_where("opinion_others.member_id ISNULL")
    :count()
  if suggestions_count > 0 then
    slot.select("warning", function()
      local linktext
      if suggestions_count == 1 then
        slot.put(_"There is one suggestion, for which only you entered an opinion. If you withdraw your interest, this suggestion will be deleted!")
        linktext = _"Withdraw interest and delete the suggestion"
      else
        slot.put(_("There are #{count} suggestions, for which only you entered an opinion. If you withdraw your interest, these suggestions will be deleted!", { count = suggestions_count }))
        linktext = _"Withdraw interest and delete the suggestions"
      end
      slot.put("<br />")
      ui.link{
        text    = linktext,
        module  = "interest",
        action  = "update",
        id      = issue.id,
        params  = { issue_id = issue.id, delete = true, confirm = true },
        routing = {
          default = {
            mode   = "redirect",
            module = param.get("module"),
            view   = "show",
            id     = param.get("id", atom.integer),
          }
        },
        external = "../../interest/update" -- workaround for bug in WebMCP
      }
    end )
    return false
  end

end

if param.get("delete", atom.boolean) then
  if interest then
    interest:destroy()
    slot.put_into("notice", _"Your interest has been removed from this issue.")
   else
    slot.put_into("notice", _"You are already not interested in this issue.")
  end
  return
end

if not app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
  error("access denied")
end

if not interest then
  interest = Interest:new()
  interest.issue_id   = issue_id
  interest.member_id  = app.session.member_id
end

interest:save()

--slot.put_into("notice", _"Interest updated")
