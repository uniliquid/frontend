local issue = Issue:by_id(param.get_id())

if not issue then
  slot.put_into("error", _"The requested issue does not exist!")
  return
end

if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

if not app.html_title.title then
	app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = issue.area } }
end)

util.help("issue.show")

slot.select("head", function()
  execute.view{ module = "issue", view = "_show", params = { issue = issue } }
end )

if app.session:has_access("all_pseudonymous") then
  if issue.fully_frozen and issue.closed then
    local members_selector = issue:get_reference_selector("direct_voters")
          :add_field("direct_voter.weight as voter_weight")
          :add_field("direct_voter.weight AS weight")
          :add_field("direct_voter.comment as voter_comment")
          :add_order_by("voter_weight DESC, lower(member.name), id")
ui.container{
  attr = { class = "member_list" },
  content = function()
    local members = members_selector:exec()
    -- initiatives (input for preftools)
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Initiatives" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        slot.put(_('This is the candidates input file for <a href="http://www.public-software-group.org/preftools">preftools</a> or this <a href="http://gruss.cc/schulze">online tool</a>. It simply lists all candidates.'))
        ui.tag{
          tag = "pre", content = function()
            local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
            for i, initiative in ipairs(initiatives) do
              slot.put("i" .. initiative.id .. "<br />")
            end
            slot.put("iSQ")
          end
        }
        end
      }
      end
    }
    -- ballots (input for preftools)
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Ballots" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        slot.put(_('This is the ballots input file for <a href="http://www.public-software-group.org/preftools">preftools</a> or this <a href="http://gruss.cc/schulze">online tool</a>. It lists all ballots in a form where &quot;<code>A ; B</code>&quot; means <code>A</code> is preferred over <code>B</code>. &quot;<code>A , B</code>&quot; means <code>A</code> and <code>B</code> are equally ranked and neither one preferred. <code>/</code> divides the Yes / Abstention / No groups.'))
        ui.tag{   
          tag = "pre", content = function()

            for i, member in ipairs(members) do
              local delegation = ""
              for j = 1, member.weight do
                local tempvoting_string = param.get("scoring")

                local tempvotings = {}
                if tempvoting_string then
                  for match in tempvoting_string:gmatch("([^;]+)") do
                    for initiative_id, grade in match:gmatch("([^:;]+):([^:;]+)") do
                      tempvotings[tonumber(initiative_id)] = tonumber(grade)
                    end
                  end
                end
                
                local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):add_order_by("initiative.satisfied_supporter_count DESC"):exec()
                
                local min_grade = -1;
                local max_grade = 1;
                
                for i, initiative in ipairs(initiatives) do
                  -- TODO performance
                  initiative.vote = Vote:by_pk(initiative.id, member.id)
                  if tempvotings[initiative.id] then
                    initiative.vote = {}
                    initiative.vote.grade = tempvotings[initiative.id]
                  end
                  if initiative.vote then
                    if initiative.vote.grade > max_grade then
                      max_grade = initiative.vote.grade
                    end
                    if initiative.vote.grade < min_grade then
                      min_grade = initiative.vote.grade
                    end
                  end
                end

                local sections = {}
                for i = min_grade, max_grade do
                  sections[i] = {}
                  for j, initiative in ipairs(initiatives) do
                    if (initiative.vote and initiative.vote.grade == i) or (not initiative.vote and i == 0) then
                      sections[i][#(sections[i])+1] = initiative
                    end
                  end
                end
                
                local approval_count, disapproval_count = 0, 0
                for i = min_grade, -1 do
                  if #sections[i] > 0 then
                    disapproval_count = disapproval_count + 1
                  end
                end
                local approval_count = 0
                for i = 1, max_grade do
                  if #sections[i] > 0 then
                    approval_count = approval_count + 1
                  end
                end
                
                for i = max_grade, min_grade, -1 do
                  if i == 0 then
                    slot.put("/ iSQ ")
                  elseif i == -1 then
                    slot.put("/ ")
                  elseif not (i == max_grade) then
                    slot.put("; ")
                  end
                  for j,ini in ipairs(sections[i]) do
                    if i == 0 or j > 1 then
                      slot.put(", ")
                    end
                    slot.put("i" .. ini.id .. " ")
                  end
                end
                slot.put("<br />")

              end
            end
          end
          }
        end
        }
      end
      }
    end
    }
