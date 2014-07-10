Battle = mondelefant.new_class()
Battle.table = 'battle'

function Battle:getByInitiativeIds(winning_id, losing_id)
  local selector = Battle:new_selector()
  selector:add_where { "winning_initiative_id = ?", winning_id }
  selector:add_where { "losing_initiative_id = ?", losing_id }
  selector:optional_object_mode()
  return selector:exec()
end
