slot.put_into("title", _"Email address confirmation")

ui.form{
  attr = { class = "vertical" },
  module = "index",
  action = "confirm_rights",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    if param.get("for_unit") then
    ui.field.hidden{
      name = "for_unit",
      value = param.get("for_unit")
    }
    else
    ui.field.text{
      label = _"For Unit",
      name = "for_unit",
      value = param.get("for_unit")
    }
    end
    ui.field.text{
      label = _"Confirmation code",
      name = "secret",
      value = param.get("secret")
    }
    ui.submit{ text = _"Confirm" }
  end
}
