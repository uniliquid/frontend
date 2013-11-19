ui.tag{ tag = "ul", content = function()

  if app.session.member_id then
    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _"Display settings",
        module = 'member',
        view = 'settings_display'
      }
    end }
  end
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"Voting rights log",
        external = "/static/hourly.php"
      }
      
    end }
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"Initiative style sheet",
        external = "https://wiki.piratenpartei.at/wiki/AG:Liquid/Antragsformatvorlage"
      }
      
    end }
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"Policies",
        external = "/policy/list.html"
      }
      
    end }
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"Accreditation",
        external = "https://wiki.piratenpartei.at/wiki/AG:Liquid/Akkreditierungsbefugte"
      }
      
    end }
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"FAQ",
        external = "https://wiki.piratenpartei.at/wiki/AG:Liquid/FAQ"
      }
      
    end }
    ui.tag{ tag = "li", content = function()

      ui.link{
        text = _"Tutorial",
        external = "https://wiki.piratenpartei.at/wiki/AG:Liquid/Tutorial"
      }
      
    end }

end }

