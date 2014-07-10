local initiative = Initiative:by_id(param.get("initiative_id"))

local issue

if initiative then
  issue = initiative.issue
else
  issue = Issue:by_id(param.get("issue_id"))
end

if app.session.member_id then
  if initiative then
    initiative:load_everything_for_member_id(app.session.member.id)
  end
  issue:load_everything_for_member_id(app.session.member.id)
end

local member = Member:by_id(param.get("member_id", atom.integer))

local members_selector = Member:new_selector()
  :join("delegating_voter", nil, "delegating_voter.member_id = member.id")
  :add_where{ "delegating_voter.issue_id = ?", issue.id }
  :add_where{ "delegating_voter.delegate_member_ids[1] = ?", member.id }
  :add_field("delegating_voter.weight", "voter_weight")
  :join("issue", nil, "issue.id = delegating_voter.issue_id")


execute.view{
  module = "issue", view = "_head", params = {
    issue = issue, initiative = initiative
  }
}

execute.view{ module = "issue", view = "_sidebar_state", params = {
  issue = issue,
} }

execute.view { 
  module = "issue", view = "_sidebar_issue", params = {
    issue = issue,
    highlight_initiative_id = initiative and initiative.id or nil,
  }
}

execute.view { 
  module = "issue", view = "_sidebar_whatcanido", params = {
    issue = issue
  }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = issue,
    initiative = initiative
  }
}


ui.section( function()
    
  ui.sectionHead( function()
    ui.heading{ level = 1, content = _("Incoming delegations for '#{member}'", { member = member.name }) }
  end)

  execute.view{
    module = "member",
    view = "_list",
    params = {
      members_selector = members_selector,
      trustee = member,
      issue = issue,
      initiative = initiative,
      for_votes = true, no_filter = true,
      
    }
  }
  
end )
