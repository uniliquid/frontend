Rights = mondelefant.new_class()
Rights.table = 'votingrights'
Rights.primary_key = { "member_id", "key" }
Interest:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Rights:by_pk(member_id, key)
  return self:new_selector()
    :add_where{ "member_id = ? AND key = ?", member_id, key }
    :optional_object_mode()
    :exec()
end

function Rights:by_kv(key, value)
  return self:new_selector()
    :add_where{ "key = ? AND value = ?", key, value }
    :optional_object_mode()
    :exec()
end
