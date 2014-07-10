local initiative = Initiative:by_id(param.get("initiative_id"))

local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end

local initiator = Initiator:by_pk(initiative.id, app.session.member.id)
if not initiator or initiator.accepted ~= true then
  error("access denied")
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
  attr = { class = "vertical section" },
  module = "initiative",
  action = "remove_initiator",
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
      ui.heading { level = 2, content = _"Remove an initiator from initiative" }
    end )

    ui.sectionRow( function()
      local records = initiative:get_reference_selector("initiating_members"):add_where("accepted OR accepted ISNULL"):exec()
      ui.heading{ level = 2, content = _"Choose an initiator to remove" }
      ui.field.select{
        name = "member_id",
        foreign_records = records,
        foreign_id = "id",
        foreign_name = "name",
      }
      slot.put("<br />")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "btn btn-dangerous",
          value = _"Remove initiator"
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