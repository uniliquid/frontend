local delegations = Delegation:delegations_to_check_for_member_id(app.session.member_id)
    
ui.title(_"Current unit and area delegations need confirmation")

ui.actions(function()
  if not app.session.needs_delegation_check then
    ui.link{ module = "index", view = "index", text = _"Cancel" }
  end
end)

ui.form{
  module = "index", action = "check_delegations",
  routing = {
    default = { mode = "redirect", module = "index", view = "index" },
    error = { mode = "redirect", module = "index", view = "check_delegations" }
  },
  content = function()
  
    ui.tag{ tag = "table", attr = { class = "striped" }, content = function()

      ui.tag{ tag = "tr", content = function()
          
        ui.tag{ tag = "th", content = _"unit / area" }
        ui.tag{ tag = "th", content = _"delegated to" }
        ui.tag{ tag = "th", content = _"action" }
        
      end }
      
      for i, delegation in ipairs(delegations) do
          
        local unit = Unit:by_id(delegation.unit_id)
        local area = Area:by_id(delegation.area_id)
        local member = Member:by_id(delegation.trustee_id)
        local info
        if area then
          area:load_delegation_info_once_for_member_id(app.session.member_id)
          info = area.delegation_info
        else
          unit:load_delegation_info_once_for_member_id(app.session.member_id)
          info = unit.delegation_info
        end

        ui.tag{ tag = "tr", content = function ()
        
          ui.tag { tag = "td", content = function()
            ui.tag{ tag = "span", attr = { class = "unit_link" }, content = delegation.unit_name }
            ui.tag{ tag = "span", attr = { class = "area_link" }, content = delegation.area_name }
          end }
          
          ui.tag { tag = "td", content = function()
            if (member) then
              local text = _"delegates to"
              ui.image{
                attr = { class = "delegation_arrow", alt = text, title = text },
                static = "delegation_arrow_24_horizontal.png"
              }
              execute.view{ module = "member_image", view = "_show", params = {
                member = member, class = "micro_avatar", popup_text = member.name,
                  image_type = "avatar", show_dummy = true,
                } }
              slot.put("&nbsp;")
              ui.tag { tag = "span", content = delegation.member_name }
            else
              ui.tag{ tag = "span", content = _"Abandon unit delegation" }
            end
          end }
          
          ui.tag { tag = "td", content = function()
            local checked = config.check_delegations_default
            ui.tag{ tag = "input", attr = {
              type = "radio",
              id = "delegation_" .. delegation.id .. "_confirm",
              name = "delegation_" .. delegation.id,
              value = "confirm",
              checked = checked == "confirm" and "checked" or nil
            } }
            ui.tag{ 
              tag = "label", 
              attr = { ["for"] = "delegation_" .. delegation.id .. "_confirm" }, 
              content = _"confirm"
            }
            ui.tag{ tag = "input", attr = {
              type = "radio", 
              id = "delegation_" .. delegation.id .. "_revoke",
              name = "delegation_" .. delegation.id,
              value = "revoke",
              checked = checked == "revoke" and "checked" or nil 
            } }
            ui.tag{ 
              tag = "label", 
              attr = { ["for"] = "delegation_" .. delegation.id .. "_revoke" }, 
              content = _"revoke"
            }
          end}

        end }
        
      end
      
    end}


    slot.put("<br />")

    ui.submit{ text = _"Finish delegation check" }
  
  end
}
