function getIssuesSelector()
  return Issue:new_selector()
    :add_order_by([[
      coalesce(
        issue.fully_frozen + issue.voting_time, 
        issue.half_frozen + issue.verification_time, 
        issue.accepted + issue.discussion_time, 
        issue.created + issue.admission_time
      ) - now()
    ]])
end

--[[
ui.title( function ()
  ui.link { attr = { class = "home" }, module = "index", view = "index", text = _"Home" }
end)
--]]

ui.title()

if false then
slot.select ( "tabs", function ()
  
  ui.tag {
    attr = { onclick = "showTab(0);" },
    content = "units",
  }
  slot.put ( " " )
  ui.tag {
    attr = { onclick = "showTab(1);" },
    content = "timeline"
  }
  slot.put ( " " )
  ui.tag {
    attr = { onclick = "showTab(2);" },
    content = "what"
  }
  slot.put ( " " )
  ui.tag {
    attr = { onclick = "showTab(3);" },
    content = "members"
  }
  
end )

ui.script { script = [[
  
  var tabs = ["tab1", "main", "tab2", "tab3"]
  var currentId;
  
  function showTab(id) {
    var tabId = tabs[id];
    $('.tab').hide();
    $('.main').hide();
    $('.' + tabId).show();
    currentId = id;
  };
  
  showTab(0);
  
  $(function(){
    // Bind the swipeHandler callback function to the swipe event on div.box
    $( "body" ).on( "swiperight", function swipeHandler( event ) {
      newId = currentId - 1;
      if (newId < 0) return;
      showTab(newId);
    } )
    $( "body" ).on( "swipeleft", function swipeHandler( event ) {
      newId = currentId + 1;
      if (newId > tabs.length - 1) return;
      showTab(newId);
    } )
  });
  
]]}
end


if app.session.member then
  execute.view{ module = "index", view = "_sidebar_motd_intern" }
else
  execute.view{ module = "index", view = "_sidebar_motd_public" }
end

if app.session:has_access("anonymous") then
  -- show the units the member has voting privileges for
  execute.view {
    module = "index", view = "_sidebar_units", params = {
      member = app.session.member
    }
  }
end

-- show the user what can be done
execute.view { module = "index", view = "_sidebar_whatcanido" }

-- show active members
if app.session:has_access("all_pseudonymous") then
  execute.view{ module = "index", view = "_sidebar_members" }
end

if app.session:has_access("anonymous") then
  
  if not app.session.member then
--    execute.view {
--      module = "slideshow", view = "_index"
--    }
  end
  
  execute.view {
    module = "issue", view = "_list2", params = { }
  }
  
end -- if app.session:has_access "anonymous"