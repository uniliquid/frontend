local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))
local tmp = db:query({ "SELECT text_entries_left FROM member_contingent_left WHERE member_id = ? AND polling = ?", app.session.member.id, initiative.polling }, "opt_object")
if tmp and tmp.text_entries_left and tmp.text_entries_left < 1 then
  slot.put_into("error", _"Sorry, you have reached your personal flood limit. Please be slower...")
  return false
end

if not app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id) then
  error("access denied")
end


local name = param.get("name")
local name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"This title is really too short!")
  return false
end

local formatting_engine = param.get("formatting_engine")

local formatting_engine_valid = false
for fe, dummy in pairs(config.formatting_engine_executeables) do
  if formatting_engine == fe then
    formatting_engine_valid = true
  end
end
if not formatting_engine_valid then
  error("invalid formatting engine!")
end

if param.get("preview") then
  return false
end

local argument = Argument:new()
argument.side              = param.get("side")
argument.author_id         = app.session.member.id
argument.name              = name
argument.formatting_engine = formatting_engine
param.update(argument, "content", "initiative_id")
argument:save()

-- TODO important m1 selectors returning result _SET_!
local issue = argument.initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed!")
  return false
--elseif issue.fully_frozen then
--  slot.put_into("error", _"Voting for this issue has already begun!")
--  return false
end

-- positive rating
local rating = Rating:new()
rating.issue_id      = issue.id
rating.initiative_id = initiative.id
rating.argument_id   = argument.id
rating.member_id     = app.session.member.id
rating:save()

slot.put_into("notice", _"Your argument has been added.")
