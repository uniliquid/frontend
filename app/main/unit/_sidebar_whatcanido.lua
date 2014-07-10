local unit = param.get ( "unit", "table" )

ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHeadWhatCanIDo()
  
  if app.session.member then
  
    if app.session.member:has_voting_right_for_unit_id ( unit.id ) then
      ui.sidebarSection( function ()
        
        if not unit.delegation_info.first_trustee_id then
          ui.heading{ level = 3, content = _"I want to delegate this organizational unit" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link {
                module = "delegation", view = "show", params = {
                  unit_id = unit.id,
                },
                content = _("choose delegatee", {
                  unit_name = unit.name
                })
              }
            end }
          end }
        else
          ui.container { attr = { class = "right" }, content = function()
            local member = Member:by_id(unit.delegation_info.first_trustee_id)
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
          ui.heading{ level = 3, content = _"You delegated this unit" }

          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link {
                module = "delegation", view = "show", params = {
                  unit_id = unit.id,
                },
                content = _("change/revoke delegation", {
                  unit_name = unit.name
                })
              }
            end }
          end }
        end
      end )

      ui.sidebarSection( function()
        ui.heading { level = 3, content = _"I want to start a new initiative" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = _"Open the appropriate subject area where your issue fits in and follow the instruction on that page." }
        end } 
      end )
    
    else
      ui.sidebarSection( _"You are not entitled to vote in this unit" )
    end

  end
  
end )