local argument = param.get("argument", "table") or Argument:by_id(param.get("argument_id"))

local tabs = {
  module = "argument",
  view = "show_tab",
  static_params = {
    argument_id = argument.id
  }
}

tabs[#tabs+1] =
  {
    name = "description",
    label = argument.side == "pro" and _"Argument pro" or _"Argument contra",
    module = "argument",
    view = "_argument",
    params = {
      argument = argument
    }
  }

if app.session.member_id then
  tabs[#tabs+1] =
    {
      name = "ratings",
      label = _"Ratings",
      module = "argument",
      view = "_ratings",
      params = {
        argument = argument
      }
    }
end

ui.tabs(tabs)