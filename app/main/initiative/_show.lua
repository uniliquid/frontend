local initiative = param.get("initiative", "table")
local full = param.get("full", atom.boolean)

local show_as_head = not full and param.get("show_as_head", atom.boolean)

initiative:load_everything_for_member_id(app.session.member_id)

local issue = initiative.issue

-- TODO performance
local initiator
if app.session.member_id then
  initiator = Initiator:by_pk(initiative.id, app.session.member.id)
end

if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

if not full then
app.html_title.title = initiative.name
app.html_title.subtitle = _("Initiative i#{id}", { id = initiative.id })

slot.select("head", function()
  execute.view{
    module = "issue", view = "_head",
    params = { issue = issue, initiative = initiative }
  }
end)
end

local initiators_members_selector = initiative:get_reference_selector("initiating_members")
  :add_field("initiator.accepted", "accepted")
  :add_order_by("member.name")
if initiator and initiator.accepted then
  initiators_members_selector:add_where("initiator.accepted ISNULL OR initiator.accepted")
else
  initiators_members_selector:add_where("initiator.accepted")
end

local initiators = initiators_members_selector:exec()

if not full then
local initiatives_selector = initiative.issue:get_reference_selector("initiatives")
slot.select("head", function()
  execute.view{
    module = "issue",
    view = "_show",
    params = {
      issue = initiative.issue,
      initiative_limit = 3,
      for_initiative = initiative
    }
  }
end)

util.help("initiative.show")

end
if not full or (not initiative.issue.fully_frozen and not initiative.issue.closed and not initiative.revoked) or initiative.admitted then


local class = "initiative_head"

if initiative.polling then
  class = class .. " polling"
end

