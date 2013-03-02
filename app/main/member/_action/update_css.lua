local style = param.get("css") == "friendly" and "friendly" or "style"
app.session.member:set_setting("liquidfeedback_frontend_stylesheet_url",config.absolute_base_url .. "static/" .. style .. ".css")
app.session.member:save()
