function util.initiative_pie(initiative, d, gap)
  if not initiative.issue.closed or not initiative.admitted then
    return
  end
  
  if initiative.issue.voter_count == 0 or initiative.positive_votes == nil or initiative.negative_votes == nil then
    return
  end
  
  local first_preference_votes = initiative.first_preference_votes
  if first_preference_votes == nil then
    first_preference_votes = 0
  end
    
  local d = d or 100
  local gap = gap or d / 20
  
  local r = d/2
  local r_circle = r - gap
  
  local function circle(p)
    return
      gap + 2 * r_circle * ( 1 + math.sin( 2 * math.pi * p ) ) / 2,
      gap + 2 * r_circle * ( 1 - math.cos( 2 * math.pi * p ) ) / 2
  end
  
  local function getpath(start, stop)
    local start_x, start_y = circle(start)
    local stop_x, stop_y = circle(stop)
    local large = stop - start > 0.5 and "1" or "0"
    return "M" .. r .. "," .. r .. " "
        .. "L" .. start_x .. ",".. start_y .. " " .. " "
        .. "A" .. r_circle .. "," .. r_circle .. " 0 " .. large .. ",1 " .. stop_x .. "," .. stop_y .. " "
        .. "z"
  end
  
  local function uniPie(color, content)
    ui.tag {
      tag = "svg",
      attr = {
        class = "initiative_pie",
        width = d .. "px",
        height = d .. "px",
      },
      content = function ()
        ui.tag { tag = "circle", attr = {
          cx=r, cy=r, r=r_circle, fill = color, stroke = "#fff", ["stroke-width"] = "2"
        }, content = function () ui.tag { tag = "title", content = content } end  }
      end
    }
  end
  
  local function piePiece(path, fill, content)
    ui.tag {
      tag = "path",
      attr = {
        d = path,
        fill = fill,
        stroke = "#fff",
        ["stroke-width"] = "2",
        ["stroke-linecap"] = "butt"
      }, 
      content = function ()
        ui.tag {
          tag = "title", 
          content = content
        }
      end  
    }
  end
  
  local function pie(args)
    local offset = args.offset or 0
    local list = {}
    local sum = 0
    for i, element in ipairs(args) do
      element.start = sum + offset
      list[#list+1] = element
      sum = sum + element.value
    end
    
    for i, element in ipairs(list) do
      if element.value == sum then
        uniPie(element.fill, _(element.label, { count = element.value } ))
        return
      end
    end
    ui.tag {
      tag = "svg",
      attr = {
        class = "initiative_pie",
        width = d .. "px",
        height = d .. "px"
      },
      content = function ()
        table.sort(list, function (a, b)
          return a.value < b.value
        end )
        for i, element in ipairs(list) do
          local path = getpath(element.start / sum, (element.start + element.value) / sum)
          local content = _(element.label, { count = element.value })
          piePiece(path, element.fill, content)
        end
      end
    }
  end
  
  local yes1 = first_preference_votes
  local yes = initiative.positive_votes - first_preference_votes
  local neutral = initiative.issue.voter_count - initiative.positive_votes - initiative.negative_votes
  local no = initiative.negative_votes
  
  local sum = yes1 + yes + neutral + no
  
  local q = initiative.issue.policy.direct_majority_num / initiative.issue.policy.direct_majority_den
      
  
  local maxrot = sum * 7 / 12 - no
  
  local offset = 0
  
  if maxrot > 0 then
    offset = math.min (
      maxrot, 
      no * ( 1 / ( 1 / q - 1 ) -1 ) / 2
    )
  end
    
  pie{
    { value = yes1,    fill = "#0a0", label = _"#{count} Yes, first choice" },
    { value = yes,     fill = "#6c6", label = _"#{count} Yes, alternative choice" },
    { value = neutral, fill = "#ccc", label = _"#{count} Neutral" },
    { value = no,      fill = "#c00", label = _"#{count} No" },
    offset = - offset
  }
    
end