if not app.session:has_access("all_pseudonymous") then
  return
end

ui.sidebar ( "tab-members", function ()
  local member_count = MemberCount:get()
  ui.sidebarHead( function()
    ui.heading {
      level = 2,
      content = _("Registered members (#{count})", { count = member_count })
    }
  end )

  local selector = Member:new_selector()
    :add_where("active")
    :add_order_by("last_login DESC NULLS LAST, id DESC")
    :limit(50)
  
  execute.view {
    module = 'member', view   = '_list', params = {
      members_selector = selector,
      no_filter = true, no_paginate = true,
      member_class = "sidebarRow sidebarRowNarrow"
    }
  }
  
  ui.link {
    attr = { class = "sidebarRow moreLink" },
    text = _"Show full member list",
    module = "member", view = "list"
  }
  
end )
