<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: /liquid/suggestion/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?>

