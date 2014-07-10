local members_selector = param.get("members_selector", "table")
members_selector:add_where("member.activated NOTNULL")

local initiative = param.get("initiative", "table")
local issue = param.get("issue", "table")
local trustee = param.get("trustee", "table")
local initiator = param.get("initiator", "table")
local for_votes = param.get("for_votes", atom.boolean)
local no_filter = param.get ( "no_filter",  atom.boolean )
local no_paginate = param.get ( "no_paginate",  atom.boolean )

local paginator_name = param.get("paginator_name")

local member_class = param.get("member_class")

if initiative or issue then
  if for_votes then
    members_selector:left_join("delegating_voter", "_member_list__delegating_voter", { "_member_list__delegating_voter.issue_id = issue.id AND _member_list__delegating_voter.member_id = ?", app.session.member_id })
    members_selector:add_field("member.id = ANY(_member_list__delegating_voter.delegate_member_ids)", "in_delegation_chain")
  else
    members_selector:left_join("delegating_interest_snapshot", "_member_list__delegating_interest", { "_member_list__delegating_interest.event = issue.latest_snapshot_event AND _member_list__delegating_interest.issue_id = issue.id AND _member_list__delegating_interest.member_id = ?", app.session.member_id })
    members_selector:add_field("member.id = ANY(_member_list__delegating_interest.delegate_member_ids)", "in_delegation_chain")
  end
end

ui.add_partial_param_names{ "member_list" }

local filter = { name = "member_list" }

filter[#filter+1] = {
  name = "last_activity",
  label = _"Latest activity",
  selector_modifier = function(selector) selector:add_order_by("last_login DESC NULLS LAST, id DESC") end
}
filter[#filter+1] = {
  name = "newest",
  label = _"Newest",
  selector_modifier = function(selector) selector:add_order_by("activated DESC, id DESC") end
}
filter[#filter+1] = {
  name = "oldest",
  label = _"Oldest",
  selector_modifier = function(selector) selector:add_order_by("activated, id") end
}

filter[#filter+1] = {
  name = "name",
  label = _"A-Z",
  selector_modifier = function(selector) selector:add_order_by("name") end
}
filter[#filter+1] = {
  name = "name_desc",
  label = _"Z-A",
  selector_modifier = function(selector) selector:add_order_by("name DESC") end
}

if issue or initiative then
  no_filter = true
  if for_votes then
      members_selector:add_order_by("voter_weight DESC, name, id")
  else
      members_selector:add_order_by("weight DESC, name, id")
  end
end


function list_members()
  local ui_paginate = ui.paginate
  if no_paginate then
    ui_paginate = function (args) args.content() end
  end
  ui_paginate{
    name = paginator_name,
    anchor = paginator_name,
    selector = members_selector,
    per_page = 50,
    content = function() 
      ui.container{
        attr = { class = "member_list" },
        content = function()
          local members = members_selector:exec()

          for i, member in ipairs(members) do
            ui.sectionRow( function()
              execute.view{
                module = "member",
                view = "_show_thumb",
                params = {
                  class = member_class,
                  member = member,
                  initiative = initiative,
                  issue = issue,
                  trustee = trustee,
                  initiator = initiator
                }
              }
            end )
          end


        end
      }
    end
  }
end

  
if no_filter then
  list_members()
else
  ui.filters {
    label = _"Change order",
    selector = members_selector,
    content = list_members,
    filter
  }
end