local initiative = Initiative:by_id(param.get("initiative_id"))

local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end


local records = {
  {
    id = "-1",
    name = _"Choose member"
  }
}
local contact_members = app.session.member:get_reference_selector("saved_members"):add_order_by("name"):exec()
for i, record in ipairs(contact_members) do
  records[#records+1] = record
end

execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue,
    member = app.session.member
  }
}

execute.view{ module = "issue", view = "_sidebar_state", params = {
  initiative = initiative
} }

execute.view { 
  module = "issue", view = "_sidebar_issue", 
  params = {
    issue = initiative.issue,
    highlight_initiative_id = initiative.id
  }
}

execute.view {
  module = "issue", view = "_sidebar_whatcanido",
  params = { initiative = initiative }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = initiative.issue, initiative = initiative
  }
}

ui.form{
  attr = { class = "wide section" },
  module = "initiative",
  action = "add_initiator",
  params = {
    initiative_id = initiative.id,
  },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id,
      params = {
        tab = "initiators",
      }
    }
  },
  content = function()

    ui.sectionHead( function()
      ui.link{
        module = "initiative", view = "show", id = initiative.id,
        content = function ()
          ui.heading { 
            level = 1,
            content = initiative.display_name
          }
        end
      }
      ui.heading { level = 2, content = _"Invite an initiator to initiative" }
    end )

    ui.sectionRow( function()
      ui.heading { level = 2, content = _"Choose a member to invite" }
      ui.field.select{
        name = "member_id",
        foreign_records = records,
        foreign_id = "id",
        foreign_name = "name"
      }
      ui.container{ content = _"You can choose only members which you have been saved as contact before." }
      slot.put("<br />")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "btn btn-default",
          value = _"Invite member"
        },
        content = ""
      }
      slot.put("<br />")
      slot.put("<br />")
      ui.link{
        content = _"Cancel",
        module = "initiative",
        view = "show",
        id = initiative.id,
        params = {
          tab = "initiators"
        }
      }
    end )
  end
}