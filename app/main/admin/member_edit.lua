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
      view = "member_edit",
      id = member and member.id
    }
  },
  content = function()

    if member then
      ui.field.text{ label = _"Id", value = member.id }
    end

    ui.field.text{     label = _"Identification", name = "identification" }
    ui.container{ content = function() ui.tag{ tag = "label", attr = { class = "ui_field_label" }, content = _"Show in " .. config.mv_name } ui.tag{ tag = "span", attr = {}, content = function() ui.link { text = _"Show in " .. config.mv_name, external = config.mv_decryption_url .. member.identification:gsub("+","-"):gsub("/","_"):gsub("=","$") } end } end }
    ui.field.text{     label = _"Notification email", name = "notify_email" }
    if member and member.activated then
      ui.field.text{     label = _"Screen name",        name = "name" }
      ui.field.boolean{  label = _"Delete avatar",      name = "avatar_delete" }
      ui.field.boolean{  label = _"Delete photo",      name = "photo_delete" }
      ui.field.text{     label = _"Login name",        name = "login" }
    end
    ui.field.boolean{  label = _"Admin?",       name = "admin" }
    
    if member then
      ui.field.text{ label = _"Account created", value = member.created }
    end

    if member then
      ui.field.text{ label = _"Account activated", value = member.activated }
    end

    if member then
      ui.field.text{ label = _"Account last login", value = member.last_login }
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
    
    if not member or member.activated then
      ui.field.boolean{  label = _"Send password reset link?",       name = "password_reset" }
    end
    
    if member and member.activated then
      ui.field.boolean{  label = _"Lock member?",       name = "locked" }
    end
    
    if member and member.activated then
      ui.field.boolean{  label = _"Deactivate account?",       name = "deactivate" }
    end
    
    ui.field.boolean{ 
      label = _"Member inactive?", name = "deactivate",
      readonly = member and member.active, value = member and member.active == false
    }
    
    slot.put("<br />")
    ui.submit{         text  = _"Save" }
  end
}
