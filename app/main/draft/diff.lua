local old_draft_id = param.get("old_draft_id", atom.integer)
local new_draft_id = param.get("new_draft_id", atom.integer)

if not old_draft_id or not new_draft_id then
  slot.put_into("error", _"Please choose two versions of the draft to compare")
  return
end

if old_draft_id == new_draft_id then
  slot.put_into("error", _"Please choose two different versions of the draft to compare")
  return
end

if old_draft_id > new_draft_id then
  local tmp = old_draft_id
  old_draft_id = new_draft_id
  new_draft_id = tmp
end

local old_draft = Draft:by_id(old_draft_id)
local new_draft = Draft:by_id(new_draft_id)

execute.view{
  module = "draft",
  view = "_head",
  params = {
    draft = new_draft,
    title = _("Difference between the drafts from #{old} and #{new}", {
      old = format.timestamp(old_draft.created),
      new = format.timestamp(new_draft.created)
    })
  }
}
-- message about new draft
local initiative = new_draft.initiative
if app.session.member_id and not initiative.revoked and not initiative.issue.closed then
  local supporter = app.session.member:get_reference_selector("supporters")
    :add_where{ "initiative_id = ?", initiative.id }
    :optional_object_mode()
    :exec()
  if supporter then
    local old_draft_id = supporter.draft_id
    local new_draft_id = initiative.current_draft.id
    if old_draft_id ~= new_draft_id then
    ui.container{
      attr = { class = "draft_updated_info" },
      content = function()
        slot.put(_"The draft of this initiative has been updated!")
        slot.put(" ")
        ui.link{
          text   = _"Refresh support to current draft",
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
    }
  end
end

local old_draft_content = string.gsub(string.gsub(old_draft.content, "\n", " ###ENTER###\n"), " ", "\n")
local new_draft_content = string.gsub(string.gsub(new_draft.content, "\n", " ###ENTER###\n"), " ", "\n")

local key = multirand.string(26, "123456789bcdfghjklmnpqrstvwxyz");

local old_draft_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-old.tmp")
local new_draft_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-new.tmp")

local old_draft_file = assert(io.open(old_draft_filename, "w"))
old_draft_file:write(old_draft_content)
old_draft_file:write("\n")
old_draft_file:close()

local new_draft_file = assert(io.open(new_draft_filename, "w"))
new_draft_file:write(new_draft_content)
new_draft_file:write("\n")
new_draft_file:close()

local output, err, status = extos.pfilter(nil, "sh", "-c", "diff -U 1000000000 '" .. old_draft_filename .. "' '" .. new_draft_filename .. "' | grep -v ^--- | grep -v ^+++ | grep -v ^@")

os.remove(old_draft_filename)
os.remove(new_draft_filename)

local last_state = "first_run"

local function process_line(line)
  local state_char = string.sub(line, 1, 1)
  local state
  if state_char == "+" then
    state = "added"
  elseif state_char == "-" then
    state = "removed"
  elseif state_char == " " then
    state = "unchanged"
  end
  local state_changed = false
  if state ~= last_state then
    if last_state ~= "first_run" then
      slot.put("</span> ")
    end
    last_state = state
    state_changed = true
    slot.put("<span class=\"diff_" .. tostring(state) .. "\">")
  end

  line = string.sub(line, 2, #line)
  if line ~= "###ENTER###" then
    if not state_changed then
      slot.put(" ")
    end
    slot.put(encode.html(line))
  else
    slot.put("<br />")
  end
end

if not status then
  ui.field.text{ value = _"The drafts do not differ" }
else
  ui.container{
    tag = "div",
    attr = { class = "diff" },
    content = function()
      output = output:gsub("[^\n\r]+", function(line)
        process_line(line)
      end)
    end
  }
end 

