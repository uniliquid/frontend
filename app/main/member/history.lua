local member = Member:by_id(param.get_id())

ui.titleMember(member)

ui.section( function()

  ui.sectionHead( function()
    ui.heading{ level = 1, content = _"Account history" }
  end)

  ui.sectionRow( function()
    ui.form{
      attr = { class = "vertical" },
      content = function()
        ui.field.text{ label = _"Current name", value = member.name }
        ui.field.text{ label = _"Current status", value = member.active and _'activated' or _'deactivated' }
      end
    }


    local entries = member:get_reference_selector("history_entries"):add_order_by("id DESC"):exec()
    
    if #entries > 0 then
      ui.tag{
        tag = "table",
        content = function()
          ui.tag{
            tag = "tr",
            content = function()
              ui.tag{
                tag = "th",
                content = _("Name")
              }
              ui.tag{
                tag = "th",
                content = _("Status")
              }
              ui.tag{
                tag = "th",
                content = _("until")
              }
            end
          }
          for i, entry in ipairs(entries) do
            ui.tag{
              tag = "tr",
              content = function()
                ui.tag{
                  tag = "td",
                  content = entry.name
                }
                ui.tag{
                  tag = "td",
                  content = entry.active and _'activated' or _'deactivated',
                }
                ui.tag{
                  tag = "td",
                  content = format.timestamp(entry["until"])
                }
              end
            }
          end
        end
      }
    end
    slot.put("<br />")
    ui.container{
      content = _("This member account has been created at #{created}", { created = format.timestamp(member.activated)})
    }
  end)

end)