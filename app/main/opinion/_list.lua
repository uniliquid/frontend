local opinions_selector = param.get("opinions_selector", "table")

ui.list{
  attr = { style = "table-layout: fixed" },
  records = opinions_selector:exec(),
  columns = {
    {
      label = nil,
      content = function(record)
      end
    },
    {
      label = _"Member name",
      label_attr = { style = "width: 101px;" },
      content = function(arg) return Member.object.ui_field_avatar_name(arg.member) end
    },
    {
      label = _"Incoming delegations",
      content = function(record)
        if record.weight > 1 then
          slot.put("+" .. record.weight-1)
        end
      end
    },
    --[[
    {
      label = nil,
      content = function(record)
      end
    },
    --]]--
    {
      label = _"Degree",
      label_attr = { style = "width: 250px;" },
      content = function(record)
        if record.degree == -2 then
          slot.put(_"must not")
        elseif record.degree == -1 then
          slot.put(_"should not")
        elseif record.degree == 1 then
          slot.put(_"should")
        elseif record.degree == 2 then
          slot.put(_"must")
        end
      end
    },
    {
      label = _"Suggestion currently implemented",
      content = function(record)
        if record.fulfilled then
          slot.put(_"Yes")
        else
          slot.put(_"No")
        end
      end
    },
    {
      label = _"happiness",
      content = function(record)
        if record then
          if (record.fulfilled and record.degree > 0) or (not record.fulfilled and record.degree < 0) then
            local title = _"satisfied"
            ui.image{ attr = { alt = title, title = title }, static = "icons/emoticon_happy.png" }
          elseif record.degree == 1 or record.degree == -1 then
            local title = _"a bit unsatisfied"
            ui.image{ attr = { alt = title, title = title }, static = "icons/emoticon_unhappy.png" }
          else
            local title = _"more unsatisfied"
            ui.image{ attr = { alt = title, title = title }, static = "icons/emoticon_unhappy_red.png" }
          end
        end
      end
    },
  }
}
