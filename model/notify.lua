Notify = mondelefant.new_class()
Notify.table = 'notify'
Notify.primary_key = { "member_id", "interest" }

Notify:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Notify:by_member_interest(member_id, interest)
  return self:new_selector()
    :add_where{ "member_id = ? AND interest = ?", member_id, interest }
    :optional_object_mode()
    :exec()
end

function Notify:records()
  local records = {}
  table.insert(records,{ level = "all", phase = _"New", name = "initiative_created_in_new_issue", title = _"New issue and initiative" })
  table.insert(records,{ level = "all", phase = _"New", name = "admission__initiative_created_in_existing_issue", title = _"New initiative in issue" })
  table.insert(records,{ level = "all", phase = _"New", name = "admission__new_draft_created", title = _"New draft for initiative" })
  table.insert(records,{ level = "all", phase = _"New", name = "admission__suggestion_created", title = _"New suggestion for initiative" })
  table.insert(records,{ level = "all", phase = _"New", name = "admission__initiative_revoked", title = _"Initiative revoked" })
  table.insert(records,{ level = "all", phase = _"New", name = "canceled_revoked_before_accepted", title = _"Issue was cancelled due to revocation" })
  table.insert(records,{ level = "all", phase = _"New", name = "canceled_issue_not_accepted", title = _"Issue was not accepted" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion", title = _"Issue reached discussion" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion__initiative_created_in_existing_issue", title = _"New initiative in issue" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion__new_draft_created", title = _"New draft for initiative" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion__suggestion_created", title = _"New suggestion for initiative" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion__argument_created", title = _"New argument for initiative" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "discussion__initiative_revoked", title = _"Initiative revoked" })
  table.insert(records,{ level = "discussion", phase = _"Discussion", name = "canceled_after_revocation_during_discussion", title = _"Issue was cancelled due to revocation (during discussion)" })
if not config.no_verification then
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "verification", title = _"Issue was frozen" })
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "verification__initiative_created_in_existing_issue", title = _"New initiative in issue" })
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "verification__argument_created", title = _"New argument for initiative" })
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "verification__initiative_revoked", title = _"Initiative revoked" })
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "canceled_after_revocation_during_verification", title = _"Issue was cancelled due to revocation (during verification)" })
  table.insert(records,{ level = "verification", phase = _"Frozen", name = "canceled_no_initiative_admitted", title = _"Issue was cancelled because no initiative was admitted" })
end
  table.insert(records,{ level = "voting", phase = _"Voting", name = "voting", title = _"Voting for issue started" })
  table.insert(records,{ level = "voting", phase = _"Voting", name = "finished_with_winner", title = _"Issue was finished (with winner)" })
  table.insert(records,{ level = "voting", phase = _"Voting", name = "finished_without_winner", title = _"Issue was finished (without winner)" })
return records
end

function Notify:enum_interest()
  return { "all", "my_units", "my_areas", "interested", "potentially", "supported", "initiated", "voted" }
end
