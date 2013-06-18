function ui.filters(args)
ui.container{
  attr = { class = "filter_menu_head" },
  content = function()
local el_id = ui.create_unique_id()
      for idx, filter in ipairs(args) do
        local filter_name = filter.name or "filter"
  ui.tag{
    tag = "ul",
    attr = { id = "filter_menu" .. filter.name, class = "filter_menu" },
    content = function()
        local current_option = atom.string:load(cgi.params[filter_name])
        if not current_option then
          current_option = param.get(filter_name)
        end
        local current_option_valid = false
        for idx, option in ipairs(filter) do
          if current_option == option.name then
            current_option_valid = true
          end
        end
        if not current_option or #current_option == 0 or not current_option_valid then
          current_option = filter[1].name
        end
        local id     = param.get_id_cgi()
        local params = param.get_all_cgi()
        ui.tag{
          tag = "li",
          attr = {},
          content = function()
            slot.put(filter.label)
            for idx, option in ipairs(filter) do
              params[filter_name] = option.name
              local attr = {}
              if current_option == option.name then
                attr.class = "active"
                option.selector_modifier(args.selector)
                ui.link{
                  attr    = attr,
                  module  = request.get_module(),
                  view    = request.get_view(),
                  id      = id,
                  params  = params,
                  text    = option.label,
                  partial = {
                    params = {
                      [filter_name] = option.name
                    }
                  }
                }
      ui.tag{
        tag = "ul",
        attr = { class = "filter_menu_sub" },
        content = function()
            slot.put(filter.label)
            for idx, option in ipairs(filter) do
        ui.tag{
          tag = "li",
          attr = { class = "ui_filter_head_sub" },
          content = function()
              params[filter_name] = option.name
              local attr = {}
              if current_option == option.name then
                attr.class = "active"
              end
              if idx > 1 then
                slot.put(" ")
              end
              ui.link{
                attr    = attr,
                module  = request.get_module(),
                view    = request.get_view(),
                id      = id,
                params  = params,
                text    = option.label,
                partial = {
                  params = {
                    [filter_name] = option.name
                  }
                }
              }
            end
        }
        end
      end
  }
              end
            end
          end
        }
      end
  }
  end
end
}
  ui.container{
    attr = { class = "ui_filter_content" },
    content = function()
      args.content()
    end
  }
end
