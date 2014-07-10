local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  area = issue.area

  ui.title(_"Add alternative initiative to issue")

  ui.actions(function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
      end,
      module = "issue",
      view = "show",
      id = issue.id,
      params = { tab = "suggestions" }
    }
  end)
else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
end

local polling = param.get("polling", atom.boolean)

local policy_id = param.get("policy_id", atom.integer)
local policy

if policy_id then
  policy = Policy:by_id(policy_id)
end

if issue_id then
  ui.title(_"Create new issue")
end

local preview = param.get("preview")

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
    ui.field.text{ label = _"Unit",  value = area.unit.name }
    ui.field.text{ label = _"Area",  value = area.name }
    if issue_id then
      slot.put("<br />")
      ui.field.text{ label = _"Issue",  value = issue_id }
    elseif policy then
      slot.put("<br />")
      ui.field.hidden{ name = "policy_id", value = policy.id }
      ui.field.text{ label = _"Policy",  value = policy.name }
      if policy.free_timeable then
        local available_timings
        if config.free_timing and config.free_timing.available_func then
          available_timings = config.free_timing.available_func(policy)
          if available_timings == false then
            error("error in free timing config")
          end
        end
        if available_timings then
          ui.field.select{
            label = _"Free timing",
            name = "free_timing",
            foreign_records = available_timings,
            foreign_id = "id",
            foreign_name = "name",
            value = param.get("free_timing")
          }
        else
          ui.field.text{ label = _"Free timing", name = "free_timing", value = param.get("free_timing") }
        end
      end
    elseif not config.disable_policy_selection then
      tmp = { { id = -1, name = _"Please choose a policy" } }
      for i, allowed_policy in ipairs(area.allowed_policies) do
        if not allowed_policy.polling then
          tmp[#tmp+1] = allowed_policy
        end
      end
      ui.field.select{
        label = _"Policy",
        name = "policy_id",
        foreign_records = tmp,
        foreign_id = "id",
        foreign_name = "name",
        value = param.get("policy_id", atom.integer) or area.default_policy and area.default_policy.id
      }
      ui.tag{
        tag = "div",
        content = function()
          ui.tag{
            tag = "label",
            attr = { class = "ui_field_label" },
            content = function() slot.put("&nbsp;") end,
          }
          ui.tag{
            content = function()
              ui.link{
                text = _"Information about the available policies",
                module = "policy",
                view = "list"
              }
              slot.put(" ")
              ui.link{
                attr = { target = "_blank" },
                text = _"(new window)",
                module = "policy",
                view = "list"
              }
            end
          }
        end
      }
    end
    
    if issue and issue.policy.polling and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
      ui.field.boolean{ name = "polling", label = _"No admission needed", value = polling }
    end
    
    if preview then
      ui.heading{ level = 1, content = encode.html(param.get("name")) }
      local discussion_url = param.get("discussion_url")
      ui.container{
        attr = { class = "ui_field_label" },
        content = _"Discussion with initiators"
      }
      ui.tag{
        tag = "span",
        content = function()
          if discussion_url:find("^https?://") then
            if discussion_url and #discussion_url > 0 then
              ui.link{
                attr = {
                  class = "actions",
                  target = "_blank",
                  title = discussion_url
                },
                content = discussion_url,
                external = discussion_url
              }
            end
          else
            slot.put(encode.html(discussion_url))
          end
        end
      }
      ui.container{
        attr = { class = "draft_content wiki" },
        content = function()
          slot.put(format.wiki_text(param.get("draft"), param.get("formatting_engine")))
        end
      }
      slot.put("<br />")
      ui.submit{ text = _"Save" }
      slot.put("<br />")
      slot.put("<br />")
    end
    slot.put("<br />")

    ui.field.text{
      label = _"Title of initiative",
      name  = "name",
      attr = { maxlength = 256 },
      value = param.get("name")
    }
    ui.field.text{
      label = _"Discussion URL",
      name = "discussion_url",
      value = param.get("discussion_url")
    }

    ui.wikitextarea("draft", _"Content")

    ui.submit{ name = "preview", text = _"Preview" }
    ui.submit{ attr = { class = "additional" }, text = _"Save" }
  end
}
