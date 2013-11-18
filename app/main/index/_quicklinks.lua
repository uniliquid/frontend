local only_direct
local only_interest
if app.session.member then
  local setting_key = "liquidfeedback_frontend_show_only_direct"
  local setting = Setting:by_pk(app.session.member.id, setting_key)
  only_direct = setting and setting.value
  local setting_key = "liquidfeedback_frontend_show_only_membership"
  local setting = Setting:by_pk(app.session.member.id, setting_key)
  only_interest = setting and setting.value
end

-- quick links
ui.actions(function()
  ui.link{
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/email.png" }
      ui.tag { content = _"Latest vote results" }
    end,
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter = "finished",
      filter_interest = "unit"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/email_go.png" }
      ui.tag { content = _"Voted by delegation" }
    end,
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter_interest = "voted",
      filter_delegation = "delegated"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/email_open_image.png" }
      ui.tag { content = _"Not yet voted" }
    end,
    module = "index",
    view = "index",
    params = {
      tab = "open",
      -- filter_policy_sel = "p1",
      filter_policy = only_direct and "direct" or "any",
      filter_voting = "not_voted",
      filter = "frozen",
      filter_interest = only_interest and "area" or "unit"
    }
  }
end)

