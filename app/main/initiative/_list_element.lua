local initiative = param.get("initiative", "table")
local for_event = param.get("for_event", atom.boolean)

local issue = initiative.issue

local class = "initiative"

if initiative.rank == 1 then
  class = class .. " rank1"
end

if initiative.revoked then
  class = class .. " revoked"
end

ui.container{
  attr = { class = class },
  content = function ()
    if initiative.rank ~= 1 and not for_event then
      execute.view {
        module = "initiative", view = "_bargraph", params = {
          initiative = initiative,
          battled_initiative = issue.initiatives[1]
        }
      }
      slot.put(" ")
    end
    ui.tag {
      attr = { class = "initiative_name" },
      content = function()
        ui.link {
          text = initiative.display_name,
          module = "initiative", view = "show", id = initiative.id
        }
        slot.put(" ")
        if initiative.vote_grade ~= nil then
          if initiative.vote_grade > 0 then
            local text = _"voted yes"
            ui.image { attr = { class = "icon16", title = text, alt = text }, static = "icons/32/support_satisfied.png" }
          elseif initiative.vote_grade == 0 then
          elseif initiative.vote_grade < 0 then
            local text = _"voted no"
            ui.image { attr = { class = "icon16", title = text, alt = text }, static = "icons/32/voted_no.png" }
          end
        elseif app.session.member then
          if initiative.member_info.supported then
            if initiative.member_info.satisfied then
              local text = _"supporter"
              ui.image { attr = { class = "icon16", title = text, alt = text }, static = "icons/32/support_satisfied.png" }
            else
              local text = _"supporter with restricting suggestions"
              ui.image { attr = { class = "icon16", title = text, alt = text }, static = "icons/32/support_unsatisfied.png" }
            end           
          end
        end
      end
    }

  end
}

if initiative.rank == 1 
  and issue.voter_count 
  and initiative.positive_votes ~= nil 
  and initiative.negative_votes ~= nil 
  and not for_event
then
  function percent(p, q)
    if q > 0 then
      return math.floor(p / q * 100) .. "%"
    else
      return "0%"
    end
  end
  local result = ""
  if initiative.eligible then
    result = _("Reached #{sign}#{num}/#{den}", {
      sign = issue.policy.direct_majority_strict and ">" or "≥",
      num = issue.policy.direct_majority_num,
      den = issue.policy.direct_majority_den
    })
  else
    result = _("Failed  #{sign}#{num}/#{den}", {
      sign = issue.policy.direct_majority_strict and ">" or "≥",
      num = issue.policy.direct_majority_num,
      den = issue.policy.direct_majority_den
    })
  end
  local neutral_count = issue.voter_count - initiative.positive_votes - initiative.negative_votes
  
  local result_text 
  
  if issue.voter_count > 0 then
    result_text = _("#{result}: #{yes_count} Yes (#{yes_percent}), #{no_count} No (#{no_percent}), #{neutral_count} Abstention (#{neutral_percent})", {
      result = result,
      yes_count = initiative.positive_votes,
      yes_percent = percent(initiative.positive_votes, issue.voter_count),
      neutral_count = neutral_count,
      neutral_percent = percent(neutral_count, issue.voter_count),
      no_count = initiative.negative_votes,
      no_percent = percent(initiative.negative_votes, issue.voter_count)
    })
  else
    result_text = _("#{result}: No votes (0)", { result = result })
  end
  
  ui.container { attr = { class = "result" }, content = result_text }

end
      
