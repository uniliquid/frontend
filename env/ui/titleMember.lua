function ui.titleMember(title, title2)
  local member = app.session.member
  if type(title) == "table" then
    member = title
    title = title2
  end
  ui.title(function()
    if member then
      ui.link { module = "member", view = "show", id = member.id, content = member.name }
    end
    if title then
      ui.tag { attr = { class = "member" }, content = function()
        ui.tag{ tag = "span", content = title }
      end }
    end
  end)
end