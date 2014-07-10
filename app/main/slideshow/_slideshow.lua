local slides = param.get( "slides", "table" )

local show_slides = {}

for i, slide in ipairs( slides ) do
  
  if slide.initiative then
    show_slides[ #show_slides + 1 ] = slide
  end
  
end
  
slot.select( "slideshow", function ()
  
  ui.container { attr = { class = "slideshow" }, content = function ()
    
    for i, slide in ipairs( show_slides ) do
      
      if slide.initiative.issue.closed then
        view = "finished"
      elseif slide.initiative.issue.fully_frozen then
        view = "voting"
      elseif slide.initiative.issue.half_frozen then
        view = "verification"
      elseif slide.initiative.issue.admitted then
        view = "discussion"
      else
        view = "admission"
      end
      
      ui.container { attr = { class = "slide slide-" .. i }, content = function ()

        if slide.initiative.issue.closed then
          util.initiative_pie(slide.initiative, 150)
        end

        ui.container {
          attr = { class = "slideshowTitle" },
          content = slide.title
        }

        execute.view {
          module = "initiative", view = "_list_element", params = {
            initiative = slide.initiative
          }
        }

      end }
      
    end

    
  end }
    
end )

ui.script{ script = [[

var slideshowCurrent = 0;
var slideshowCount = ]] .. #show_slides .. [[ ;
function slideshowShowSlide(i) {
  $(".slideshow .slide").slideUp();
  $(".slideshow .slide-" + i).slideDown();
  slideshowCurrent = i;
}

function slideshowShowNext() {
  var next = slideshowCurrent + 1;
  if (next > slideshowCount) {
    next = 1;
  }
  slideshowShowSlide(next);
  window.setTimeout(slideshowShowNext, 7500);
}

slideshowShowNext();

  
  ]]}