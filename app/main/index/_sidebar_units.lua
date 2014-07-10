local member = param.get ( "member", "table" )
local units
if member then
  units = member.units
  units:load_delegation_info_once_for_member_id(member.id)
else
  units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
  ui.sidebar( "tab-whatcanido", function()
    ui.sidebarHead( function()
      ui.heading { level = 2, content = _"Organizational units" }
    end )
    ui.sidebarSection( function()
      execute.view { module = "unit", view = "_list" }
    end )
  end )
  return
end


for i, unit in ipairs(units) do
  
  ui.sidebar ( "tab-whatcanido units", function ()

    local areas_selector = Area:new_selector()
      :reset_fields()
      :add_field("area.id", nil, { "grouped" })
      :add_field("area.unit_id", nil, { "grouped" })
      :add_field("area.name", nil, { "grouped" })
      :add_where{ "area.unit_id = ?", unit.id }
      :add_where{ "area.active" }
      :add_order_by("area.name")

    if member then
      areas_selector:left_join ( 
        "membership", nil, 
        { "membership.area_id = area.id AND membership.member_id = ?", member.id } 
      )
      areas_selector:add_field("membership.member_id NOTNULL", "subscribed", { "grouped" })
    end

    local areas = areas_selector:exec()
    if member then
      areas:load_delegation_info_once_for_member_id(member.id)
    end
    
    if #areas > 0 then

      ui.container {
        attr = { class = "sidebarHead" },
        content = function ()
          ui.heading { level = 2, content = function ()
            ui.link {
              attr = { class = "unit" },
              module = "unit", view = "show", id = unit.id,
              content = unit.name
            }
          
            if member then
              local delegation = Delegation:by_pk(member.id, unit.id, nil, nil)
              
              if delegation then
                ui.link { 
                  module = "delegation", view = "show", params = {
                    unit_id = unit.id
                  },
                  attr = { class = "delegation_info" }, 
                  content = function ()
                    ui.delegation(delegation.trustee_id, delegation.trustee.name)
                  end
                }
              end
            end
          end }
          
        end
      }
      
      
      ui.tag { tag = "div", attr = { class = "areas areas-" .. unit.id }, content = function ()
      
        local any_subscribed = false
        local subscribed_count = 0
        for i, area in ipairs(areas) do

          local class = "sidebarRow"
          class = class .. (not area.subscribed and " disabled" or "")
          
          ui.tag { tag = "div", attr = { class = class }, content = function ()
            
            if area.subscribed then
              local text = _"subscribed"
              ui.image { attr = { class = "icon24 star", alt = text, title = text }, static = "icons/48/star.png" }
              any_subscribed = true
              subscribed_count = subscribed_count +1
            end
            
            if member then
              local delegation = Delegation:by_pk(member.id, nil, area.id, nil)
        
              if delegation then
                ui.link { 
                  module = "delegation", view = "show", params = {
                    area_id = area.id
                  },
                  attr = { class = "delegation_info" }, 
                  content = function ()
                    ui.delegation(delegation.trustee_id, delegation.trustee_id and delegation.trustee.name)
                  end
                }
              end
            end
      
            slot.put ( " " )
            
            ui.link {
              attr = { class = "area" },
              module = "area", view = "show", id = area.id,
              content = area.name
            }
            
            
          end }
        end
        if subscribed_count < #areas then
          local text 
          if any_subscribed then
            text = _"show other subject areas"
          else
            text = _"show subject areas"
          end
          ui.script{ script = "$('.areas-" .. unit.id .. "').addClass('folded');" }
          ui.tag { tag = "div", attr = { class = "sidebarRow moreLink whenfolded" }, content = function ()
            ui.link {
              attr = { 
                onclick = "$('.areas-" .. unit.id .. "').removeClass('folded'); return false;"
              },
              text = text
            }
          end }
          ui.tag { tag = "div", attr = { class = "sidebarRow moreLink whenunfolded" }, content = function ()
            ui.link {
              attr = { 
                onclick = "$('.areas-" .. unit.id .. "').addClass('folded'); return false;"
              },
              text = _"collapse subject areas"
            }
          end }
        end
      end }
    end 
  end )
end


