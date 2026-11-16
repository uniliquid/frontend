if app.session and app.session.member then

  -- The session is deleted; a new anonymous one replaces it.
  Session:logout()
  slot.put_into("notice", _"Logout successful")
  if config.etherpad then
    request.set_cookie{
      path = config.etherpad.cookie_path,
      name = "sessionID",
      value = "invalid"
    }
  end
end
