<?php

header("Content-type: text/plain");

error_reporting(-1);

$url = $_GET['url'];

$ret = array();

exec("/afs/cs.pitt.edu/usr0/tbl8/public/html/Astro/bin/jhead -h", $data, $ret);

foreach($data as $line)
	echo "$line \n";
	
echo $ret;

?>