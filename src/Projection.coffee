class Projection
	constructor:->
		@parameters = null
		this.getHeader("./images/testframe.jpeg")
		coords = this.unproject(499,499)

	getHeader:(image)=>
		@parameters = new Object
		
		$.ajaxSetup({'async': false});

		# grab the image headers
		$.getJSON("./imageHeader.php?url=#{image}", (data) =>
			$.each(data, (key, val) =>
				if key == "CRVAL_1"
					@parameters.crval1 = val
				if key == "CRVAL_2"
					@parameters.crval2 = val
				if key == "CRPIX_1"
					@parameters.crpix1 = val
				if key == "CRPIX_2"
					@parameters.crpix2 = val
				if key == "CD1_1"
					@parameters.cd11 = val
				if key == "CD1_2"
					@parameters.cd12 = val
				if key == "CD2_1"
					@parameters.cd21 = val
				if key == "CD2_2"
					@parameters.cd22 = val
			)
		)
		
		$.ajaxSetup({'async': true});
		
		return
	
	unproject: (xsize, ysize)=>
		
		xpix = [0..xsize]
		ypix = [0..ysize]
		
		x = [0..xsize]
		y = [0..xsize]
		
		long = [0..xsize]
		lat = [0..xsize] 
				
		for i in [0..xsize]
			
			x[i] = [0..ysize]
			y[i] = [0..ysize]
			lat[i] = [0..ysize]
			long[i] = [0..ysize]
			
			for j in [0..ysize]
			
				x[i][j] = @parameters.cd11 * (xpix[i]-@parameters.crpix1) +
					@parameters.cd12 * (ypix[j]-@parameters.crpix2)
					
				y[i][j] = @parameters.cd21 * (xpix[i]-@parameters.crpix1) +
					@parameters.cd22 * (ypix[j]-@parameters.crpix2)
				
				long[i][j] = Math.atan2(-y[i][j],x[i][j])
				lat[i][j] = Math.PI/2.0
				
				r = Math.sqrt(Math.pow(x[i][j],2),Math.pow(y[i][j],2))
				
				if r > lat[i][j]
					lat[i][j] = Math.atan((180.0/Math.PI)/r)
					
		return [lat,long]
		
		