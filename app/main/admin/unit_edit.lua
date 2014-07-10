local id = param.get_id()

local unit = Unit:by_id(id)

if unit then
  ui.titleAdmin(_"Organizational unit")
end

local units = {
  { id = nil, name = "" }
}

for i, unit in ipairs(Unit:get_flattened_tree()) do
  units[#units+1] = { id = unit.id, name = unit.name }
end

ui.form{
  attr = { class = "vertical section" },
  module = "admin",
  action = "unit_update",
  id = unit and unit.id,
  record = unit,
  routing = {
    default = {
      mode = "redirect",
      modules = "admin",
      view = "index"
    }
  },
  content = function()
    ui.sectionHead( function()
      ui.heading { level = 1, content = unit and unit.name or _"New organizational unit" }
    end )
    ui.sectionRow( function()
      ui.field.select{
        label = _"Parent unit",
        name = "parent_id",
        foreign_records = units,
        foreign_id      = "id",
        foreign_name    = "name"
      }
      ui.field.text{     label = _"Name",         name = "name" }
      ui.field.text{     label = _"Description",  name = "description", multiline = true }
      ui.field.boolean{  label = _"Active?",      name = "active" }

      slot.put("<br />")
      ui.submit{         text  = _"update unit" }
      slot.put(" ")
      ui.link{ module = "admin", view = "index", content = _"cancel" }
    end )
  end
}
