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
    if initiative.issue.fully_frozen and initiative.issue.closed
      or initiative.admitted == false then
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
            elseif initiative.rank then
              local label = _"Not approved" .. label_rank
              ui.image{ 
                attr = { alt = label, title = label },
                static = "icons/16/delete.png"
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
      -- closed during new?!
      local label = _"Not approved"
      ui.image{
        attr = { alt = label, title = label },
        static = "icons/16/cross.png"
      }
    end
  end }

  ui.container{ attr = { class = "bar" }, content = function()
    if initiative.issue.fully_frozen and initiative.issue.closed and initiative.rank then
      if initiative.negative_votes and initiative.positive_votes then
        local max_value = initiative.issue.voter_count
          if initiative.positive_direct_votes and initiative.negative_direct_votes then
            local maj = initiative.issue.policy.direct_majority_num / initiative.issue.policy.direct_majority_den
            local turnout = (initiative.positive_votes + initiative.negative_votes) / max_value
            local result = initiative.positive_votes / (initiative.positive_votes + initiative.negative_votes)
            if result > maj then
              quorum = maj * turnout 
            else 
              quorum = maj * turnout + (1 - turnout)
              --quorum = maj * turnout
            end
            ui.bargraph{
              title_prefix = _"Votes" .. ": ",
              max_value = max_value,
              width = 100,
              quorum = max_value * quorum,
              quorum_color = "#000",
              bars = {
                { color = "#0a5", css = "yes_direct", value = initiative.positive_direct_votes, text = _"Yes (direct)" },
                { color = "#0b6", css = "yes_delegation", value = initiative.positive_votes - initiative.positive_direct_votes, text = _"Yes (delegation)" },
              { color = "#aaa", css = "abstention_direct", value = initiative.issue.direct_voter_count - initiative.negative_direct_votes - initiative.positive_direct_votes, text = _"Abstention" },
              { color = "#bbb", css = "abstention_delegation", value = max_value - initiative.negative_votes - initiative.positive_votes - (initiative.issue.direct_voter_count - initiative.negative_direct_votes - initiative.positive_direct_votes), text = _"Abstention (delegation)" },
              { color = "#b55", css = "no_delegation", value = initiative.negative_votes - initiative.negative_direct_votes, text = _"No (delegation)" },
                { color = "#a00", css = "no_direct", value = initiative.negative_direct_votes, text = _"No (direct)" },
              -- { color = "#b55", css = "no_delegation", value = initiative.negative_votes - initiative.negative_direct_votes, text = _"No (delegation)" },
                               
              -- { color = "#aaa", css = "abstention_direct", value = initiative.issue.direct_voter_count - initiative.negative_direct_votes - initiative.positive_direct_votes, text = _"Abstention" },
               -- { color = "#bbb", css = "abstention_delegation", value = max_value - initiative.negative_votes - initiative.positive_votes - (initiative.issue.direct_voter_count - initiative.negative_direct_votes - initiative.positive_direct_votes), text = _"Abstention (delegation)" },


              }
            }
          else
          -- for old initiatives without calculated values for direct voters
          ui.bargraph{
            title_prefix = _"Votes" .. ": ",
          max_value = max_value,
          width = 100,
          bars = {
            { color = "#0a5", css = "yes_direct_both", value = initiative.positive_votes, text = _"Yes" },
            { color = "#aaa", css = "abstention_both", value = max_value - initiative.negative_votes - initiative.positive_votes, text = _"Abstentions" },
            { color = "#a00", css = "no_both", value = initiative.negative_votes, text = _"No" },
          }
        }
        end
      else
              ui.bargraph{
                width = 100,
                max_value = 1,
                bars = {
                  { color = "#fff",value = 1, css = "", text = _"Not accepted" }
                }
              }
         --slot.put("&nbsp;")
      end
    else
      local max_value = initiative.issue.population or 0
      local quorum = 0
      if initiative.issue.accepted then
        quorum = initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den
      elseif initiative.issue.policy.issue_quorum_num then
        quorum = initiative.issue.policy.issue_quorum_num / initiative.issue.policy.issue_quorum_den
      end
      ui.bargraph{
        title_prefix = _"Supporters" .. ": ",
        max_value = max_value,
        width = 100,
        quorum = max_value * quorum,
        quorum_color = "#00F",
        bars = {
          { color = "#fa0", css = "support", value = (initiative.satisfied_supporter_count or 0), text = _"Supporters" },
          { color = "#aaa", css = "potential", value = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0), text = _"Potential supporters"  },
          { color = "#fff", css = "interested", value = max_value - (initiative.supporter_count or 0), text = _"Interested non-supporters" },
        }
      }
    end
  end }


   if app.session.member_id then
     ui.container{ attr = { class = "interest interest_vote" }, content = function()
      if initiative.issue.fully_frozen and initiative.issue.closed then
        initiative.issue:load_everything_for_member_id(for_member.id)
        if initiative.issue.member_info.direct_voted then
          local vote = Vote:by_pk(initiative.id, for_member.id)
          if vote then
            local vote_text = vote.grade
            if vote.grade > 0 then vote_text = "+"..vote.grade end
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
                    label = _"This member voted yes." .. " ("..vote_text..")"
                  else
                    label = _"You voted yes." .. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label},
                    static = "icons/16/thumb_up_green.png"
                  }
                  slot.put("<span class='yes_vote'>"..vote_text.."</span>")
                elseif vote.grade < 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted no." .. " ("..vote_text..")"
                  else
                    label = _"You voted no." .. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_down_red.png"
                  }
                  slot.put("<span class='no_vote'>"..vote_text.."</span>")
                else
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member abstained." .. " ("..vote_text..")"
                  else
                    label = _"You abstained." .. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/bullet_yellow.png"
                  }
                  slot.put("<span class='abstention_vote'>"..vote_text.."</span>")
                end
              end
            }
          end
        elseif initiative.issue.member_info.voted_delegate_member_id then
          local vote = Vote:by_pk(initiative.id, initiative.issue.member_info.voted_delegate_member_id)
          --print(vote.grade)
          if vote then
            --print(vote.grade)
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
                    label = _"This member voted yes via delegation." .. " ("..vote.grade..")"
                  else
                    label = _"You voted yes via delegation.".. " ("..vote.grade..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_up_green_arrow.png"
                  }
                  slot.put("<span class='yes_vote'>"..vote.grade.."</span>")
                elseif vote.grade < 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted no via delegation.".. " ("..vote.grade..")"
                  else
                    label = _"You voted no via delegation.".. " ("..vote.grade..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_down_red_arrow.png"
                  }
                  slot.put("<span class='no_vote'>"..vote.grade.."</span>")
                else
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member abstained via delegation.".. " ("..vote.grade..")"
                  else
                    label = _"You abstained via delegation.".. " ("..vote.grade..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/bullet_yellow_arrow.png"
                  }
                  slot.put("<span class='abstention_vote'>"..vote.grade.."</span>")
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
