Policy = mondelefant.new_class()
Policy.table = 'policy'

Policy:add_reference{
  mode          = '1m',
  to            = "Issue",
  this_key      = 'id',
  that_key      = 'policy_id',
  ref           = 'issues',
  back_ref      = 'policy'
}

function Policy:build_selector(args)
  local selector = self:new_selector()
  if args.active ~= nil then
    selector:add_where{ "active = ?", args.active }
  end
  selector:add_order_by("index")
  return selector
end

function Policy.object_get:free_timeable()
  if self.discussion_time == nil and self.verification_time == nil and self.voting_time == nil then
    return true
  end
  return false
end