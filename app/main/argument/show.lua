local argument = Argument:by_id(param.get_id())

if not argument then
  slot.put_into('error', _"Argument does not exist!")
  return
end


app.html_title.title = argument.name
app.html_title.subtitle = _("Argument ##{id}", { id = argument.id })

ui.title((argument.side == "pro" and _"Argument pro" or _"Argument contra") .. _(" ##{id}", { id = argument.id }), argument.initiative.issue.area.unit, argument.initiative.issue.area, argument.initiative.issue, argument.initiative)

ui.actions(function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/resultset_previous.png" }
        slot.put(_"Back")
    end,
    module = "initiative",
    view = "show",
    id = argument.initiative.id,
    params = { tab = "arguments" }
  }
end)

util.help("argument.show", _"Argument")

execute.view{
  module = "argument",
  label = argument.side == "pro" and _"Argument pro" or _"Argument contra",
  view = "_argument",
  params = {
    argument = argument
  }
}

if app.session.member_id then
  execute.view{
    name = "ratings",
    label = _"Ratings",
    module = "argument",
    view = "_ratings",
    params = {
      argument = argument
    }
  }
end

