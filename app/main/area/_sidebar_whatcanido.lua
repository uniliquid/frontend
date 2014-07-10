local member = param.get ( "member", "table" ) or app.session.member

local area = param.get ( "area", "table" )

local participating_trustee_id
local participating_trustee_name
if member then
  if area.delegation_info.first_trustee_participation then
    participating_trustee_id = area.delegation_info.first_trustee_id
    participating_trustee_name = area.delegation_info.first_trustee_name
  elseif area.delegation_info.other_trustee_participation then
    participating_trustee_id = area.delegation_info.other_trustee_id
    participating_trustee_name = area.delegation_info.other_trustee_name
  end
end

ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHeadWhatCanIDo()
  
  if member and not app.session.member:has_voting_right_for_unit_id(area.unit_id) then
    ui.sidebarSection( _"You are not entitled to vote in this unit" )
  end
  
  if member and app.session.member:has_voting_right_for_unit_id(area.unit_id) then
    if not area.delegation_info.own_participation then
      ui.sidebarSection ( function ()
      
        ui.heading {
          level = 3, 
          content = _"I want to participate in this subject area"
        }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.tag { content = function ()
              ui.link {
                module = "membership", action = "update",
                routing = { default = {
                  mode = "redirect", module = "area", view = "show", id = area.id
                } },
                params = { area_id = area.id },
                text = _"subscribe"
              }
            end }
          end }
        end }
      end )
    end
      
    if area.delegation_info.own_participation then
      ui.sidebarSection ( function ()
        ui.image{ attr = { class = "right" }, static = "icons/48/star.png" }
        ui.heading {
          level = 3, 
          content = _"You are subscribed for this subject area" 
        }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.tag { content = function ()
              ui.link {
                module = "membership", action = "update",
                routing = { default = {
                  mode = "redirect", module = "area", view = "show", id = area.id
                } },
                params = { area_id = area.id, delete = true },
                text = _"unsubscribe"
              }
            end }
          end }
        end }
      end )
    end
    
    
    ui.sidebarSection ( function ()
    

      if not area.delegation_info.first_trustee_id then
        ui.heading{ level = 3, content = _"I want to delegate this subject area" }
      else
        ui.container { attr = { class = "right" }, content = function()
          local member = Member:by_id(area.delegation_info.first_trustee_id)
          execute.view{
            module = "member_image",
            view = "_show",
            params = {
              member = member,
              image_type = "avatar",
              show_dummy = true
            }
          }
        end }
        ui.heading{ level = 3, content = _"You delegated this subject area" }
      end

      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        if area.delegation_info.own_delegation_scope == "unit" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                unit_id = area.unit_id,
              },
              content = _("change/revoke delegation of organizational unit")
            }
          end }
        end
        
        if area.delegation_info.own_delegation_scope == nil then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                area_id = area.id
              },
              content = _"choose subject area delegatee" 
            }
          end }
        elseif area.delegation_info.own_delegation_scope == "area" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                area_id = area.id
              },
              content = _"change/revoke area delegation" 
            }
          end }
        else
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                area_id = area.id
              },
              content = _"change/revoke delegation only for this subject area" 
            }
          end }
        end
      end }
    end )


      
      
    if app.session.member:has_voting_right_for_unit_id ( area.unit_id ) then
      ui.sidebarSection ( function ()
        ui.heading {
          level = 3, 
          content = _("I want to start a new initiative", {
            area_name = area.name
          } ) 
        }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = _"Take a look through the existing issues. Maybe someone else started a debate on your topic (and you can join it) or the topic has been decided already in the past." }
          ui.tag { tag = "li", content = function ()
            ui.tag { content = function ()
              ui.tag { content = _"If you cannot find any appropriate existing issue, " }
              ui.link {
                module = "initiative", view = "new",
                params = { area_id = area.id },
                text = _"start an initiative in a new issue"
              }
            end }
          end }
        end }
      end )
    end
  else
  end
  
end )