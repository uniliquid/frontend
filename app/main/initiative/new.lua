local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  issue:load_everything_for_member_id(app.session.member_id)
  area = issue.area

else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
  area:load_delegation_info_once_for_member_id(app.session.member_id)
end

local polling = param.get("polling", atom.boolean)

local policy_id = param.get("policy_id", atom.integer)
local policy

local preview = param.get("preview")

if #(slot.get_content("error")) > 0 then
  preview = false
end

if policy_id then
  policy = Policy:by_id(policy_id)
end

if issue_id then
  execute.view {
    module = "issue", view = "_head", 
    params = { issue = issue, member = app.session.member }
  }
  execute.view { 
    module = "issue", view = "_sidebar_state", 
    params = {
      issue = issue
    }
  }
  execute.view { 
    module = "issue", view = "_sidebar_issue", 
    params = {
      issue = issue
    }
  }
else
  execute.view {
    module = "area", view = "_head", 
    params = { area = area, member = app.session.member }
  }
  execute.view { 
    module = "initiative", view = "_sidebar_policies", 
    params = {
      area = area,
    }
  }
end





if not preview and not issue_id and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
  ui.actions(function()
    ui.link{ 
      text = _"Standard policies",
      module = "initiative", view = "new", params = {
        area_id = area.id
      }
    }
    for i, policy in ipairs(area.allowed_policies) do
      if policy.polling  then
        slot.put(" &middot; ")
        ui.link{ 
          text = policy.name,
          module = "initiative", view = "new", params = {
            area_id = area.id, policy_id = policy.id        
          }
        }
      end
    end
  end)
end

ui.form{
  module = "initiative",
  action = "create",
  params = {
    area_id = area.id,
    issue_id = issue and issue.id or nil
  },
  attr = { class = "vertical" },
  content = function()
  
    if preview then
      ui.section( function()
        ui.sectionHead( function()
          ui.heading{ level = 1, content = encode.html(param.get("name")) }
          if not issue then
            ui.container { content = policy.name }
          end
          slot.put("<br />")

          ui.field.hidden{ name = "formatting_engine", value = param.get("formatting_engine") }
          ui.field.hidden{ name = "policy_id", value = param.get("policy_id") }
          ui.field.hidden{ name = "name", value = param.get("name") }
          ui.field.hidden{ name = "draft", value = param.get("draft") }
          local formatting_engine
          if config.enforce_formatting_engine then
            formatting_engine = config.enforce_formatting_engine
          else
            formatting_engine = param.get("formatting_engine")
          end
          ui.container{
            attr = { class = "draft_content wiki" },
            content = function()
              slot.put(format.wiki_text(param.get("draft"), formatting_engine))
            end
          }
          slot.put("<br />")

          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              class = "btn btn-default",
              value = _'Publish now'
            },
            content = ""
          }
          slot.put("<br />")
          slot.put("<br />")
          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              name = "edit",
              class = "btn-link",
              value = _'Edit again'
            },
            content = ""
          }
          slot.put(" | ")
          if issue then
            ui.link{ content = _"Cancel", module = "issue", view = "show", id = issue.id }
          else
            ui.link{ content = _"Cancel", module = "area", view = "show", id = area.id }
          end
        end )
      end )
    else
      
     
      execute.view{ module = "initiative", view = "_sidebar_wikisyntax" }

      ui.section( function()
        if preview then
          ui.sectionHead( function()
            ui.heading { level = 1, content = _"Edit again" }
          end )
        elseif issue_id then
          ui.sectionHead( function()
            ui.heading { level = 1, content = _"Add a new competing initiative to issue" }
          end )
        else
          ui.sectionHead( function()
            ui.heading { level = 1, content = _"Create a new issue" }
          end )
        end
      
        ui.sectionRow( function()
          if not preview and not issue_id then
            ui.container { attr = { class = "section" }, content = _"Before creating a new issue, please check any existant issues before, if the topic is already in discussion." }
            slot.put("<br />")
          end
          if not issue_id then
            tmp = { { id = -1, name = "" } }
            for i, allowed_policy in ipairs(area.allowed_policies) do
              if not allowed_policy.polling then
                tmp[#tmp+1] = allowed_policy
              end
            end
            ui.heading{ level = 2, content = _"Please choose a policy for the new issue:" }
            ui.field.select{
              name = "policy_id",
              foreign_records = tmp,
              foreign_id = "id",
              foreign_name = "name",
              value = param.get("policy_id", atom.integer) or area.default_policy and area.default_policy.id
            }
            if policy and policy.free_timeable then
              ui.sectionRow( function()
                local available_timings
                if config.free_timing and config.free_timing.available_func then
                  available_timings = config.free_timing.available_func(policy)
                  if available_timings == false then
                    error("error in free timing config")
                  end
                end
                ui.heading{ level = 4, content = _"Free timing:" }
                if available_timings then
                  ui.field.select{
                    name = "free_timing",
                    foreign_records = available_timings,
                    foreign_id = "id",
                    foreign_name = "name",
                    value = param.get("free_timing")
                  }
                else
                  ui.field.text{
                    name = "free_timing",
                    value = param.get("free_timing")
                  }
                end
              end )
            end
          end

          if issue and issue.policy.polling and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
            slot.put("<br />")
            ui.field.boolean{ name = "polling", label = _"No admission needed", value = polling }
          end
          
          slot.put("<br />")
          ui.heading { level = 2, content = _"Enter a title for your initiative (max. 140 chars):" }
          ui.field.text{
            attr = { style = "width: 100%;" },
            name  = "name",
            value = param.get("name")
          }
          ui.container { content = _"The title is the figurehead of your iniative. It should be short but meaningful! As others identifies your initiative by this title, you cannot change it later!" }
          
          if not config.enforce_formatting_engine then
            slot.put("<br />")
            ui.heading { level = 4, content = _"Choose a formatting engine:" }
            ui.field.select{
              name = "formatting_engine",
              foreign_records = config.formatting_engines,
              attr = {id = "formatting_engine"},
              foreign_id = "id",
              foreign_name = "name",
              value = param.get("formatting_engine")
            }
          end
          slot.put("<br />")

          ui.heading { level = 2, content = _"Enter your proposal and/or reasons:" }
          ui.field.text{
            name = "draft",
            multiline = true, 
            attr = { style = "height: 50ex; width: 100%;" },
            value = param.get("draft") or
                [[
Proposal
======

Replace me with your proposal.


Reasons
======

Argument 1
------

Replace me with your first argument


Argument 2
------

Replace me with your second argument

]]
          }
          if not issue or issue.state == "admission" or issue.state == "discussion" then
            ui.container { content = _"You can change your text again anytime during admission and discussion phase" }
          else
            ui.container { content = _"You cannot change your text again later, because this issue is already in verfication phase!" }
          end
          slot.put("<br />")
          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              name = "preview",
              class = "btn btn-default",
              value = _'Preview'
            },
            content = ""
          }
          slot.put("<br />")
          slot.put("<br />")
          
          if issue then
            ui.link{ content = _"Cancel", module = "issue", view = "show", id = issue.id }
          else
            ui.link{ content = _"Cancel", module = "area", view = "show", id = area.id }
          end
        end )
      end )
    end
  end
}
