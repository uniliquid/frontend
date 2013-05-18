<?
header("Location: http://uniliquid.at/liquid/index/landing.html");
/*<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="de-AT">
  <head>
    <title>UniLiquid</title> 
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
    <meta name="viewport" content="width=device-width" />
    <link rel="stylesheet" href="style.css" type="text/css" media="screen" /> 
    <link rel="icon" href="favicon.ico" type="image/x-icon">
<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="flot/excanvas.min.js"></script><![endif]-->
<script language="javascript" type="text/javascript" src="flot/jquery.js"></script>
<script language="javascript" type="text/javascript" src="flot/jquery.flot.js"></script>
<script language="javascript" type="text/javascript" src="date.format.js"></script>
<script type="text/javascript">
$(function () {
<?
$users = array();
$error = 'Der Admin ist auf der Tastatur eingeschlafen und hat die Entf-Taste erwischt.';
$dbconn = pg_connect("dbname=liquid_feedback") or die($error);
$result = pg_query("SELECT to_char(created, 'DD-MM-YYYY') AS date FROM member ORDER BY created;") or die($error);
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC))
{
  $date = new DateTime($line['date']);
  $users[$date->getTimestamp()] = intval($users[$date->getTimestamp()]) + 1;
}
pg_free_result($result);
echo "  var users = [";
$sum = 0;
foreach ($users as $date => $count)
{
  if ($sum != 0)
    echo ",";
  $sum += $count;
  echo "[".$date."000,$sum]";
}
echo "];\n";
?>
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
  </head>
  <body>
      <div class="page"><div id="default" class="main"><div id="slot_default" class="slot_default"><div class="ui_tabs"><div class="ui_tabs"><div class="area_list"><div class="area">
      <div id="box" class="area_head" style="height: 200%;">
<div class="title">
        <br />
        <h1 style="font-size: 300%;"><center>
          UniLiquid
        </center></h1>
      </div>
      <div class="content"></div>
</div>
      <div class="content">
        <p align="center">
          <a href="/liquid/">Mitmachen</a>
          &nbsp; &middot;  &nbsp;
          <a href="/liquid/index/index.html?tab=open&filter=frozen&filter_voting=not_voted">Abstimmen</a>
       <p/>
      </div>
</div>
</div>
</div>
        <br style="clear: both;" />
<div class="initiative_head">
<div class="title">
        <h2>Über das UniLiquid</h2>
</div>
<div class="content">
<p>UniLiquid bietet den Studierenden auf Österreichs Universitäten die Möglichkeit, auch nach der Wahl ihre Ideen einzubringen, mitzugestalten und mitzubestimmen. </p>
<p>Die Kontrolle, ob jemand wirklich studiert, erfolgt über die universitätsspezifischen E-Mail-Adressen. Durch die Nutzung von Pseudonymen kann das System anonym genutzt werden. Die gleichzeitige Öffentlichkeit der Abstimmergebnisse garantiert Transparenz beim Ergebnis.</p>
<p>UniLiquid wird von den Unipiraten Österreich betrieben. Die Matrikelnummern und E-Mail-Adressen unterliegen größtem Datenschutz und werden weder weitergegeben noch von uns ausgewertet, sondern lediglich zur Kontaktaufnahme mit dir und damit zur Verifikation deines Studierendenstatus verwendet.</p>
<p>Die verwendete Software ist eine Weiterentwicklung von <a href="http://liquidfeedback.org/">LiquidFeedback</a>. Eine kurze Videoanleitung zum Gebrauch findest du <a href="https://www.youtube.com/watch?v=WVa2Txtqe1g">hier auf YouTube</a>.</p>
<p>UniLiquid ist erst seit Kurzem online und wird ständig weiterentwickelt werden. Es dauert sicher eine Weile, bis die volle Funktionalität gegeben ist und genügend Studierende teilnehmen.</p>
<p><a href="http://uniliquid.at/liquid/index/register.html">Registriere dich</a>, teste die Software, überzeuge dich von den Möglichkeiten der digitalen Partizipation und ermögliche so echte Mitbestimmung in deiner Studierendenvertretung.</p>
      </div>
</div>
<div class="initiative_head">
<div class="title">
        <h2>Statistik</h2>
</div>
<div class="content">
<?
$error = 'Der Admin ist auf der Tastatur eingeschlafen und hat die Entf-Taste erwischt.';
function getCount($table)
{
global $error;
$result = pg_query("SELECT COUNT(*) AS c FROM $table") or die($error);
$line = pg_fetch_array($result, null, PGSQL_ASSOC);
$count = $line['c'];
pg_free_result($result);
return $count;
}
$dbconn = pg_connect("dbname=liquid_feedback") or die($error);
$issues = getCount("issue");
$initiatives = getCount("initiative");
$suggestions = getCount("suggestion");
$arguments = getCount("argument");
$members = getCount("member");
$active = getCount("member WHERE active");
echo "        Themen:&nbsp;<b>$issues</b> &nbsp; &middot; &nbsp; Initiativen:&nbsp;<b>$initiatives</b> &nbsp; &middot; &nbsp; Anregungen: &nbsp;<b>$suggestions</b> &nbsp; &middot; &nbsp; Argumente: &nbsp;<b>$arguments</b> &nbsp; &middot; &nbsp; Mitglieder:&nbsp;<b>$members</b> &nbsp; &middot; &nbsp; Aktive:&nbsp;<b>$active</b>\n";
?>
<div id="grafik" style="width:400px; height:100px; margin-left:auto;
margin-right:auto; margin-top:10px;"></div>
<div id="choices" style="display: none;"></div>
</div>
</div>
<div class="initiative_head">
<div class="title">
<h2>Hinweise & Neuigkeiten</h2>
</div>
        <ul>
          <li><b>13.05.2013</b> Freischaltung einiger weiterer Universitäten. Insgesamt sind jetzt 16 Universitäten freigeschaltet. Sollte deine fehlen kontaktiere einfach den Support.</li>
          <li><b>13.05.2013:</b> Freischaltung der Themenbereiche und Einführung <a href="http://uniliquid.at/liquid/policy/list.html">verschiedener Regelwerke</a>. Für weitere Regelwerks- oder Themenbereichsänderungen wurde das Regelwerk <a href="http://uniliquid.at/liquid/policy/show/4.html">Änderung von Themenbereichen und Regelwerken</a> eingeführt.</li>
          <li><b>12.05.2013:</b> Freischaltung BOKU Wien, MedUni Wien, TU Wien, Uni Linz, Uni Wien</li>
          <li><b>11.05.2013:</b> Start der Seite</li>
        </ul>
      </div>
</div>
<div class="initiative_head">
<div class="title">
        <h2>Und so funktionierts</h2>
</div>
<div class="content">
<ol>
<li>Melde dich unter dem Tab <a href="http://uniliquid.at/liquid/index/register.html">Registrierung</a> mit einer beliebigen E-Mail und Pseudonym an.</li>
<li>Sobald du deine Registrierung bestätigt hast (E-Mails checken), kannst du dein Wahlrecht für deine Uni anfordern. Geh dazu zum Tab <a href="http://uniliquid.at/liquid/member/rights.html">Mein Stimmrecht</a>, wähle deine Universität aus. Je nach Universität werden wir dich nach deiner Matrikelnummer oder deiner Studierenden-E-Mail-Adresse fragen. Gib diese dann ein, wir senden dir dann eine E-Mail, in der ein Bestätigungslink enthalten ist.</li>
<li>Nun kannst du für deine Uni Anträge erstellen, kommentieren und verbessern oder Alternativanträge einbringen – und natürlich darüber abstimmen!</li>
</ol>
<h3>Hintergrund</h3>
<ol>
<li>Unter <a href="http://uniliquid.at/schulze.pdf">uniliquid.at/schulze.pdf</a> findest du eine genaue Beschreibung wie das Schulzeverfahren in Liquid zum Einsatz kommt.</li>
</ol>
</div>
</div>
        <center><p>
          <a href="mailto:support@uniliquid.at">Support via E-Mail</a>
        </p></center>

<div id="footer" class="footer">
<div id="slot_footer" class="slot_footer">
        <p>
          <a href="/liquid/index/about.html">Impressum</a> 
          &middot;
          <a href="/liquid/index/usage_terms.html">Nutzungsbedingungen</a>
          &middot;
          <a href="/liquid/index/privacy.html">Datenschutzerklärung</a>
          &middot; 
          <a href="/liquid/index/pseudonyme.html">Umgang mit Pseudonymen</a>
          <p />
          Die Texte von Initiativen und Anregungen stehen unter der Creative Commons Lizens <a href="http://creativecommons.org/licenses/by-sa/3.0/at/legalcode">CC-BY-SA</a>
          <p />
          <a href="http://creativecommons.org/licenses/by-sa/3.0/at/legalcode"><img src="/liquid/static/doc/CC%2dBY%2dSA%5ficon.png"></a> 
        </p>
      </div>
</div></div></div></div>
  </body>
</html>
*/
?>