local inis = {}
local battles = {}
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Battles" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        slot.put(_('Count on how many ballots an initiative <code>A</code> is preferred over another initiative <code>B</code>. Now count on how many ballots it is the other way round, e.g. <code>B</code> is preferred over <code>A</code>. Ignore ballots which have the two initiatives equally ranked. This table shows exactly these comparisons. The initiative on the left is preferred over the initiative on the top on the number of ballots given in the according cell of the table.<br />For the next step of the schulze method you have to highlight each winner. Just compare both table entries for <code>A</code> vs. <code>B</code>. We call this a <b>battle</b>. If one of the numbers is bigger, it is highlighted and the according initiative wins the battle.<br /><br />'))
battles["SQ"] = {}
local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
for i, ini_x in ipairs(initiatives) do
  battles[ini_x.id] = {}
  battles[ini_x.id][ini_x.id] = ""
  local battled_initiatives = Initiative:new_selector()
    :add_field("winning_battle.count", "winning_count")
    :join("battle", "winning_battle", { "winning_battle.winning_initiative_id = ? AND winning_battle.losing_initiative_id = initiative.id", ini_x.id })
    :exec()
  for i, ini_y in ipairs(battled_initiatives) do
    battles[ini_x.id][ini_y.id] = ini_y.winning_count
  end
  battles[ini_x.id]["SQ"] = ini_x.positive_votes;
  battles["SQ"][ini_x.id] = ini_x.negative_votes;
  inis[i] = ini_x.id;
