slot.select ( 'instance_name', function ()
  slot.put ( encode.html ( config.instance_name ) )
end)

  
slot.select ( 'navigation_right', function ()

  if app.session:has_access ("anonymous") and not (app.session.needs_delegation_check) then
  
    ui.form {
      attr = { class = "inline search" },
      method = "get",
      module = "index", view   = "search",
      content = function ()
        
        ui.field.text {
          attr = { placeholder = "search" },
          name = "q"
        }
        
      end 
    }

    ui.link {
      attr = { class = "searchLink" },
      module = "index", view = "search", content = function ()
        ui.image { static = "icons/16/magnifier.png" }
      end
    }
    
  end
  
  if app.session.member == nil then
    
    slot.put ( " " )
    
    ui.link {
      text   = _"Login",
      module = 'index',
      view   = 'login',
      params = {
        redirect_module = request.get_module(),
        redirect_view = request.get_view(),
        redirect_id = param.get_id()
      }
    }
    
    slot.put ( " " )
    
    ui.link {
      text   = _"Registration",
      module = 'index',
      view   = 'register'
    }

  end
  
  
  if app.session.member then
  
    slot.put ( " " )
    
    ui.tag { attr = { id = "member_menu" }, content = function()
      util.micro_avatar(app.session.member)
    end }
    
  end -- if app.session.member
    
end)

-- show notifications about things the user should take care of
if app.session.member then
  execute.view{
    module = "index", view = "_sidebar_notifications", params = {
      mode = "link"
    }
  }
end

slot.select ("footer", function ()
  if app.session.member_id and app.session.member.admin then
    ui.link {
      text   = _"System settings",
      module = 'admin',
      view   = 'index'
    }
    slot.put(" &middot; ")
  end
  ui.link{
    text   = _"About site",
    module = 'index',
    view   = 'about'
  }
  if config.use_terms then
    slot.put(" &middot; ")
    ui.link{
      text   = _"Use terms",
      module = 'index',
      view   = 'usage_terms'
    }
  end
  slot.put(" &middot; ")
  ui.link{
    text   = _"LiquidFeedback",
    external = "http://www.public-software-group.org/liquid_feedback"
  }
end)

execute.inner()
