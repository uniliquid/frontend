local member = Member:by_id(param.get_id())
local member_id_me = app.session.member_id
if member_id_me then
member_me = Member:by_id(member_id_me)
trace.disable()
local content = slot.use_temporary(function()
  slot.put(_"Hallo " .. member.name .. ",\n\n")
  slot.put(member_me.name .. _" aus dem " .. config.instance_name .. _" hat dir folgende Nachricht geschickt:\n\n------------------------------------------\n\n")
  slot.put(param.get("text") .. "\n\n")
  slot.put("------------------------------------------\n\n")
  if config.mail_aliases and member.name ~= nil and member.name:match("^[A-Za-z][A-Za-z0-9%.%%%+%-]*$") then
    slot.put(_"Du kannst direkt per Mail oder unter " .. request.get_absolute_baseurl() .. "member/show/" .. member_me.id .. ".html" .. " auf die Nachricht antworten.\n\n---\n")
  else
    slot.put(_"Unter " .. request.get_absolute_baseurl() .. "member/show/" .. member_me.id .. ".html" .. " kannst du auf die Nachricht antworten.\n\n---\n")
  end
end)
local mail_from = config.mail_from
local mail_reply_to = config.mail_noreply
local mail_envelope_from = config.mail_envelope_from
if config.mail_aliases and member.name ~= nil and member.name:match("^[A-Za-z][A-Za-z0-9%.%%%+%-]*$") then
  mail_from = member.name .. '@' .. config.hostname
  mail_envelope_from = mail_from
  mail_reply_to = mail_from
end
local success = net.send_mail{
  envelope_from = mail_envelope_from,
  from          = mail_from,
  reply_to      = mail_reply_to,
  to            = member.notify_email,
  subject       = "[Liquid] Nachricht eines Benutzers",
  content_type  = "text/plain; charset=UTF-8",
  content       = content
}
if success then
  slot.put_into("notice", _"Your message has been sent")
  return
end
end
slot.put_into("error", _"Your message has not been sent")
