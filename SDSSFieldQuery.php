<?php
	
	error_reporting(-1);
	
	// $_GET["ra"] = 0;
	// $_GET["dec"] = 0;	
	// $_GET["radius"] = 10;	
	// $_GET["zoom"] = 0;	
	
	$flag = false
		
/* parse the xml to get the fields to wget with*/

	function sdss_fix ($input) {
		// convert input into array of lines
		// http://php.net/manual/en/function.preg-split.php
		$lines = preg_split('/\n/', $input);

		// debugging
		// http://us2.php.net/manual/en/function.print-r.php
		//print_r($lines);

		$found_row = 0;
		$output = "";
		//$count = 0;

		// traverse over array of lines
		// http://us2.php.net/manual/en/control-structures.foreach.php
		foreach ($lines as $oneline) {
			// http://us2.php.net/manual/en/function.preg-match.php
			if (preg_match("/<Row>/i", $oneline)) {
				// regular row
				$found_row = 1;
				$output .= $oneline. "\n";
				$count++;

			} elseif (!$found_row) {
				// header info
				$output .= $oneline. "\n";

			} else {
				// extra tags, ignore
			}
		}
		$output .= "</Answer></root>";

		//print "==== $count ====\n";
		return $output;
	}

	function parseSDSS($output) {
			
			$element = explode("<row>", $output);
			      
			$xml = new SimpleXMLElement($output);
        
				$xpath_run = "//field[@col='run']";
        $xpath_camcol  = "//field[@col='camcol']";
				$xpath_rerun = "//field[@col='rerun']";
        $xpath_field  = "//field[@col='field']";
				
        $out_run = $xml->xpath($xpath_run);
        $out_camcol = $xml->xpath($xpath_camcol);
				$out_rerun = $xml->xpath($xpath_rerun);
        $out_field = $xml->xpath($xpath_field);
        
        $imagefields = array();
        
        $i = 0;
        while(list( , $node) = each($out_run)) {
            $imagefields[$i] = array(trim($node), 0);
            $i++;
        }
        
        $i = 0;
        while(list( , $node) = each($out_camcol)) {
            $imagefields[$i][1] = trim($node);
            $i++;
        }

				$i = 0;
	        while(list( , $node) = each($out_rerun)) {
	            $imagefields[$i][2] = trim($node);
	            $i++;
	        }
				$i = 0;
	      while(list( , $node) = each($out_field)) {
	          $imagefields[$i][3] = trim($node);
	          $i++;
	      }
        
        return $imagefields;
  }

/* parse the query and wget images */

	function getImages($output){
				
		$out = parseSDSS($output);
		
//		$File = "sdss-wget.lis";
//		$fh = fopen($File, 'w');
		$ret_val = array();
		
		// Construct a file with a list of the jpeg and fits urls, one on each line
		foreach($out as $imageFields){
		
			/* JPEGS
			* $jpegurl = http://das.sdss.org/imaging/$run/$rerun/Zoom/$camcol/$filename
			*	$filename = fpC-$run-$camcol-$rerun-$field-z00.jpeg (z00 = zoom in 00,10,15,20,30)
			* In $filename, run is padded to a total of 6 digits and field is padded to a total of 4 digits
			* $imageFields = array(run, camcol, rerun, field) 
			*/

			/*FITS
			* $fitsurl = http://das.sdss.org/imaging/$run/$rerun/corr/$camcol/$filename
			*	$filename = fpC-$run-filter$camcol-$field.fit.gz
			*In $filename, run is padded to a total of 6 digits and field is padded to a total f 4 digits
			*$imageFields = array(run, camcol, rerun, field)
			*/

			$jpegurl = "http://das.sdss.org/imaging/" . $imageFields[0] . "/" . $imageFields[2] . "/Zoom/" . $imageFields[1] . "/fpC-" . str_pad($imageFields[0],6,"0",STR_PAD_LEFT) . "-" . $imageFields[1] . "-" . $imageFields[2] . "-" . str_pad($imageFields[3],4,"0",STR_PAD_LEFT) . "-z00.jpeg";
			$fitsurl = "http://das.sdss.org/imaging/" . $imageFields[0] . "/" . $imageFields[2] . "/corr/" . $imageFields[1] . "/fpC-" . str_pad($imageFields[0],6,"0",STR_PAD_LEFT) . "-r" . $imageFields[1] . "-" . str_pad($imageFields[3],4,"0",STR_PAD_LEFT) . ".txt";			

			// Testing - prints out each url as a link

			$jpegname = "fpC-" . str_pad($imageFields[0],6,"0",STR_PAD_LEFT) . "-" . $imageFields[1] . "-" . $imageFields[2] . "-" . str_pad($imageFields[3],4,"0",STR_PAD_LEFT) . "-z00.jpeg";
			$textname = "fpC-" . str_pad($imageFields[0],6,"0",STR_PAD_LEFT) . "-r" . $imageFields[1] . "-" . str_pad($imageFields[3],4,"0",STR_PAD_LEFT) . ".txt";
			
			if($flag == true)
				array_push($ret_val, $jpegurl);
			else
				array_push($ret_val, $jpegname);
				
			array_push($ret_val, $textname);
			
			$jpegStringData = "$jpegurl\n";
			$fitsStringData = "$fitsurl\n";
			
//			fwrite($fh, $jpegStringData);
//			fwrite($fh, $fitsStringData);
			
		}
		
//		fclose($fh); 
		
		echo json_encode($ret_val);
		
//		$inputfile = "sdss-wget.lis";            
//		$cmd = "wget -nd -nH -q -i $inputfile -P ./sdss";

//		exec($cmd);

//		$unzipcmd = "gunzip ./sdss/*.gz";
//		exec($unzipcmd);
	}
	
	$file = "http://astro.cs.pitt.edu/tim/timCurrent/lib/db/remote/searchSDSS.php";
	
	$the_query = "SELECT distinct n.fieldid, n.distance, f.ra, f.dec, f.run, f.rerun, f.camcol, f.field, dbo.fHTMGetString(f.htmid) as htmid FROM dbo.fGetNearbyFrameEq(" . $_GET["ra"] . "," . $_GET["dec"] . "," . $_GET["radius"] . "," . $_GET["zoom"] . ") as n JOIN Frame as f on n.fieldid = f.fieldid ORDER by n.distance";
//	echo $the_query;		
	$url = $file;
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLINFO_HEADER_OUT, 1);	
	// Set overlay to 1 if you want the original xml and don't use if want a json object
	$fields_string = array('query' => $the_query, 'overlay' => 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields_string);
	// Return the output as a string instead of printing it out
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
	$output = curl_exec($ch);
	
	$headers = curl_getinfo($ch, CURLINFO_HEADER_OUT);
//	echo "curl string $headers\n\n";
//	echo "\n\ncurl: $output\n";
	curl_close($ch);
	
	$fix = sdss_fix($output);	
			
	getImages($output);
	
?>