ui.container{ attr = { class = class }, content = function()

  local text = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name })
  if show_as_head then
    ui.link{
      attr = { class = "title" }, text = text,
      module = "initiative", view = "show", id = initiative.id
    }
  else
    ui.container{ attr = { class = "title" }, content = text }
  end
  if app.session:has_access("authors_pseudonymous") then

    ui.container{ attr = { class = "content left" }, content = function()

      ui.tag{
        attr = { class = "initiator_names" },
        content = function()
          for i, initiator in ipairs(initiators) do
            slot.put(" ")
            if app.session:has_access("all_pseudonymous") then
              ui.link{
                content = function ()
                  execute.view{
                    module = "member_image",
                    view = "_show",
                    params = {
                      member = initiator,
                      image_type = "avatar",
                      show_dummy = true,
                      class = "micro_avatar",
                      popup_text = text
                    }
                  }
                end,
                module = "member", view = "show", id = initiator.id
              }
              slot.put(" ")
            end
            ui.link{
              text = initiator.name,
              module = "member", view = "show", id = initiator.id
            }
            if not initiator.accepted and not initiative.revoked then
              ui.tag{ attr = { title = _"Not accepted yet" }, content = "?" }
            end
          end
          if initiator and initiator.accepted and not initiative.issue.fully_frozen and not initiative.issue.closed and not initiative.revoked then
            slot.put(" &middot; ")
            ui.link{
              image = { attr = { class = "spaceicon" }, static = "icons/16/user_add.png" },
              attr = { class = "action" },
              content = function()
                slot.put(_"Invite initiator")
              end,
              module = "initiative",
              view = "add_initiator",
              params = { initiative_id = initiative.id }
            }
            if #initiators > 1 then
              slot.put(" &middot; ")
              ui.link{
                content = function()
                  image = { attr = { class = "spaceicon" }, static = "icons/16/user_delete.png" },
                  slot.put(_"Remove initiator")
                end,
                module = "initiative",
                view = "remove_initiator",
                params = { initiative_id = initiative.id }
              }
            end
          end
          if initiator and initiator.accepted == false and not initiative.revoked then
              slot.put(" &middot; ")
              ui.link{
                image = { attr = { class = "spaceicon" }, static = "icons/16/cross.png" },
                text   = _"Cancel refuse of invitation",
                module = "initiative",
                action = "remove_initiator",
                params = {
                  initiative_id = initiative.id,
                  member_id = app.session.member.id
                },
                routing = {
                  ok = {
                    mode = "redirect",
                    module = "initiative",
                    view = "show",
                    id = initiative.id
                  }
                }
              }
          end
          if (initiative.discussion_url and #initiative.discussion_url > 0) then
            slot.put(" &middot; ")
            if initiative.discussion_url:find("^https?://") then
              if initiative.discussion_url and #initiative.discussion_url > 0 then
                ui.link{
                  attr = {
                    target = "_blank",
                    title = initiative.discussion_url
                  },
                  image = { attr = { class = "spaceicon" }, static = "icons/16/comments.png" },
                  text = _"Discuss with initiators",
                  external = initiative.discussion_url
                }
              end
            else
              slot.put(encode.html(initiative.discussion_url))
            end
          end
          if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
            slot.put(" &middot; ")
            ui.link{
              image = { attr = { class = "spaceicon" }, static = "icons/16/comment_edit.png" },
              text   = _"change discussion URL",
              module = "initiative",
              view   = "edit",
              id     = initiative.id
            }
            slot.put(" ")
          end
        end
      }
    end }

  if app.session.member_id then
      ui.container{ attr = { class = "content right" }, content = function()
      execute.view{
        module = "supporter",
        view = "_show_box",
        params = {
          initiative = initiative
        }
      }
    end }
  end

  slot.put('<div class="clearfix"></div>')
  
  end

  -- voting results
  if initiative.issue.fully_frozen and initiative.issue.closed and initiative.admitted then
    local class = initiative.winner and "admitted_info" or "not_admitted_info"
    ui.container{
      attr = { class = class },
      content = function()
        local max_value = initiative.issue.voter_count
        slot.put("&nbsp;")
        local positive_votes = initiative.positive_votes
        local negative_votes = initiative.negative_votes
        local sum_votes = initiative.positive_votes + initiative.negative_votes
        local function perc(votes, sum)
          if sum > 0 and votes > 0 then return " (" .. string.format( "%.f", votes * 100 / sum ) .. "%)" end
          return ""
        end
        slot.put(_"Yes" .. ": <b>" .. tostring(positive_votes) .. perc(positive_votes, sum_votes) .. "</b>")
        slot.put(" &middot; ")
        slot.put(_"Abstention" .. ": <b>" .. tostring(max_value - initiative.negative_votes - initiative.positive_votes)  .. "</b>")
        slot.put(" &middot; ")
        slot.put(_"No" .. ": <b>" .. tostring(initiative.negative_votes) .. perc(negative_votes, sum_votes) .. "</b>")
        slot.put(" &middot; ")
        slot.put("<b>")
        if initiative.winner then
          slot.put(_"Approved")
        elseif initiative.rank then
          slot.put(_("Not approved (rank #{rank})", { rank = initiative.rank }))
        else
          slot.put(_"Not approved")
        end
        slot.put("</b>")

      end
    }

    ui.container{
      attr = { class = "content" },
      content = function()
        execute.view{
          module = "initiative",
          view = "_battles",
          params = { initiative = initiative }
        }
      end
    }

  end

  -- initiative not admitted info
  if initiative.admitted == false then
    local policy = initiative.issue.policy
    ui.container{
      attr = { class = "not_admitted_info" },
      content = _("This initiative has not been admitted! It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den) })
    }
  end

  -- initiative revoked info
  if initiative.revoked then
    ui.container{
      attr = { class = "revoked_info" },
      content = function()
        slot.put(_("This initiative has been revoked at #{revoked}", { revoked = format.timestamp(initiative.revoked) }))
        local suggested_initiative = initiative.suggested_initiative
        if suggested_initiative then
          slot.put("<br /><br />")
          slot.put(_("The initiators suggest to support the following initiative:"))
          slot.put(" ")
          ui.link{
            content = _("Issue ##{id}", { id = suggested_initiative.issue.id } ) .. ": " .. encode.html(suggested_initiative.name),
            module = "initiative",
            view = "show",
            id = suggested_initiative.id
          }
        end
      end
    }
  end


  -- invited as initiator
  if initiator and initiator.accepted == nil and not initiative.revoked and not initiative.issue.half_frozen and not initiative.issue.closed then
    ui.container{
      attr = { class = "initiator_invite_info" },
      content = function()
        slot.put(_"You are invited to become initiator of this initiative.")
        slot.put(" ")
        ui.link{
          image  = { static = "icons/16/tick.png" },
          text   = _"Accept invitation",
          module = "initiative",
          action = "accept_invitation",
          id     = initiative.id,
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }
        slot.put(" ")
        ui.link{
          image  = { static = "icons/16/cross.png" },
          text   = _"Refuse invitation",
          module = "initiative",
          action = "reject_initiator_invitation",
          params = {
            initiative_id = initiative.id,
            member_id = app.session.member.id
          },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }
      end
    }
  end

  -- draft updated
  local supporter

  if app.session.member_id then
    supporter = app.session.member:get_reference_selector("supporters")
      :add_where{ "initiative_id = ?", initiative.id }
      :optional_object_mode()
      :exec()

    if supporter and not initiative.revoked and not initiative.issue.closed then
      local old_draft_id = supporter.draft_id
      local new_draft_id = initiative.current_draft.id
      if old_draft_id ~= new_draft_id then
        ui.container{
          attr = { class = "draft_updated_info" },
          content = function()
            ui.image{ attr = { class = "spaceicon" }, static = "icons/16/arrow_refresh.png" }
            slot.put(_"The draft of this initiative has been updated!")
            slot.put(" ")
            ui.link{
              image = { attr = { class = "spaceicon" }, static = "icons/16/script_code.png" },
              content = _"Show diff",
              module = "draft",
              view = "diff",
              params = {
                old_draft_id = old_draft_id,
                new_draft_id = new_draft_id
              }
            }
            if not initiative.revoked then
              slot.put(" ")
              local icon = "icons/16/thumb_up_orange.png"
              local text = _"Refresh support to current draft"
              if supporter:has_critical_opinion() then
                icon = "icons/16/thumb_up_grey.png"
                text = _"Refresh potential support to current draft"
              end
              ui.link{
                image = { attr = { class = "spaceicon" }, static = icon },
                text  =  text,
                module = "initiative",
                action = "add_support",
                id     = initiative.id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = "initiative",
                    view = "show",
                    id = initiative.id
                  }
                }
              }
            end
          end
        }
      end
    end
  end

  if not show_as_head then
    local drafts_count = initiative:get_reference_selector("drafts"):count()

    ui.container{ attr = { class = "content" }, content = function()
    
      if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
        ui.link{
          content = function()
            ui.image{ attr = { class = "spaceicon" }, static = "icons/16/script_edit.png" }
            slot.put(_"Edit draft")
          end,
          module = "draft",
          view = "new",
          params = { initiative_id = initiative.id }
        }
        slot.put(" &middot; ")
        ui.link{
          content = function()
            ui.image{ attr = { class = "spaceicon" }, static = "icons/16/script_delete.png" }
            slot.put(_"Revoke initiative")
          end,
          module = "initiative",
          view = "revoke",
          id = initiative.id
        }
        slot.put(" &middot; ")
      end

      ui.tag{
        attr = { class = "draft_version" },
        content = _("Latest draft created at #{date} #{time}", {
          date = format.date(initiative.current_draft.created),
          time = format.time(initiative.current_draft.created, { hide_seconds = true })
        })
      }
      slot.put(" &middot; ")
      ui.link{
        module = "draft",
        view = "show",
        id = initiative.current_draft.id,
        params = { source = 1 },
        image = { attr = { class = "spaceicon" }, static = "icons/16/script_code_red.png" },
        content = _("Source")
      }

      if drafts_count > 1 then
        slot.put(" &middot; ")
        ui.link{
          module = "draft", view = "list", params = { initiative_id = initiative.id },
          image = { attr = { class = "spaceicon" }, static = "icons/16/script_code.png" },
          text = _("List all revisions (#{count})", { count = drafts_count })
        }
      end
    end }

    execute.view{
      module = "draft",
      view = "_show",
      params = {
        draft = initiative.current_draft
      }
    }
  end
