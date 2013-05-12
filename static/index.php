<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="de-AT">
  <head>
    <title>TestLiquid</title> 
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
    <meta name="viewport" content="width=device-width" />
    <link rel="stylesheet" href="style.css" type="text/css" media="screen" /> 
    <link rel="icon" href="favicon.ico" type="image/x-icon">
  </head>
  <body>
      <div class="page"><div id="default" class="main"><div id="slot_default" class="slot_default"><div class="ui_tabs"><div class="ui_tabs"><div class="area_list"><div class="area">
      <div id="box" class="area_head" style="height: 200%;">
<div class="title">
        <br />
        <h1 style="font-size: 300%;"><center>
          TestLiquid
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
      </div>
</div>
<div class="initiative_head">
<div class="title">
<h2>Hinweise & Neuigkeiten</h2>
</div>
        <ul>
          <li><b>12.05.2013:</b> Freischaltung Uni Wien</li>
          <li><b>11.05.2013:</b> Start der Seite</li>
        </ul>
      </div>
</div>
<div class="initiative_head">
<div class="title">
        <h2>Hilfe & Infos</h2>
</div>
<div class="content">
        <p>
          Bei diesem Liquid-System können alle Besucher alle Inhalte sehen. Studierende können Inhalte einstellen. 
        </p>
        <p>
          <a href="mailto:support@liquid.unipiraten.at">Support via Mail</a>
        </p>
      </div>
</div>
<div id="footer" class="footer">
<div id="slot_footer" class="slot_footer">
        <p>
          <a href="/liquid/index/about.html">Impressum</a> 
          &middot;
          <a href="/liquid/static/doc/useterms.html">Nutzungsbedingungen</a>
          &middot;
          <a href="/liquid/static/doc/privacy.html">Datenschutzerklärung</a>
          &middot; 
          <a href="/liquid/static/doc/pseudonyme.html">Umgang mit Pseudonymen</a>
          <p />
          Die Texte von Initiativen und Anregungen stehen unter der Creative Commons Lizens <a href="/liquid/static/doc/cclicense.html">CC-BY-SA</a>
          <p />
          <a href="/liquid/static/doc/cclicense.html"><img src="/liquid/static/doc/CC%2dBY%2dSA%5ficon.png"></a> 
        </p>
      </div>
  </body>
</html>

