local initiative = Initiative:by_id ( param.get_id() )
local member = app.session.member

if not initiative then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

local issue_info

if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
  issue_info = initiative.issue.member_info
end

execute.view {
  module = "issue", view = "_head", 
  params = {
    issue = initiative.issue,
    initiative = initiative,
    member = app.session.member
  }
}

if app.session.member_id then
  direct_supporter = initiative.issue.member_info.own_participation and initiative.member_info.supported
end

ui.script { script = [[
  function showTab(tabId) {
    $('.tab').hide();
    $('.main').hide();
    $('.main, .slot_extra .section').hide();
    $('.' + tabId).show();
    if (tabId == "main") $('.slot_extra .section').show();
  };
  showTab('main');
]]}

execute.view{ module = "issue", view = "_sidebar_state", params = {
  initiative = initiative
} }

execute.view { 
  module = "issue", view = "_sidebar_issue", 
  params = {
    issue = initiative.issue,
    highlight_initiative_id = initiative.id
  }
}

execute.view {
  module = "issue", view = "_sidebar_whatcanido",
  params = { initiative = initiative }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = initiative.issue, initiative = initiative
  }
}

ui.section( function ()
  execute.view{
    module = "initiative", view = "_head", params = {
      initiative = initiative
    }
  }

  if direct_supporter and not initiative.issue.closed then
    local supporter = app.session.member:get_reference_selector("supporters")
      :add_where{ "initiative_id = ?", initiative.id }
      :optional_object_mode()
      :exec()
      
    if supporter then

      local old_draft_id = supporter.draft_id
      local new_draft_id = initiative.current_draft.id
      
      if old_draft_id ~= new_draft_id then
        ui.sectionRow( "draft_updated_info", function ()
          ui.container{ 
            attr = { class = "info" },
            content = _"The draft of this initiative has been updated!"
          }
          slot.put(" ")
          ui.link{
            content = _"show differences",
            module = "draft",
            view = "diff",
            params = {
              old_draft_id = old_draft_id,
              new_draft_id = new_draft_id
            }
          }
          if not initiative.revoked then
            slot.put(" | ")
            ui.link{
              text   = _"refresh my support",
              module = "initiative",
              action = "add_support",
              id     = initiative.id,
              params = { draft_id = initiative.current_draft.id },
              routing = {
                default = {
                  mode = "redirect",
                  module = "initiative",
                  view = "show",
                  id = initiative.id
                }
              }
            }
            slot.put(" | ")
          end

          ui.link{
            text   = _"remove my support",
            module = "initiative",
            action = "remove_support",
            id     = initiative.id,
            routing = {
              default = {
                mode = "redirect",
                module = "initiative",
                view = "show",
                id = initiative.id
              }
            }
          }

        end )
      end
    end
  end
  

  ui.sectionRow( function ()
    ui.container {
      attr = { class = "draft" },
      content = function ()
        slot.put ( initiative.current_draft:get_content ( "html" ) )
      end
    }
  end )

end)

ui.link { attr = { name = "suggestions" }, text = "" }


