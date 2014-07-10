if app.session.member then
  ui.title(_"Notifications")
    
  ui.section( function() 

    ui.sectionHead( function()
      ui.heading{ level = 1, content = _"Notifications" }
    end )
  
    ui.sectionRow( function()
      execute.view { module = "index", view = "_sidebar_notifications" }
    end ) 
  end )
end
