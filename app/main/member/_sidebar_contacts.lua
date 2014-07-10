local member = param.get("member", "table")

local public_contacts_selector = Contact:build_selector{
  public = true,
  member_id = member.id,
  order = "name"
}

local private_contacts_selector = Contact:build_selector{
  public = false,
  member_id = member.id,
  order = "name"
}

ui.sidebar( "tab-members", function()

  ui.sidebarHead( function()
    ui.heading { level = 2, content = _"Published contacts" }
  end )
  
  --ui.sidebarSection( function()

    if public_contacts_selector:count() == 0 then
      ui.sidebarSection( function()
        ui.field.text{ value = _"No published contacts" }
      end )
    else
      ui.paginate{
        selector = public_contacts_selector,
        name = "contacts",
        content = function()
          local contacts = public_contacts_selector:exec()
          for i, contact in ipairs(contacts) do
            ui.sidebarSection( "sidebarRowNarrow", function()
              execute.view{ module = "member_image", view = "_show", params = {
                member_id = contact.other_member.id, class = "micro_avatar", 
                popup_text = contact.other_member.name,
                image_type = "avatar", show_dummy = true,
              } }
              slot.put(" ")
              ui.link{
                content = contact.other_member.name,
                module = "member",
                view = "show",
                id = contact.other_member.id
              }
            end )
          end
        end
      }
    end
  --end )
    
    
  if member.id == app.session.member.id and private_contacts_selector:count() > 0 then

    ui.sidebarHead( function()
      ui.heading { level = 2, content = _"Private contacts" }
    end )
    
    ui.paginate{
      selector = private_contacts_selector,
      name = "contacts",
      content = function()
        local contacts = private_contacts_selector:exec()
        for i, contact in ipairs(contacts) do
          ui.sidebarSection( "sidebarRowNarrow", function()
            execute.view{ module = "member_image", view = "_show", params = {
              member_id = contact.other_member.id, class = "micro_avatar", 
              popup_text = contact.other_member.name,
              image_type = "avatar", show_dummy = true,
            } }
            slot.put(" ")
            ui.link{
              content = contact.other_member.name,
              module = "member",
              view = "show",
              id = contact.other_member.id
            }
          end )
        end
      end
    }

  end
end )