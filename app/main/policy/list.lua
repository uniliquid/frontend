ui.title(_"Policies")

util.help("policy.list", _"Policies")
local policies = Policy:new_selector()
  :add_where("active")
  :add_order_by("index")
  :exec()

ui.list{
  records = policies,
  columns = {
    {
      label_attr = { width = "500" },
      label = _"Policy",
      content = function(policy)
        ui.link{
          module = "policy", view = "show", id = policy.id,
          attr = { style = "font-weight: bold" },
          content = function()
            slot.put(encode.html(policy.name))
            if not policy.active then
              slot.put(" (", _"disabled", ")")
            end
          end
        }
        ui.tag{
          tag = "div",
          content = policy.description
        }
      end
    },
    {
      label_attr = { width = "200" },
      label = _"Phases",
      content = function(policy)
        if policy.polling then
          ui.field.text{ label = _"" }
        else
          ui.field.text{ label = _"New" .. ":", value = "≤ " .. policy.admission_time:gsub("days",_"days"):gsub("day",_"day") }
          ui.field.text{ label = _"Discussion" .. ":", value = policy.discussion_time:gsub("days",_"days"):gsub("day",_"day") or _"variable" }
          ui.field.text{ label = _"Frozen" .. ":", value = policy.verification_time:gsub("days",_"days"):gsub("day",_"day") or _"variable" }
          ui.field.text{ label = _"Voting" .. ":", value = policy.voting_time:gsub("days",_"days"):gsub("day",_"day") or _"variable" }
        end
      end
    },
    {
      label_attr = { width = "200" },
      label = _"Quorum",
      content = function(policy)
        if policy.polling then
          ui.field.text{ label = _"Issue quorum" .. ":", value = _"without" }
        else
          ui.field.text{
            label = _"Issue quorum" .. ":", 
            value = "≥ " .. tonumber(string.format("%.1f", policy.issue_quorum_num / policy.issue_quorum_den * 100)) .. "%"
          }
        end
         ui.field.text{
           label = _"Initiative quorum" .. ":",
           value = "≥ " .. tonumber(string.format("%.1f", policy.initiative_quorum_num / policy.initiative_quorum_den * 100)) .. "%"
         }
         ui.field.text{
           label = _"Direct majority" .. ":",
           value = (policy.direct_majority_strict and ">" or "≥" ) .. " " .. tonumber(string.format("%.1f", policy.direct_majority_num / policy.direct_majority_den * 100)) .. "%"
         }
         ui.field.text{
           label = _"Indirect majority" .. ":",
           value = (policy.indirect_majority_strict and ">" or "≥" ) .. " " .. tonumber(string.format("%.1f", policy.indirect_majority_num / policy.indirect_majority_den * 100)) .. "%"
        }
      end
    },
  }
}
