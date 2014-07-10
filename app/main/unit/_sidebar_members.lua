if not app.session:has_access("all_pseudonymous") then
  return
end

local unit = param.get("unit", "table")
local members_selector = Member:new_selector()
  :join("privilege", nil, { "privilege.member_id = member.id AND privilege.unit_id = ? AND privilege.voting_right", unit.id })
  :add_where("active")
  :limit(50)

local member_count = unit.member_count or 0
  
ui.sidebar ( "tab-members", function ()
  ui.sidebarHead( function ()
    ui.heading {
      level = 2,
      content = _("Eligible members (#{count})", { count = member_count })
    }
  end )
  execute.view {
    module = 'member', view   = '_list', params = {
      members_selector = members_selector,
      no_filter = true, no_paginate = true,
      member_class = "sidebarRow sidebarRowNarrow"
    }
  }
  if member_count > members_selector:count() then
    ui.link {
      text = _"Show all members",
      module = "member", view = "list"
    }
  end
end )
