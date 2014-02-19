ui.title(_"Upload images")

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
  ui.title(_"no such member")
end

util.help("member.edit_images", _"Images")

ui.form{
  record = member,
  attr = { 
    class = "vertical",
    enctype = 'multipart/form-data'
  },
  module = "member",
  action = "update_images",
  routing = {
    ok = {
      mode = "redirect",
      module = "member",
      view = "show",
      id = member.id
    }
  },
  content = function()
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = member, 
        image_type = "avatar"
      }
    }
    ui.field.image{ field_name = "avatar", label = _"Avatar" }
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = member, 
        image_type = "photo"
      }
    }
    ui.field.image{ field_name = "photo", label = _"Photo" }
    ui.submit{ value = _"Save", id = member.id }
  end
}
