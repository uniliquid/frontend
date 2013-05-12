<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: http://gruss.cc/suggestion/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?>

