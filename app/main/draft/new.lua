local initiative = Initiative:by_id(param.get("initiative_id"))
initiative:load_everything_for_member_id(app.session.member_id)
initiative.issue:load_everything_for_member_id(app.session.member_id)


execute.view{
  module = "issue", view = "_head", params = {
    issue = initiative.issue,
    initiative = initiative
  }
}

execute.view { 
  module = "issue", view = "_sidebar_issue", 
  params = {
    issue = initiative.issue,
  }
}



ui.form{
  record = initiative.current_draft,
  attr = { class = "vertical section" },
  module = "draft",
  action = "add",
  params = { initiative_id = initiative.id },
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
      ui.heading { level = 1, content = initiative.display_name }
    end)
    
    if param.get("preview") then
      ui.sectionRow( function()
        ui.field.hidden{ name = "formatting_engine", value = param.get("formatting_engine") }
        ui.field.hidden{ name = "content", value = param.get("content") }
        if config.enforce_formatting_engine then
          formatting_engine = config.enforce_formatting_engine
        else
          formatting_engine = param.get("formatting_engine")
        end
        ui.container{
          attr = { class = "draft" },
          content = function()
            slot.put(format.wiki_text(param.get("content"), formatting_engine))
          end
        }

        slot.put("<br />")
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "btn btn-default",
            value = _'Publish now'
          },
          content = ""
        }
        slot.put("<br />")
        slot.put("<br />")

        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            name = "edit",
            class = "btn-link",
            value = _'Edit again'
          },
          content = ""
        }
        slot.put(" | ")
        ui.link{
          content = _"Cancel",
          module = "initiative",
          view = "show",
          id = initiative.id
        }
      end )

    else
      ui.sectionRow( function()
        execute.view{ module = "initiative", view = "_sidebar_wikisyntax" }
      
        if not config.enforce_formatting_engine then
          ui.field.select{
            label = _"Wiki engine",
            name = "formatting_engine",
            foreign_records = config.formatting_engines,
            attr = {id = "formatting_engine"},
            foreign_id = "id",
            foreign_name = "name"
          }
        end

        ui.heading{ level = 2, content = _"Enter your proposal and/or reasons" }

        ui.field.text{
          name = "content",
          multiline = true,
          attr = { style = "height: 50ex; width: 100%;" },
          value = param.get("content")
        }
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            name = "preview",
            class = "btn btn-default",
            value = _'Preview'
          },
          content = ""
        }
        slot.put("<br />")
        slot.put("<br />")
        
        ui.link{
          content = _"Cancel",
          module = "initiative",
          view = "show",
          id = initiative.id
        }
        
      end )
    end
  end
}
