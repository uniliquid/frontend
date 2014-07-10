function format.wiki_text(wiki_text, formatting_engine)

  if not formatting_engine then
    error("Formatting engine identifier required")
  end

  local fe
  
  for i, fe_entry in ipairs(config.formatting_engines) do
    if fe_entry.id == formatting_engine then
      fe = fe_entry
      break
    end
  end

  if not fe then
    error("Formatting engine not found")
  end
  
  local html, errmsg, exitcode = assert(
    extos.pfilter(wiki_text, fe.executable, table.unpack(fe.args or {}))
  )
  
  if exitcode > 0 then
    trace.debug(html, errmsg)
    error("Wiki parser process returned with error code " .. tostring(exitcode))
  elseif exitcode < 0 then
    trace.debug(html, errmsg)
    error("Wiki parser process was terminated by signal " .. tostring(-exitcode))
  end

  if fe.remove_images then
    html = string.gsub(html, '<img [^>]*>', '')
  end
  
  return html
  
end
