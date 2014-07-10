ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHeadWhatCanIDo()

  if app.session.member then
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to know whats going on" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = _"take a look on the issues (see left)" }
        ui.tag { tag = "li", content = _"by default only those issues are shown, for which your are eligible to participate (change filters on top of the list)" }
      end } 
    end )
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to stay informed" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = function ()
          ui.tag{ content = _"check your " }
          ui.link{
            module = "member", view = "settings_notification",
            params = { return_to = "home" },
            text = _"notifications settings"
          }
        end }
        ui.tag { tag = "li", content = function ()
          ui.tag{ content = _"subscribe subject areas or add your interested to issues and you will be notified about changes (follow the instruction on the area or issue page)" }
        end }
      end } 
    end )
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to start a new initiative" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = _"open the appropriate subject area for your issue and follow the instruction on that page." }
      end } 
    end )
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to delegate my vote" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = _"open the organizational unit, subject area or issue you like to delegate and follow the instruction on that page." }
      end } 
    end )
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to take a look at other organizational units" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = function ()
          ui.link{
            module = "unit", view = "list",
            text = _"show all units"
          }
        end }
      end } 
    end )
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"I want to learn more about LiquidFeedback" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = function()
          ui.link { module = "help", view = "introduction", content = _"structured discussion" }
        end }
        ui.tag { tag = "li", content = function()
          ui.link { module = "help", view = "introduction", content = _"4 phases of a decision" }
        end }
        ui.tag { tag = "li", content = function()
          ui.link { module = "help", view = "introduction", content = _"vote delegation" }
        end }
        ui.tag { tag = "li", content = function()
          ui.link { module = "help", view = "introduction", content = _"preference voting" }
        end }
      end } 
    end )
  end 

end )
