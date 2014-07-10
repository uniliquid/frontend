local id = param.get("id")

if not id then
  return
end

local issue = Issue:by_id(id)
issue:load_everything_for_member_id ( app.session.member_id )
issue.initiatives:load_everything_for_member_id ( app.session.member_id )

ui.titleAdmin(_"Cancel issue")

ui.form{
  module = "admin",
  action = "cancel_issue",
  id = id,
  attr = { class = "vertical section" },
  content = function()
    
    ui.sectionHead( function()
      ui.heading { level = 1, content = _("Cancel issue ##{id}", { id = issue.id }) }
    end )

    ui.sectionRow( function()
      execute.view{ module = "initiative", view = "_list", params = {
        issue = issue,
        initiatives = issue.initiatives
      } }
    end )
    
    ui.sectionRow( function()
      ui.field.text{ label = _"public administrative notice:", name = "admin_notice", multiline = true }
      ui.submit{ text = _"cancel issue now" }
      slot.put(" ")
      ui.link { module = "admin", view = "index", content = "go back to safety" }
    end )
  end
}

