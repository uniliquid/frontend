if config.motd_public then
  slot.select("motd", function()
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(config.motd_public)
      end
    }
  end )
end
