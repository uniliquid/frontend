ui.titleMember(_"avatar/photo")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  record = app.session.member,
  attr = { 
    class = "vertical section",
    enctype = 'multipart/form-data'
  },
  module = "member",
  action = "update_images",
  routing = {
    ok = {
      mode = "redirect",
      module = "member",
      view = "show",
      id = app.session.member_id
    }
  },
  content = function()
    ui.sectionHead( function()
      ui.heading { level = 1, content = _"Upload avatar/photo" }
    end )
    ui.sectionRow( function()
      execute.view{
        module = "member_image",
        view = "_show",
        params = {
          class = "right",
          member = app.session.member, 
          image_type = "avatar"
        }
      }
      ui.heading { level = 2, content = _"Avatar"}
      ui.container { content = _"Your avatar is a small photo, which will be shown always next to your name." }
      slot.put("<br />")
      ui.field.image{ field_name = "avatar" }
      slot.put("<br /><br />")
      execute.view{
        module = "member_image",
        view = "_show",
        params = {
          class = "right",
          member = app.session.member, 
          image_type = "photo"
        }
      }
      ui.heading { level = 2, content = _"Photo"}
      ui.container { content = _"Your photo will be shown in your profile." }
      slot.put("<br />")
      ui.field.image{ field_name = "photo" }
      slot.put("<br style='clear: right;' />")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "btn btn-default",
          value = _"publish avatar/photo"
        },
        content = ""
      }
      slot.put("<br /><br /><br />")
      ui.link{
        content = _"cancel",
        module = "member", view = "show", id = app.session.member.id
      }
    end )
  end
}