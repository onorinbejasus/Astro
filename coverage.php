<?php

header("Content-type: text/html");

function parseRange($output){
	
	echo $output;
	
}
$file = "http://astro.cs.pitt.edu/Tim/panickos/astro-demo/lib/db/remote/searchSDSS.php";

$the_query = "SELECT * FROM dbo.fHtmCoverRegion('CIRCLE LATLON 39.3008 -76.610616 30')";
//	echo $the_query;		
$url = $file;
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 1);
// Set overlay to 1 if you want the original xml and don't use if want a json object
$fields_string = array('query' => $the_query, 'overlay' => 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
// Return the output as a string instead of printing it out
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
$output = curl_exec($ch);
curl_close($ch);

parseRange($output);

?>