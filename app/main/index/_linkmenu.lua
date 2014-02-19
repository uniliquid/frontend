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
  for i, link in ipairs(config.linkmenu) do
    ui.tag{ tag = "li", content = function()
      ui.link{
        text = link.text
        external = link.external
      }
    end }
  end

end }