ui.container {
  attr = { class = "section suggestions" },
  content = function ()

    if # ( initiative.suggestions ) > 0 then
  
      ui.sectionHead( function ()
        ui.heading { 
          level = 1, 
          content = _("Suggestions for improvement (#{count})", { count = # ( initiative.suggestions ) } ) 
        }
        ui.container { content = _"written and rated by the supportes of this initiative to improve the proposal and its reasons" }
      end )
      
      for i, suggestion in ipairs(initiative.suggestions) do
        
        local opinion = Opinion:by_pk(app.session.member_id, suggestion.id)

        local class = "sectionRow suggestion"
        if suggestion.id == param.get("suggestion_id", atom.number) then
          class = class .. " highlighted"
        end
        if member and not initiative.issue.fully_frozen and not initiative.issue.closed and initiative.member_info.supported then
          class = class .. " rateable"
        end
      
        
        ui.tag { tag = "div", attr = { class = class, id = "s" .. suggestion.id }, content = function ()

          if opinion then
            
            ui.container { attr = { class = "opinion"}, content = function()
              local class = ""
              local text = ""
              
              if opinion.degree == 2 then
                class = "must"
                text = _"must"
              elseif opinion.degree == 1 then
                class = "should"
                text = _"should"
              elseif opinion.degree == 0 then
                class = "neutral"
                text = _"neutral"
              elseif opinion.degree == -1 then
                class = "shouldnot"
                text = _"should not"
              elseif opinion.degree == -2 then
                class = "mustnot"
                text = _"must not"
              end
              
              ui.tag { 
                attr = { class = class }, 
                content = text 
              }
              
              slot.put ( " " )
              
              if 
                (opinion.degree > 0 and not opinion.fulfilled)
                or (opinion.degree < 0 and opinion.fulfilled)
              then
                ui.tag{ content = _"but" }
              else
                ui.tag{ content = _"and" }
              end
                
              slot.put ( " " )
              
              local class = ""
              local text = ""
              
              if opinion.fulfilled then
                class = "implemented"
                text = _"is implemented"
              else
                class = "notimplemented"
                text = _"is not implemented"
              end

              ui.tag { 
                attr = { class = class }, 
                content = text
              }

              if 
                (opinion.degree > 0 and not opinion.fulfilled)
                or (opinion.degree < 0 and opinion.fulfilled)
              then
                if math.abs(opinion.degree) > 1 then
                  slot.put(" !!")
                else
                  slot.put(" !")
                end
              else
                slot.put(" ✓")
              end

            end }

          end
          
          
          ui.link { attr = { name = "s" .. suggestion.id }, text = "" }
          ui.heading { level = 2, 
            attr = { class = "suggestionHead" },
            content = format.string(suggestion.name, {
            truncate_at = 160, truncate_suffix = true
          }) }
  

            local plus2  = (suggestion.plus2_unfulfilled_count or 0)
                            + (suggestion.plus2_fulfilled_count or 0)
            local plus1  = (suggestion.plus1_unfulfilled_count  or 0)
                            + (suggestion.plus1_fulfilled_count or 0)
            local minus1 = (suggestion.minus1_unfulfilled_count  or 0)
                            + (suggestion.minus1_fulfilled_count or 0)
            local minus2 = (suggestion.minus2_unfulfilled_count  or 0)
                            + (suggestion.minus2_fulfilled_count or 0)
            
            local with_opinion = plus2 + plus1 + minus1 + minus2

            local neutral = (suggestion.initiative.supporter_count or 0)
                            - with_opinion

            local neutral2 = with_opinion 
                              - (suggestion.plus2_fulfilled_count or 0)
                              - (suggestion.plus1_fulfilled_count or 0)
                              - (suggestion.minus1_fulfilled_count or 0)
                              - (suggestion.minus2_fulfilled_count or 0)
            
            ui.container { 
            attr = { class = "suggestionInfo" },
            content = function ()
              
              if with_opinion > 0 then
                ui.container { attr = { class = "suggestion-rating" }, content = function ()
                  ui.tag { content = _"collective rating:" }
                  slot.put("&nbsp;")
                  ui.bargraph{
                    max_value = suggestion.initiative.supporter_count,
                    width = 100,
                    bars = {
                      { color = "#0a0", value = plus2 },
                      { color = "#8a8", value = plus1 },
                      { color = "#eee", value = neutral },
                      { color = "#a88", value = minus1 },
                      { color = "#a00", value = minus2 },
                    }
                  }
                  slot.put(" | ")
                  ui.tag { content = _"implemented:" }
                  slot.put ( "&nbsp;" )
                  ui.bargraph{
                    max_value = with_opinion,
                    width = 100,
                    bars = {
                      { color = "#0a0", value = suggestion.plus2_fulfilled_count },
                      { color = "#8a8", value = suggestion.plus1_fulfilled_count },
                      { color = "#eee", value = neutral2 },
                      { color = "#a88", value = suggestion.minus1_fulfilled_count },
                      { color = "#a00", value = suggestion.minus2_fulfilled_count },
                    }
                  }
                end }
              end

              if app.session:has_access("authors_pseudonymous") then
                util.micro_avatar ( suggestion.author )
              else
                slot.put("<br />")
              end
              
              ui.container {
                attr = { class = "suggestion-text" },
                content = function ()
                  slot.put ( suggestion:get_content( "html" ) )

              if direct_supporter then
                
                ui.container {
                  attr = { class = "rating" },
                  content = function ()

                    if not opinion then
                      opinion = {}
                    end
                    ui.form { 
                      module = "opinion", action = "update", params = {
                        suggestion_id = suggestion.id
                      },
                      routing = { default = {
                        mode = "redirect", 
                        module = "initiative", view = "show", id = suggestion.initiative_id,
                        params = { suggestion_id = suggestion.id },
                        anchor = "s" .. suggestion.id -- TODO webmcp
                      } },
                      content = function ()
                      
                        
                        ui.heading { level = 3, content = _"Should the initiator implement this suggestion?" }
                        ui.container { content = function ()
                        
                          local active = opinion.degree == 2
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "degree", value = 2, 
                            id = "s" .. suggestion.id .. "_degree2",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_degree2",
                              class = active and "active-plus2" or nil,
                            },
                            content = _"must"
                          }
                          
                          local active = opinion.degree == 1
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "degree", value = 1,
                            id = "s" .. suggestion.id .. "_degree1",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_degree1",
                              class = active and "active-plus1" or nil,
                            },
                            content = _"should"
                          }

                          local active = not opinion.member_id
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "degree", value = 0,
                            id = "s" .. suggestion.id .. "_degree0",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_degree0",
                              class = active and "active-neutral" or nil,
                            },
                            content = _"neutral"
                          }

                          local active = opinion.degree == -1
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "degree", value = -1,
                            id = "s" .. suggestion.id .. "_degree-1",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_degree-1",
                              class = active and "active-minus1" or nil,
                            },
                            content = _"should not"
                          }

                          local active = opinion.degree == -2
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "degree", value = -2,
                            id = "s" .. suggestion.id .. "_degree-2",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_degree-2",
                              class = active and "active-minus2" or nil,
                            },
                            content = _"must not"
                          }
                        end }
                        
                        slot.put("<br />")

                        ui.heading { level = 3, content = _"Did the initiator implement this suggestion?" }
                        ui.container { content = function ()
                          local active = opinion.fulfilled == false
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "fulfilled", value = "false",
                            id = "s" .. suggestion.id .. "_notfulfilled",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_notfulfilled",
                              class = active and "active-notfulfilled" or nil,
                            },
                            content = _"No (not yet)"
                          }

                          local active = opinion.fulfilled
                          ui.tag { tag = "input", attr = {
                            type = "radio", name = "fulfilled", value = "true",
                            id = "s" .. suggestion.id .. "_fulfilled",
                            checked = active and "checked" or nil
                          } }
                          ui.tag { 
                            tag = "label", 
                            attr = {
                              ["for"] = "s" .. suggestion.id .. "_fulfilled",
                              class = active and "active-fulfilled" or nil,
                            },
                            content = _"Yes, it's implemented"
                          }
                        end }
                        slot.put("<br />")
                        
                        ui.tag{
                          tag = "input",
                          attr = {
                            type = "submit",
                            class = "btn btn-default",
                            value = _"publish my rating"
                          },
                          content = ""
                        }
                        
                      end 
                    }

                  end -- if not issue,fully_frozen or closed
                }
              end 
                
                local text = _"Read more"
                
                if direct_supporter then
                  text = _"Show more and rate this"
                end
                  
                ui.link { 
                  attr = { 
                    class = "suggestion-more",
                    onclick = "$('#s" .. suggestion.id .. "').removeClass('folded').addClass('unfolded'); return false;"
                  },
                  text = text
                }
                
                ui.link { 
                  attr = { 
                    class = "suggestion-less",
                    onclick = "$('#s" .. suggestion.id .. "').addClass('folded').removeClass('unfolded'); return false;"
                  },
                  text = _"Show less"
                }
                end
              }
              
              ui.script{ script = [[
                var textEl = $('#s]] .. suggestion.id .. [[ .suggestion-text');
                var height = textEl.height();
                if (height > 150) $('#s]] .. suggestion.id .. [[').addClass('folded');
              ]] }
               
            end
          } -- ui.paragraph
          
              

        end } -- ui.tag "li"
        
      end -- for i, suggestion
      
    else -- if #initiative.suggestions > 0
      
      local text
      if initiative.issue.closed then
        text = "No suggestions"
      else
        text = "No suggestions (yet)"
      end
      ui.sectionHead( function()
        ui.heading { level = 1, content = text }
      end)
      
    end -- if #initiative.suggestions > 0
    
  end
}
