local initiative_id = param.get("initiative_id")
local initiative = Initiative:by_id(initiative_id)

local side = param.get("side")

ui.title(function()
  if side == "pro" then
    slot.put(_"Add new argument pro")
  else
    slot.put(_"Add new argument contra")
  end
end, initiative.issue.area.unit, initiative.issue.area, initiative.issue, initiative)

ui.actions(function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/cancel.png" }
      slot.put(_"Cancel")
    end,
    module = "initiative",
    view = "show",
    id = initiative_id,
    params = { tab = "arguments" }
  }
end)

ui.form{
  module = "argument",
  action = "add",
  params = { initiative_id = initiative_id, side = side },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id,
      params = { tab = "arguments" }
    }
  },
  attr = { class = "vertical" },
  content = function()

    if param.get("preview") then

      ui.container{ attr = { class = "initiative_head" }, content = function()

        ui.container{ attr = { class = "title suggestion_title" }, content = param.get("name") }

        ui.container{ attr = { class = "content" }, content = function()

          ui.container{
            attr = { class = "initiator_names" },
            content = function()

              if app.session:has_access("all_pseudonymous") then
                ui.link{
                  content = function()
                    execute.view{
                      module = "member_image",
                      view = "_show",
                      params = {
                        member = app.session.member,
                        image_type = "avatar",
                        show_dummy = true,
                        class = "micro_avatar"
                      }
                    }
                  end,
                  module = "member", view = "show", id = app.session.member.id
                }
                slot.put(" ")
              end
              ui.link{
                text = app.session.member.name,
                module = "member", view = "show", id = app.session.member.id
              }

            end
          }

        end }

        ui.container{
          attr = { class = "draft_content wiki" },
          content = function()
            slot.put( format.wiki_text(param.get("content"), param.get("formatting_engine")) )
          end
        }

      end }

      ui.submit{ text = _"Commit argument" }
      slot.put("<br /><br /><br />")

    end

    ui.field.text{
      label = _"Title",
      name = "name",
      attr = { maxlength = 256 },
      value = param.get("name")
    }

    ui.wikitextarea("content", _"Description")

    ui.submit{ name = "preview", text = _"Preview" }
    ui.submit{ attr = { class = "additional" }, text = _"Commit argument" }

  end
}
