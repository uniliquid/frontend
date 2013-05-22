local full = param.get("full", atom.boolean)

-- quick links
ui.actions(function()
  ui.link{
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/page_white_stack.png" }
      ui.tag { content = _"Latest vote results" }
    end,
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
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/page_white_go.png" }
      ui.tag { content = _"Voted by delegation" }
    end,
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter_interest = "voted",
      filter_delegation = "delegated"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/page_white_edit.png" }
      ui.tag { content = _"Not yet voted" }
    end,
    module = "index",
    view = "index",
    params = {
      tab = "open",
      --filter_policy_sel = "p1",
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
  label = function()
    ui.image{ attr = { class = "spaceicon" }, static = "icons/16/world.png" }
    ui.tag{ content = _"Overview" }
  end,
  module = "index",
  view = "_member_home",
  params = { member = app.session.member }
}

tabs[#tabs+1] = {
  name = "open",
  label = function()
    ui.image{ attr = { class = "spaceicon" }, static = "icons/16/arrow_in.png" }
    ui.tag{ content = _"Open issues" }
  end,
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
  label = function()
    ui.image{ attr = { class = "spaceicon" }, static = "icons/16/lock.png" }
    ui.tag{ content = _"Closed issues" }
  end,
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
