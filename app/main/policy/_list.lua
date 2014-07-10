local for_area = param.get("for_area", "table")

local selector = Policy:new_selector()
  :add_where("policy.active")
  :add_order_by("policy.index")

if for_area then
  selector:join("allowed_policy", nil,
    { "allowed_policy.policy_id = policy.id AND allowed_policy.area_id = ?", for_area.id }
  )
end

local policies = selector:exec()


for i, policy in ipairs(policies) do
  ui.container { 
    attr = { class = "sidebarRow", id = "policy" .. policy.id },
    content = function ()

      ui.heading { level = 3, content = policy.name }
      
      ui.tag{
        content = policy.description
      }

      slot.put ( "<br />" )
      
      ui.link {
        attr = {
          class = "policy-show-details",
          onclick = "$('#policy" .. policy.id .. " .policy-details').show(); $('#policy" .. policy.id .. " .policy-show-details').hide(); $('#policy" .. policy.id .. " .policy-hide-details').show(); return false;"
        },
        content = _"show details"
      }
      
      ui.link {
        attr = {
          class = "policy-hide-details",
          onclick = "$('#policy" .. policy.id .. " .policy-details').hide(); $('#policy" .. policy.id .. " .policy-show-details').show(); $('#policy" .. policy.id .. " .policy-hide-details').hide(); return false;",
          style = "display: none;"
        },
        content = _"hide details"
      }
      
      ui.container {
        attr = {
          class = "policy-details",
          style = "display: none;"
        },
        content = function ()

          ui.heading { level = 4, content = _"Phase durations" }

          if policy.polling then
            ui.field.text{ label = _"New" .. ":", value = _"without" }
          else
            ui.field.text{ label = _"New" .. ":", value = "≤ " .. policy.admission_time }
          end
          ui.field.text{ label = _"Discussion" .. ":", value = policy.discussion_time or _"variable" }
          ui.field.text{ label = _"Frozen" .. ":", value = policy.verification_time or _"variable" }
          ui.field.text{ label = _"Voting" .. ":", value = policy.voting_time or _"variable" }

          ui.heading { level = 4, content = _"Quorums" }
          
          if policy.polling then
            ui.field.text{ label = _"Issue quorum" .. ":", value = _"without" }
          else
            ui.field.text{
              label = _"Issue quorum" .. ":", 
              value = "≥ " .. tostring(policy.issue_quorum_num) .. "/" .. tostring(policy.issue_quorum_den)
            }
          end
          ui.field.text{
            label = _"Initiative quorum" .. ":", 
            value = "≥ " .. tostring(policy.initiative_quorum_num) .. "/" .. tostring(policy.initiative_quorum_den)
          }
          ui.field.text{
            label = _"Direct majority" .. ":", 
            value = (policy.direct_majority_strict and ">" or "≥" ) .. " " .. tostring(policy.direct_majority_num) .. "/" .. tostring(policy.direct_majority_den)
          }
          ui.field.text{
            label = _"Indirect majority" .. ":", 
            value = (policy.indirect_majority_strict and ">" or "≥" ) .. " " .. tostring(policy.indirect_majority_num) .. "/" .. tostring(policy.indirect_majority_den)
          }
        end
      }
    end
  }
end