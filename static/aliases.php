<?
require("/opt/liquid_feedback_core/constants.php");
$password = $mail_pass;
$key = hash('SHA256', $password, true);
$iv = hash('md5', $password, true);

function aes256_encrypt($data, $key, $iv) {
        $block_size = mcrypt_get_block_size ("rijndael-128", "cbc");
        $pad = $block_size - (strlen ($data) % $block_size);
        if ( $pad <= 0 ) { $pad = 16; }
        $padded_data = $data.str_repeat (chr ($pad), $pad);
        $message = base64_encode( mcrypt_encrypt (MCRYPT_RIJNDAEL_128,
 $key, $padded_data, MCRYPT_MODE_CBC, $iv) );
        return $message;
}
function aes256_decrypt($data, $key, $iv ) {
        $block_size = mcrypt_get_block_size ("rijndael-128", "cbc");
        $message = mcrypt_decrypt (MCRYPT_RIJNDAEL_128, $key,
base64_decode($data), MCRYPT_MODE_CBC, $iv);
        $pad = ord(substr($message, -1));
        $message = substr( $message, 0, (0 - $pad) );
        return $message;
}

  $dbconn = pg_connect("dbname=liquid_feedback") or die('Verbindungsaufbau fehlgeschlagen: ' . pg_last_error());

  $query = "SELECT name FROM member WHERE name NOTNULL;";
  $result = pg_query($query) or die('Abfrage fehlgeschlagen: ' . pg_last_error());
  $names = "";
  while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
    $names .= $line['name'] . "\n";
  }
  pg_free_result($result);

  pg_close($dbconn);

  echo aes256_encrypt($names,$key,$iv);

?>
