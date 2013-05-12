<?php
   if (ereg("^[0-9]+$", $_SERVER["QUERY_STRING"]))
   {
     header("Location: http://gruss.cc:8080/initiative/show/" . $_SERVER["QUERY_STRING"] . ".html");
   }
?> 
