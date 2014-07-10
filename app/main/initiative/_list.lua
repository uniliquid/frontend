local member = param.get("member", "table") or app.session.member

local initiatives = param.get("initiatives", "table")
local highlight_initiative_id = param.get ( "highlight_initiative_id", "number" )

local for_initiative = param.get("initiative", "table")

local for_event = param.get("for_event", atom.boolean)

if for_initiative then
  initiatives = { for_initiative }
end

ui.tag { 
  tag = "ul",
  attr = { class = "initiatives" },
  content = function ()
    local last_group
    for i, initiative in ipairs(initiatives) do
      local group
      if initiative.issue.closed then
        if initiative.rank == 1 then
          group = "1st_rank"
        elseif initiative.admitted then
          group = "admitted"
        elseif initiative.revoked_by_member_id then
          group = "revoked"
        else
          group = "not_admitted"
        end
      end
      if not for_initiative and group ~= last_group and not for_event then

        local text
        if group == "admitted" then
          if initiative.issue.state == "finished_with_winner" then
            text = _"Competing initiatives in pairwise comparison to winner:"
          else
            text = _"Competing initiatives in pairwise comparison to best initiative:"
          end
        end
        if group == "not_admitted" then
          text = _("Competing initiatives failed the 2nd quorum (#{num}/#{den}):", {
            num = initiative.issue.policy.initiative_quorum_num,
            den = initiative.issue.policy.initiative_quorum_den
          } )
        end
        if text then
          slot.put("<br />")
          ui.container { attr = { class = "result" }, content = text }
        end
        last_group = group
      end

      local class = ""
      if highlight_initiative_id == initiative.id then
        class = "highlighted"
      end
      if app.session.member then
        if initiative.member_info.supported then
          class = class .. " supported"
        end
        if initiative.member_info.satisfied then
          class = class .. " satisfied"
        end
      end
      ui.tag {
        tag = "li", attr = { class = class },
        content = function ()
          execute.view {
            module = "initiative", view = "_list_element", params = {
              initiative = initiative, for_event = for_event
            }
          }
        end
      }
    end
  end 
}