local id = app.session.member_id
local for_unit = param.get("for_unit", atom.integer)
local revoke = param.get("revoke", atom.boolean)

local member = Member:by_id(id)

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
else
slot.put(_"Sorry, not yet possible.")
end
else
ui.container{
  attr = { class = "vertical" },
  id = member and member.id,
  record = member,
  readonly = true,
  content = function()
    for i, unit in ipairs(units) do
      ui.tag{ tag = "p", content = function()
      ui.tag{ tag = "b", content = unit.name .. ": " }
      if unit.voting_right then
        slot.put(_"Yes")
        if unit.id == 2 then
          slot.put(" &middot; ")
          ui.link{
            text = _"Revoke voting rights for this unit",
            module = "member",
            view = "rights",
            params = { for_unit = unit.id, revoke = true }
          }
        end
      else
        slot.put(_"No")
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
          params = { for_unit = unit.id }
        }
        end
      end
      slot.put('<div class="clearfix"></div>')
      end }
    end
  end
}
end
