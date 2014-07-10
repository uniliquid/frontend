local area = Area:by_id(param.get_id())

if not area then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

area:load_delegation_info_once_for_member_id(app.session.member_id)

app.html_title.title = area.name
app.html_title.subtitle = _("Area")

execute.view {
  module = "area", view = "_head", params = {
    area = area, member = app.session.member
  }
}

execute.view {
  module = "area", view = "_sidebar_whatcanido", params = {
    area = area
  }
}

execute.view {
  module = "area", view = "_sidebar_members", params = {
    area = area
  }
}

function getOpenIssuesSelector()
  return area:get_reference_selector("issues")
    :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
end

local admission_selector = getOpenIssuesSelector()
  :add_where("issue.state = 'admission'");

local discussion_selector = getOpenIssuesSelector()
  :add_where("issue.state = 'discussion'");

local verification_selector = getOpenIssuesSelector()
  :add_where("issue.state = 'verification'");

local voting_selector = getOpenIssuesSelector()
  :add_where("issue.state = 'voting'");


local closed_selector = area:get_reference_selector("issues")
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

local members_selector = area:get_reference_selector("members"):add_where("member.active")
local delegations_selector = area:get_reference_selector("delegations")
  :join("member", "truster", "truster.id = delegation.truster_id AND truster.active")
  :join("member", "trustee", "trustee.id = delegation.trustee_id AND trustee.active")


execute.view {
  module = "issue",
  view = "_list2",
  params = { for_area = area }
}
