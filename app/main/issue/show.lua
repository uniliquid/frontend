local issue = Issue:by_id(param.get_id())

if not issue then
  slot.put_into("error", _"The requested issue does not exist!")
  return
end

if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

if not app.html_title.title then
	app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

execute.view{
  module = "index", view = "_quicklinks"
}

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = issue.area, show_links = true } }
end)

util.help("issue.show")

slot.select("head", function()
  execute.view{ module = "issue", view = "_show", params = { issue = issue } }
end )

if app.session:has_access("all_pseudonymous") then

  ui.container{ attr = { class = "heading" }, content = function()
      ui.image{ attr = { class = "spaceicon" }, static = "icons/16/eye.png" }
      slot.put(_"Interested members")
    end
  }
  
  local interested_members_selector = issue:get_reference_selector("interested_members_snapshot")
    :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
    :add_field("direct_interest_snapshot.weight")
    :add_where("direct_interest_snapshot.event = issue.latest_snapshot_event")

  execute.view{
    module = "member",
    view = "_list",
    params = {
      issue = issue,
      members_selector = interested_members_selector
    }
  }
if config.use_lfbot_reddit_buffer then
  local exists = db:query("SELECT 1 FROM reddit_map WHERE lqfb = " .. issue.id, "opt_object")
  local test = db:query("SELECT 1 FROM reddit_map WHERE timestamp < NOW() - '30 minutes'::interval AND lqfb = " .. issue.id, "opt_object")
  if not exists or test then
      os.execute("/opt/liquid_feedback_core/reddit_check " .. issue.id)
  end
  test = db:query("SELECT buffer FROM reddit_map WHERE lqfb = " .. issue.id, "opt_object")
  if test then
    slot.put(test.buffer)
  end
end

 ui.link{ name = "details_link1", attr = { id = "details_link1", class = "heading", onclick = "return toggleDetails();" }, content = function()
  ui.image{ attr = { class = "spaceicon" }, static = "icons/16/table.png" }
  slot.put(_"Show Details")
end,
  external = "#"
}
ui.link{ name = "details_link2", attr = { id = "details_link2", class = "heading", onclick = "return toggleDetails();", style = "display: none;" }, content = function()
  ui.image{ attr = { class = "spaceicon" }, static = "icons/16/table.png" }
  slot.put(_"Hide Details")
end,
  external = "#"
}
ui.container{ attr = { id = "details", style = "display: none;", class = "initiative_head" },
content = function()
  execute.view{
    module = "issue",
    view = "_details",
    params = { issue = issue }
  }
end
}

end

if config.absolute_base_short_url then
  ui.container{
    attr = { class = "shortlink" },
    content = function()
      slot.put(_"Short link" .. ": ")
      local link = config.absolute_base_short_url .. "t" .. issue.id
      ui.link{ external = link, text = link }
    end
  }
end
