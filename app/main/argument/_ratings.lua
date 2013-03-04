local argument = param.get("argument", "table")

local issue = argument.initiative.issue

local before_voting = ""
if issue.fully_frozen then
  before_voting = " (" .. _"before begin of voting" .. ")"
end


local function supporters()

  members_selector = Member:new_selector()
    :join("rating", nil, "member.id = rating.member_id")
    :join("issue", nil, "issue.id = rating.issue_id")
    :join("direct_supporter_snapshot", nil, "direct_supporter_snapshot.event = issue.latest_snapshot_event AND direct_supporter_snapshot.initiative_id = rating.initiative_id AND direct_supporter_snapshot.member_id = member.id")
    :add_where{ "argument_id = ?", argument.id }
    :add_where("negative = FALSE")
    :add_field(1, "weight")
  if members_selector:count() > 0 then
    ui.anchor{
      name = "positive",
      attr = { class = "heading positive" },
      content = _"(Potential) supporters, who rated this argument positive" .. before_voting .. Member:count_string(members_selector)
    }
    execute.view{
      module = "member",
      view = "_list",
      params = {
        members_selector = members_selector,
        paginator_name = "supporters_positive"
      }
    }
  else
    ui.anchor{
      name = "positive",
      attr = { class = "heading positive" },
      content = _"No (potential) supporters rated this argument positive." .. before_voting
    }
    slot.put("<br />")
  end

  members_selector = Member:new_selector()
    :join("rating", nil, "member.id = rating.member_id")
    :join("issue", nil, "issue.id = rating.issue_id")
    :join("direct_supporter_snapshot", nil, "direct_supporter_snapshot.event = issue.latest_snapshot_event AND direct_supporter_snapshot.initiative_id = rating.initiative_id AND direct_supporter_snapshot.member_id = member.id")
    :add_where{ "argument_id = ?", argument.id }
    :add_where("negative = TRUE")
    :add_field(1, "weight")
  if members_selector:count() > 0 then
    ui.anchor{
      name = "negative",
      attr = { class = "heading negative" },
      content = _"(Potential) supporters, who rated this argument negative" .. before_voting .. Member:count_string(members_selector)
    }
    execute.view{
      module = "member",
      view = "_list",
      params = {
        members_selector = members_selector,
        paginator_name = "supporters_negative"
      }
    }
  else
    ui.anchor{
      name = "negative",
      attr = { class = "heading negative" },
      content = _"No (potential) supporters rated this argument negative." .. before_voting
    }
    slot.put("<br />")
  end

end


local function nonsupporters()

  members_selector = Member:new_selector()
    :join("rating", nil, "member.id = rating.member_id")
    :join("issue", nil, "issue.id = rating.issue_id")
    :left_join("direct_supporter_snapshot", nil, "direct_supporter_snapshot.event = issue.latest_snapshot_event AND direct_supporter_snapshot.initiative_id = rating.initiative_id AND direct_supporter_snapshot.member_id = member.id")
    :add_where("direct_supporter_snapshot.member_id IS NULL")
    :add_where{ "argument_id = ?", argument.id }
    :add_where("negative = FALSE")
    :add_field(1, "weight")
  if members_selector:count() > 0 then
    ui.anchor{
      name = "positive",
      attr = { class = "heading positive" },
      content = _"Non-supporters, who rated this argument positive" .. before_voting .. Member:count_string(members_selector)
    }
    execute.view{
      module = "member",
      view = "_list",
      params = {
        members_selector = members_selector,
        paginator_name = "nonsupporters_positive"
      }
    }
  else
    ui.anchor{
      name = "positive",
      attr = { class = "heading positive" },
      content = _"No non-supporters rated this argument positive." .. before_voting
    }
    slot.put("<br />")
  end

  members_selector = Member:new_selector()
    :join("rating", nil, "member.id = rating.member_id")
    :join("issue", nil, "issue.id = rating.issue_id")
    :left_join("direct_supporter_snapshot", nil, "direct_supporter_snapshot.event = issue.latest_snapshot_event AND direct_supporter_snapshot.initiative_id = rating.initiative_id AND direct_supporter_snapshot.member_id = member.id")
    :add_where("direct_supporter_snapshot.member_id IS NULL")
    :add_where{ "argument_id = ?", argument.id }
    :add_where("negative = TRUE")
    :add_field(1, "weight")
  if members_selector:count() > 0 then
    ui.anchor{
      name = "negative",
      attr = { class = "heading negative" },
      content = _"Non-supporters, who rated this argument negative" .. before_voting .. Member:count_string(members_selector)
    }
    execute.view{
      module = "member",
      view = "_list",
      params = {
        members_selector = members_selector,
        paginator_name = "nonsupporters_negative"
      }
    }
  else
    ui.anchor{
      name = "negative",
      attr = { class = "heading negative" },
      content = _"No non-supporters rated this argument negative." .. before_voting
    }
    slot.put("<br />")
  end

end


if argument.side == "pro" then
  supporters()
  nonsupporters()
else
  nonsupporters()
  supporters()
end