end }
end
if not full then
if not show_as_head then
  execute.view{
    module = "suggestion",
    view = "_list",
    params = {
      initiative = initiative,
      suggestions_selector = initiative:get_reference_selector("suggestions"),
      tab_id = param.get("tab_id")
    }
  }

  -- open arguments in discussion phase
  if issue.half_frozen or issue.fully_frozen or issue.closed then

    execute.view{
      module = "argument",
      view = "_list",
      params = {
        initiative = initiative,
        arguments_selector = initiative:get_reference_selector("arguments"),
        side = "pro",
        tab_id = param.get("tab_id")
      }
    }

    execute.view{
      module = "argument",
      view = "_list",
      params = {
        initiative = initiative,
        arguments_selector = initiative:get_reference_selector("arguments"),
        side = "contra",
        tab_id = param.get("tab_id")
      }
    }

    slot.put('<div class="clearfix"></div>')

  end

  if app.session:has_access("all_pseudonymous") then
    if initiative.issue.fully_frozen and initiative.issue.closed then
      local members_selector = initiative.issue:get_reference_selector("direct_voters")
        :left_join("vote", nil, { "vote.initiative_id = ? AND vote.member_id = member.id", initiative.id })
        :add_field("direct_voter.weight as voter_weight")
        :add_field("direct_voter.weight AS weight")
        :add_field("coalesce(vote.grade, 0) as grade")
        :add_field("direct_voter.comment as voter_comment")
        :left_join("initiative", nil, "initiative.id = vote.initiative_id")
        :left_join("issue", nil, "issue.id = initiative.issue_id")

      local delegiating_voter = param.get("delegating_voter", "table")
      local delegator_selector = delegating_voter 
    
      initiative.issue:get_reference_selector("delegating_voters")
    --[[    :left_join("delegating_voter")
      --  :left_join("vote", nil, { "vote.initiative_id = ? AND vote.member_id = member.id", initiative.id })
      ]]--  :add_field("delegating_voter.weight as voter_weight")
        :add_field("delegating_voter.weight AS weight")
        :add_field("coalesce(vote.grade, 0) as grade")
        :add_field("delegating_voters.comment as voter_comment")
        :left_join("initiative", nil, "initiative.id = vote.initiative_id")
        :left_join("issue", nil, "issue.id = initiative.issue_id")
