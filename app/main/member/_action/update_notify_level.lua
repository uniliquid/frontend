app.session.member.notify_level = param.get("notify_level")

if param.get("notify_level_s") then
  local notify_level_s = string.find(app.session.member.admin_comment or "", " 39 ") and true or false
  if not notify_level_s then
    app.session.member.admin_comment = (app.session.member.admin_comment or "") .. " 39 "
  end
else
  app.session.member.admin_comment = string.gsub(app.session.member.admin_comment or "", " 39 ", "")
end
-- standard selection
app.session.member.notify_level = param.get("notify_level", atom.string)

app.session.member:save()

-- expert selection
for idx, interest in ipairs(Notify:enum_interest()) do

  local notify = Notify:by_member_interest(app.session.member.id, interest)

  local list = param.get_list("notify__" .. interest, atom.string)
  if app.session.member.notify_level == "expert" and list and #list > 0 then

    if notify then
      -- update existing record
      for i, record in ipairs(Notify:records()) do
        notify[record.name] = false
      end
    else
      -- insert new record
      notify = Notify:new()
      notify.member_id = app.session.member.id
      notify.interest = interest
    end

    for i, value in ipairs(list) do
      notify[value] = true
    end

    notify:save()

  elseif notify then
    notify:destroy()
  end

end
