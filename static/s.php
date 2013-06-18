<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: https://liquid.piratenpartei.at/suggestion/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?>

