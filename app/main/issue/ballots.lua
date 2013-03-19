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

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = issue.area } }
end)

util.help("issue.show")

slot.select("head", function()
  execute.view{ module = "issue", view = "_show", params = { issue = issue } }
end )

if app.session:has_access("all_pseudonymous") then
  if issue.fully_frozen and issue.closed then
    local members_selector = issue:get_reference_selector("direct_voters")
          :add_field("direct_voter.weight as voter_weight")
          :add_field("direct_voter.weight AS weight")
          :add_field("direct_voter.comment as voter_comment")
          :add_order_by("voter_weight DESC, lower(member.name), id")
ui.container{
  attr = { class = "member_list" },
  content = function()
    local members = members_selector:exec()
    -- initiatives (input for preftools)
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Initiatives" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        ui.tag{
          tag = "pre", content = function()
            local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
            for i, initiative in ipairs(initiatives) do
              slot.put("i" .. initiative.id .. "<br />")
            end
            slot.put("iSQ")
          end
        }
        end
      }
      end
    }
    -- ballots (input for preftools)
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
                    slot.put("/ iSQ ")
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
local inis = {}
local battles = {}
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Battles" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
battles["SQ"] = {}
local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
for i, ini_x in ipairs(initiatives) do
  battles[ini_x.id] = {}
  battles[ini_x.id][ini_x.id] = ""
  local battled_initiatives = Initiative:new_selector()
    :add_field("winning_battle.count", "winning_count")
    :join("battle", "winning_battle", { "winning_battle.winning_initiative_id = ? AND winning_battle.losing_initiative_id = initiative.id", ini_x.id })
    :exec()
  for i, ini_y in ipairs(battled_initiatives) do
    battles[ini_x.id][ini_y.id] = ini_y.winning_count
  end
  battles[ini_x.id]["SQ"] = ini_x.positive_votes;
  battles["SQ"][ini_x.id] = ini_x.negative_votes;
  inis[i] = ini_x.id;
end
battles["SQ"]["SQ"] = "";
inis[#inis+1] = "SQ";
        ui.tag{
          tag = "table", content = function()
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = _"beats" }
                for i, ini_x in ipairs(inis) do
                  ui.tag{ tag = "td", content = "i" .. ini_x }
                end
              end
            }
          for i, ini_y in ipairs(inis) do
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = "i" .. ini_y }
                for i, ini_x in ipairs(inis) do
                  local battle
                  if battles[ini_y][ini_x] > battles[ini_x][ini_y] then
                    battle = ui.tag{ tag = "td", content = function() ui.tag{ tag = "b", content = battles[ini_y][ini_x] } end }
                  else
                    battle = ui.tag{ tag = "td", content = battles[ini_y][ini_x] }
                  end
                end
              end
            }
          end
          end
        }
        end
      }
      end
    }
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Graph" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        end
      }
      end
    }
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Winning Beatpaths" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        local p = {}
        local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
        for a,i in ipairs(inis) do
          p[i] = {}
          for b,j in ipairs(inis) do
            if i ~= j then
              if battles[i][j] > battles[j][i] then
                p[i][j] = battles[i][j]
              else
                p[i][j] = 0
              end
            end
            p[i][i] = 0
          end
        end
        for a,i in ipairs(inis) do
          for b,j in ipairs(inis) do
            if i ~= j then
              for c,k in ipairs(inis) do
                if i ~= k then
                  if j ~= k then
                    p[j][k] = math.max(p[j][k],math.min(p[j][i],p[i][k]))
                  end
                end
              end
            end
          end
        end
        ui.tag{
          tag = "table", content = function()
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = _"beats" }
                for i, ini_x in ipairs(inis) do
                  ui.tag{ tag = "td", content = "i" .. ini_x }
                end
              end
            }
          for i, ini_y in ipairs(inis) do
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = "i" .. ini_y }
                for i, ini_x in ipairs(inis) do
                  local battle
                  if p[ini_y][ini_x] > p[ini_x][ini_y] then
                    battle = ui.tag{ tag = "td", content = function() ui.tag{ tag = "b", content = p[ini_y][ini_x] } end }
                  else
                    battle = ui.tag{ tag = "td", content = p[ini_y][ini_x] }
                  end
                end
              end
            }
          end
          end
        }

        end
      }
      end
    }

  end
end
