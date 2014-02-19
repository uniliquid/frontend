ui.title(_"Notification settings")

util.help("member.settings.notification", _"Notification settings")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_notify_level",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    local notify_level_s = string.find(app.session.member.admin_comment or "", " 39 ") and true or false

    ui.tag{ tag = "p", content = _"I like to receive notifications by email about events in my areas and issues:" }
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_none",
          type = "radio", name = "notify_level", value = "none",
          checked = app.session.member.notify_level == 'none' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_none" },
        content = _"No notifications at all"
      }
    end }
     
    slot.put("<br />")
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_all",
          type = "radio", name = "notify_level", value = "all",
          checked = app.session.member.notify_level == 'all' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_all" },
        content = _"All of them"
      }
    end }
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_discussion",
          type = "radio", name = "notify_level", value = "discussion",
          checked = app.session.member.notify_level == 'discussion' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_discussion" },
        content = _"Only for issues reaching the discussion phase"
      }
    end }

    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_verification",
          type = "radio", name = "notify_level", value = "verification",
          checked = app.session.member.notify_level == 'verification' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_verification" },
        content = _"Only for issues reaching the frozen phase"
      }
    end }
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_voting",
          type = "radio", name = "notify_level", value = "voting",
          checked = app.session.member.notify_level == 'voting' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_voting" },
        content = _"Only for issues reaching the voting phase"
      }
    end }

    slot.put("<br />")
   
   if config.notify_satzung_direkt then
    ui.container{ content = function()
      ui.tag{
        tag = "input",
        attr = {
          id = "notify_level_s",
          type = "checkbox", name = "notify_level_s", value = "39",
          checked = notify_level_s and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_s" },
        content = function()
          slot.put("Unabhängig davon möchte ich per E-Mail über ")
          ui.tag{ tag = "b", content = "Satzungsänderungen" }
          slot.put(" informiert werden.")
        end
      }
    end }
    
    slot.put("<br />")
   end

    ui.container{ content = function()
      ui.tag{
        tag = "input",
        attr = {
          id = "notify_level_expert",
          type = "radio", name = "notify_level", value = "expert",
          checked = app.session.member.notify_level == 'expert' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_expert" },
        content = _"Detailed selection:"
      }
    end }

    slot.put("<br />")


    local records = Notify:records()

    -- get current selection
    local notify_table = {}
    if app.session.member.notify_level == 'expert' then

      -- get expert selection from database
      local notify = Notify:new_selector()
        :add_where({ "member_id = ?", app.session.member.id })
        :exec()
      for i,record in ipairs(notify) do
        notify_table[record.interest] = record
      end

    else

      -- show selection of the predefined notify level
      local open = false
      for key,record in ipairs(records) do
        if record.level == app.session.member.notify_level or open then

          -- my_areas
          if record.name ~= "admission__new_draft_created" and record.name ~= "admission__suggestion_created" then
            if not notify_table.my_areas then
              notify_table.my_areas = {}
            end
            notify_table.my_areas[record.name] = true
          end
          -- interested
          if not notify_table.interested then
            notify_table.interested = {}
          end
          notify_table.interested[record.name] = true
          -- potentially supported
          if not notify_table.potentially then
            notify_table.potentially = {}
          end
          notify_table.potentially[record.name] = true
          -- supported
          if not notify_table.supported then
            notify_table.supported = {}
          end
          notify_table.supported[record.name] = true

          open = true
        end
      end

    end

    -- set the radio button selection to expert if the user changes any of the checkboxes for detailed selection
    slot.put('<script type="text/javascript">function detailed() { document.getElementById("notify_level_expert").checked = true; }</script>')

    function checkbox(record, interest)
      -- exclude some combinations which do not make sense
      if (record.name == "initiative_created_in_new_issue" and interest ~= "all" and interest ~= "my_units" and interest ~= "my_areas")
      or (interest == "voted" and record.name ~= "finished_with_winner" and record.name ~= "finished_without_winner")
      or ((interest == "potentially" or interest == "supported" or interest == "initiated")
        and record.name ~= 'admission__new_draft_created'
        and record.name ~= 'admission__suggestion_created'
        and record.name ~= 'admission__initiative_revoked'
        and record.name ~= 'discussion__new_draft_created'
        and record.name ~= 'discussion__suggestion_created'
        and record.name ~= 'discussion__argument_created'
        and record.name ~= 'discussion__initiative_revoked'
        and record.name ~= 'verification__initiative_revoked'
        and record.name ~= 'verification__argument_created' ) then
        return
      end
      ui.tag{
        tag = "input",
        attr = {
          type = "checkbox",
          name = "notify__" .. interest .. "[]",
          value = record.name,
          checked = notify_table[interest] and notify_table[interest][record.name] and "checked" or nil,
          onchange = "detailed()"
        }
      }
    end

    ui.list{
      style   = "table",
      records = records,
      attr = { class = "notify" },
      columns = {
        {
          label_attr = { class = "ui_list_notify_phase" },
          field_attr = { class = "ui_list_notify_phase" },
          label = _"Phase",
          content = function(record)
            slot.put(record.phase)
          end
        },
        {
          label_attr = { class = "ui_list_notify_event" },
          field_attr = { class = "ui_list_notify_event" },
          label = _"Event",
          content = function(record)
            slot.put(record.title)
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"All",
          content = function(record)
            checkbox(record, "all")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"All in my units",
          content = function(record)
            checkbox(record, "my_units")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"All in my areas",
          content = function(record)
            checkbox(record, "my_areas")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"Interested",
          content = function(record)
            checkbox(record, "interested")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"Potentially supported",
          content = function(record)
            checkbox(record, "potentially")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"Supported",
          content = function(record)
            checkbox(record, "supported")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"Initiated",
          content = function(record)
            checkbox(record, "initiated")
          end
        },
        {
          label_attr = { class = "ui_list_notify" },
          label = _"Voted",
          content = function(record)
            checkbox(record, "voted")
          end
        }
      }
    }

    slot.put("<br />")

    ui.submit{ value = _"Change notification settings" }
  end
}
 