end
battles["SQ"]["SQ"] = "";
inis[#inis+1] = "SQ";
        ui.tag{
          tag = "table", content = function()
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = _"beats" }
                for i, ini_x in ipairs(inis) do
                  ui.tag{ tag = "td", content = "i" .. ini_x }
                end
              end
            }
          for i, ini_y in ipairs(inis) do
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = "i" .. ini_y }
                for i, ini_x in ipairs(inis) do
                  local battle
                  if battles[ini_y][ini_x] > battles[ini_x][ini_y] then
                    battle = ui.tag{ tag = "td", content = function() ui.tag{ tag = "b", content = battles[ini_y][ini_x] } end }
                  else
                    battle = ui.tag{ tag = "td", content = battles[ini_y][ini_x] }
                  end
                end
              end
            }
          end
          end
        }
        end
      }
      end
    }
    ui.container{ attr = { class = "initiative_head" }, content = function()
      ui.tag{ attr = { class = "title" }, content = _"Graph" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
      slot.put(_('Now in this step we draw a circle for each initiative. We now need to draw arrows between some of these circles. For each highlighted number from the previous table we draw an edge from the winning initiative to the losing initiative, of the according battle. (Instead of arrowheads you will see circles with the number of the edge within it. They were easier to draw automatically.) Add the (highlighted) number from the table to the edge, we will need it later.'))
      slot.put([[
<div id="content"><div id="canvas"><canvas id="canvas" width="1000" height="700"></canvas></div></div>
<script type="text/javascript" src="../../static/js/jquery-1.8.2.min.js"></script>
<script type="text/javascript" src="../../static/js/jcanvas.min.js"></script>
<script type="text/javascript">
var displayWidth = 1000;
var displayHeight = 700;
var oldTime = undefined;

var nodes = []]);
for i, ini_y in ipairs(inis) do
  slot.put([[
    {
        x: 0,
        y: 0,
        velocityX: 0,
        velocityY: 0,
        radius: 25,]]);
  slot.put("text: '" .. ini_y .. "'");
  slot.put('},');
end
slot.put([[
];

var edges = [
]]);
for i, ini_x in ipairs(inis) do
  for j, ini_y in ipairs(inis) do
    if battles[ini_x][ini_y] ~= nil and string.len(battles[ini_x][ini_y]) > 0 then
      if battles[ini_x][ini_y] > battles[ini_y][ini_x] then
slot.put([[
    {
        node1: ]] .. (i-1) .. [[,
        node2: ]] .. (j-1) .. [[,
        text: ']] .. battles[ini_x][ini_y] .. [['
    },
]]);
      end
    end
  end
end
slot.put([[
];

$(function() {
    // set random starting position
    $.each(nodes, function(index) {
        nodes[index].x = Math.random() * displayWidth;
        nodes[index].y = Math.random() * displayHeight;
    });

    // set requestAnimationFrame
    // see: http://paulirish.com/2011/requestanimationframe-for-smart-animating/
    (function() {
        var lastTime = 0;
        var vendors = ['webkit', 'moz'];
        for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
            window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
            window.cancelAnimationFrame =
                window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
        }

        if (!window.requestAnimationFrame)
            window.requestAnimationFrame = function(callback, element) {
                var currTime = new Date().getTime();
                var timeToCall = Math.max(0, 16 - (currTime - lastTime));
                var id = window.setTimeout(function() { callback(currTime + timeToCall); },
                    timeToCall);
                lastTime = currTime + timeToCall;
                return id;
            };

        if (!window.cancelAnimationFrame)
            window.cancelAnimationFrame = function(id) {
                clearTimeout(id);
            };
    }());

    // start game loop
    oldTime = new Date().getTime();
    gameLoop(oldTime);
});

function gameLoop(time) {
    // calculate deltaTime
    var deltaTime = time - oldTime;

    // debug
    //console.log(deltaTime);

    // do stuff
    update(deltaTime);
    render();

    // safe latest time in oldTime
    oldTime = time;

    // request next frame
    window.requestAnimationFrame(gameLoop);
}

function update(dt) {
    // calculate force between ALL nodes
    $.each(nodes, function(index) {
        $.each(nodes, function(index2) {
            if (index != index2) {
                var dX = nodes[index].x - nodes[index2].x;
                var dY = nodes[index].y - nodes[index2].y;
                var distance = Math.sqrt(dX * dX + dY * dY) * 0.5;

                // attract
                /*var attractFactor = 0.008;
                nodes[index].velocityX += -dX * attractFactor;
                nodes[index].velocityY += -dY * attractFactor;
                nodes[index2].velocityX += dX * attractFactor;
                nodes[index2].velocityY += dY * attractFactor;*/

                // disperse
                nodes[index].velocityX += (4 / (0.5 * nodes.length)) * (dX / (10 * distance));
                nodes[index].velocityY += (4 / (0.5 * nodes.length)) * (dY / (10 * distance));
                nodes[index2].velocityX += (4 / (0.5 * nodes.length)) * (-dX / (10 * distance));
                nodes[index2].velocityY += (4 / (0.5 * nodes.length)) * (-dY / (10 * distance));
            }
        });
    });

    // or only between nodes with edges
    /*$.each(edges, function(index) {
var node1Index = edges[index].node1;
var node2Index = edges[index].node2;

var node1 = nodes[node1Index];
var node2 = nodes[node2Index];

var dX = node1.x - node2.x;
var dY = node1.y - node2.y;
var distance = Math.sqrt(dX * dX + dY * dY);

// attract
var attractFactor = 0.01;
node1.velocityX += -dX * attractFactor;
node1.velocityY += -dY * attractFactor;
node2.velocityX += dX * attractFactor;
node2.velocityY += dY * attractFactor;

// disperse
node1.velocityX += dX / distance;
node1.velocityY += dY / distance;
node2.velocityX += -dX / distance;
node2.velocityY += -dY / distance;
});*/

    // basis node movement
    $.each(nodes, function(index) {
        // calculate distance from middle
        var dX = nodes[index].x - displayWidth / 2;
        var dY = nodes[index].y - displayHeight / 2;
        var distance = Math.sqrt(dX * dX + dY * dY);

        // attract to middle
        var attractFactor = 0.005;
        nodes[index].velocityX -= dX * attractFactor;
        nodes[index].velocityY -= dY * attractFactor;

        // disperse from middle
        var disperseFactor = 0.5;
        nodes[index].velocityX += (dX / distance) * disperseFactor;
        nodes[index].velocityY += (dY / distance) * disperseFactor;

        // damping
        nodes[index].velocityX *= 0.9;
        nodes[index].velocityY *= 0.9;

        // add velocity to position
        nodes[index].x += nodes[index].velocityX * dt;
        nodes[index].y += nodes[index].velocityY * dt;

        // clamping on edge
        if (nodes[index].x < 0) {
            nodes[index].x = 0;
            nodes[index].velocityX = 0;
        }
        if (nodes[index].y < 0) {
            nodes[index].y = 0;
            nodes[index].velocityY = 0;
        }
        if (nodes[index].x > displayWidth) {
            nodes[index].x = displayWidth;
            nodes[index].velocityX = 0;
        }
        if (nodes[index].y > displayHeight) {
            nodes[index].y = displayHeight;
            nodes[index].velocityY = 0;
        }
    });
}

function render() {
    $('canvas').clearCanvas();

    $.each(nodes, function(index) {
        $('canvas').drawArc({
            strokeStyle: '#000000',
            fillStyle: '#ffffff',
            strokeWidth: 1,
            x: nodes[index].x,
            y: nodes[index].y,
            radius: nodes[index].radius,
            closed: true
        });
        $('canvas').drawText({
          x: nodes[index].x,
          y: nodes[index].y,
          fillStyle: '#000000',
          strokeWidth: 1,
          font: '11pt sans-serif',
          text: 'i' + nodes[index].text
        });
    });

    $.each(edges, function(index) {
        var node1Index = edges[index].node1;
        var node2Index = edges[index].node2;

        var node1 = nodes[node1Index];
        var node2 = nodes[node2Index];

        var dX = node1.x - node2.x;
        var dY = node1.y - node2.y;
        var distance = Math.sqrt(dX * dX + dY * dY);
        dX /= distance;
        dY /= distance;

        var x1 = node1.x - dX * node1.radius;
        var y1 = node1.y - dY * node1.radius;
        var x2 = node2.x + dX * node2.radius;
        var y2 = node2.y + dY * node2.radius;

        var vx = x2 - x1;
        var vy = y2 - y1;

        // draw line
        $('canvas').drawLine({
            strokeStyle: '#000000',
            strokeWidth: 1,
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2
        });
        $("canvas").drawEllipse({
          strokeStyle: "#000000",
          strokeWidth: 1,
          fillStyle: "#ffffff",
          x: x2 * 0.99 + x1 * 0.01,
          y: y2 * 0.99 + y1 * 0.01,
          width: 16,
          height: 16,
        });
        $('canvas').drawText({
          x: x2 * 0.99 + x1 * 0.01,
          y: y2 * 0.99 + y1 * 0.01,
          fillStyle: '#000000',
          strokeWidth: 1,
          font: '6pt sans-serif',
          text: edges[index].text
        });
    });
}
</script>
]]);
        end
      }
      end
    }
    ui.container{ attr = { class = "initiative_head" }, content = function()
      local better = ""
      ui.tag{ attr = { class = "title" }, content = _"Winning Beatpaths" }
      ui.container{ attr = { class = "draft_content wiki" }, content = function()
        slot.put(_('Now we want to consider indirect comparisons between initiatives to finally calculate the order of the initiatives.<br />For reasons of easy understanding, think of the graph above as a map with possible flights from one city to another. The number at the edges is how much kilograms of baggage you may take upon this flight. You want to take a lot of baggage with you, so you want to find a flight (direct or with intermediate landings), such that you can take as much baggage as possible with you. You find the number of kilograms for each route (direct or with intermediate landings) in the following table.<br /><br />'))
        local p = {}
        local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):exec()
        for a,i in ipairs(inis) do
          p[i] = {}
          for b,j in ipairs(inis) do
            if i ~= j then
              if battles[i][j] > battles[j][i] then
                p[i][j] = battles[i][j]
              else
                p[i][j] = 0
              end
            end
            p[i][i] = 0
          end
        end
        for a,i in ipairs(inis) do
          for b,j in ipairs(inis) do
            if i ~= j then
              for c,k in ipairs(inis) do
                if i ~= k then
                  if j ~= k then
                    p[j][k] = math.max(p[j][k],math.min(p[j][i],p[i][k]))
                  end
                end
              end
            end
          end
        end
        ui.tag{
          tag = "table", content = function()
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = _"beats" }
                for i, ini_x in ipairs(inis) do
                  ui.tag{ tag = "td", content = "i" .. ini_x }
                end
              end
            }
          for i, ini_y in ipairs(inis) do
            ui.tag{
              tag = "tr", content = function()
                ui.tag{ tag = "td", content = "i" .. ini_y }
                for i, ini_x in ipairs(inis) do
                  local battle
                  if p[ini_y][ini_x] > p[ini_x][ini_y] then
                    battle = ui.tag{ tag = "td", content = function() ui.tag{ tag = "b", content = p[ini_y][ini_x] } end }
                    better = better .. "<br />" .. ini_y .. _" is better than " .. ini_x
                  else
                    battle = ui.tag{ tag = "td", content = p[ini_y][ini_x] }
                  end
                end
              end
            }
          end
          end
        }
        slot.put(_'<br /><br />In this table again you compare the two directions from initiative <code>A</code> to initiative <code>B</code> and from initiative <code>B</code> to initiative <code>A</code>. If one of the numbers is bigger, highlight it.<br />Now we are finished. Each highlighted number can be read as &quot;<code>A</code> is better than <code>B</code>&quot;. If you write down all variants of which initiative is better, you will get the following list, which directly defines the order of the initiatives.<br /><br />')
        ui.tag{ tag = "b", content = function() slot.put(better) end };

        end
      }
      end
    }

  end
end
