ui.title(_"About site")

ui.section( function()

  ui.sectionHead( function()
    ui.heading{ level = 1, content = _"About site" }
  end )

  ui.sectionRow( function()

    ui.heading{ level = 3, content = _"This service is provided by:" }
    slot.put(config.app_service_provider)

  end )

  ui.sectionRow( function()

    ui.heading{ level = 3, content = _"This service is provided using the following software components:" }

    local tmp = {
      {
        name = "LiquidFeedback Frontend",
        url = "http://www.public-software-group.org/liquid_feedback",
        version = config.app_version,
        license = "MIT/X11",
        license_url = "http://www.public-software-group.org/licenses"
      },
      {
        name = "LiquidFeedback Core",
        url = "http://www.public-software-group.org/liquid_feedback",
        version = db:query("SELECT * from liquid_feedback_version;")[1].string,
        license = "MIT/X11",
        license_url = "http://www.public-software-group.org/licenses"
      },
      {
        name = "WebMCP",
        url = "http://www.public-software-group.org/webmcp",
        version = _WEBMCP_VERSION,
        license = "MIT/X11",
        license_url = "http://www.public-software-group.org/licenses"
      },
      {
        name = "Lua",
        url = "http://www.lua.org",
        version = _VERSION:gsub("Lua ", ""),
        license = "MIT/X11",
        license_url = "http://www.lua.org/license.html"
      },
      {
        name = "PostgreSQL",
        url = "http://www.postgresql.org/",
        version = db:query("SELECT version();")[1].version:gsub("PostgreSQL ", ""):gsub("on.*", ""),
        license = "BSD",
        license_url = "http://www.postgresql.org/about/licence"
      },
    }

    ui.list{
      records = tmp,
      columns = {
        {
          content = function(record) 
            ui.link{
              content = record.name,
              external = record.url
            }
          end
        },
        {
          content = function(record) ui.field.text{ value = record.version } end
        },
        {
          content = function(record) 
            ui.link{
              content = record.license,
              external = record.license_url
            }
          end

        }
      }
    }

  end )

  ui.sectionRow( function()
    ui.heading{ level = 3, content = "3rd party license information:" }
    slot.put('Some of the icons used in Liquid Feedback are from <a href="http://www.famfamfam.com/lab/icons/silk/">Silk icon set 1.3</a> by Mark James. His work is licensed under a <a href="http://creativecommons.org/licenses/by/2.5/">Creative Commons Attribution 2.5 License.</a>')

  end )
end )
