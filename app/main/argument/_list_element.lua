
local initiative = param.get("initiative", "table")
local arguments_selector = param.get("arguments_selector", "table")

local tab_id = param.get("tab_id")
local show_name = param.get("show_name", atom.boolean)
if show_name == nil then
  show_name = true
end
local show_filter = param.get("show_filter", atom.boolean)
if show_filter == nil then
  show_filter = true
end

local ui_filters = ui.filters
if true or not show_filter then
  ui_filters = function(args) args.content() end
end

ui.container{ attr = { class = "box suggestion_opinion" },
  content = function()
    ui.list{
      attr = { style = "table-layout: fixed" },
      records = arguments_selector:exec(),
      columns = {
        {
          content = function(record)
            if record.side == "pro" then
              slot.put( _"Ratings by (potential) supporters" .. ":" )
            else
              slot.put( _"Ratings by interested non-supporters" .. ":" )
            end
          end
        },
        {
          label = _"Balance",
          field_attr = { style = "text-align: center" },
          content = function(record)

            local value = record.plus_count - record.minus_count
            if value > 0 then
              ui.container{
                attr = { class = "positive", style = "font-weight:bold" },
                title = _"Rating",
                content = string.format("%+d", value)
              }
            elseif value < 0 then
              ui.container{
                attr = { class = "negative", style = "font-weight:bold" },
                title = _"Rating",
                content = string.format("%+d", value)
              }
            else
              ui.container{
                attr = { class = "neutral", style = "font-weight:bold" },
                title = _"Rating",
                content = "0"
              }
            end

          end
        },
        {
          label = _"Positive",
          field_attr = { class = "positive", style = "text-align:center" },
          content = function(record)
            slot.put(record.plus_count)
          end
        },
        {
          label = _"Negative",
          field_attr = { class = "negative", style = "text-align:center" },
          content = function(record)
            slot.put(record.minus_count)
          end
        },
        {
          label = _"My rating",
          label_attr = { style = "padding-left: 1em; width: 130px; font-style: italic;" },
          field_attr = { style = "padding-left: 1em" },
          content = function(record)
            local negative
            local rating
            if app.session.member_id then
              rating = Rating:by_pk(app.session.member.id, record.id)
            end
            if rating then
              negative = rating.negative
            end
            ui.container{
              content = function()
                local has_voting_right = app.session.member and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id)
                if app.session.member_id and has_voting_right then

                  local supporter = Supporter:by_pk(initiative.id, app.session.member_id)
                  local left_bracket  = ""
                  local right_bracket = ""
                  if (record.side == "pro") == (not supporter) then -- xor
                    left_bracket  = "("
                    right_bracket = ")"
                  end

                  if initiative.issue.state == "voting" or initiative.issue.state == "closed" then
                    if negative == true then
                      ui.tag{
                        tag = "span",
                        attr = { class = "action active_red2" },
                        content = left_bracket .. _"negative" .. right_bracket
                      }
                    elseif negative == false then
                      ui.tag{
                        tag = "span",
                        attr = { class = "action active_green2" },
                        content = left_bracket .. _"positive" .. right_bracket
                      }
                    else
                      ui.tag{
                        tag = "span",
                        attr = { class = "action active" },
                        content = _"neutral"
                      }
                    end
                  else

                    params = param.get_all_cgi()
                    params['initiative_id'] = initiative.id

                    ui.link{
                      attr = { class = "action" .. (negative == false and " active_green2" or "") },
                      text = left_bracket .. _"positive" .. right_bracket,
                      module = "rating",
                      action = "update",
                      routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = params } },
                      params = {
                        argument_id = record.id,
                        negative = false
                      }
                    }
                    slot.put(" ")
                    ui.link{
                      attr = { class = "action" .. (negative == nil and " active" or "") },
                      text = _"neutral",
                      module = "rating",
                      action = "update",
                      routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = params } },
                      params = {
                        argument_id = record.id,
                        delete = true
                      }
                    }
                    slot.put(" ")
                    ui.link{
                      attr = { class = "action" .. (negative == true and " active_red2" or "") },
                      text = left_bracket .. _"negative" .. right_bracket,
                      module = "rating",
                      action = "update",
                      routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = params } },
                      params = {
                        argument_id = record.id,
                        negative = true
                      }
                    }
                  end

                  if record.side == "pro" then
                    if not supporter then
                      slot.put(" &nbsp; " .. _"Your rating is not counted, because you don't support this initiative.")
                    end
                  else
                    if supporter then
                      slot.put(" &nbsp; " .. _"Your rating is not counted, because you support this initiative.")
                    end
                  end

                elseif app.session.member_id then
                  ui.field.text{ value = _"[No voting privilege]" }
                else
                  ui.field.text{ value = _"[Registered members only]" }
                end
              end
            }
          end
        },
      }
    }
  end
}
