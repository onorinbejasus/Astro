<?php

header("Content-type: text/plain");

error_reporting(-1);
set_error_handler('exceptions_error_handler');

$url = $_GET['url'];
exec("./bin/jhead $url", $data, $ret);

$ret_val = array(
	"CRVAL_1" => 0,
	"CRVAL_2" => 0,
	"CRPIX_1" => 0,
	"CRPIX_2" => 0,
	"CD1_1" => 0,
	"CD1_2" => 0,
	"CD2_1" => 0,
	"CD2_2" => 0
);

function exceptions_error_handler($severity, $message, $filename, $lineno) {
  if (error_reporting() == 0) {
    return;
  }
  if (error_reporting() & $severity) {
    throw new ErrorException($message, 0, $severity, $filename, $lineno);
  }
}

foreach($data as $line){
	$values = explode(" : ", $line);
	foreach($values as $v){
		if(strncmp("CRVAL1",$v,6) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CRVAL_1"] = $float;
		}
		else if(strncmp("CRVAL2",$v,6) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CRVAL_2"] = $float;
		}
		else if(strncmp("CRPIX1",$v,6) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);	
			$ret_val["CRPIX_1"] = $float;
		}
		else if(strncmp("CRPIX2",$v,6) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CRPIX_2"] = $float;
		}
		else if(strncmp("CD1_1",$v,5) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CD1_1"] = $float;
		}
		else if(strncmp("CD1_2",$v,5) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CD1_2"] = $float;
		}
		else if(strncmp("CD2_1",$v,5) == 0){
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CD2_1"] = $float;
		}
		else if(strncmp("CD2_2",$v,5) == 0){
			$value = 0;
			$value = explode("=",$v);
			$float = floatval($value[1]);
			$ret_val["CD2_2"] = $float;
		}
	}
}

echo json_encode($ret_val);

?>