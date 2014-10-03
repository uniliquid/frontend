local delegations_selector = param.get("delegations_selector", "table")
local outgoing = param.get("outgoing", atom.boolean)
local incoming = param.get("incoming", atom.boolean)
local member = app.session.member
local level = param.get("level")
local level_id = param.get("level_id",atom.integer)
if member and level == "area" then
  ui.link{ image = ui.image{ attr = { class = "spaceicon" }, static = "icons/16/folder_go.png" }, text = _"Change my delegation", module = "delegation", view = "show", params = { area_id = level_id, member_id = member.id } }
elseif member and level == "unit" then
  ui.link{ image = ui.image{ attr = { class = "spaceicon" }, static = "icons/16/folder_go.png" }, text = _"Change my delegation", module = "delegation", view = "show", params = { unit_id = level_id, member_id = member.id } }
end
slot.put("<br style='clear: left;' />")
slot.put("<br style='clear: left;' />")
local function delegation_scope(delegation)
  ui.container{
    attr = { class = "delegation_scope" },
    content = function()
      local area
      local unit
      if delegation.issue then
        area = delegation.issue.area
      elseif delegation.area then
        area = delegation.area
      else
        unit = delegation.unit
      end
      if unit then
        ui.link{
          content = _"Unit '#{name}'":gsub("#{name}", unit.name),
          module = "unit",
          view = "show",
          id = unit.id
        }
      end
      if area then
        ui.link{
          content = _"Area '#{name}'":gsub("#{name}", area.name),
          module = "area",
          view = "show",
          id = area.id
        }
      end
      if delegation.issue then
        ui.link{
          content = _"Issue ##{id}":gsub("#{id}", delegation.issue.id),
          module = "issue",
          view = "show",
          id = delegation.issue.id
        }
      end
    end
  }
end


ui.paginate{
  selector = delegations_selector,
  content = function()
    for i, delegation in ipairs(delegations_selector:exec()) do
      ui.container{
        attr = { class = "delegation_list_entry" },
        content = function()
          if outgoing then
            delegation_scope(delegation)
          else
            execute.view{
              module = "member",
              view = "_show_thumb",
              params = { member = delegation.truster }
            }
          end
          ui.image{
            attr = { class = "delegation_arrow" },
            static = "delegation_arrow.jpg"
          }
          if incoming then
            delegation_scope(delegation)
          else
            if delegation.trustee then
              execute.view{
                module = "member",
                view = "_show_thumb",
                params = { member = delegation.trustee }
              }
            else
              ui.tag{ content = _"Delegation abandoned" }
            end
          end
        end
      }
    end
    slot.put("<br style='clear: left;' />")
  end
}
