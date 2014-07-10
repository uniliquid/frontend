local params = param.get_all_cgi()

local for_unit = param.get("for_unit", atom.boolean)
local for_area = param.get("for_area", atom.boolean)
local for_events = param.get("for_events", atom.boolean)
local for_member = param.get("for_member", "table")
local member = param.get("member", "table")
local phase = params["phase"]

local filters = {}

local admission_order_field = "filter_issue_order.order_in_unit"
if for_area then
  admission_order_field = "filter_issue_order.order_in_area"
end

if not for_issue and not for_member then
  
  -- mode

  local filter = { class = "filter_mode", name = "mode" }
  
  filter[#filter+1] = {
    name = "issue",
    label = _"issue view",
    selector_modifier = function () end
  }

  filter[#filter+1] = {
    name = "timeline",
    label = _"timeline",
    selector_modifier = function ( selector ) 
      selector:add_order_by ( "event.occurrence DESC" )
      selector:add_order_by ( "id DESC" )
    end
  }

  filters[#filters+1] = filter

  -- context

  local filter = { class = "filter_filter", name = "filter" }
  
  if member and not for_unit and not for_area then
    filter[#filter+1] = {
      name = "my_units",
      label = _"in my units",
      selector_modifier = function ( selector )
        selector:join ( "area", "filter_area", "filter_area.id = issue.area_id" )
        selector:join ( "privilege", "filter_privilege", { 
          "filter_privilege.unit_id = filter_area.unit_id AND filter_privilege.member_id = ?", member.id
        })
      end
    }
  end
  
  if member and not for_area then
    
    filter[#filter+1] = {
      name = "my_areas",
      label = _"in my areas",
      selector_modifier = function ( selector )
        selector:join ( "membership", "filter_membership", { 
          "filter_membership.area_id = issue.area_id AND filter_membership.member_id = ?", member.id
        })
      end
    }
  end
  
  if member then
    filter[#filter+1] = {
      name = "my_issues",
      label = _"my issues",
      selector_modifier = function ( selector )
        selector:left_join("interest", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? ", member.id })
        --selector:left_join("direct_interest_snapshot", "filter_interest_s", { "filter_interest_s.issue_id = issue.id AND filter_interest_s.member_id = ? AND filter_interest_s.event = issue.latest_snapshot_event", member.id })
        selector:left_join("delegating_interest_snapshot", "filter_d_interest_s", { "filter_d_interest_s.issue_id = issue.id AND filter_d_interest_s.member_id = ? AND filter_d_interest_s.event = issue.latest_snapshot_event", member.id })
      end
    }
  end
  
  filter[#filter+1] = {
    name = "all",
    label = _"all issues",
    selector_modifier = function()  end
  }

  filters[#filters+1] = filter

  -- phase
  
  local filter = { name = "phase" }
  
  filter[#filter+1] = {
    name = "all",
    label = _"in all phases",
    selector_modifier = function ( selector )
      if not for_events then
        selector:left_join ( "issue_order_in_admission_state", "filter_issue_order",    "filter_issue_order.id = issue.id" )
        selector:add_order_by ( "issue.closed DESC NULLS FIRST" )
        selector:add_order_by ( "issue.accepted ISNULL" )
        selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN NULL ELSE justify_interval(coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()) END" )
        selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN " .. admission_order_field .. " ELSE NULL END" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "admission",
    label = _"(1) Admission",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "admission" }
      if not for_events then
        selector:left_join ( "issue_order_in_admission_state", "filter_issue_order", "filter_issue_order.id = issue.id" )
        selector:add_order_by ( admission_order_field )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "discussion",
    label = _"(2) Discussion",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "discussion" }
      if not for_events then
        selector:add_order_by ( "issue.accepted + issue.discussion_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "verification",
    label = _"(3) Verification",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "verification" }
      if not for_events then
        selector:add_order_by ( "issue.half_frozen + issue.verification_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "voting",
    label = _"(4) Voting",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "voting" }
      if not for_events then
        selector:add_order_by ( "issue.fully_frozen + issue.voting_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "closed",
    label = _"(5) Result",
    selector_modifier = function ( selector )
      if not for_events then
        selector:add_where ( "issue.closed NOTNULL" )
        selector:add_order_by ( "issue.closed DESC" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filters[#filters+1] = filter
  
  -- my issues

  if params["filter"] == "my_issues" then
    
    local delegation = params["delegation"]

    local filter = { class = "filter_interest subfilter", name = "interest" }
    
    filter[#filter+1] = {
      name = "all",
      label = _"interested directly or via delegation",
      selector_modifier = function ( selector ) 
        selector:add_where ( "filter_interest.issue_id NOTNULL OR filter_d_interest_s.issue_id NOTNULL" )
      end
    }

    filter[#filter+1] = {
      name = "direct",
      label = _"direct interest",
      selector_modifier = function ( selector )  
        selector:add_where ( "filter_interest.issue_id NOTNULL" )
      end
    }

    filter[#filter+1] = {
      name = "via_delegation",
      label = _"interest via delegation",
      selector_modifier = function ( selector )  
        selector:add_where ( "filter_d_interest_s.issue_id NOTNULL" )
      end
    }

    filter[#filter+1] = {
      name = "initiated",
      label = _"initiated by me",
      selector_modifier = function ( selector )  
        selector:add_where ( "filter_interest.issue_id NOTNULL" )
      end
    }
    
    filters[#filters+1] = filter

  end
  
  -- voting

  if phase == "voting" and member then
  
    local filter = { class = "subfilter", name = "voted" }
    
    filter[#filter+1] = {
      name = "all",
      label = _"voted and not voted by me",
      selector_modifier = function(selector)  end
    }

    filter[#filter+1] = {
      name = "voted",
      label = _"voted by me",
      selector_modifier = function(selector) 
        selector:join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
      end
    }

    filter[#filter+1] = {
      name = "not_voted",
      label = _"not voted by me",
      selector_modifier = function(selector)
        selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
        selector:add_where("filter_direct_voter.issue_id ISNULL")
      end
    }
    filters[#filters+1] = filter
    
    
  end
  
  -- closed

  if phase == "closed" then
  
    local filter = { class = "subfilter", name = "closed" }
    
    filter[#filter+1] = {
      name = "finished",
      label = _"finished",
      selector_modifier = function ( selector )
        selector:add_where ( "issue.state::text like 'finished_%'" )
      end
    }

    filter[#filter+1] = {
      name = "canceled",
      label = _"canceled",
      selector_modifier = function ( selector )  
        selector:add_where ( "issue.closed NOTNULL AND NOT issue.state::text like 'finished_%' AND issue.accepted NOTNULL" )
      end
    }

    filter[#filter+1] = {
      name = "not_accepted",
      label = _"not admitted",
      selector_modifier = function ( selector )  
        selector:add_where ( "issue.closed NOTNULL AND issue.accepted ISNULL" )
      end
    }

    if member then
      filter[#filter+1] = {
        name = "voted",
        label = _"voted by me",
        selector_modifier = function(selector)
          selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
          selector:left_join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
          selector:add_where("filter_direct_voter.issue_id NOTNULL or filter_delegating_voter.issue_id NOTNULL")
        end
      }

      filter[#filter+1] = {
        name = "voted_direct",
        label = _"voted directly by me",
        selector_modifier = function(selector)
          selector:join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
        end
      }

      filter[#filter+1] = {
        name = "voted_via_delegation",
        label = _"voted via delegation",
        selector_modifier = function(selector)
          selector:join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
        end
      }

      filter[#filter+1] = {
        name = "not_voted",
        label = _"not voted by me",
        selector_modifier = function(selector)
          selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
          selector:left_join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
          selector:add_where("filter_direct_voter.issue_id ISNULL AND filter_delegating_voter.issue_id ISNULL")
        end
      }
    end
    
    filters[#filters+1] = filter
    
    
  end

  
end


return filters
