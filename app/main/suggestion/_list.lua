
local initiative = param.get("initiative", "table")
local suggestions_selector = param.get("suggestions_selector", "table")

suggestions_selector:add_order_by("proportional_order NULLS LAST, plus2_unfulfilled_count + plus1_unfulfilled_count DESC, plus2_unfulfilled_count DESC, id")

local ui_filters = ui.filters
if true or not show_filter then
  ui_filters = function(args) args.content() end
end

local suggestions = suggestions_selector:exec()
if #suggestions < 1 and (initiative.issue.half_frozen or initiative.revoked or initiative.issue.fully_frozen or initiative.issue.closed) then
  return
end

ui.container{ attr = { class = "initiative_head" },
  content = function()
     if app.session.member_id
      and not initiative.issue.half_frozen
      and not initiative.issue.closed
      and not initiative.revoked
      and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id)
    then
      local supporter = Supporter:by_pk(initiative.id, app.session.member.id)
      ui.link{
        attr = { class = "add" },
        image = { attr = { class = "spaceicon" }, static = "icons/16/note_add.png" },
        module = "suggestion",
        view = "new",
        params = { initiative_id = initiative.id,
                   degree = supporter and 1 or 2 },
        text = _"New suggestion"
      }
    end

    local suggestions = suggestions_selector:exec()
    local onclick = "";
    local display1 = "display: block;";
    local display2 = "display: none;"
    if #suggestions > 0 then
      onclick = "return toggleSuggestions();"
      if not initiative.issue.half_frozen then
        local tmp = display1;
        display1 = display2;
        display2 = tmp;
      end
    end
    ui.anchor{ name = "suggestions", attr = { class = "title anchor", href = "#", onclick = onclick }, content = function()
      ui.container{ attr = { id = "suggestions1", style = display1 }, content = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/note.png" }
      if #suggestions < 1 then
        slot.put(_"No suggestions yet")
      elseif #suggestions == 1 then
        slot.put(_"Show 1 Suggestion")
      else
        slot.put(_("Show #{count} Suggestions", { count = #suggestions }))
      end
      end
      }
      ui.container{ attr = { id = "suggestions2", style = display2 }, content = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/note.png" }
        slot.put(_("Suggestions (Hide)"))
      end
      }
    end
    }
    ui.container{ attr = { id = "suggestions_block", class = "content", style = display2 }, content = function()
      ui.paginate{
        selector = suggestions_selector,
        anchor = "suggestions",
        per_page = 20, -- number of suggestions per page
        content = function()
          if #suggestions > 0 then
            ui.list{
              attr = { style = "table-layout: fixed;" },
              records = suggestions,
              columns = {
                {
                  label_attr = { style = "width: 101px;" },
                  content = function(record)
                    if record.minus2_unfulfilled_count then
                      local max_value = record.initiative.supporter_count
                      local must = record.plus2_unfulfilled_count + record.plus2_fulfilled_count
                      local should = record.plus1_unfulfilled_count + record.plus1_fulfilled_count
                      local shouldnot = record.minus1_unfulfilled_count + record.minus1_fulfilled_count
                      local mustnot = record.minus2_unfulfilled_count + record.minus2_fulfilled_count
                      local neutral = max_value - must - should - shouldnot - mustnot 
                      ui.bargraph{
                        max_value = max_value,
                        width = 100,
                        bars = {
                          { color = "#0a0", value = must, text =  tostring(must) .. " " .. _"must" .. " / " },
                          { color = "#8f8", value = should, text = tostring(should) .. " " .. _"should" .. " / " },
                          { color = "#eee", value = neutral, text = tostring(neutral) .. " " .. _"neutral" .. " / " },
                          { color = "#f88", value = shouldnot, text = tostring(shouldnot) .. " " .. _"should not" .. " / " },
                          { color = "#a00", value = mustnot, text = tostring(mustnot) .. " " .. _"must not" },
                        }
                      }
                    end
                  end
                },
                {
                  content = function(record)
                    ui.link{
                      text = record.name,
                      module = "suggestion",
                      view = "show",
                      id = record.id
                    }
                    local degree
                    local opinion
                    if app.session.member_id then
                      opinion = Opinion:by_pk(app.session.member.id, record.id)
                    end
                    if opinion then
                      local degrees = {
                        ["-2"] = _"must not",
                        ["-1"] = _"should not",
                        ["0"] = _"neutral",
                        ["1"] = _"should",
                        ["2"] = _"must"
                      }
                      slot.put(" &middot; ")
                      ui.tag{ content = degrees[tostring(opinion.degree)] }
                      slot.put(" &middot; ")
                      if opinion.fulfilled then
                        ui.tag{ content = _"implemented" }
                      else
                        ui.tag{ content = _"not implemented" }
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
