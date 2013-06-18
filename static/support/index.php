<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title>Support</title>
</head>

<body style="margin:50px; padding:50px;">
<?php
require("/opt/liquid_feedback_core/constants.php");

function dateForm()
{
$rest = '
<br />
<br />
<hr>
<br />
<br />
';
$query = "SELECT name,next_time FROM auto_freeze;";
$result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
$rest .= '
Next date for <b>' . $line['name'] . '</b>: ' . $line['next_time'] . '<br />
';
}
pg_free_result($result);
$rest .= '
Set next date for:
<form method="POST">
<select name="date_id">
';
$query = "SELECT id,name,next_time FROM auto_freeze;";
$result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
$rest .= '
<option value="'.$line['id'].'">' . $line['name'] . '</option>
';
}
pg_free_result($result);
$rest .= '
</select>
<br />
<input type="text" size="30" name="date" value="">
<input type="submit" name="changedate" value="Set Date"><br />
</form>
';
return $rest;
}

$rest = '';

$dbconn = pg_connect("dbname=liquid_feedback")
  or die('Verbindungsaufbau fehlgeschlagen: ' . pg_last_error());

$searchbox = 1;
if (isset($_POST["action"]) && preg_match("/^[a-z ]+$/i", $_POST["action"]) == 1 && isset($_POST["id"]) && preg_match("/^[0-9]+$/", $_POST["id"]) == 1)
{
  $a = $_POST["action"];
  $id = $_POST["id"];
  if ($a == "Send password reset link")
  {
    echo 'Sent password reset link...';
    exec('cd /opt/liquid_feedback_frontend && echo "Member:send_password_reset('.$id.')" | ../webmcp/bin/webmcp_shell myconfig');
  }
  else if ($a == "Send invitation")
  {
    exec("/opt/liquid_feedback_core/sendinvitation.sh $id");
    echo 'Sent invitation';
  }
  else if ($a == "Show Admidio ID")
  {
    $query = "SELECT identification FROM member WHERE id = $id;";
    $result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
    if (isset($_POST["password"]) && pg_num_rows($result) > 10) {
      echo 'Too many results...';
    }
    elseif ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
      $decrypted = rtrim(mcrypt_decrypt(MCRYPT_RIJNDAEL_256, md5($_POST["password"]), base64_decode($line["identification"]), MCRYPT_MODE_CBC, md5(md5($_POST["password"]))), "\0");
      echo 'Admidio ID is: ' . $decrypted;
    }
    pg_free_result($result);
  }
  else if ($a == "Deactivate Account")
  {
    $query = "UPDATE member SET active = false,activated = null,last_activity = null,password = null WHERE id = $id;";
    $result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
    echo 'Account deactivated. Email will be copied from admidio on next full hour. Invitation will be send then as well.';
    if (pg_affected_rows($result) != 1)
    {
      echo '<br />Something went wrong... ' . pg_affected_rows($result) . ' users deactivated! please tell the admin about this error!';
    }
    pg_free_result($result);
  }
