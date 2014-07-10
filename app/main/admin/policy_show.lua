local policy = Policy:by_id(param.get_id()) or Policy:new()

local hint = not policy.id

ui.titleAdmin(policy.name or _"New policy")

ui.section( function()

  ui.sectionHead( function()
    ui.heading { level = 1, content = _"Policy" }
  end )
  ui.sectionRow( function()
    ui.form{
      attr = { class = "vertical" },
      record = policy,
      module = "admin",
      action = "policy_update",
      routing = {
        default = {
          mode = "redirect",
          module = "admin",
          view = "index"
        }
      },
      id = policy.id,
      content = function()

        ui.field.text{ label = _"Index",        name = "index", value = hint and "1" or nil }

        ui.field.text{ label = _"Name",        name = "name" }
        ui.field.text{ label = _"Description", name = "description", multiline = true }
        ui.field.text{ label = _"Hint",        readonly = true, 
                        value = _"Interval format:" .. " 3 mons 2 weeks 1 day 10:30:15" }

        ui.field.text{ label = _"Admission time",     name = "admission_time", value = hint and "30 days" or nil }
        ui.field.text{ label = _"Discussion time",    name = "discussion_time", value = hint and "30 days" or nil }
        ui.field.text{ label = _"Verification time",  name = "verification_time", value = hint and "15 days" or nil }
        ui.field.text{ label = _"Voting time",        name = "voting_time", value = hint and "15 days" or nil }

        ui.field.text{ label = _"Issue quorum numerator",   name = "issue_quorum_num", value = hint and "10" or nil }
        ui.field.text{ label = _"Issue quorum denominator", name = "issue_quorum_den", value = hint and "100" or nil }

        ui.field.text{ label = _"Initiative quorum numerator",   name = "initiative_quorum_num", value = hint and "10" or nil }
        ui.field.text{ label = _"Initiative quorum denominator", name = "initiative_quorum_den", value = hint and "100" or nil }

        ui.field.text{ label = _"Direct majority numerator",   name = "direct_majority_num", value = hint and "50" or nil }
        ui.field.text{ label = _"Direct majority denominator", name = "direct_majority_den", value = hint and "100" or nil }
        ui.field.boolean{ label = _"Strict direct majority", name = "direct_majority_strict", value = hint and true or nil }
        ui.field.text{ label = _"Direct majority positive",   name = "direct_majority_positive", value = hint and "0" or nil }
        ui.field.text{ label = _"Direct majority non negative", name = "direct_majority_non_negative", value = hint and "0" or nil }

        ui.field.text{ label = _"Indirect majority numerator",   name = "indirect_majority_num", value = hint and "50" or nil }
        ui.field.text{ label = _"Indirect majority denominator", name = "indirect_majority_den", value = hint and "100" or nil }
        ui.field.boolean{ label = _"Strict indirect majority", name = "indirect_majority_strict", value = hint and true or nil }
        ui.field.text{ label = _"Indirect majority positive",   name = "indirect_majority_positive", value = hint and "0" or nil }
        ui.field.text{ label = _"Indirect majority non negative", name = "indirect_majority_non_negative", value = hint and "0" or nil }

        ui.field.boolean{ label = _"No reverse beat path", name = "no_reverse_beat_path", value = hint and false or nil }
        ui.field.boolean{ label = _"No multistage majority", name = "no_multistage_majority", value = hint and false or nil }
        ui.field.boolean{ label = _"Polling mode", name = "polling", value = hint and false or nil }


        ui.field.boolean{ label = _"Active?", name = "active", value = hint and true or nil }

        ui.submit{ text = _"update policy" }
        slot.put(" ")
        ui.link { module = "admin", view = "index", content = _"cancel" }
      end
    }
  end )
end )