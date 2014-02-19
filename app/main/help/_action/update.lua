local help_ident = param.get("help_ident")
local hide = param.get("hide", atom.boolean)

local setting_key = "liquidfeedback_frontend_hidden_help_" .. help_ident
local setting = Setting:by_pk(app.session.member.id, setting_key)

if hide == config.enable_help_per_default and not setting then
  setting = Setting:new()
  setting.member_id = app.session.member.id
  setting.key = setting_key
  setting.value = "hidden"
  setting:save()
elseif hide ~= config.enable_help_per_default and setting then
  setting:destroy()
end
