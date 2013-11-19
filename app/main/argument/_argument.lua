local argument = param.get("argument", "table")

ui.container{ attr = { class = "initiative_head suggestion_head" }, content = function()

  ui.container{ attr = { class = "title suggestion_title" }, content = argument.name }

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
                  member = argument.author,
                  image_type = "avatar",
                  show_dummy = true,
                  class = "micro_avatar"
                }
              }
            end,
            module = "member", view = "show", id = argument.author.id
          }
          slot.put(" ")
          ui.link{
            text = argument.author.name,
            module = "member", view = "show", id = argument.author.id
          }
        end

        ui.tag{
          attr = { class = "draft_version suggestion_created" },
          content = _("at #{date} #{time}", {
            date = format.date(argument.created),
            time = format.time(argument.created)
          })
        }

      end
    }

  end }

  ui.container{
    attr = { class = "draft_content wiki" },
    content = function()
      slot.put(argument:get_content("html"))
    end
  }

end }

slot.put('<br style="clear: both;" />'); 

execute.view{
  module = "argument",
  view = "_list_element",
  params = {
    arguments_selector = Argument:new_selector():add_where{ "id = ?", argument.id },
    initiative = argument.initiative,
    show_name = false,
    show_filter = false
  }
}

if config.absolute_base_short_url then
  ui.container{
    attr = { class = "shortlink" },
    content = function()
      slot.put(_"Short link" .. ": ")
      local link = config.absolute_base_short_url .. "a" .. argument.id
      ui.link{ external = link, text = link }
    end
  }
end
