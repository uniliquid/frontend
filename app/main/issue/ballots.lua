local issue = Issue:by_id(param.get_id())

if not issue then
  slot.put_into("error", _"The requested issue does not exist!")
  return
end

if app.session:has_access("all_pseudonymous") then
  if issue.closed and issue.ranks_available then
    local members_selector = issue:get_reference_selector("direct_voters")
          :left_join("vote", nil, { "vote.issue_id = ? AND vote.member_id = member.id", issue.id })
          :add_field("direct_voter.weight as voter_weight")
          :add_field("direct_voter.weight AS weight")
          :add_field("coalesce(vote.grade, 0) as grade")
          :add_field("direct_voter.comment as voter_comment")
          :left_join("issue", nil, "issue.id = vote.issue_id")
          :left_join("delegating_voter", "_member_list__delegating_voter", { "_member_list__delegating_voter.issue_id = issue.id AND _member_list__delegating_voter.member_id = ?", app.session.member_id })
          :add_field("_member_list__delegating_voter.delegate_member_ids", "delegate_member_ids")
          :add_order_by("voter_weight DESC, lower(member.name), id")
        ui.container{
          attr = { class = "member_list" },
          content = function()
            local members = members_selector:exec()
            ui.container{ attr = { class = "initiative_head" }, content = function()
            ui.tag{ attr = { class = "title" }, content = _"Initiatives" }
            ui.container{ attr = { class = "draft_content wiki" }, content = function()
      ui.tag{
        tag = "pre", content = function()
                local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
                for i, initiative in ipairs(initiatives) do
                  slot.put("i" .. initiative.id .. "<br />")
                end
                slot.put("SQ")
end
}
               end
              }
              end
            }
            ui.container{ attr = { class = "initiative_head" }, content = function()
            ui.tag{ attr = { class = "title" }, content = _"Ballots" }
            ui.container{ attr = { class = "draft_content wiki" }, content = function()
      ui.tag{   
        tag = "pre", content = function()

            for i, member in ipairs(members) do
              local delegation = ""
              for j = 1, member.weight do
local tempvoting_string = param.get("scoring")

local tempvotings = {}
if tempvoting_string then
  for match in tempvoting_string:gmatch("([^;]+)") do
    for initiative_id, grade in match:gmatch("([^:;]+):([^:;]+)") do
      tempvotings[tonumber(initiative_id)] = tonumber(grade)
    end
  end
end

local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):add_order_by("initiative.satisfied_supporter_count DESC"):exec()

local min_grade = -1;
local max_grade = 1;

for i, initiative in ipairs(initiatives) do
  -- TODO performance
  initiative.vote = Vote:by_pk(initiative.id, member.id)
  if tempvotings[initiative.id] then
    initiative.vote = {}
    initiative.vote.grade = tempvotings[initiative.id]
  end
  if initiative.vote then
    if initiative.vote.grade > max_grade then
      max_grade = initiative.vote.grade
    end
    if initiative.vote.grade < min_grade then
      min_grade = initiative.vote.grade
    end
  end
end

local sections = {}
for i = min_grade, max_grade do
  sections[i] = {}
  for j, initiative in ipairs(initiatives) do
    if (initiative.vote and initiative.vote.grade == i) or (not initiative.vote and i == 0) then
      sections[i][#(sections[i])+1] = initiative
    end
  end
end

local approval_count, disapproval_count = 0, 0
for i = min_grade, -1 do
  if #sections[i] > 0 then
    disapproval_count = disapproval_count + 1
  end
end
local approval_count = 0
for i = 1, max_grade do
  if #sections[i] > 0 then
    approval_count = approval_count + 1
  end
end

for i = max_grade, min_grade, -1 do
if i == 0 then
slot.put("/ SQ ")
elseif i == -1 then
slot.put("/ ")
elseif not (i == max_grade) then
slot.put("; ")
end
for j,ini in ipairs(sections[i]) do
if i == 0 or j > 1 then
slot.put(", ")
end
slot.put("i" .. ini.id .. " ")
end
end
slot.put("<br />")

              end
            end
end
}
end
}
            end
            }

          end
        }
  end
end
