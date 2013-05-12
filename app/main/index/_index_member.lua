local full = param.get("full", atom.boolean)

-- quick links
ui.actions(function()
  ui.link{
    text = _"Latest vote results",
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter = "finished",
      filter_interest = "unit"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = _"Voted by delegation",
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter_interest = "voted",
      filter_delegation = "delegated"
    }
  }
  slot.put(" &middot; ")
  ui.tag{ tag = "b", content = function()
  ui.link{
    text = _"My voting rights",
    module = "member",
    view = "rights"
  }
  end
  }
  slot.put(" &middot; ")
  ui.link{
    text = _"Noch nicht abgestimmte Anträge",
    module = "index",
    view = "index",
    params = {
      tab = "open",
      filter_policy_sel = "p1",
      filter_policy = "any",
      filter_voting = "not_voted",
      filter = "frozen",
      filter_interest = "unit"
    }
  }
end)
 
local tabs = {
  module = "index",
  view = "index"
}

tabs[#tabs+1] = {
  name = "areas",
  label = _"Home",
  icon = { static = "icons/16/package.png" },
  module = "index",
  view = "_member_home",
  params = { member = app.session.member }
}

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed ISNULL")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed NOTNULL")
      :add_order_by("issue.closed DESC")

  }
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = { }
}

tabs[#tabs+1] = {
  name = "members",
  label = _"Members",
  module = 'member',
  view   = '_list',
  params = { members_selector = Member:new_selector():add_where("active") }
}

if not param.get("tab") then
  execute.view{
    module = "index", view = "_notifications"
  }
end

ui.tabs(tabs)
