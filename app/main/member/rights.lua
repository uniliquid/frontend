if config.voting_rights_management then
local id = app.session.member_id
local for_unit = param.get("for_unit", atom.integer)
local revoke = param.get("revoke", atom.boolean)
local rest = param.get("rest", atom.boolean)

local member = Member:by_id(id)
local all_units = true
if not member then
  return false
end

ui.title(_("My voting rights"))
util.help("member.settings.voting_rights", _"My voting rights")

if for_unit == 2 then
  if revoke ~= nil and not revoke then
    local unit_id = 2
    local privilege = Privilege:by_pk(unit_id, member.id)
    if privilege and not privilege.voting_right then
      privilege.voting_right = true
      privilege:save()
    elseif not privilege then
      privilege = Privilege:new()
      privilege.unit_id = unit_id
      privilege.member_id = member.id
      privilege.voting_right = true
      privilege:save()
    end
  elseif revoke ~= nil and revoke then
    local unit_id = 2
    local privilege = Privilege:by_pk(unit_id, member.id)
    if privilege then
      privilege:destroy()
    end
  end
  for_unit = nil
end

local units_selector = Unit:new_selector()
  
units_selector
  :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
  :add_field("privilege.voting_right", "voting_right")
  :add_order_by("unit.name ASC")

local units = units_selector:exec()

local found_unit
for i, unit in ipairs(units) do
  if unit.id == for_unit then
    found_unit = unit
  end
end

if found_unit and not found_unit.voting_right then
if found_unit.mail and string.find(found_unit.mail, 'XXXXXXX') then 
ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_rights",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.hidden{ name = "for_unit", value = for_unit }
    local matn = Rights:by_pk(app.session.member.id, "matn")
    if matn then
      ui.field.hidden{ name = "matn" }
    else
      ui.field.text{ label = _"Matr. Number", name = "matn" }
    end
    ui.submit{ value = _"Request Confirmation Mail" }
  end
}
return true
elseif found_unit.mail and string.len(found_unit.mail) > 5 then
ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_rights",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.hidden{ name = "for_unit", value = for_unit }
    ui.field.text{ label = _"Email address", name = "email" }
    ui.submit{ value = _"Request Confirmation Mail" }
  end
}
return true
else
slot.put(_"To get voting rights in this unit, we need to verify your matriculation number. Currently this is possible at one of the following universities:<br />")
all_units = false
end
end
ui.container{
  attr = { class = "vertical" },
  id = member and member.id,
  record = member,
  readonly = true,
  content = function()
    local unit_tree = {}
    for i, unit in ipairs(units) do
      if not unit.parent_id then
        unit_tree[#unit_tree+1] = unit
        recursive_add_child_units(units, unit)
      end
    end
   local units2
   if all_units then
    local depth = 1
    units2 = {}
    for i, unit in ipairs(unit_tree) do
      unit.depth = depth
      units2[#units2+1] = unit
      recursive_get_child_units(units2, unit, depth + 1)
    end
   else
    units2 = {}
    for i, unit in ipairs(units) do
      if rest then
        if unit.voting_right and unit.mail and unit.mail ~= 'none' and not string.find(unit.mail, 'XXXXXXX') then
          unit.depth = 1
          units2[#units2+1] = unit
        end
      else
        if not unit.voting_right and unit.mail and string.find(unit.mail, 'XXXXXXX') then
          unit.depth = 1
          units2[#units2+1] = unit
        end
      end
    end
   end
  ui.list{
    attr = { class = "unit_list" },
    records = units2,
    columns = {
      {
        content = function(unit)
         if all_units or rest or not unit.voting_right and unit.mail and string.find(unit.mail, 'XXXXXXX') then
          if all_units then
          for i = 1, unit.depth - 1 do
            slot.put("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
          end
          end
          ui.link{ text = function()
              ui.image{ attr = { class = "spaceicon", style = "width: 16px; height: 16px;" }, static = "icons/units/" .. unit.name .. ".ico" }
              ui.tag{ content = unit.name }
            end,
            module = "unit", view = "show", id = unit.id
          }
          slot.put(" &middot; Stimmrecht: ")
      if unit.voting_right then
        ui.image{ attr = { alt = _"Yes", class = "spaceicon" }, static = "icons/16/tick.png" }
        if unit.id == 2 then
          slot.put(" &middot; ")
          ui.link{
            text = _"Revoke voting rights for this unit",
            module = "member",
            view = "rights",
            params = { for_unit = unit.id, revoke = true }
          }
        elseif rest then
          slot.put(" &middot; ")
          ui.link{
            text = _"Meet your local UniLiquid support to get voting rights",
            module = "member",
            view = "show",
            id = unit.admin_id
          }
        end
      else
        ui.image{ attr = { alt = _"No", class = "spaceicon" }, static = "icons/16/cross.png" }
        if unit.id == 2 then
          slot.put(" &middot; ")
          ui.link{
            text = _"Get voting rights for this unit",
            module = "member",
            view = "rights",
            params = { for_unit = unit.id, revoke = false }
          }
        else
        slot.put(" &middot; ")
        ui.link{
          text = _"Get voting rights for this unit",
          module = "member",
          view = "rights",
          params = { for_unit = unit.id, matr = true }
        }
        end
      end
      end
      end
      }
    }
  }
end
}
if not all_units and not rest then
  slot.put('<br style="clear: both;" />')
  slot.put('<br style="clear: both;" />')
  ui.link{
    image = ui.image{ attr = { class = "spaceicon" }, static = "icons/16/emoticon_unhappy.png" },
    text = _"I'm not studying at any of the universities above",
    module = "member",
    view = "rights",
    params = { for_unit = for_unit, rest = true }
  }
end
end
