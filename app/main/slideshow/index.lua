local unit = param.get( "unit", "table" )
local area = param.get( "area", "table" )

local args = {
  unit_id = unit and unit.id or nil,
  area_id = area and area.id or nil
}

local issues = Issue:new_selector():exec()


local slides = {}

for i, issue in ipairs( issues ) do
  slides[ #slides+1 ] = {
    title = issue.state_name,
    initiative = issue.initiatives[1]
  }
end


execute.view { 
  module = "slideshow", view = "_slideshow", params = {
    slides = slides
  }
}