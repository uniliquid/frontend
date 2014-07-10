ui.form{
  attr = { class = "login" },
  module = 'index',
  action = 'login',
  routing = {
    ok = {
      mode   = 'redirect',
      module = param.get("redirect_module") or "index",
      view = param.get("redirect_view") or "index",
      id = param.get("redirect_id"),
    },
    error = {
      mode   = 'forward',
      module = 'index',
      view   = 'login',
    }
  },
  content = function()
    ui.field.text{
      attr = { id = "username_field" },
      label     = _'login name',
      html_name = 'login',
      value     = ''
    }
    ui.script{ script = 'document.getElementById("username_field").focus();' }
    ui.field.password{
      label     = _'Password',
      html_name = 'password',
      value     = ''
    }
    ui.submit{
      text = _'Login'
    }
    slot.put("&nbsp;&nbsp;")
    ui.link{ module = "index", view = "reset_password", text = _"Forgot password?" }
  end
}