local initiative = param.get("initiative", "table")
local batteled_initiative = param.get("battled_initiative", "table")

local grey = "#eee"

if initiative.issue.fully_frozen and initiative.issue.closed
   and initiative.negative_votes and initiative.positive_votes and initiative.rank ~= 1 then
    if not batteled_initiative then
      return
    end
    local battle1 = Battle:getByInitiativeIds(batteled_initiative.id, initiative.id)
    local battle2 = Battle:getByInitiativeIds(initiative.id, batteled_initiative.id)
    
    if not battle1 or not battle2 then
      return
    end
    
    local positive_votes = battle2.count
    local negative_votes = battle1.count
    
    local max_value = initiative.issue.voter_count
    if max_value > 0 then
      ui.bargraph{
        max_value = max_value * 2,
        width = 100,
        bars = {
          { color = grey, value = max_value - negative_votes },
          { color = "#a00", value = negative_votes },
          { color = "#0a0", value = positive_votes },
          { color = grey, value = max_value - positive_votes },
        }
      }
    else
      ui.bargraph{
        max_value = 1,
        width = 100,
        bars = {
          { color = grey, value = 1 },
        }
      }
    end
else
  local max_value = initiative.issue.population or 0
  local quorum
  if initiative.issue.accepted then
    quorum = initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den
  else
    quorum = initiative.issue.policy.issue_quorum_num / initiative.issue.policy.issue_quorum_den
  end
  ui.bargraph{
    max_value = max_value,
    width = 100,
    quorum = max_value * quorum,
    quorum_color = "#00F",
    bars = {
      { color = "#5a5", value = (initiative.satisfied_supporter_count or 0) },
      { color = "#fa5", value = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0) },
      { color = grey, value = max_value - (initiative.supporter_count or 0) },
    }
  }
end
