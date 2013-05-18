<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: http://uniliquid.at/liquid/suggestion/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?>

