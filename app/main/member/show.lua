local member = Member:by_id(param.get_id())

if not member or not member.activated then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

local limit = 25

local initiated_initiatives = Initiative:new_selector()
  :join("initiator", nil, { "initiator.initiative_id = initiative.id and initiator.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_where("issue.closed ISNULL")
  :add_order_by("initiative.id DESC")
  :limit(limit+1)
  :exec()
  
initiated_initiatives:load("issue")
initiated_initiatives:load_everything_for_member_id(member.id)

local supported_initiatives = Initiative:new_selector()
  :join("supporter", nil, { "supporter.initiative_id = initiative.id and supporter.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_where("issue.closed ISNULL")
  :add_order_by("initiative.id DESC")
  :limit(limit+1)
  :exec()

supported_initiatives:load("issue")
supported_initiatives:load_everything_for_member_id(member.id)

local voted_initiatives = Initiative:new_selector()
  :add_where("initiative.rank = 1")
  :join("direct_voter", nil, { "direct_voter.issue_id = initiative.issue_id and direct_voter.member_id = ?", member.id })
  :join("vote", nil, { "vote.initiative_id = initiative.id and vote.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_order_by("issue.closed DESC, initiative.id DESC")
  :add_field("vote.grade", "vote_grade")
  :add_field("vote.first_preference", "vote_first_preference")
  :limit(limit+1)
  :exec()

voted_initiatives:load("issue")
voted_initiatives:load_everything_for_member_id(member.id)
  
local incoming_delegations_selector = member:get_reference_selector("incoming_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id AND _member_showtab_issue.closed ISNULL")
  :add_where("_member_showtab_issue.closed ISNULL")
  :add_order_by("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :limit(limit+1)

local outgoing_delegations_selector = member:get_reference_selector("outgoing_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id AND _member_showtab_issue.closed ISNULL")
  :add_where("_member_showtab_issue.closed ISNULL")
  :add_order_by("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :limit(limit+1)


app.html_title.title = member.name
app.html_title.subtitle = _("Member")

ui.titleMember(member)

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = member
  }
}

execute.view {
  module = "member", view = "_sidebar_contacts", params = {
    member = member
  }
}


ui.section( function() 
  ui.sectionHead( function()
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = member,
        image_type = "avatar",
        show_dummy = true,
        class = "left"
      }
    }
    ui.heading{ level = 1, content = member.name }
    slot.put("<br />")
    ui.container {
      attr = { class = "right" },
      content = function()
        ui.link{
          content = _"Account history",
          module = "member", view = "history", id = member.id
        }
      end
    }
    if member.identification then
      ui.container{ content = member.identification }
    end
  end )
  ui.sectionRow( function()
    execute.view{
      module = "member",
      view = "_profile",
      params = { member = member }
    }
  end )
end )


ui.section( function()
  ui.sectionHead( function()
    ui.heading { level = 2, content = _"Initiatives created by this member" }
  end )
  ui.sectionRow( function()
    for i, initiative in ipairs(initiated_initiatives) do
      execute.view {
        module = "initiative", view = "_list",
        params = { initiative = initiative },
        member = member
      }
    end
  end )
end )

ui.section( function()
  ui.sectionHead( function()
    ui.heading { level = 2, content = _"What this member is currently supporting" }
  end )
  ui.sectionRow( function()
    for i, initiative in ipairs(supported_initiatives) do
      execute.view {
        module = "initiative", view = "_list",
        params = { initiative = initiative },
        member = member
      }
    end
  end )
end )

ui.section( function()
  ui.sectionHead( function()
    ui.heading { level = 2, content = _"How this member voted" }
  end )
  ui.sectionRow( function()
    for i, initiative in ipairs(voted_initiatives) do
      execute.view {
        module = "initiative", view = "_list",
        params = { initiative = initiative }
      }
    end
  end )
end )


ui.section( function()
  ui.sectionHead( function()
    ui.heading { level = 2, content = _"Outgoing delegations" }
  end )
  ui.sectionRow( function()
    execute.view {
      module = "delegation", view = "_list",
      params = { delegations_selector = outgoing_delegations_selector, outgoing = true },
    }
  end )
end )


ui.section( function()
   
  ui.sectionHead( function()
    ui.heading { level = 2, content = _"Incoming delegations" }
  end )
  ui.sectionRow( function()
    execute.view {
      module = "delegation", view = "_list",
      params = { delegations_selector = incoming_delegations_selector, incoming = true },
    }
  end )
  
end )
