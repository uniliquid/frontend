<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: /liquid/initiative/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?> 
