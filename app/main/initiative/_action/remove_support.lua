local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

-- TODO important m1 selectors returning result _SET_!
local issue = initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.fully_frozen then 
  slot.put_into("error", _"Voting for this issue has already begun.")
  return false
end

local member = app.session.member

local supporter = Supporter:by_pk(initiative.id, member.id)

if not param.get("confirm", atom.boolean) then

  -- find suggestions, which have opinions only by this member
  local suggestions_count = Suggestion:new_selector()
    :add_where{ "suggestion.initiative_id = ?", initiative.id }
    :join("opinion", nil, "opinion.suggestion_id = suggestion.id")
    :add_where{ "opinion.member_id = ?", member.id }
    :left_join("opinion", "opinion_others", { "opinion_others.suggestion_id = suggestion.id AND opinion_others.member_id != ?", member.id })
    :add_where("opinion_others.member_id ISNULL")
    :count()
  if suggestions_count > 0 then
    slot.select("warning", function()
      local linktext
      if suggestions_count == 1 then
        slot.put(_"There is one suggestion, for which only you entered an opinion. If you withdraw your support, this suggestion will be deleted!")
        linktext = _"Withdraw support and delete the suggestion"
      else
        slot.put(_("There are #{count} suggestions, for which only you entered an opinion. If you withdraw your support, these suggestions will be deleted!", { count = suggestions_count }))
        linktext = _"Withdraw support and delete the suggestions"
      end
      slot.put("<br />")
      ui.link{
        text    = linktext,
        module  = "initiative",
        action  = "remove_support",
        id      = initiative.id,
        params  = { confirm = true },
        routing = {
          default = {
            mode   = "redirect",
            module = "initiative",
            view   = "show",
            id     = initiative.id,
          }
        },
        external = "../../initiative/remove_support" -- workaround for bug in WebMCP
      }
    end )
    return false
  end

end

if supporter then  
  supporter:destroy()
  slot.put_into("notice", _"Your support has been removed from this initiative")
else
  slot.put_into("notice", _"You are already not supporting this initiative")
end