echo '
<hr>
';
}
if (isset($_POST["id"]) && preg_match("/^[0-9]+$/", $_POST["id"]) == 1)
{
$id = $_POST["id"];

$query = "SELECT id,login,locked,active,created,activated,last_login,notify_email,name,identification FROM member WHERE id = $id;";
$result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
if (pg_num_rows($result) > 10) {
echo 'Too many results...';
}
else {
if ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
echo '
<form method="POST">
    <p>
       <table border=1><tr><td><table border=0>
       <tr><td>id</td><td>'.$line["id"].'</td></tr>
       <tr><td>login</td><td>'.$line["login"].'</td></tr>
       <tr><td>name</td><td>'.$line["name"].'</td></tr>
       <tr><td>email</td><td>'.$line["notify_email"].'</td></tr>
       <tr><td>account created</td><td>'.$line["created"].'</td></tr>
       <tr><td>account activated</td><td>'.$line["activated"].'</td></tr>
       <tr><td>last login</td><td>'.$line["last_login"].'</td></tr>
       <tr><td>account active</td><td>'.($line["active"] == 't'?'Yes':'No').'</td></tr>
       <tr><td>locked (no voting right)</td><td>'.($line["locked"] == 't'?'Yes':'No').'</td></tr>
       <tr><td>identification</td><td>'.$line["identification"].'</td></tr>
       <tr><td>action<input type="hidden" name="id" value="'.$line["id"].'"></td>
           <td><input type="submit" name="action" value="Send password reset link"></td></tr>
'.($line["active"] == 't'?'':'
       <tr><td></td>
           <td><input type="submit" name="action" value="Send invitation"></td></tr>
').'
       <tr><td>Admidio Decryption Password: <input type="password" name="password" size="20" value=""></td>
           <td><input type="submit" name="action" value="Show Admidio ID"></td></tr>
       <tr><td></td>
           <td><input type="submit" name="action" value="Deactivate Account"> (inactive accounts are reinvited automatically and set to the mail addr from admidio)</td></tr>
</table></td></tr></table>
    </p>
</form>
';
}
}
pg_free_result($result);
echo '
<hr>
';
}
else if (isset($_POST["str"]) && preg_match("/^[a-z0-9@äöü ]+$/i", $_POST["str"]) == 1)
{
$s = $_POST["str"];

$query = "SELECT id,login,locked,active,created,activated,last_login,notify_email,name,identification FROM member WHERE lower(invite_code) LIKE '%".strtolower($s)."%' OR lower(login) LIKE '%".strtolower($s)."%' OR lower(notify_email) LIKE '%".strtolower($s)."%' OR lower(name) LIKE '%".strtolower($s)."%' OR lower(identification) LIKE '%".strtolower($s)."%' OR lower(authentication) LIKE '%".strtolower($s)."%' OR lower(organizational_unit) LIKE '%".strtolower($s)."%' OR lower(realname) LIKE '%".strtolower($s)."%' OR lower(address) LIKE '%".strtolower($s)."%' OR lower(email) LIKE '%".strtolower($s)."%' OR lower(xmpp_address) LIKE '%".strtolower($s)."%' OR lower(website) LIKE '%".strtolower($s)."%';";
$result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
if (pg_num_rows($result) > 20) {
echo 'Too many results...';
}
else {
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
echo '
<form method="POST">
    <p>
       <table border=1><tr><td><table border=0>
       <tr><td>id</td><td>'.$line["id"].'</td></tr>
       <tr><td>login</td><td>'.$line["login"].'</td></tr>
       <tr><td>name</td><td>'.$line["name"].'</td></tr>
       <tr><td>email</td><td>'.$line["notify_email"].'</td></tr>
       <tr><td>account created</td><td>'.$line["created"].'</td></tr>
       <tr><td>account activated</td><td>'.$line["activated"].'</td></tr>
       <tr><td>last login</td><td>'.$line["last_login"].'</td></tr>
       <tr><td>account active</td><td>'.($line["active"] == 't'?'Yes':'No').'</td></tr>
       <tr><td>locked (no voting right)</td><td>'.($line["locked"] == 't'?'Yes':'No').'</td></tr>
       <tr><td>identification</td><td>'.$line["identification"].'</td></tr>
       <tr><td>select this one<input type="hidden" name="id" value="'.$line["id"].'"></td>
           <td><input type="submit" name="submit" value="Select"></td></tr></table></td></tr></table>
    </p>
</form>
';
}
}
pg_free_result($result);
echo '
<hr>
';
}
else if (isset($_POST["changedate"]) AND isset($_POST["date"]) AND isset($_POST["date_id"]) AND preg_match("/^\d+$/i",$_POST["date_id"]) == 1 AND preg_match("/^[\d- :+]+$/i",$_POST["date"]) == 1)
{
$query = "UPDATE auto_freeze SET next_time = '".$_POST["date"]."' WHERE id = ".$_POST["date_id"].";";
$result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
if ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
}
pg_free_result($result);
$s = '';
$rest = dateForm();
}
else
{
echo 'Please enter string to search for';
$s = '';
$rest = dateForm();
}
echo '
<form method="POST">
    <p><input type="text" size="40" name="str" value="'.$s.'">
       <input type="submit" name="submit" value="Search">
    </p>
</form>
';
echo $rest;
pg_close($dbconn);
?>
</body>
</html>
<?php

?>
