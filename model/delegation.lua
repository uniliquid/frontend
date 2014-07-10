Delegation = mondelefant.new_class()
Delegation.table = 'delegation'

Delegation:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'truster_id',
  that_key      = 'id',
  ref           = 'truster',
}

Delegation:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'trustee_id',
  that_key      = 'id',
  ref           = 'trustee',
}

Delegation:add_reference{
  mode          = 'm1',
  to            = "Unit",
  this_key      = 'unit_id',
  that_key      = 'id',
  ref           = 'unit',
}

Delegation:add_reference{
  mode          = 'm1',
  to            = "Area",
  this_key      = 'area_id',
  that_key      = 'id',
  ref           = 'area',
}

Delegation:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

function Delegation:by_pk(truster_id, unit_id, area_id, issue_id)
  local selector = self:new_selector():optional_object_mode()
  selector:add_where{ "truster_id = ?", truster_id }
  if unit_id then
    selector:add_where{ "unit_id = ?",    unit_id }
  else
    selector:add_where("unit_id ISNULL")
  end
  if area_id then
    selector:add_where{ "area_id = ?",    area_id }
  else
    selector:add_where("area_id ISNULL")
  end
  if issue_id then
    selector:add_where{ "issue_id = ? ",  issue_id }
  else
    selector:add_where("issue_id ISNULL ")
  end
  return selector:exec()
end

function Delegation:selector_for_broken(member_id)
  return Delegation:new_selector()
    :left_join("issue", nil, "issue.id = delegation.issue_id")
    :add_where("issue.id ISNULL OR issue.closed ISNULL")
    :join("member", nil, "delegation.trustee_id = member.id")
    :add_where{"delegation.truster_id = ?", member_id}
    :add_where{"member.active = 'f' OR (member.last_activity IS NULL OR age(member.last_activity) > ?::interval)", config.delegation_warning_time }
end

function Delegation:delegations_to_check_for_member_id(member_id, for_update)

  Member:new_selector():add_where({ "id = ?", member_id }):for_update():exec()
  
  local selector =  Delegation:new_selector()
    :add_field("member.name", "member_name")
    :add_field("unit.name", "unit_name")
    :add_field("area.name", "area_name")
    :left_join("area", nil, "area.active AND area.id = delegation.area_id")
    :join("unit", nil, "unit.active AND (unit.id = delegation.unit_id OR unit.id = area.unit_id)")
    :left_join("member", nil, "member.id = delegation.trustee_id")
    :add_where({ "delegation.truster_id = ?", member_id })
    :add_order_by("unit.name, area.name NULLS FIRST")
    
  if for_update then
    selector:for_update_of("delegation")
  end
    
  return selector:exec()
  
end 