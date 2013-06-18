<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: https://liquid.piratenpartei.at/issue/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?>

