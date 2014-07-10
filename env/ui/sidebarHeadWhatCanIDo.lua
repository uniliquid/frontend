function ui.sidebarHeadWhatCanIDo ()
  ui.sidebarHead( function ()
    --ui.image{ attr = { class = "right icon24" }, static = "icons/48/info.png" }
    ui.heading {
      level = 2, content = _"What can I do here?"
    }
  end )
  if not app.session.member then
    ui.sidebarSection( function()
      ui.heading { level = 3, content = _"Closed user group" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = function ()
          ui.link {
            content = _"login to participate",
            module = "index", view = "login"
          }
        end }
      end } 
    end )
  end
end
