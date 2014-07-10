local old_draft_id = param.get("old_draft_id", atom.integer)
local new_draft_id = param.get("new_draft_id", atom.integer)
local initiative_id = param.get("initiative_id", atom.number)

if not old_draft_id 
  or not new_draft_id 
  or old_draft_id == new_draft_id
then
  slot.reset_all()
  slot.select("error", function()
    ui.tag{ content = _"Please choose two different versions of the draft to compare" }
  end )
  request.redirect{
    module = "draft", view = "list", params = {
      initiative_id = initiative_id
    }
  }
  return
end

if old_draft_id > new_draft_id then
  local tmp = old_draft_id
  old_draft_id = new_draft_id
  new_draft_id = tmp
end

local old_draft = Draft:by_id(old_draft_id)
local new_draft = Draft:by_id(new_draft_id)

local initiative = new_draft.initiative

if app.session.member then
  initiative:load_everything_for_member_id(app.session.member_id)
  initiative.issue:load_everything_for_member_id(app.session.member_id)
end


execute.view{ module = "issue", view = "_sidebar_state", params = {
  initiative = initiative
} }

execute.view { 
  module = "issue", view = "_sidebar_issue", 
  params = {
    issue = initiative.issue,
    highlight_initiative_id = initiative.id
  }
}

execute.view {
  module = "issue", view = "_sidebar_whatcanido",
  params = { initiative = initiative }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = initiative.issue, initiative = initiative
  }
}



execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue
  }
}



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

ui.section( function()
  ui.sectionHead( function()
    ui.link{
      module = "initiative", view = "show", id = initiative.id,
      content = function ()
        ui.heading { 
          level = 1,
          content = initiative.display_name
        }
      end
    }
    ui.heading{ level = 2, content = _("Comparision of revisions #{id1} and #{id2}", {
      id1 = old_draft.id,
      id2 = new_draft.id 
    } ) }
  end )

  if app.session.member_id and not new_draft.initiative.revoked then
    local supporter = app.session.member:get_reference_selector("supporters")
      :add_where{ "initiative_id = ?", new_draft.initiative_id }
      :optional_object_mode()
      :exec()
    if supporter and supporter.draft_id ~= new_draft.id then
      ui.sectionRow("draft_updated_info", function()
        ui.container{ 
          attr = { class = "info" },
          content = _"The draft of this initiative has been updated!"
        }
        slot.put(" ")
        ui.link{
          text   = _"refresh my support",
          module = "initiative",
          action = "add_support",
          id     = new_draft.initiative.id,
          params = { draft_id = new_draft.id },
          routing = {
            default = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = new_draft.initiative.id
            }
          }
        }

        slot.put(" &middot; ")
         
        ui.link{
          text   = _"remove my support",
          module = "initiative",
          action = "remove_support",
          id     = new_draft.initiative.id,
          routing = {
            default = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = new_draft.initiative.id
            }
          }
        }        
        
      end )
    end
  end

  ui.sectionRow( function()

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

  end )
end )