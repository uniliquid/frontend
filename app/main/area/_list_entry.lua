local area = param.get("area", "table")
local member = param.get("member", "table")

ui.container{ attr = { class = "area" }, content = function()

  execute.view{ module = "area", view = "_head", params = { area = area, hide_unit = true, show_content = true, member = member } }
  
  local style = ""
  if area.name == 'Sandkasten/Spielwiese' or area.name == 'Sandkasten' or area.name == 'Spielwiese' then
    style = "background: linear-gradient(rgb(251, 251, 251), rgb(237, 237, 237)) repeat scroll 0% 0% rgb(237, 237, 237);"
  end

  ui.container{ attr = { class = "content", style = style }, content = function()
    ui.tag{ content = function()
       ui.image{ attr = { class = "spaceicon" }, static = "icons/16/page_white.png" }
      slot.put(_"Issues:")
    end
    }
    slot.put(" ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/new.png" },
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "new" },
      text = _("#{count} new", { count = area.issues_new_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/comments.png" },
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "accepted" },
      text = _("#{count} in discussion", { count = area.issues_discussion_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/lock.png" },
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "half_frozen" },
      text = _("#{count} in verification", { count = area.issues_frozen_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/email_open_image.png" },
      module = "area", view = "show", id = area.id, params = { tab = "open", filter = "frozen" },
      text = _("#{count} in voting", { count = area.issues_voting_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/chart_bar.png" },
      module = "area", view = "show", id = area.id, params = { tab = "closed", filter = "finished" },
      text = _("#{count} finished", { count = area.issues_finished_count }) 
    }
    slot.put(" &middot; ")
    ui.link{ 
      image = { attr = { class = "spaceicon" }, static = "icons/16/bin.png" },
      module = "area", view = "show", id = area.id, params = { tab = "closed", filter = "canceled" },
      text = _("#{count} canceled", { count = area.issues_canceled_count }) 
    }
  end }

end }
