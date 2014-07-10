local initiative_id = param.get("initiative_id")

ui.form{
  module = "suggestion",
  action = "add",
  params = { initiative_id = initiative_id },
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id,
      params = { tab = "suggestions" }
    }
  },
  attr = { class = "section vertical" },
  content = function()
  
    ui.sectionHead( function()
      ui.heading { level = 1, content = _"Add a new suggestion for improvement" }
    end)
    
    ui.sectionRow( function()
    
      local supported = Supporter:by_pk(initiative_id, app.session.member.id) and true or false
      if not supported then
        ui.field.text{
          attr = { class = "warning" },
          value = _"You are currently not supporting this initiative directly. By adding suggestions to this initiative you will automatically become a potential supporter."
        }
      end
      ui.field.text{ label = _"A short title (80 chars max)", name = "name" }
      
      if not config.enforce_formatting_engine then
        ui.field.select{
          label = _"Wiki engine",
          name = "formatting_engine",
          foreign_records = config.formatting_engines,
          attr = {id = "formatting_engine"},
          foreign_id = "id",
          foreign_name = "name",
          value = param.get("formatting_engine")
        }
        ui.tag{
          tag = "div",
          content = function()
            ui.tag{
              tag = "label",
              attr = { class = "ui_field_label" },
              content = function() slot.put("&nbsp;") end,
            }
            ui.tag{
              content = function()
                ui.link{
                  text = _"Syntax help",
                  module = "help",
                  view = "show",
                  id = "wikisyntax",
                  attr = {onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
                }
                slot.put(" ")
                ui.link{
                  text = _"(new window)",
                  module = "help",
                  view = "show",
                  id = "wikisyntax",
                  attr = {target = "_blank", onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
                }
              end
            }
          end
        }
      end

      ui.field.text{
        label = _"Describe how the proposal and/or the reasons of the initiative could be improved",
        name = "content",
        multiline = true, 
        attr = { style = "height: 50ex;" },
        value = param.get("content")
      }

      ui.field.select{
        label = _"How important is your suggestions for you?",
        name = "degree",
        foreign_records = {
          { id =  1, name = _"should be implemented"},
          { id =  2, name = _"must be implemented"},
        },
        foreign_id = "id",
        foreign_name = "name"
      }
      
      ui.submit{ text = _"publish suggestion" }
      slot.put(" ")
      ui.link{
        content = _"cancel",
        module = "initiative",
        view = "show",
        id = initiative_id,
        params = { tab = "suggestions" }
      }

    end )
  end
}
