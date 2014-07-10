if not app.session:has_access("all_pseudonymous") then
  return
end

local area = param.get("area", "table")
local members_selector = Member:new_selector()
  :join("membership", nil, { "membership.member_id = member.id AND membership.area_id = ?", area.id })
  :add_where("member.active")
  :limit(50)
  
ui.sidebar ( "tab-members", function ()
  ui.sidebarHead( function ()
    ui.heading {
      level = 2,
      content = _("Subscribed members (#{count})", {
        count = area.direct_member_count
      })
    }
  end )
  execute.view {
    module = 'member', view   = '_list', params = {
      members_selector = members_selector,
      no_filter = true, no_paginate = true,
      member_class = "sidebarRow sidebarRowNarrow"
   }
  }
  if area.direct_member_count > members_selector:count() then
    ui.link {
      text = _"Show all members",
      module = "member", view = "list"
    }
  end
end )
