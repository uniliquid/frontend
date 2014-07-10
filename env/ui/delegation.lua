function ui.delegation(to_member_id, to_member_name)
  local text = _"delegates to"
  ui.image{
    attr = { class = "delegation_arrow", alt = text, title = text },
    static = "delegation_arrow_24_horizontal.png"
  }

  if to_member_id and to_member_name then
    execute.view{
      module = "member_image", view = "_show", params = {
        member_id = to_member_id, 
        class = "micro_avatar", 
        image_type = "avatar",
        popup_text = to_member_name,
        show_dummy = true
      }
    }
  end
end