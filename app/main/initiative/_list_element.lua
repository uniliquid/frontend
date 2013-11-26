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
            end
              local yes_direct = initiative.positive_direct_votes
              local yes_delegation = initiative.positive_votes - yes_direct
              local no_direct = initiative.negative_direct_votes
              local no_delegation = initiative.negative_votes - no_direct
              local abstention_direct = initiative.issue.direct_voter_count - no_direct - yes_direct
              local abstention_delegation = max_value - initiative.negative_votes - initiative.positive_votes - abstention_direct
            ui.bargraph{
              title_prefix = _"Votes" .. ": ",
              max_value = max_value,
              width = 100,
              quorum = max_value * quorum,
              quorum_color = "#000",
              bars = {
                { color = "#0a5", css = "yes_direct", value = yes_direct, text = _("Yes: #{num}", {num = yes_direct}) .. " "},
                { color = "#0b6", css = "yes_delegation", value = yes_delegation, text = _("(+#{num} delegation)", {num = yes_delegation}) .. " / " },
                { color = "#aaa", css = "abstention_direct", value = abstention_direct, text = _("Abstention: #{num}", {num = abstention_direct}) .. " " },
                { color = "#bbb", css = "abstention_delegation", value = abstention_delegation, text = _("(+#{num} delegation)", {num = abstention_delegation}) .. " / " },
                { color = "#b55", css = "no_delegation", value = no_delegation, text = _("No: #{num}", {num = no_direct}) .. " "},
                { color = "#a00", css = "no_direct", value = no_direct, text = _("(+#{num} delegation)", {num = no_delegation}) .. " / " .. _("Majority: ≥#{num_maj} (#{percent_maj}%)", {num_maj = math.ceil(turnout * max_value * maj), percent_maj = maj*100}) }
              }
            }
          else
          -- for old initiatives without calculated values for direct voters
            local yes = initiative.positive_votes
            local no = initiative.negative_votes
            local abstention =  max_value - yes - no
          ui.bargraph{
            title_prefix = _"Votes" .. ": ",
          max_value = max_value,
          width = 100,
          bars = {
            { color = "#0a5", css = "yes_direct_both", value = yes, text = _("Yes: #{num}", {num = yes}) .. " / " },
            { color = "#aaa", css = "abstention_both", value = abstention, text = _("Abstention: #{num}", {num = abstention}) .. " / " },
            { color = "#a00", css = "no_both", value = initiative.negative_votes, text = _("No: #{num}", {num = no}) },
          }
        }
        end
      else
        -- this should never happen
              ui.bargraph{
                width = 100,
                max_value = 1,
                bars = {
                  { color = "#fff",value = 1, css = "", text = _"Not accepted" }
                }
              }
      end
    else
      local max_value = initiative.issue.population or 0
      local quorum = 0
      if initiative.issue.accepted then
        quorum = initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den
      elseif initiative.issue.policy.issue_quorum_num then
        quorum = initiative.issue.policy.issue_quorum_num / initiative.issue.policy.issue_quorum_den
      end
      local direct_support = (initiative.satisfied_direct_supporter_count or 0)
      local delegated_support = (initiative.satisfied_supporter_count or 0) - (initiative.satisfied_direct_supporter_count or 0)
      local direct_potential = (initiative.direct_supporter_count or 0) - (initiative.satisfied_direct_supporter_count or 0)
      local delegated_potential = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0) - ((initiative.direct_supporter_count or 0) - (initiative.satisfied_direct_supporter_count or 0))
      ui.bargraph{
        title_prefix = _"Supporters" .. ": ",
        max_value = max_value,
        width = 100,
        quorum = max_value * quorum,
        quorum_color = "#00F",
        bars = {
          { color = "#f90", css = "direct_support", value = direct_support, text = _("Supporters: #{num}", {num = direct_support}) .. " " },
          { color = "#fb0", css = "delegated_support", value = delegated_support, text = _("(+#{num} delegation)", {num = delegated_support}) .. " / " },
          { color = "#aaa", css = "direct_potential", value = direct_potential, text = _("Potential supporters: #{num}", {num = direct_potential}) .. " " },
          { color = "#bbb", css = "delegated_potential", value = delegated_potential, text = _("(+#{num} delegation)", {num = delegated_potential}) .. " / " },
          { color = "#fff", css = "", value = max_value - (initiative.supporter_count or 0), text = _("Interested non-supporters: #{num}", {num = max_value - (initiative.supporter_count or 0)}) .. " / " .. _("Quorum: ≥#{num_votes} (#{percent_votes}%)", { num_votes = math.ceil( quorum * max_value ), percent_votes = quorum * 100}) },
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
          if vote then
            local vote_text = vote.grade
            if vote.grade > 0 then vote_text = "+"..vote.grade end
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
                    label = _"This member voted yes via delegation." .. " ("..vote_text..")"
                  else
                    label = _"You voted yes via delegation.".. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_up_green_arrow.png"
                  }
                  slot.put("<span class='yes_vote'>"..vote_text.."</span>")
                elseif vote.grade < 0 then
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member voted no via delegation.".. " ("..vote_text..")"
                  else
                    label = _"You voted no via delegation.".. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/thumb_down_red_arrow.png"
                  }
                  slot.put("<span class='no_vote'>"..vote_text.."</span>")
                else
                  local label
                  if for_member and for_member.id ~= app.session.member_id then
                    label = _"This member abstained via delegation.".. " ("..vote_text..")"
                  else
                    label = _"You abstained via delegation.".. " ("..vote_text..")"
                  end
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/bullet_yellow_arrow.png"
                  }
                  slot.put("<span class='abstention_vote'>"..vote_text.."</span>")
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
            static = "icons/16/thumb_up.png"
            }
          end
        elseif initiative.member_info.supported then
          if initiative.member_info.satisfied then
            local label
            if for_member and for_member.id ~= app.session.member_id then
              label = _"This member is supporter of this initiative via delegation."
            else
              label = _"You are supporter of this initiative via delegation."
            end
            ui.image{
              attr = { alt = label, title = label },
              static = "icons/16/thumb_up_light_green_arrow.png"
            }
          else
            local label
            if for_member and for_member.id ~= app.session.member_id then
              label = _"This member is potential supporter of this initiative via delegation."
            else
              label = _"You are potential supporter of this initiative via delegation."
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
