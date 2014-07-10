if config.motd_intern then
  slot.select("motd", function()
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(config.motd_intern)
      end
    }
  end )
end
