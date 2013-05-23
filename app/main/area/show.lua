local area = Area:by_id(param.get_id())

if not area then
  slot.put_into("error", _"The requested area does not exist!")
  return
end

app.html_title.title = area.name
app.html_title.subtitle = _("Area")

util.help("area.show")

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = area, show_content = true, show_links = true, member = app.session.member } }
end)

ui.container{
  attr = { class = "vertical"},
  content = function()
    ui.field.text{ value = area.description }
  end
}

local open_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed ISNULL")
  :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

local closed_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

local members_selector = area:get_reference_selector("members"):add_where("member.active AND NOT member.locked")
local delegations_selector = area:get_reference_selector("delegations")
  :join("member", "truster", "truster.id = delegation.truster_id AND truster.active")
  :join("member", "trustee", "trustee.id = delegation.trustee_id AND trustee.active")

local tabs = {
  module = "area",
  view = "show_tab",
  static_params = { area_id = area.id },
}

tabs[#tabs+1] = {
  name = "open",
  icon = "icons/16/arrow_in.png",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = open_issues_selector, for_area = true
  }
}
tabs[#tabs+1] = {
  name = "closed",
  icon = "icons/16/lock.png",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = closed_issues_selector, for_area = true
  }
}

tabs[#tabs+1] = {
  name = "timeline",
  icon = "icons/16/time.png",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = { for_area = area }
}

if app.session:has_access("all_pseudonymous") then
  tabs[#tabs+1] =
    {
      name = "members",
      icon = "icons/16/group.png",
      label = _"Participants" .. " (" .. tostring(members_selector:count()) .. ")",
      module = "member",
      view = "_list",
      params = { members_selector = members_selector }
    }

  tabs[#tabs+1] =
    {
      name = "delegations",
      icon = "icons/16/group_go.png",
      label = _"Delegations" .. " (" .. tostring(delegations_selector:count()) .. ")",
      module = "delegation",
      view = "_list",
      params = { delegations_selector = delegations_selector }
    }
end

ui.tabs(tabs)