--]]--
      ui.anchor{ name = "voter", attr = { class = "heading" }, content = _"Voters" .. Member:count_string(members_selector) }

      local filters = {
        {
          name = "filter",
          anchor = "voter",
          reset_params = { "voter" },
          {
            name = "weight",
            label = _"by weight",
            selector_modifier = function(members_selector) end
          },
          {
            name = "yan",
            label = _"yes / abstention / no",
            selector_modifier = function(selector) members_selector:add_order_by("sign(vote.grade) DESC") end
          },
          {
            name = "yes",
            label = _"Yes",
            selector_modifier = function(selector)
              members_selector:add_where("vote.grade > 0")
            end
          },
          {
            name = "abstention",
            label = _"Abstention",
            selector_modifier = function(selector)
              members_selector:add_where("vote.grade = 0")
            end
          },
          {
            name = "no",
            label = _"No",
            selector_modifier = function(selector)
              members_selector:add_where("vote.grade < 0")
            end
          },
          {
            name = "abc",
            label = _"alphabetically",
            selector_modifier = function(selector) members_selector:add_order_by("lower(member.name), id") end
          },
          {
            name = "comment",
            label = _"with comment",
            selector_modifier = function(selector) members_selector:add_where("length(direct_voter.comment) > 0") end
          },
          ----[[
          { 
            name = "all", 
            label = _"all voters",
            selector_modifier = function(delegator_selector) end
          },--]]--
        }
      }

      filters.content = function()
        execute.view{
          module = "member",
          view = "_list",
          params = {
            initiative = initiative,
            for_votes = true,
            members_selector = members_selector,
            paginator_name = "voter"
          }
        }
      end
    
      ui.container{
        attr = { class = "voter" },
        content = function()
          ui.filters(filters)
        end
      }

 --[[     execute.view{
                module = "member",
                        view = "_list",
                                params = {
                                            initiative = initiative,
                                                      members_selector = members_selector:add_where("vote.grade = 0"),
                                                                paginator_name = "qwer"
                                                                        }
                                                                              }

      execute.view{
        module = "member",
        view = "_list",
        params = {
          initiative = initiative,
          members_selector = members_selector:add_where("vote.grade < 0"),
          paginator_name = "asdf"
        }
      }
--]]--
    end

    local before_voting = ""
    if issue.fully_frozen then
      before_voting = " (" .. _"before begin of voting" .. ")"
    end

    -- supporters
    local members_selector = initiative:get_reference_selector("supporting_members_snapshot")
              :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
              :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
              :add_field("direct_interest_snapshot.weight")
              :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
              :add_where("direct_supporter_snapshot.satisfied")
              :add_field("direct_supporter_snapshot.informed", "is_informed")

