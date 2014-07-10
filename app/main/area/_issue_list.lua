local issues_selector = param.get("issues_selector", "table")
local phase = param.get("phase")

if phase == "admission" then
  headline = _"Issues in admission phase"
elseif phase == "discussion" then
  headline = _"Issues in discussion phase"
elseif phase == "verification" then
  headline = _"Issues in verification phase"
elseif phase == "voting" then
  headline = _"Issues in voting phase"
elseif phase == "closed" then
  headline = _"Closed issues"
end
  
ui.heading { level = "1", content = headline }

local issues = issues_selector:exec()

ui.tag {
  tag = "ul",
  attr = { class = { "issues" } },
  content = function ()

    for i, issue in ipairs(issues) do
      
      ui.tag { tag = "li", content = function ()
        ui.heading { level = 2, content = issue.name }
        
        execute.view { 
          module = "initiative", view = "_list", params = {
            initiatives = issue.initiatives,
            state = phase
          }
        }
        
        slot.put ( '<hr class="nice" />' )
        
      end }
      
    end
  end
}