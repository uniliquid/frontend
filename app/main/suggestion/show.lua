local suggestion = Suggestion:by_id(param.get_id())

-- redirect to initiative if suggestion does not exist anymore
if not suggestion then
  local initiative_id = param.get('initiative_id', atom.integer)
  if initiative_id then
    slot.reset_all{ except = { "notice", "error" } }
    request.redirect{
      module = "initiative",
      view = "show",
      id = initiative_id,
      params = { tab = "suggestions" }
    }
  else
    slot.put_into('error', _"Suggestion does not exist anymore!")
  end
  return
end


app.html_title.title = suggestion.name
app.html_title.subtitle = _("Suggestion ##{id}", { id = suggestion.id })

ui.title(_("Suggestion ##{id}", { id = suggestion.id }), suggestion.initiative.issue.area.unit, suggestion.initiative.issue.area, suggestion.initiative.issue, suggestion.initiative)

ui.actions(function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/resultset_previous.png" }
      slot.put(_"Back")
    end,
    module = "initiative",
    view = "show",
    id = suggestion.initiative.id,
    params = { tab = "suggestions" }
  }
end)

execute.view{
  module = "suggestion",
  view = "_suggestion",
  params = {
    suggestion = suggestion
  }
}

if app.session.member_id then
execute.view{
  module = "suggestion",
  view = "_opinions",
  params = {
    suggestion = suggestion
  }
}
end
