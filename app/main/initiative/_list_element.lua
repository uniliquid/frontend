local initiative = param.get("initiative", "table")
local selected = param.get("selected", atom.boolean)
local for_member = param.get("for_member", "table") or app.session.member

local class = "initiative"

if selected then
  class = class .. " selected"
end

if initiative.polling then
  class = class .. " polling"
end

ui.container{ attr = { class = class }, content = function()

  ui.container{ attr = { class = "rank" }, content = function()
    if (initiative.issue.accepted and initiative.issue.closed and initiative.issue.ranks_available) or initiative.admitted == false then
      ui.form_element(args, {fetch_value = true}, function(args)
        ui.tag{
          attr = { class = "rank" },
          content = function()
            local label_rank = ""
            if initiative.rank then
              label_rank = " " .. _("(rank #{rank})", { rank = initiative.rank })
            end
            if initiative.eligible and initiative.rank == 1 then
              local label = _"Approved" .. label_rank
              ui.image{
                attr = { alt = label, title = label },
                static = "icons/16/award_star_gold_2.png"
              }
            elseif initiative.eligible and initiative.rank then
              local label = _"Not approved" .. label_rank
              ui.image{
                attr = { alt = label, title = label },
                static = "icons/16/award_star_silver_2.png"
              }
            else
              local label = _"Not approved" .. label_rank
              ui.image{
                attr = { alt = label, title = label },
                static = "icons/16/cross.png"
              }
            end
            if initiative.rank then
              ui.tag{
                attr = { class = "value" },
                content = tostring(initiative.rank)
              }
            end
          end
        }
      end)
    elseif not initiative.issue.closed then
      local label = _"Initiative in open issue"
      ui.image{
        attr = { alt = label, title = label },
        static = "icons/16/script.png"
      }
    else
      local label = _"Not approved"
      ui.image{
        attr = { alt = label, title = label },
        static = "icons/16/cross.png"
      }
    end
  end }

  ui.container{ attr = { class = "bar" }, content = function()
    if initiative.issue.fully_frozen and initiative.issue.closed then
      if initiative.issue.ranks_available then 
        if initiative.negative_votes and initiative.positive_votes then
          local max_value = initiative.issue.voter_count
          if initiative.positive_direct_votes and initiative.negative_direct_votes then
            ui.bargraph{
              title_prefix = _"Votes" .. ": ",
              max_value = max_value,
              width = 100,
              bars = {
                { color = "#0a5", value = initiative.positive_direct_votes },
                { color = "#0b6", value = initiative.positive_votes - initiative.positive_direct_votes },
                { color = "#aaa", value = max_value - initiative.negative_votes - initiative.positive_votes },
                { color = "#b55", value = initiative.negative_votes - initiative.negative_direct_votes },
                { color = "#a00", value = initiative.negative_direct_votes }
              }
            }
          else
          -- for old initiatives without calculated values for direct voters
          ui.bargraph{
            title_prefix = _"Votes" .. ": ",
            max_value = max_value,
            width = 100,
            bars = {
              { color = "#0a5", value = initiative.positive_votes },
              { color = "#aaa", value = max_value - initiative.negative_votes - initiative.positive_votes },
              { color = "#a00", value = initiative.negative_votes },
            }
          }
        end
        else
          slot.put("&nbsp;")
        end
      else
        slot.put(_"Counting of votes")
      end
    else
      local max_value = initiative.issue.population or 0
      local quorum
      if initiative.issue.accepted then
        quorum = initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den
      else
        quorum = initiative.issue.policy.issue_quorum_num / initiative.issue.policy.issue_quorum_den
      end
      ui.bargraph{
        title_prefix = _"Supporters" .. ": ",
        max_value = max_value,
        width = 100,
        quorum = max_value * quorum,
        quorum_color = "#00F",
        bars = {
          { color = "#4c6", value = (initiative.satisfied_supporter_count or 0) },
          { color = "#aaa", value = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0) },
          { color = "#fff", value = max_value - (initiative.supporter_count or 0) },
        }
      }
    end
  end }


   if app.session.member_id then
     ui.container{ attr = { class = "interest" }, content = function()
      if initiative.issue.fully_frozen and initiative.issue.closed then
        initiative.issue:load_everything_for_member_id(for_member.id)
        if initiative.issue.member_info.direct_voted then
          local vote = Vote:by_pk(initiative.id, for_member.id)
          if vote then
            ui.link{
              module = "vote",
              view = "list",
              params = {
                issue_id = initiative.issue.id,
                member_id = for_member.id,
              },
              content = function()
                if vote.grade > 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted yes."
                  else
                    label = _"You voted yes."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_up_green.png"
                  }
                elseif vote.grade < 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted no."
                  else
                    label = _"You voted no."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_down_red.png"
                  }
                else
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member abstained."
                  else
                    label = _"You abstained."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/bullet_yellow.png"
                  }
                end
              end
            }
          end
        elseif initiative.issue.member_info.voted_delegate_member_id then
          local vote = Vote:by_pk(initiative.id, initiative.issue.member_info.voted_delegate_member_id)
          if vote then
            ui.link{
              module = "vote",
              view = "list",
              params = {
                issue_id = initiative.issue.id,
                member_id = initiative.issue.member_info.voted_delegate_member_id,
              },
              content = function()
                local label
                if vote.grade > 0 then
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted yes via delegation."
                  else
                    label = _"You voted yes via delegation."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_up_green_arrow.png"
                  }
                elseif vote.grade < 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted no via delegation."
                  else
                    label = _"You voted no via delegation."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_down_red_arrow.png"
                  }
                else
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member abstained via delegation."
                  else
                    label = _"You abstained via delegation."
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/bullet_yellow_arrow.png"
                  }
                end
              end
            }
          end
        end
      else
        if initiative.member_info.directly_supported then
           if initiative.member_info.satisfied then
            local label
            if for_member and for_member.id ~= app.session.member_id then
              label = _"This member is supporter of this initiative."
            else
              label = _"You are supporter of this initiative."
            end
            ui.image{
              attr = { alt = label, title = label },
              static = "icons/16/thumb_up_light_green.png"
            }
          else
            local label
            if for_member and for_member.id ~= app.session.member_id then
              label = _"This member is potential supporter of this initiative."
            else
              label = _"You are potential supporter of this initiative."
            end
             ui.image{
               attr = { alt = label, title = label },
            static = "icons/16/thumb_up_arrow.png"
          }
        end
      end
      end
    end }
    if initiative.member_info.initiated then
      ui.container{ attr = { class = "interest" }, content = function()
        local label
        if for_member and for_member.id ~= app.session.member_id then
          label = _"This member is initiator of this initiative."
        else
          label = _"You are initiator of this initiative."
        end
        ui.image{
          attr = { alt = label, title = label },
          static = "icons/16/user_edit.png"
        }
      end }
    end
  end

  ui.container{
    attr = { class = "name" .. (initiative.name_highlighted and "" or " ellipsis") },
    content = function()
    local link_class = "initiative_link"
    if initiative.revoked then
      link_class = "revoked"
    end
    ui.link{
      attr = { class = link_class },
      content = function()
        local name
        if initiative.name_highlighted then
          name = encode.highlight(initiative.name_highlighted)
        else
          name = encode.html(initiative.name)
        end
        ui.tag{ content = "i" .. initiative.id .. ": " }
        slot.put(name)
      end,
      module  = "initiative",
      view    = "show",
      id      = initiative.id
    }
        
  end }

end }
