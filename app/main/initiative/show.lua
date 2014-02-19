local initiative = Initiative:by_id(param.get_id())

if not initiative then
  slot.put_into("error", _"The requested initiative does not exist!")
  return
end

execute.view{
  module = "index", view = "_quicklinks"
}

execute.view{
  module = "initiative", view = "_show", params = {
    initiative = initiative
  }
}
