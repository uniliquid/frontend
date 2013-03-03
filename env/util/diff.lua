function util.diff(old_content, new_content)

  -- diff understands \r not as a line break but as a change within the line
  old_content = string.gsub(old_content, "\r\n", "\n")
  old_content = string.gsub(old_content, "\n", " ###ENTER###\n")
  old_content = string.gsub(old_content, " ", "\n")

  new_content = string.gsub(new_content, "\r\n", "\n")
  new_content = string.gsub(new_content, "\n", " ###ENTER###\n")
  new_content = string.gsub(new_content, " ", "\n")

  local key = multirand.string(26, "123456789bcdfghjklmnpqrstvwxyz");

  local old_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-old.tmp")
  local new_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-new.tmp")

  local old_file = assert(io.open(old_filename, "w"))
  old_file:write(old_content)
  old_file:write("\n")
  old_file:close()

  local new_file = assert(io.open(new_filename, "w"))
  new_file:write(new_content)
  new_file:write("\n")
  new_file:close()

  local output, err, status = extos.pfilter(nil, "sh", "-c", "diff -U 1000000000 '" .. old_filename .. "' '" .. new_filename .. "' | grep -v ^--- | grep -v ^+++ | grep -v ^@")

  os.remove(old_filename)
  os.remove(new_filename)

  local last_state = "first_run"
  local first_in_line = true

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
      if not state_changed and not first_in_line then
        slot.put(" ")
      end
      slot.put(encode.html(line))
      first_in_line = false
    else
      slot.put("\n<br />")
      first_in_line = true
    end

  end

  if output == "" then
    ui.field.text{ value = _"The versions do not differ." }
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

end
