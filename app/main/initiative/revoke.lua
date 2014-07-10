local initiative = Initiative:by_id(param.get_id())
local initiatives = app.session.member
  :get_reference_selector("supported_initiatives")
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_where("issue.closed ISNULL")
  :add_order_by("issue.id")
  :exec()

  
local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end


local tmp = { { id = -1, myname = _"Suggest no initiative" }}
for i, initiative in ipairs(initiatives) do
  initiative.myname = _("Issue ##{issue_id}: #{initiative_name}", {
    issue_id = initiative.issue.id,
    initiative_name = initiative.name
  })
  tmp[#tmp+1] = initiative
end

execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue,
    member = member
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
  action = "revoke",
  id = initiative.id,
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id
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
      ui.heading { level = 2, content = _"Revoke initiative" }
    end )

    ui.sectionRow( function()

      ui.heading{ level = 2, content = _"Do you want to suggest to support another initiative?" }
    
      ui.field.select{
        name = "suggested_initiative_id",
        foreign_records = tmp,
        foreign_id = "id",
        foreign_name = "myname",
        value = param.get("suggested_initiative_id", atom.integer)
      }
      ui.container{ content = _"You may choose one of the ongoing initiatives you are currently supporting" }
      slot.put("<br />")
      ui.heading { level = 2, content = _"Are you aware that revoking an initiative is irrevocable?" }
      ui.container{ content = function()
        ui.tag{ tag = "input", attr = {
          type = "checkbox",
          name = "are_you_sure",
          value = "1"
        } }
        ui.tag { content = _"I understand, that this is not revocable" }
      end }
      
      
      slot.put("<br />")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "btn btn-dangerous",
          value = _"Revoke now"
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