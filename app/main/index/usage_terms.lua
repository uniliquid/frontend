ui.title(_"Terms of use")

ui.section( function()

  ui.sectionHead( function()
    ui.heading { level = 1, content = _"Terms of use" }
  end )

  ui.sectionRow( function()

    ui.container{
      attr = { class = "wiki use_terms" },
      content = function()
        slot.put(config.use_terms)
      end
    }

  end )
end )