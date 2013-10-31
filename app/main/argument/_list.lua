local initiative = param.get("initiative", "table")
local side = param.get("side")
local arguments_selector = param.get("arguments_selector", "table")
  :add_where{ "side = ?", side }
  :add_order_by("plus_count - minus_count DESC, id")

local supporter
if app.session.member_id then
  supporter = Supporter:by_pk(initiative.id, app.session.member.id)
end

local ui_filters = ui.filters
if true or not show_filter then
  ui_filters = function(args) args.content() end
end

local arguments = arguments_selector:exec()
if #arguments < 1 and initiative.issue.closed then
  return
end


ui.container{
  attr = { class = "initiative_head " .. (side == "pro" and "details_issue" or "details_initiative") },
  content = function()

    if app.session.member_id
--      and not initiative.issue.fully_frozen
      and not initiative.issue.closed
      and not initiative.revoked
      and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id)
    then
      ui.link{
        attr = { class = "add" },
        module = "argument",
        view = "new",
        params = { initiative_id = initiative.id, side = side },
        text = side == "pro" and _"New argument pro" or _"New argument contra",
        image = { attr = { class = "spaceicon" }, static = side == "pro" and "icons/16/comment_add.png" or "icons/16/comment_delete.png" }
      }
    end

    ui.anchor{
      name = "arguments",
      attr = { class = "title anchor" },
      content = side == "pro" and function()
        ui.image{ attr = { class = "spaceicon" }, static = "icons/16/add.png" }
        slot.put(_"Arguments pro")
      end
      or function()
        ui.image{ attr = { class = "spaceicon" }, static = "icons/16/delete.png" }
        slot.put(_"Arguments contra")
      end
    }

    ui.container{ attr = { class = "content" }, content = function()
      ui.paginate{
        selector = arguments_selector,
        anchor = "arguments",
        per_page = 10, -- number of arguments per page
        content = function()
          local arguments = arguments_selector:exec()
          if #arguments < 1 then
            if not initiative.issue.fully_frozen and not initiative.issue.closed then
              ui.tag{ content = _"No arguments yet" }
            else
              ui.tag{ content = _"No arguments" }
            end
          else
            ui.list{
              records = arguments,
              columns = {
                {
                  field_attr = { style = "text-align: right" },
                  content = function(record)

                    local value = record.plus_count - record.minus_count
                    if value > 0 then
                      ui.container{
                        attr = { class = "positive" },
                        title = _"Rating",
                        content = string.format("%+d", value)
                      }
                    elseif value < 0 then
                      ui.container{
                        attr = { class = "negative" },
                        title = _"Rating",
                        content = string.format("%+d", value)
                      }
                    else
                      ui.container{
                        attr = { class = "neutral" },
                        title = _"Rating",
                        content = "0"
                      }
                    end

                  end
                },
                {
                  content = function(record)
                    ui.link{
                      text = record.name,
                      module = "argument",
                      view = "show",
                      id = record.id
                    }
                    local degree
                    local rating
                    if app.session.member_id then
                      rating = Rating:by_pk(app.session.member.id, record.id)
                      if rating then
                        slot.put(" &middot; ")
                        local left_bracket  = ""
                        local right_bracket = ""
                        if (record.side == "pro") == (not supporter) then -- xor
                          left_bracket  = "("
                          right_bracket = ")"
                        end
                        if rating.negative == true then
                          ui.tag{ attr = { class = "negative" }, content = left_bracket .. _"negative" .. right_bracket }
                        else
                          ui.tag{ attr = { class = "positive" }, content = left_bracket .. _"positive" .. right_bracket }
                        end
                      end
                    end
                  end
                },
              }
            }
          end
        end
      }
    end }

  end
}