--    local supp_num = string.gmatch(Member:count_string(members_selector), "%d+")
--        print(supp_num(0))
--                print(supp_num(1))

    if members_selector:count() > 0 then
      ui.anchor{
        name = "supporters",
        attr = { class = "heading" },
        content = function()
          ui.image{ attr = { class = "spaceicon" }, static = "icons/16/thumb_up_orange.png" }
          slot.put(_"Supporters" .. before_voting .. Member:count_string(members_selector))
        end
      }    
      
      execute.view{
        module = "member",
        view = "_list",
        params = {
          initiative = initiative,
          members_selector = members_selector,
          paginator_name = "supporters"
        }
    }
    else
      ui.anchor{
        name = "supporters",
        attr = { class = "heading" },
        content = function()
          ui.image{ attr = { class = "spaceicon" }, static = "icons/16/thumb_up_orange.png" }
          slot.put(_"No supporters" .. before_voting)
        end
      }
      slot.put("<br />")
    end

    local members_selector = initiative:get_reference_selector("supporting_members_snapshot")
              :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
              :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
              :add_field("direct_interest_snapshot.weight")
              :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
              :add_where("NOT direct_supporter_snapshot.satisfied")
              :add_field("direct_supporter_snapshot.informed", "is_informed")

    if members_selector:count() > 0 then
      ui.anchor{
        name = "potential_supporters",
        attr = { class = "heading" },
        content = function()
          ui.image{ attr = { class = "spaceicon" }, static = "icons/16/thumb_up_grey.png" }
          slot.put(_"Potential supporters" .. before_voting  .. Member:count_string(members_selector))
        end
      }
                
      execute.view{
        module = "member",
        view = "_list",
        params = {
          initiative = initiative,
          members_selector = members_selector,
          paginator_name = "potential_supporters"
        }
      }
    else
      ui.anchor{
        name = "potential_supporters",
        attr = { class = "heading" },
        content = function()
          ui.image{ attr = { class = "spaceicon" }, static = "icons/16/thumb_up_grey.png" }
          slot.put(_"No potential supporters" .. before_voting)
        end
      }
      slot.put("<br />")
    end
    
    -- initiative details
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
    execute.view {
      module = "initiative",
      view = "_details",
      params = {
        initiative = initiative,
        members_selector = members_selector
      }
    }
end
}

    slot.put('<div class="clearfix"></div>')

  end

  if config.absolute_base_short_url then
    ui.container{
      attr = { class = "shortlink" },
      content = function()
        slot.put(_"Short link" .. ": ")
        local link = config.absolute_base_short_url .. "i" .. initiative.id
        ui.link{ external = link, text = link, image = { attr = { class = "spaceicon" }, static = "icons/16/link.png" } }
      end
    }
  end
end
end
