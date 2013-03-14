
app.html_title = {}

execute.inner()

local html_title = ""

-- add ":" to prefix
if app.html_title.prefix then
  html_title = app.html_title.prefix .. ": "
end

-- add "-" to title 
if app.html_title.title then
  html_title = html_title .. app.html_title.title .. " - "
end

-- add "-" to subtitle
if app.html_title.subtitle then
  html_title = html_title .. app.html_title.subtitle .. " - "
end

slot.put_into("html_title", encode.html(html_title) .. _"Liquid" .. " - " .. config.instance_name)
