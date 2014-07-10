local delegations = Delegation:delegations_to_check_for_member_id(app.session.member_id, true)


-- check if for any unit/area delegation an option is choosen
for i, delegation in ipairs(delegations) do
  
  local option = param.get("delegation_" .. delegation.id)
  
  if option == "confirm" then
  elseif option == "revoke" then
  else
    slot.put_into("error", _"Please decide for each delegation to confirm or to revoke it!")
    return false
  end
  
end  

-- revoke delegations
for i, delegation in ipairs(delegations) do

  local option = param.get("delegation_" .. delegation.id)
  
  if option == "revoke" then
    local d = Delegation:by_id(delegation.id)
    if d.truster_id == app.session.member_id then
      d:destroy()
    end
  end
end
    
-- set delegation check as done
app.session.member.last_delegation_check = "now"
app.session.member.last_activity = "now"
app.session.member.active = true
app.session.member:save()

app.session.needs_delegation_check = false
app.session:save()
