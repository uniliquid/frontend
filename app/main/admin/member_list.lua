local search = param.get("search")
local search_admin     = param.get("search_admin",     atom.integer)
local search_activated = param.get("search_activated", atom.integer)
local search_locked    = param.get("search_locked",    atom.integer)
local search_active    = param.get("search_active",    atom.integer)

local order = param.get("order")
local desc  = param.get("desc", atom.integer)
if not order then
  order = "id"
end

ui.title(_"Member list")

--[[ui.actions(function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Register new member",
    module = "admin",
    view = "member_edit",
    params = {
      search           = search,
      search_admin     = search_admin,
      search_activated = search_activated,
      search_locked    = search_locked,
      search_active    = search_active,
      order            = order,
      desc             = desc,
      page             = param.get("page", atom.integer)
    }
  }
end)]]


ui.form{
  module = "admin", view = "member_list",
  -- Form method should be GET, but WebMCP adds some unwanted parameters, so we use POST.
  attr = { class = "member_list_form" },
  content = function()
  
    ui.field.text{
      label = _"Search:",
      name = "search",
      value = search
    }
    ui.field.select{
      name = "search_admin",
      foreign_records  = {
        {id = 0, name = "---" .. _"Admin" .. "?---"},
        {id = 1, name = _"Admin"},
        {id = 2, name = _"Not admin"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_admin
    }

    ui.field.select{
      name = "search_activated",
      foreign_records  = {
        {id = 0, name = "---" .. _"Activated" .. "?---"},
        {id = 1, name = _"Activated"},
        {id = 2, name = _"Not activated"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_activated
    }

    ui.field.select{
      name = "search_locked",
      foreign_records  = {
        {id = 0, name = "---" .. _"Locked" .. "?---"},
        {id = 1, name = _"Locked"},
        {id = 2, name = _"Not locked"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_locked
    }

    ui.field.select{
      name = "search_active",
      foreign_records  = {
        {id = 0, name = "---" .. _"Active" .. "?---"},
        {id = 1, name = _"Active"},
        {id = 2, name = _"Not active"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_active
    }

    ui.submit{ value = _"Search / Filter" }

    ui.field.hidden{ name = "order", value = order }
    ui.field.hidden{ name = "desc",  value = desc }

  end
}
local admin = nil
if search_admin == 1 then
  admin = true
elseif search_admin == 2 then
  admin = false
end
local locked = nil
if search_locked == 1 then
  locked = true
elseif search_locked == 2 then
  locked = false
end
local active = nil
if search_active == 1 then
  active = true
elseif search_active == 2 then
  active = false
end
local members_selector = Member:build_selector{
  admin_search = search,
  admin     = admin,
  locked    = locked,
  active    = active
}
local activated = nil
if search_activated == 1 then
  members_selector:add_where("activated NOTNULL")
elseif search_activated == 2 then
  members_selector:add_where("activated ISNULL")
end
local params_tpl = {
  search           = search,
  search_admin     = search_admin,
  search_activated = search_activated,
  search_locked    = search_locked,
  search_active    = search_active
}

if desc then
  members_selector:add_order_by(order .. " DESC")
else
  members_selector:add_order_by(order)
end
 
ui.tag{
  tag = "p",
  content = _("#{count} members found:", { count = members_selector:count() })
}
ui.paginate{
  selector = members_selector,
  per_page = 30,
  content = function() 
    ui.list{
      records = members_selector:exec(),
      columns = {
        {
          field_attr = { style = "text-align: right;" },
          name = "id",
          label = function()
            local params = params_tpl
            params['order'] = "id"
            if not desc then
              params['desc'] = 1
            end
            ui.link{
              text = _"Id",
              module = "admin",
              view = "member_list",
              params = params
            }
            if order == "id" then
              if desc then
                slot.put("&uarr;")
              else
                slot.put("&darr;")
              end
            end
          end
        },
        {
          name = "identification",
          label = function()
            local params = params_tpl
            params['order'] = "identification"
            if not desc then
              params['desc'] = 1
            end
            ui.link{
              text = _"Identification",
              module = "admin",
              view = "member_list",
              params = params
            }
            if order == "identification" then
              if desc then
                slot.put("&uarr;")
              else
                slot.put("&darr;")
              end
            end
          end
        },
        {
          label = function()
            local params = params_tpl
            params['order'] = "name"
            if not desc then
              params['desc'] = 1
            end
            ui.link{
              text = _"Screen name",
              module = "admin",
              view = "member_list",
              params = params
            }
            if order == "name" then
              if desc then
                slot.put("&uarr;")
              else
                slot.put("&darr;")
              end
            end
          end,
          content = function(record)
            if (record.name) then
              ui.link{
                text = record.name,
                module = "member",
                view = "show",
                id = record.id
              }
            end
          end
        },
        {
          label = _"Admin?",
          content = function(record)
            if record.admin then
              ui.field.text{ value = _"Admin" }
            end
          end
        },
        {
          content = function(record)
            if record.locked then
              ui.field.text{ value = _"Locked" }
            end
          end
        },
        {
          content = function(record)
            if not record.activated then
              ui.field.text{ value = _"Not activated" }
            elseif not record.active then
              ui.field.text{ value = _"Inactive" }
            else
              ui.field.text{ value = _"Active" }
            end
          end
        },
        {
          content = function(record)
            ui.link{
              attr = { class = "action admin_only" },
              text = _"Edit",
              module = "admin",
              view = "member_edit",
              id = record.id,
              params = {
                search           = search,
                search_admin     = search_admin,
                search_activated = search_activated,
                search_locked    = search_locked,
                search_active    = search_active,
                order            = order,
                desc             = desc,
                page             = param.get("page", atom.integer)
              }
            }
          end
        }
      }
    }
  end
}
