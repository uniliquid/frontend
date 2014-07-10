local unit_id = config.single_unit_id or param.get_id()

local unit = Unit:by_id(unit_id)

if not unit then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end


unit:load_delegation_info_once_for_member_id(app.session.member_id)

local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
areas_selector:add_order_by("member_weight DESC")

local members_selector = Member:build_selector{
  active = true,
  voting_right_for_unit_id = unit.id
}

local delegations_selector = Delegation:new_selector()
  :join("member", "truster", "truster.id = delegation.truster_id AND truster.active")
  :join("privilege", "truster_privilege", "truster_privilege.member_id = truster.id AND truster_privilege.unit_id = delegation.unit_id AND truster_privilege.voting_right")
  :join("member", "trustee", "trustee.id = delegation.trustee_id AND truster.active")
  :join("privilege", "trustee_privilege", "trustee_privilege.member_id = trustee.id AND trustee_privilege.unit_id = delegation.unit_id AND trustee_privilege.voting_right")
  :add_where{ "delegation.unit_id = ?", unit.id }

local open_issues_selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :add_where{ "area.unit_id = ?", unit.id }
  :add_where("issue.closed ISNULL")
  :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

local closed_issues_selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :add_where{ "area.unit_id = ?", unit.id }
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

  

execute.view { module = "unit", view = "_head", params = { unit = unit } }


execute.view { 
  module = "unit", view = "_sidebar", params = { 
    unit = unit
  }
}

execute.view { 
  module = "unit", view = "_sidebar_whatcanido", params = { 
    unit = unit
  }
}

execute.view { 
  module = "unit", view = "_sidebar_members", params = { 
    unit = unit
  }
}

execute.view {
  module = "issue",
  view = "_list2",
  params = { for_unit = unit, head = function ()
    ui.heading { attr = { class = "left" }, level = 1, content = unit.name }
  end }
}

--[[
if app.session:has_access("all_pseudonymous") then
  tabs[#tabs+1] = {
    name = "eligible_voters",
    label = _"Eligible voters",
    module = "member",
    view = "_list",
    params = { members_selector = members_selector }
  }

  tabs[#tabs+1] = {
    name = "delegations",
    label = _"Delegations",
    module = "delegation",
    view = "_list",
    params = { delegations_selector = delegations_selector }
  }
end

ui.tabs(tabs)

--]]