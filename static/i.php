<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: https://lqfb.piratenpartei.at/initiative/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?> 
