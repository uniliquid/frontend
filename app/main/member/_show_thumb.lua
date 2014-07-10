local initiator = param.get("initiator", "table")
local member = param.get("member", "table")

local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")
local trustee = param.get("trustee", "table")

local class = param.get("class")

local name_html
if member.name_highlighted then
  name_html = encode.highlight(member.name_highlighted)
else
  name_html = encode.html(member.name)
end

local container_class = "member_thumb"
if initiator and member.accepted ~= true then
  container_class = container_class .. " not_accepted"
end

if member.is_informed == false then
  container_class = container_class .. " not_informed"
end

if class then
  container_class = container_class .. " " .. class
end

local in_delegation_chain = member.in_delegation_chain
--[[if member.delegate_member_ids then
  for member_id in member.delegate_member_ids:gmatch("(%w+)") do
    if tonumber(member_id) == member.id then
      in_delegation_chain = true
    end
  end
end
--]]
if in_delegation_chain or ((issue or initiative) and member.id == app.session.member_id) then
  container_class = container_class .. " in_delegation_chain"
end

ui.container{
  attr = { class = container_class },
  content = function()

    local function doit()
      execute.view{
        module = "member_image",
        view = "_show",
        params = {
          member = member,
          image_type = "avatar",
          show_dummy = true
        }
      }
      ui.tag{
        attr = { class = "member_name" },
        content = function() slot.put(name_html) end
      }
    end
    
    if app.session:has_access("everything") then
      ui.link{
        attr = { title = _"Show member" },
        module = "member",
        view = "show",
        id = member.id,
        content = doit
      }
    else
      ui.tag{ content = doit }
    end

    if member.grade then
      slot.put ( " " )
      ui.link{
        module = "vote",
        view = "list",
        params = {
          issue_id = initiative.issue.id,
          member_id = member.id,
        },
        content = function()
          if member.grade > 0 then
            ui.image{
              attr = { 
                alt   = _"Voted yes",
                title = _"Voted yes",
                class = "icon24 right"
              },
              static = "icons/32/support_satisfied.png"
            }
          elseif member.grade < 0 then
            ui.image{
              attr = { 
                alt   = _"Voted no",
                title = _"Voted no",
                class = "icon24 right"
              },
              static = "icons/32/voted_no.png"
            }
          else
            ui.image{
              attr = { 
                alt   = _"Abstention",
                title = _"Abstention",
                class = "icon24 right"
              },
              static = "icons/16/bullet_yellow.png"
            }
          end
        end
      }
    end

    if (member.voter_comment) then
      ui.link{
        module = "vote",
        view = "list",
        params = {
          issue_id = issue.id,
          member_id = member.id,
        },
        content = function()
          ui.image{
            attr = { 
              alt   = _"Voting comment available",
              title = _"Voting comment available",
              class = "icon24 right"
            },
            static = "icons/16/comment.png"
          }
        end
      }
    end

    local weight = 0
    if member.weight then
      weight = member.weight
    end
    if member.voter_weight then
      weight = member.voter_weight
    end

    if (issue or initiative) and weight > 1 then
      local module = "interest"
      if member.voter_weight then
        module = "vote"
      end
        
      slot.put ( " " )
      ui.link{
        attr = { 
          class = in_delegation_chain and "in_delegation_chain" or nil,
          title = _"Number of incoming delegations, follow link to see more details"
        },
        content = _("+ #{weight}", { weight = weight - 1 }),
        module = module,
        view = "show_incoming",
        params = { 
          member_id = member.id, 
          initiative_id = initiative and initiative.id or nil,
          issue_id = issue and issue.id or nil
        }
      }
    end
    
    if member.supporter then
      slot.put ( " " )
      if member.supporter_satisfied then
        local text = _"supporter"
        ui.image{ attr = { class = "icon24 right", alt = text, title = text }, static = "icons/32/support_satisfied.png" }
      else
        local text = _"supporter with restricting suggestions"
        ui.image{ attr = { class = "icon24 right", alt = text, title = text }, static = "icons/32/support_unsatisfied.png" }
      end
    end

    if not member.active then
      slot.put ( " " )
      local text = _"member inactive"
      ui.image{
        attr = { alt = text, title = text },
        static = "icons/16/cross.png"
      }
      ui.tag{ content = _"inactive" }
    end

    if initiator and initiator.accepted then
      if member.accepted == nil then
        slot.put(_"Invited")
      elseif member.accepted == false then
        slot.put(_"Rejected")
      end
    end

    if member.is_informed == false then
      local text = _"Member has not approved latest draft"
      ui.image{
        attr = { alt = text, title = text },
        static = "icons/16/help_yellow.png"
      }
    end

  end
}
