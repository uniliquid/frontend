local issue = Issue:by_id ( param.get_id () )

if not issue then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

local initiatives = issue.initiatives

if app.session.member_id then
  issue:load_everything_for_member_id ( app.session.member_id )
  initiatives:load_everything_for_member_id ( app.session.member_id )
end

if not app.html_title.title then
  app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

execute.view {
  module = "issue", view = "_head", 
  params = { issue = issue, member = app.session.member }
}

execute.view{ module = "issue", view = "_sidebar_state", params = {
  issue = issue
} }

execute.view { 
  module = "issue", view = "_sidebar_whatcanido", params = {
    issue = issue
  }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = issue
  }
}

ui.section( function ()
  
  execute.view{ 
    module = "issue", view = "_head2", params = {
      issue = issue
    }
  }

  if issue.initiatives[1].rank == 1 then
    execute.view{ module = "initiative", view = "_sidebar_state", params = {
      initiative = issue.initiatives[1]
    } }
  end
  
  ui.sectionRow( function ()
    execute.view {
      module = "initiative", view = "_list",
      params = { 
        issue = issue,
        initiatives = initiatives
      }
    }
  end )

end )

ui.section(function()
  ui.sectionHead( function()
    ui.heading { level = 1, content = _"Details" }
  end )
  local policy = issue.policy
  ui.form{
    record = issue,
    readonly = true,
    attr = { class = "sectionRow form" },
    content = function()
      if issue.snapshot then
        ui.field.timestamp{ label = _"Last counting:", value = issue.snapshot }
      end
      ui.field.text{       label = _"Population",            name = "population" }
      ui.field.timestamp{  label = _"Created at",            name = "created" }
      if policy.polling then
        ui.field.text{       label = _"Admission time",        value = _"Implicitly admitted" }
      else
        ui.field.text{       label = _"Admission time",        value = format.interval_text(issue.admission_time_text) }
        ui.field.text{
          label = _"Issue quorum",
          value = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den)
        }
        if issue.population then
          ui.field.text{
            label = _"Currently required",
            value = math.ceil(issue.population * policy.issue_quorum_num / policy.issue_quorum_den)
          }
        end
      end
      if issue.accepted then
        ui.field.timestamp{  label = _"Accepted at",           name = "accepted" }
      end
      ui.field.text{       label = _"Discussion time",       value = format.interval_text(issue.discussion_time_text) }
      if issue.half_frozen then
        ui.field.timestamp{  label = _"Half frozen at",        name = "half_frozen" }
      end
      ui.field.text{       label = _"Verification time",     value = format.interval_text(issue.verification_time_text) }
      ui.field.text{
        label   = _"Initiative quorum",
        value = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den)
      }
      if issue.population then
        ui.field.text{
          label   = _"Currently required",
          value = math.ceil(issue.population * (issue.policy.initiative_quorum_num / issue.policy.initiative_quorum_den)),
        }
      end
      if issue.fully_frozen then
        ui.field.timestamp{  label = _"Fully frozen at",       name = "fully_frozen" }
      end
      ui.field.text{       label = _"Voting time",           value = format.interval_text(issue.voting_time_text) }
      if issue.closed then
        ui.field.timestamp{  label = _"Closed",                name = "closed" }
      end
    end
  }

end )

