<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width" />
    <link rel="shortcut icon" type="image/x-icon" href="favicon.ico">
    <link rel="stylesheet" type="text/css" media="screen" href="static/trace.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="static/gregor.js/gregor.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="static/style.css" />
    
    <script type="text/javascript">jsFail = true;</script>
    <![if !IE]>
      <script type="text/javascript">jsFail = false;</script>
    <![endif]>
    <script type="text/javascript" src="static/js/jsprotect.js"></script>
    <script type="text/javascript" src="static/js/partialload.js"></script>
    <script type="text/javascript">var ui_tabs_active = {};</script>
  </head>
  <body>
    <div class="initiative_head">
<?
function printPosts($tid,&$i, &$posts, &$text)
{
  $text .= '<ul style="list-style-type: none;">';
  foreach ($posts as $post)
  {
    if ($post->data->author == 'Liquid')
      continue;
    $i++;
    $text .= '<li><b>'.$post->data->author.' (<a href="https://reddit.piratenpartei.at/comments/'.$tid.'#'.$post->data->id.'" target="_blank">Antworten</a>):</b> '.htmlspecialchars_decode($post->data->body_html);
    if ($post->data->replies)
      printPosts($tid,$i,$post->data->replies->data->children,$text);
    $text .= "</li>";
  }
  $text .= '</ul>';
}
$title = 'Noch keine Diskussionsbeiträge';
$text = '';
if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
{
  require("/opt/liquid_feedback_core/constants.php");

  $dbconn = pg_connect("dbname=lfbot") or die('Verbindungsaufbau fehlgeschlagen: ' . pg_last_error());

  $query = "SELECT forum FROM reddit_map WHERE lqfb = '" . $_SERVER["QUERY_STRING"] . "' LIMIT 1;";
  $result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
  $tid = 0;
  while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
    $tid = $line["forum"];
  }
  pg_free_result($result);

  pg_close($dbconn);
  $data = file_get_contents("https://reddit.piratenpartei.at/comments/$tid.json");
  if (strlen($data) < 100)
  {
    $text = "Noch keine Beiträge";
    return;
  }
  $data = json_decode($data);
  $data = $data[1]->data->children;
  $i = 0;
  printPosts($tid,$i,$data,$text);
  if ($i > 0)
  {
    $title = "$i Diskussionsbeiträge";
  }
  else
  {
    $title = 'Noch keine Diskussionsbeiträge';
    $text = '';
  }
}
echo<<<END
<a href="https://reddit.piratenpartei.at/comments/$tid" target="_blank" name="discussion" class="title anchor"><img src="static/icons/16/note.png" class="spaceicon" />$title</a>
<div class="content">
$text
END;
?>
</div>
</div>
</body>
</html>
