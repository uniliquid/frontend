local member = param.get ( "member", "table" ) or app.session.member

local unit = param.get ( "unit", "table" )

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
  unit:load_delegation_info_once_for_member_id(member.id)
  areas:load_delegation_info_once_for_member_id(member.id)
end

  
ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHead( function ()
    ui.heading {
      level = 2, content = _"Subject areas"
    }
  end )
  
  if #areas > 0 then
    
    ui.container { class = "areas", content = function ()
      
      for i, area in ipairs ( areas ) do
        
        ui.container { attr = { class = "sidebarRow" }, content = function ()
        
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
        
          if area.subscribed then
            ui.image { attr = { class = "icon24 star" }, static = "icons/48/star.png" }
          end
          
          ui.link {
            attr = { class = "area" },
            module = "area", view = "show", id = area.id,
            content = area.name
          }
          
        end } -- ui.tag "li"
        
      end -- for i, area
      
    end } -- ui.tag "ul"
    
  end -- if #areas > 0

end ) -- ui.sidebar