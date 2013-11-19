
local setting_keys = {"liquidfeedback_frontend_stylesheet_url","liquidfeedback_frontend_show_new_issues","liquidfeedback_frontend_show_only_direct","liquidfeedback_frontend_show_only_membership"}
local params = {"stylesheet_url","new_issues","only_direct","only_membership"}

for i, setting_key in ipairs(setting_keys) do
local stylesheet_url = util.trim(param.get(params[i]))
local setting = Setting:by_pk(app.session.member.id, setting_key)

if stylesheet_url and #stylesheet_url > 0 then
  if not setting then
    setting = Setting:new()
    setting.member_id = app.session.member.id
    setting.key = setting_key
  end
  setting.value = stylesheet_url
  setting:save()
elseif setting then
  setting:destroy()
end
end

slot.put_into("notice", _"Display settings have been updated")
