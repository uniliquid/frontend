local suggestion = param.get("suggestion", "table")

ui.container{ attr = { class = "initiative_head suggestion_head" }, content = function()

  ui.container{ attr = { class = "title suggestion_title" }, content = suggestion.name }

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
                  member = suggestion.author,
                  image_type = "avatar",
                  show_dummy = true,
                  class = "micro_avatar"
                }
              }
            end,
            module = "member", view = "show", id = suggestion.author.id
          }
          slot.put(" ")
          ui.link{
            text = suggestion.author.name,
            module = "member", view = "show", id = suggestion.author.id
          }
        end

        ui.tag{
          attr = { class = "draft_version suggestion_created" },
          content = _("at #{date} #{time}", {
            date = format.date(suggestion.created),
            time = format.time(suggestion.created, { hide_seconds = true })
          })
        }

      end
    }

  end }

  ui.container{
    attr = { class = "draft_content wiki" },
    content = function()
      slot.put(suggestion:get_content("html"))
    end
  }

end }
slot.put('<br style="clear: both;" />')
--ui.container{ attr = { class = "heading" }, content = _"Your opinion to this suggestion" }
execute.view{
  module = "suggestion",
  view = "_list_element",
  params = {
    suggestions_selector = Suggestion:new_selector():add_where{ "id = ?", suggestion.id },
    initiative = suggestion.initiative,
    show_name = false,
    show_filter = false
  }
}

if config.absolute_base_short_url then
  ui.container{
    attr = { class = "shortlink" },
    content = function()
      slot.put(_"Short link" .. ": ")
      local link = config.absolute_base_short_url .. "s" .. suggestion.id
      ui.link{ external = link, text = link }
    end
  }
end
