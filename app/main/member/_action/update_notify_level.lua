app.session.member.notify_level = param.get("notify_level")

if param.get("notify_level_s") then
  local notify_level_s = string.find(app.session.member.admin_comment or "", " 39 ") and true or false
  if not notify_level_s then
    app.session.member.admin_comment = (app.session.member.admin_comment or "") .. " 39 "
  end
else
  app.session.member.admin_comment = string.gsub(app.session.member.admin_comment or "", " 39 ", "")
end

app.session.member:save()
