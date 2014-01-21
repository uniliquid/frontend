local initiative = Initiative:by_id(param.get("initiative_id"))

slot.put_into("title", _"Invite an initiator to initiative")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "initiative",
    view = "show",
    id = initiative.id,
    params = {
      tab = "initiators"
    }
  }
end)

util.help("initiative.add_initiator", _"Invite an initiator to initiative")

ui.form{
  attr = { class = "vertical" },
  module = "initiative",
  action = "add_initiator",
  params = {
    initiative_id = initiative.id,
  },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id,
      params = {
        tab = "initiators",
      }
    }
  },
  content = function()
    local records = {
      {
        id = "-1",
        name = _"Choose member"
      }
    }

    local all_members = Member:build_selector{
      voting_right_for_unit_id = voting_right_unit_id,
      active = true,
      locked = false,
      order = "name"
    }:exec()

    local contact_members = Member:build_selector{
      is_contact_of_member_id = app.session.member_id,
      voting_right_for_unit_id = voting_right_unit_id,
      active = true,
      locked = false,
      order = "name"
    }:exec()

    -- add saved members
    if #contact_members > 0 then
      records[#records+1] = {id="_", name= "--- " .. _"Saved contacts" .. " ---"}
      for i, record in ipairs(contact_members) do
        records[#records+1] = record
      end
    end
    -- add all members
    if #all_members > 0 then
      records[#records+1] = {id="_", name= "--- " .. _"All members" .. " ---"}
      for i, record in ipairs(all_members) do
        records[#records+1] = record
      end
    end
    disabled_records = {}
    disabled_records["_"] = true
    disabled_records[app.session.member_id] = true

    ui.field.select{
      label = _"Member",
      name = "member_id",
      foreign_records = records,
      foreign_id = "id",
      foreign_name = "name",
      disabled_records = disabled_records
    }
    ui.submit{ text = _"Save" }
  end
}
