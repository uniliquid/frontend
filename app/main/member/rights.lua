local id = app.session.member_id
local for_unit = param.get("for_unit", atom.integer)

local member = Member:by_id(id)

ui.title(_("My voting rights"))
util.help("member.settings.voting_rights", _"My voting rights")

local units_selector = Unit:new_selector()
  
if member then
  units_selector
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :add_field("privilege.voting_right", "voting_right")
end

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
    ui.field.text{ label = _"Matr. Number", name = "matn" }
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
      else
        slot.put(_"No")
        if unit.mail and string.find(unit.mail, 'XXXXXXX') then
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
