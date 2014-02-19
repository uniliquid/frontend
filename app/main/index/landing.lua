app.html_title.title = _"UniLiquid"

slot.put([[
<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="../static/flot/excanvas.min.js"></script><![endif]-->
<script language="javascript" type="text/javascript" src="../static/flot/jquery.js"></script>
<script language="javascript" type="text/javascript" src="../static/flot/jquery.flot.js"></script>
<script language="javascript" type="text/javascript" src="../static/date.format.js"></script>
<script type="text/javascript">
$(function () {
]])

local users = {}
local j = 0
local old = 0
local dates_q = db:query("SELECT to_char(created, 'YYYY') AS year, to_char(created, 'MM') AS month, to_char(created, 'DD') AS day FROM member ORDER BY created;")
for i, date in ipairs(dates_q) do
  local unixtime = os.time({year=tonumber(date.year), month=tonumber(date.month), day=tonumber(date.day)})
  if (old ~= unixtime) then
    j = j + 1
    old = unixtime
  end
  if not users[j] then
    users[j] = {}
    users[j].count = 0
  end
  users[j].count = users[j].count + 1;
  users[j].date = unixtime
end
slot.put("  var users = [")
local sum = 0
for i, user in ipairs(users) do
  if (sum ~= 0) then
    slot.put(",")
  end
  sum = sum + user.count
  slot.put("[" .. user.date .. "000," .. sum .. "]");
end
slot.put("];\n");
slot.put([[
  var userdata = { label: "Mitglieder", data: users };
  var data =  [ userdata ];

  var datasets = {
    "Mitglieder": {
      label: "Mitglieder",
      data: users
    }
  };
    
  // hard-code color indices to prevent them from shifting as
    // countries are turned on/off
    var i = 0;
    $.each(datasets, function(key, val) {
        val.color = i;
        ++i;
    });
    // insert checkboxes 
    var choiceContainer = $("#choices");
    $.each(datasets, function(key, val) {
        choiceContainer.append('<input type="checkbox" name="' + key +
                               '" checked="checked" id="id' + key + '">' +
                               '<label for="id' + key + '">'
                                + val.label + '</label> ');
    });
    choiceContainer.find("input").click(plotAccordingToChoices);

  var doptions = {
    series: {
      lines: { show: true },
      points: {
        show: true,
        radius: 2
      }
    },
    grid: { hoverable: true, clickable: true },
    xaxis: {
      show: true,
      mode: "time",
      timeformat: "%d.%m.",
      minTickSize: [1, "day"],
      //labelWidth: 40,
      labelHeight: 15,
      //reserveSpace: true
    },
    yaxis: {
      show: true,
      min: 0,
      minTickSize: 1
    },
    legend: {
      position: "nw"
    }
  };
    
    function plotAccordingToChoices() {
        var data = [];

        choiceContainer.find("input:checked").each(function () {
            var key = $(this).attr("name");
            if (key && datasets[key])
                data.push(datasets[key]);
        });

        if (data.length > 0)
            $.plot($("#grafik"), data, doptions);
    }
  
    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y - 25,
            left: x - 30,
            border: '1px solid #333',
            padding: '3px',
      'border-radius': '3px',
      color: '#444',
            'background-color': 'rgba(255, 255, 255,0.8)',
      'font-size': '10px',
            opacity: 1
        }).appendTo("body").fadeIn(400);
    } 

    plotAccordingToChoices();
  
    var previousPoint = null;
    $("#grafik").bind("plothover", function (event, pos, item) {
        $("#x").text(pos.x.toFixed(2));
        $("#y").text(pos.y.toFixed(2));

    if (item) {
      if (previousPoint != item.dataIndex) {
        previousPoint = item.dataIndex;
        
        $("#tooltip").remove();
        var x = item.datapoint[0].toFixed(0)/10,
          y = item.datapoint[1].toFixed(0);
        
        showTooltip(item.pageX, item.pageY,
              dateFormat(x*10, "dd.mm.yyyy") + ": " + y );
      }
    }
    else {
      $("#tooltip").remove();
      previousPoint = null;            
    }
        
    });
});
</script>
]]
slot.put(config.landing_page_content_html)

local issues = db:query("SELECT COUNT(*) AS count FROM issue", "object").count
local initiatives = db:query("SELECT COUNT(*) AS count FROM initiative", "object").count
local suggestions = db:query("SELECT COUNT(*) AS count FROM suggestion", "object").count
local arguments = db:query("SELECT COUNT(*) AS count FROM argument", "object").count
local members = db:query("SELECT COUNT(*) AS count FROM member", "object").count
--local active = db:query("SELECT COUNT(*) AS count FROM member WHERE active", "object").count

slot.put('<div class="content">\n       Themen:&nbsp;<b>' .. issues .. '</b> &nbsp; &middot; &nbsp; Initiativen:&nbsp;<b>' .. initiatives .. '</b> &nbsp; &middot; &nbsp; Anregungen: &nbsp;<b>' .. suggestions .. '</b> &nbsp; &middot; &nbsp; Argumente: &nbsp;<b>' .. arguments .. '</b> &nbsp; &middot; &nbsp; Mitglieder:&nbsp;<b>' .. members .. '</b>');-- &nbsp; &middot; &nbsp; Aktive:&nbsp;<b>69</b>');
