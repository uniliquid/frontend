if app.session.member_id then
  if config.motd_public then
    local help_text = config.motd_public
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end

  util.help("index.index", _"Home")

  execute.view{
    module = "index", view = "_index_member"
  }

elseif app.session:has_access("anonymous") then
  if config.motd_public then
    local help_text = config.motd_public
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end

local tabs = {
  module = "index",
  view = "index"
}

tabs[#tabs+1] = {
  name = "units",
  label = _"Overview",
  icon = "icons/16/world.png",
  module = "unit",
  view = "_list",
}

tabs[#tabs+1] = {
  name = "open",
  icon = "icons/16/email_open.png",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed ISNULL")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
  }
}

tabs[#tabs+1] = {
  name = "closed",
  icon = "icons/16/email.png",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed NOTNULL")
      :add_order_by("issue.closed DESC")

  }
}

tabs[#tabs+1] = {
  name = "timeline",
  icon = "icons/16/time.png",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = {
    global = true,
    }
}

if config.enable_general_assembly_mode then
tabs[#tabs+1] = {
  icon = "icons/16/map.png",
  name = "bgv",
  label = _"BGV",
  module = "issue",
  view = "_list",
  params = {
    issues_selector = Issue:new_selector()
      :add_where("issue.policy_id IN (4,21,7,9,17)")
      :add_where("issue.fully_frozen > now() - '2 months'::interval OR (issue.fully_frozen ISNULL AND issue.accepted + issue.discussion_time < now() + '2 months'::interval)")
      --:add_where("issue.state IN ('admission', 'discussion', 'verification', 'voting', 'finished_with_winner', 'finished_without_winner')")
      :add_where("issue.state IN ('discussion', 'verification', 'voting', 'finished_with_winner', 'finished_without_winner')")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

  }
}
end

  if app.session:has_access('all_pseudonymous') then
    tabs[#tabs+1] = {
      name = "members",
		  icon = "icons/16/group.png",
      label = _"Members",
      module = 'member',
      view   = '_list',
      params = { members_selector = Member:new_selector():add_where("active") }
    }
  end

  ui.tabs(tabs)
  
else

  if config.motd_public then
    local help_text = config.motd_public
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end

  ui.tag{ tag = "p", content = _"Closed user group, please login to participate." }

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
  end
}

end

