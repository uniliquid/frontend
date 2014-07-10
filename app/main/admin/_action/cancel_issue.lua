local issue = Issue
  :new_selector()
  :add_where{ "id = ?", param.get_id()}
  :single_object_mode()
  :for_update()
  :exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
end  

issue.state = "canceled_by_admin"
issue.closed = "now"

local admin_notice
if issue.admin_notice then
  admin_notice = issue.admin_notice .. "\n\n"
else
  admin_notice = ""
end

admin_notice = admin_notice .. param.get("admin_notice")

issue.admin_notice = admin_notice

issue:save()

slot.put_into("notice", _"Issue has been canceled")