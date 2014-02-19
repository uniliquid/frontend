slot.select('navigation', function()

if config.landing_page then
  ui.link{
    content = function()
      ui.image{ static = "favicon.ico" }
      ui.tag{ attr = { class = "logo" }, content = config.instance_name }
    end,
    external = "/"
  }
  ui.link{
    content = function()
      ui.image{ static = "icons/16/world.png" }
      ui.tag{ content = _"Overview" }
    end,
    module = 'index',
    view   = 'index'
  }
else
  ui.link{
    content = function()
      ui.image{ static = "favicon.ico" }
      ui.tag{ attr = { class = "logo" }, content = config.instance_name }
    end,
    module = 'index',
    view   = 'index'
  }
end
  
  if app.session:has_access("anonymous") then

    ui.link{
      content = function()
        ui.image{ static = "icons/16/magnifier.png" }
        ui.tag{ content = _"Search" }
      end,
      module = 'index',
      view   = 'search'
    }

    if app.session.member == nil then
      ui.link{
        content = function()
          ui.image{ static = "icons/16/key.png" }
          ui.tag{ content = _"Login" }
        end,
        module = 'index',
        view   = 'login',
        params = {
          redirect_module = request.get_module(),
          redirect_view = request.get_view(),
          redirect_id = param.get_id()
        }
      }
    elseif config.voting_rights_management then
      ui.link{
        content = function()
          ui.image{ static = "icons/16/pencil.png" }
          ui.tag{ content = _"My voting rights" }
        end,
        module = 'member',
        view   = 'rights'
      }
    end
    
  end

  if app.session.member == nil and config.register_without_invite_code then
    ui.link{
      content = function()
        ui.image{ static = "icons/16/user_add.png" }
        ui.tag{ content = _"Registration" }
      end,
      module = 'index',
      view   = 'register'
    }
  end

  ui.tag{ 
    tag = "ul",
    attr = { id = "link_menu" },
    content = function()
    ui.tag{ 
        tag = "li",
        content = function()
          ui.link{
            module = "index",
            view = "linkmenu",
            content = function()
              ui.image{ static = "icons/16/page_white_magnify.png" }
              ui.tag{ content = _"Important Links" }
            end
          }
          execute.view{ module = "index", view = "_linkmenu" }
        end
      }
    end
  }

end
end)

slot.select('navigation_right', function()
  ui.tag{ 
    tag = "ul",
    attr = { id = "member_menu" },
    content = function()
    ui.tag{ 
        tag = "li",
        content = function()
          ui.link{
            module = "index",
            view = "menu",
            content = function()
              if app.session.member_id then
                execute.view{
                  module = "member_image",
                  view = "_show",
                  params = {
                    member = app.session.member,
                    image_type = "avatar",
                    show_dummy = true,
                    class = "micro_avatar",
                  }
                }
                ui.tag{ content = app.session.member.name }
              else
                ui.image{ static = "icons/16/user.png" }
                ui.tag{ content = _"Select language" }
              end
            end
          }
          execute.view{ module = "index", view = "_menu" }
        end
      }
    end
  }
end)

slot.select("footer", function()
  if app.session.member_id and app.session.member.admin then
    ui.link{
      text   = _"Admin",
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
end)

execute.inner()
