local initiative = Initiative:by_id(param.get_id())

initiative:load_everything_for_member_id(app.session.member_id)
initiative.issue:load_everything_for_member_id(app.session.member_id)


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



execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue
  }
}

ui.form{
  method = "get",
  module = "draft",
  view = "diff",
  attr = { class = "section" },
  content = function()
    ui.field.hidden{ name = "initiative_id", value = initiative.id }
  
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
      ui.heading { level = 2, content = _"Draft history" }
    end)
    
    ui.sectionRow( function()
    
      local columns = {
        {
          label = _"draft ID",
          content = function(record)
            ui.tag { content = record.id }
          end
        },
        {
          label = _"published at",
          content = function(record)
            ui.link{
              attr = { class = "action" },
              module = "draft", view = "show", id = record.id,
              text = format.timestamp(record.created)
            }
          end
        },
        {
          label = _"compare",
          content = function(record)
            slot.put('<input type="radio" name="old_draft_id" value="' .. tostring(record.id) .. '">')
            slot.put('<input type="radio" name="new_draft_id" value="' .. tostring(record.id) .. '">')
          end
        }
      }
      
      if app.session:has_access("authors_pseudonymous") then
        columns[#columns+1] = {
          label = _"author",
          content = function(record)
            if record.author then
              return util.micro_avatar ( record.author )
            end
          end
        }
      end
      
      ui.list{
        records = initiative.drafts,
        columns = columns
      }
      
      slot.put("<br />")
      ui.container { attr = { class = "actions" }, content = function()
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "btn btn-default",
            value = _"compare revisions"
          },
          content = ""
        }
      end }
    end )
  end
}
