local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")
local member = param.get("member", "table") or app.session.member

if initiative then
  issue = initiative.issue
end

local privileged_to_vote = app.session.member and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id)

local active_trustee_id
if member then
  if not issue.member_info.own_participation then
    if issue.member_info.first_trustee_participation then
      active_trustee_id = issue.member_info.first_trustee_id
    elseif issue.member_info.other_trustee_participation then
      active_trustee_id = issue.member_info.other_trustee_id
    end
  end
end

ui.sidebar ( "tab-whatcanido", function ()

  ui.sidebarHeadWhatCanIDo()
      
  local supporter

  if initiative and app.session.member_id then
    supporter = app.session.member:get_reference_selector("supporters")
      :add_where{ "initiative_id = ?", initiative.id }
      :optional_object_mode()
      :exec()
  end

  local view_module
  local view_id

  if initiative then
    issue = issue
    view_module = "initiative"
    view_id = initiative.id
  else
    view_module = "issue"
    view_id = issue.id
  end
  
  local initiator
  if initiative and app.session.member_id then
    initiator = Initiator:by_pk(initiative.id, app.session.member.id)
  end

  local initiators 
  
  if initiative then
    local initiators_members_selector = initiative:get_reference_selector("initiating_members")
      :add_field("initiator.accepted", "accepted")
      :add_order_by("member.name")
    if initiator and initiator.accepted then
      initiators_members_selector:add_where("initiator.accepted ISNULL OR initiator.accepted")
    else
      initiators_members_selector:add_where("initiator.accepted")
    end
    
    initiators = initiators_members_selector:exec()
  end

  if initiator and 
    initiator.accepted and 
    not issue.fully_frozen and 
    not issue.closed and 
    not initiative.revoked 
  then

    ui.container { attr = { class = "sidebarRow" }, content = function ()
      ui.heading { level = 3, content = function()
        ui.tag { content = _"You are initiator of this initiative" }
      end }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag { tag = "li", content = function ()
          ui.link{
            module = "draft", view = "new",
            params = { initiative_id = initiative.id },
            content = _"edit proposal and/or reasons"
          }
        end }
        ui.tag { tag = "li", content = function ()
          ui.link{
            attr = { class = "action" },
            module = "initiative", view = "add_initiator",
            params = { initiative_id = initiative.id },
            content = _"invite another initiator"
          }
        end }
        if #initiative.initiators > 1 then
          ui.tag { tag = "li", content = function ()
            ui.link{
              module = "initiative", view = "remove_initiator",
              params = { initiative_id = initiative.id },
              content = _"remove an initiator"
            }
          end }
        end
        ui.tag { tag = "li", content = function ()
          ui.link{
            module = "initiative", view = "revoke", id = initiative.id,
            content = _"revoke initiative"
          }
        end }
      end }
    end }
  end

  -- invited as initiator
  if initiator and initiator.accepted == nil and not initiative.issue.half_frozen and not initiative.issue.closed then
    ui.container { attr = { class = "sidebarRow highlighted" }, content = function ()
      ui.heading { level = 3, content = function()
        ui.tag { content = _"You are invited to become initiator of this initiative" }
      end }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag{ tag = "li", content = function ()
          ui.link{
            content = _"accept invitation",
            module = "initiative",
            action = "accept_invitation",
            id     = initiative.id,
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            }
          }
        end }
        
        ui.tag{ tag = "li", content = function ()
          ui.link{
            content = _"refuse invitation",
            module = "initiative",
            action = "reject_initiator_invitation",
            params = {
              initiative_id = initiative.id,
              member_id = app.session.member.id
            },
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            }
          }
        end }
      end }
    end }
  end


  if privileged_to_vote and issue.member_info.first_trustee_id then
    local member = Member:by_id(issue.member_info.first_trustee_id)
    ui.sidebarSection( function ()
      ui.container { attr = { class = "right" }, content = function()
        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member = member,
            image_type = "avatar",
            show_dummy = true
          }
        }
      end }
      if issue.member_info.own_delegation_scope == "unit" then
        ui.heading{ level = 3, content = _"You delegated this organizational unit" }
      elseif issue.member_info.own_delegation_scope == "area" then
        ui.heading{ level = 3, content = _"You delegated this subject area" }
      elseif issue.member_info.own_delegation_scope == "issue" then
        ui.heading{ level = 3, content = _"You delegated this issue" }
      end

      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        if issue.member_info.own_delegation_scope == "area" or
           issue.member_info.own_delegation_scope == "unit" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                issue_id = issue.id,
                initiative_id = initiative and initiative.id or nil
              },
              content = _"change/revoke delegation only for this issue" 
            }
          end }
        end
        if issue.member_info.own_delegation_scope == "unit" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                unit_id = issue.area.unit_id,
              },
              content = _("change/revoke delegation of organizational unit", {
                unit_name = issue.area.unit.name
              })
            }
          end }
        elseif issue.member_info.own_delegation_scope == "area" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                area_id = issue.area_id,
              },
              content = _"change/revoke delegation of subject area" 
            }
          end }
        end
        if issue.member_info.own_delegation_scope == nil then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                issue_id = issue.id,
                initiative_id = initiative and initiative.id or nil
              },
              content = _"choose issue delegatee" 
            }
          end }
        elseif issue.member_info.own_delegation_scope == "issue" then
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                issue_id = issue.id,
                initiative_id = initiative and initiative.id or nil
              },
              content = _"change/revoke issue delegation" 
            }
          end }
        end
      end }

      if issue.member_info.first_trustee_id and issue.member_info.own_participation then
        local text = _"As long as you are interested in this issue yourself, the delegation is suspended for this issue, but it will be applied again in the voting phase unless you vote yourself."
        if issue.state == "voting" then
          text = _"This delegation is suspended, because you voted yourself."
        end
        ui.container { content = text }
      end
    end )
  end
  
  if privileged_to_vote and not issue.closed and not issue.fully_frozen then
    if issue.member_info.own_participation then
      ui.sidebarSection( function ()
        ui.container{ attr = { class = "right" }, content = function()
          ui.image{ attr = { class = "right" }, static = "icons/48/eye.png" }
          if issue.member_info.weight and issue.member_info.weight > 1 then
            slot.put("<br />")
            ui.tag{ 
              attr = { class = "right" },
              content = "+" .. issue.member_info.weight - 1
           }
          end
        end }
        ui.heading{ level = 3, content = _("You are interested in this issue", { id = issue.id }) }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          if issue.member_info.weight and issue.member_info.weight > 1 then
            ui.tag { tag = "li", content = function ()
              ui.link {
                module = "delegation", view = "show_incoming",
                params = { issue_id = issue.id, member_id = app.session.member_id },
                content = _("you have #{count} incoming delegations", {
                  count = issue.member_info.weight - 1
                })
              }
            end }
          end
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "interest", action = "update",
              routing = { default = {
                mode = "redirect", module = view_module, view = "show", id = view_id
              } },
              params = { issue_id = issue.id, delete = true },
              text = _"remove my interest"
            }
          end }
        end }
      end )
    else
      ui.sidebarSection( function ()
        ui.heading{ level = 3, content = _("I want to participate in this issue", { id = issue.id }) }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "interest", action = "update", 
              params = { issue_id = issue.id },
              routing = { default = {
                mode = "redirect", module = view_module, view = "show", id = view_id
              } },
              text = _"add my interest"
            }
          end }
          ui.tag { tag = "li", content = _"browse through the competing initiatives" }
        end }
      end )
    end

    if initiative then
      
      if not initiative.member_info.supported or active_trustee_id then
        ui.container { attr = { class = "sidebarRow" }, content = function ()
          ui.heading { level = 3, content = function()
            ui.tag { content = _"I like this initiative and I want to support it" }
          end }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link {
                module = "initiative", action = "add_support", 
                routing = { default = {
                  mode = "redirect", module = "initiative", view = "show", id = initiative.id
                } },
                id = initiative.id,
                text = _"add my support"
              }
            end }
          end }
        end }
          
      else -- if not supported
        ui.container { attr = { class = "sidebarRow" }, content = function ()
          if initiative.member_info.satisfied then
            ui.image{ attr = { class = "right icon48" }, static = "icons/32/support_satisfied.png" }
          else
            ui.image{ attr = { class = "right icon48" }, static = "icons/32/support_unsatisfied.png" }
          end
          ui.heading { level = 3, content = _"You are supporting this initiative" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            if not initiative.member_info.satisfied then
              ui.tag { tag = "li", content = function ()
                ui.tag { content = function ()
                  ui.link {
                    external = "#suggestions",
                    content = _"you restricted your support by rating suggestions as must or must not"
                  }
                end }
              end }
            end
            ui.tag { tag = "li", content = function ()
              ui.tag { content = function ()
                ui.link {
                  xattr = { class = "btn btn-remove" },
                  module = "initiative", action = "remove_support", 
                  routing = { default = {
                    mode = "redirect", module = "initiative", view = "show", id = initiative.id
                  } },
                  id = initiative.id,
                  text = _"remove my support"
                }
              end }
            end }
          end }
        end }

      end -- not supported
      
      ui.container { attr = { class = "sidebarRow" }, content = function ()
        ui.heading { level = 3, content = _"I want to improve this initiative" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          if issue.state == "verification" then
            ui.tag { tag = "li", content = _"this issue is in verification phase, therefore the initiative text cannot be updated anymore" }
          elseif issue.state == "voting" then
            ui.tag { tag = "li", content = _"this issue is in voting phase, therefore the initiative text cannot be updated anymore" }
          else
            
            if initiative.member_info.initiated then
              ui.tag { tag = "li", content =_"take a look at the suggestions of your supporters" }
              ui.tag { tag = "li", content =_"if you like to implement a suggestion in your proposal and/or reasons, update your initiative draft" }
              ui.tag { tag = "li", content =_"to argue about suggestions, just add your arguments to your reasons in the initiative draft, so your supporters can learn about your opinion" }
            end
            
            if not initiative.member_info.supported or active_trustee_id then
              ui.tag { tag = "li", content =_"add your support (see above) and rate or write new suggestions (and thereby restrict your support to certain conditions if necessary)" }
            else
              ui.tag { tag = "li", content = _"take a look at the suggestions (see left) and rate them" }
              ui.tag { tag = "li", content = function ()
                ui.link {
                  module = "suggestion", view = "new", params = {
                    initiative_id = initiative.id
                  },
                  content = _"write a new suggestion" 
                }
              end }
            end
          end
        end }
      end }
      
    end
    
    if 
      (issue.state == "admission" or 
      issue.state == "discussion" or
      issue.state == "verification")
    then
      ui.sidebarSection( function ()
        if initiative then
          ui.heading{ level = 3, content = _"I don't like this initiative and I want to add my opinion or counter proposal" }
        else
          ui.heading{ level = 3, content = _"I don't like any of the initiative in this issue and I want to add my opinion or counter proposal" }
        end
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "issue", view = "show", id = issue.id,
              content = _"take a look at the competing initiatives"
            }
          end }
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "initiative", view = "new", 
              params = { issue_id = issue.id },
              content = _"start a new competing initiative"
            }
          end }
        end }
      end )
    end 
    
    if not issue.member_info.first_trustee_id then
      ui.sidebarSection( function ()
        ui.heading{ level = 3, content = _"I want to delegate this issue" }
      
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.link {
              module = "delegation", view = "show", params = {
                issue_id = issue.id,
                initiative_id = initiative and initiative.id or nil
              },
              content = _"choose issue delegatee" 
            }
          end }
        end }
      end )
    end
    
  end
  
  if initiator and initiator.accepted == false then
    ui.container { attr = { class = "sidebarRow" }, content = function ()
      ui.heading { level = 3, content = function()
        ui.tag { content = _"You refused to become initiator of this initiative" }
      end }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        ui.tag{ tag = "li", content = function ()
          ui.link{
            text   = _"allow invitation again",
            module = "initiative",
            action = "remove_initiator",
            params = {
              initiative_id = initiative.id,
              member_id = app.session.member.id
            },
            routing = {
              ok = {
                mode = "redirect",
                module = "initiative",
                view = "show",
                id = initiative.id
              }
            }
          }
        end }
      end }
    end }
  end
    

  
  if privileged_to_vote then
    
    if initiative and
      (issue.state == "admission" or 
      issue.state == "discussion" or
      issue.state == "verification")
    then
      
    elseif issue.state == "verification" then
      
    elseif issue.state == "voting" then
      if not issue.member_info.direct_voted then
        if not issue.member_info.non_voter then
          ui.container { attr = { class = "sidebarRow" }, content = function ()
            ui.heading { level = 3, content = _"I like to vote on this issue:" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.tag { content = function ()
                  if not issue.closed then
                    ui.link {
                      xattr = { class = "btn btn-vote" },
                      module = "vote", view = "list", 
                      params = { issue_id = issue.id },
                      text = _"vote now"
                    }
                  end
                end }
              end }
            end }
          end }
        end
        ui.container { attr = { class = "sidebarRow" }, content = function ()
          if not issue.member_info.non_voter then
            ui.heading { level = 3, content = _"I don't like to vote this issue (myself):" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.link{
                  content = _"do not notify me about this voting anymore",
                  module = "vote",
                  action = "non_voter",
                  params = { issue_id = issue.id },
                  routing = {
                    default = {
                      mode = "redirect",
                      module = request.get_module(),
                      view = request.get_view(),
                      id = param.get_id_cgi(),
                      params = param.get_all_cgi()
                    }
                  }
                }
              end }
            end }
          else
            ui.heading { level = 3, content = _"You do not like to vote this issue (yourself)" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.link{
                  in_brackets = true,
                  content = _"discard",
                  module = "vote",
                  action = "non_voter",
                  params = { issue_id = issue.id, delete = true },
                  routing = {
                    default = {
                      mode = "redirect",
                      module = request.get_module(),
                      view = request.get_view(),
                      id = param.get_id_cgi(),
                      params = param.get_all_cgi()
                    }
                  }
                }
              end }
            end }
          end
        end }
      else
        ui.container { attr = { class = "sidebarRow" }, content = function ()
          ui.heading { level = 3, content = _"I like to change/revoke my vote:" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.tag { content = function ()
                if not issue.closed then
                  ui.link {
                    xattr = { class = "btn btn-vote" },
                    module = "vote", view = "list", 
                    params = { issue_id = issue.id },
                    text = _"change my vote"
                  }
                end
              end }
            end }
            ui.tag { tag = "li", content = function ()
              ui.tag { content = function ()
                if not issue.closed then
                  ui.link {
                    module = "vote", action = "update",
                    params = {
                      issue_id = issue.id,
                      discard = true
                    },
                    routing = {
                      default = {
                        mode = "redirect",
                        module = "issue",
                        view = "show",
                        id = issue.id
                      }
                    },
                    text = _"discard my vote"
                  }
                end
              end }
            end }
          end } 

        end } 
        
      end
    end
  end
  
  if app.session.member and not privileged_to_vote then
    ui.sidebarSection( _"You are not entitled to vote in this unit" )
  end
  
  if issue.closed then
    ui.container { attr = { class = "sidebarRow" }, content = function ()
      ui.heading { level = 3, content = _"This issue is closed" }
    end }
  end
  
  if initiative and config.tell_others and config.tell_others.initiative then
    ui.container { attr = { class = "sidebarRow" }, content = function ()
        
      ui.heading { level = 3, content = _"Tell others about this initiative:" }
      ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
        
        for i, link in ipairs (config.tell_others.initiative(initiative)) do
          ui.tag { tag = "li", content = function ()
            ui.link ( link )
          end }
        end
      
      end }
    end }
  end
  
  
end )
