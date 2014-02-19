<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Stimmberechtigte Nutzer in Liquid</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" media="screen" href="gregor.js/gregor.css" />
<link rel="stylesheet" type="text/css" media="screen" href="style.css" />
</head>
<body>

    <div class="topbar">
      <div class="topbar_content">
        <div class="navigation" id="navigation">
          <div class="slot_navigation" id="slot_navigation"><a href="../index/index.html"><span class="logo">Liquid</span> &middot; Piratenpartei Österreichs</a><a href="../index/search.html">Suchen</a></div>
        </div>
        <br style="clear: both;" />
      </div>
    </div>
<div class="page">
<div class="main" id="default">
<div class="slot_default" id="slot_default"><div class="ui_tabs ui_tabs_content"><div class="ui_filter ui_filter_head">
<?php
  //error_reporting(E_ALL);
  //ini_set('display_errors', 1);
  $u = 1;
  $selected = array_fill(0,20,"");
  if (isset($_GET["unit"]) && preg_match("/^\d+$/", $_GET["unit"], $matches, PREG_OFFSET_CAPTURE) == 1 && $_GET["unit"] >= 1 && $_GET["unit"] <= 20)
  {
    $u = $_GET["unit"];
  }
  $selected[$u] = " class=\"active\"";
  echo "<a href=\"?unit=1\"" . $selected[1] . ">Österreich</a>\n";
  echo "<a href=\"?unit=6\"" . $selected[6] . ">Burgenland</a>\n";
  echo "<a href=\"?unit=10\"" . $selected[10] . ">Kärnten</a>\n";
  echo "<a href=\"?unit=4\"" . $selected[4] . ">Niederösterreich</a>\n";
  echo "<a href=\"?unit=5\"" . $selected[5] . ">Oberösterreich</a>\n";
  echo "<a href=\"?unit=7\"" . $selected[7] . ">Salzburg</a>\n";
  echo "<a href=\"?unit=3\"" . $selected[3] . ">Steiermark</a>\n";
  echo "<a href=\"?unit=8\"" . $selected[8] . ">Tirol</a>\n";
  echo "<a href=\"?unit=9\"" . $selected[9] . ">Vorarlberg</a>\n";
  echo "<a href=\"?unit=2\"" . $selected[2] . ">Wien</a>\n";
  echo '<br /><br />';
  echo "<a href=\"?unit=11\"" . $selected[11] . ">Graz</a>\n";
  if ($u >= 1 && $u <= 20)
  {
    echo "<br /> <br /><div class=\"wiki use_terms\">\n";
    echo "<h2>Stimmberechtigte Nutzer in Liquid Gliederung ";
    if ($u == 1)
      echo "Piratenpartei Österreichs</h2>\n";
    else if ($u == 2)
      echo "Piratenpartei Wien</h2>\n";
    else if ($u == 3)
      echo "Piratenpartei Steiermark</h2>\n";
    else if ($u == 4)
      echo "Piratenpartei Niederösterreich</h2>\n";
    else if ($u == 5)
      echo "Piratenpartei Oberösterreich</h2>\n";
    else if ($u == 6)
      echo "Piratenpartei Burgenland</h2>\n";
    else if ($u == 7)
      echo "Piratenpartei Salzburg</h2>\n";
    else if ($u == 8)
      echo "Piratenpartei Tirol</h2>\n";
    else if ($u == 9)
      echo "Piratenpartei Vorarlberg</h2>\n";
    else if ($u == 10)
      echo "Piratenpartei Kärnten</h2>\n";
    else if ($u == 11)
      echo "Region Graz</h2>\n";
    else
      echo "$u</h2>\n";

    if (isset($_GET["full"]) && preg_match("/^\d+$/", $_GET["full"], $matches, PREG_OFFSET_CAPTURE) == 1 && $_GET["full"] == 1)
    {
      include("/opt/liquid_feedback_statistics/" . $u . ".html");
    }
    else
    {
      $handle = @fopen("/opt/liquid_feedback_statistics/" . $u . ".html",'r');
      if ($handle)
      {
        for ($i = 0; $i < 50; $i++)
        {
          if (($buffer = fgets($handle)) == false)
          {
            break;
          }
          echo $buffer;
        }
      }
      fclose($handle);
    }
  }
  echo "</div></div></div>\n";
  if (!isset($_GET["full"]) || preg_match("/^\d+$/", $_GET["full"], $matches, PREG_OFFSET_CAPTURE) != 1 || $_GET["full"] != 1)
  {
    echo "<br><br><a href=\"hourly.php?unit=$u&full=1\" class=\"more_events_links\">Zeige ältere Ereignisse</a><br><br>";
  }
echo <<<END
    </div>
      <br style="clear: both;" />
    </div>
    <div class="footer" id="footer">
      <div class="slot_footer" id="slot_footer"><a href="../admin/index.html">Admin</a> &middot; <a href="../index/about.html">Impressum</a> &middot; <a href="../index/usage_terms.html">Nutzungsbedingungen</a>
END;
  echo shell_exec("/opt/liquid_feedback_core/config_footer.sh");
?>
    </div>
  </body>
</html>

