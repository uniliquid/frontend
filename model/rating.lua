Rating = mondelefant.new_class()
Rating.table = 'rating'
Rating.primary_key = { "member_id", "argument_id" }

Rating:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Rating:add_reference{
  mode          = 'm1',
  to            = "Argument",
  this_key      = 'argument_id',
  that_key      = 'id',
  ref           = 'argument',
}

Rating:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Rating:by_pk(member_id, argument_id)
  return self:new_selector()
    :add_where{ "member_id = ?",     member_id }
    :add_where{ "argument_id = ?", argument_id }
    :optional_object_mode()
    :exec()
end
