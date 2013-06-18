local id = param.get_id()

local member = Member:by_id(id)

if member then
  ui.title(_("Member: '#{identification}' (#{name})", { identification = member.identification, name = member.name }))
  ui.actions(function()
    if member.activated then
      ui.link{
        text = _("Profile"),
        module = "member",
        view = "show",
        id = member.id
      }
    end
  end)
else
  ui.title(_"Register new member")
end

local units_selector = Unit:new_selector()
  
if member then
  units_selector
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :add_field("privilege.voting_right", "voting_right")
end

local units = units_selector:exec()
  
ui.form{
  attr = { class = "vertical" },
  module = "admin",
  action = "member_update",
  id = member and member.id,
  record = member,
  readonly = not app.session.member.admin,
  routing = {
    default = {
      mode = "redirect",
      modules = "admin",
      view = "member_list",
      params = {
        search           = param.get("search"),
        search_admin     = param.get("search_admin",     atom.integer),
        search_activated = param.get("search_activated", atom.integer),
        search_locked    = param.get("search_locked",    atom.integer),
        search_active    = param.get("search_active",    atom.integer),
        order            = param.get("order"),
        desc             = param.get("desc", atom.integer),
        page             = param.get("page", atom.integer)
      }
    }
  },
  content = function()

    if member then
      ui.field.text{ label = _"Id", value = member.id }
    end

    ui.field.text{     label = _"Identification", name = "identification" }
    ui.field.text{     label = _"Notification email", name = "notify_email" }
    if member and member.activated then
      ui.field.text{     label = _"Screen name",        name = "name" }
      ui.field.text{     label = _"Login name",        name = "login" }
    end
    ui.field.boolean{  label = _"Admin?",       name = "admin" }
    local matn = Rights:by_pk(member.id, "matn")
    if not matn then
      ui.field.text{     label = _"Matriculation number", name = "matn", value = "" }
    end

    slot.put("<br />")
    
    for i, unit in ipairs(units) do
      ui.field.boolean{
        name = "unit_" .. unit.id,
        label = unit.name,
        value = unit.voting_right
      }
    end
    slot.put("<br /><br />")

    if not member or not member.activated then
      ui.field.boolean{  label = _"Send invite?",       name = "invite_member" }
    end
    
    if member and member.activated then
      ui.field.boolean{  label = _"Lock member?",       name = "locked" }
    end
    
    ui.field.boolean{ 
      label = _"Member inactive?", name = "deactivate",
      readonly = member and member.active, value = member and member.active == false
    }
    
    slot.put("<br />")
    ui.submit{         text  = _"Save" }
  end
}
