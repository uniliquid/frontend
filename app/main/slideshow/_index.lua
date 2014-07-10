local unit = param.get( "unit", "table" )
local area = param.get( "area", "table" )

local args = {
  unit_id = unit and unit.id or nil,
  area_id = area and area.id or nil
}

local lastWinner = Initiative:getLastWinner( args )
local lastLooser = Initiative:getLastLoser( args )
local nextEndingVoting = Initiative:getNextEndingVoting( args )
local nextEndingVerification = Initiative:getNextEndingVerification( args )
local nextEndingDiscussion = Initiative:getNextEndingDiscussion( args )
local bestInAdmission = Initiative:getBestInAdmission( args )

local slides = { }

if lastWinner then
  slides[#slides+1] = {
    title = _"Latest approved issue",
    initiative = lastWinner
  }
end

if lastLooser then
  slides[#slides+1] = {
    title = _"Latest disapproved issue",
    initiative = lastLooser
  }
end

if nextEndingVoting then
  slides[#slides+1] = {
    title = _("Voting #{time_info}", { time_info = nextEndingVoting.issue.state_time_text }),
    initiative = nextEndingVoting
  }
end

if nextEndingVerification then
  slides[#slides+1] = {
    title = _("Verification #{time_info}", { time_info = nextEndingVerification.issue.state_time_text }),
    initiative = nextEndingVerification
  }
end

if nextEndingDiscussion then
  slides[#slides+1] = {
    title = _("Discussion #{time_info}", { time_info = nextEndingDiscussion.issue.state_time_text }),
    initiative = nextEndingDiscussion
  }
end

if bestInAdmission then
  slides[#slides+1] = {
    title = _"Best not admitted initiative",
    initiative = bestInAdmission
  }
end

execute.view { 
  module = "slideshow", view = "_slideshow", params = {
    slides = slides
  }
}
