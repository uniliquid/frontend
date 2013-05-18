ui.title(_"Edit my profile")

util.help("member.edit", _"Edit my page")

ui.form{
  record = app.session.member,
  attr = { class = "vertical" },
  module = "member",
  action = "update",
  routing = {
    ok = {
      mode = "redirect",
      module = "member",
      view = "show",
      id = app.session.member_id
    }
  },
  content = function()
    ui.field.text{ label = _"Organizations", name = "organizational_unit", readonly = config.locked_profile_fields.organizational_unit }
    ui.field.text{ label = _"Fields of study", name = "internal_posts", readonly = config.locked_profile_fields.internal_posts }
    ui.field.text{ label = _"Real name", name = "realname", readonly = config.locked_profile_fields.realname }
    ui.field.text{ label = _"Birthday" .. " YYYY-MM-DD ", name = "birthday", attr = { id = "profile_birthday" }, readonly = config.locked_profile_fields.birthday }
    ui.script{ static = "gregor.js/gregor.js" }
    util.gregor("profile_birthday", "document.getElementById('timeline_search_date').form.submit();")
    ui.field.text{ label = _"Address", name = "address", multiline = true, readonly = config.locked_profile_fields.address }
    ui.field.text{ label = _"email", name = "email", readonly = config.locked_profile_fields.email }
    ui.field.text{ label = _"xmpp", name = "xmpp_address", readonly = config.locked_profile_fields.xmpp_address }
    ui.field.text{ label = _"Website", name = "website", readonly = config.locked_profile_fields.website }
    ui.field.text{ label = _"Phone", name = "phone", readonly = config.locked_profile_fields.phone }
    ui.field.text{ label = _"Mobile phone", name = "mobile_phone", readonly = config.locked_profile_fields.mobile_phone }
    ui.field.text{ label = _"Profession", name = "profession", readonly = config.locked_profile_fields.profession }
    --ui.field.text{ label = _"External memberships", name = "external_memberships", multiline = true, readonly = config.locked_profile_fields.external_memberships }
    --ui.field.text{ label = _"External posts", name = "external_posts", multiline = true, readonly = config.locked_profile_fields.external_posts }

    ui.wikitextarea("statement", _"Statement")
    
    ui.submit{ value = _"Save" }
  end
}
