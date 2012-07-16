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
		
		rtod = 57.29577951308323
		dtor = 0.0174532925
		
		xpix = [0..xsize]
		ypix = [0..ysize]
		
		ra = [0..xsize] 
		dec = [0..xsize] 		
			
		for i in [0..xsize]
			
			ra[i] = [0..ysize]
			dec[i] = [0..ysize]			
			
			for j in [0..ysize]
				
				# Step 2
				
				x = @parameters.cd11 * (xpix[i]-@parameters.crpix1) +
					@parameters.cd12 * (ypix[j]-@parameters.crpix2)
					
				y = @parameters.cd21 * (xpix[i]-@parameters.crpix1) +
					@parameters.cd22 * (ypix[j]-@parameters.crpix2)
				
				# Step 3
				
				long = Math.atan2(-y,x)
				lat = (Math.PI/2.0) * dtor
				
				r = Math.sqrt(Math.pow(x,2),Math.pow(y,2))
				
				if r > lat
					lat = Math.atan((180.0/Math.PI)/r)
				
				# Step 4
				
				l = Math.cos(lat)*Math.cos(long)
				m = Math.cos(lat)*Math.sin(long)
				n = Math.sin(lat)
				
				# TAN begin
				
				phi = 0.0 
				theta = 90.0 * dtor
				
				lonpole = if @parameters.crval2 > 0.0 then 0.0 else 180.0*dtor
				latpole = 90.0 * dtor
				rapole = @parameters.crval1 * dtor
				decpole = @parameters.crval2 * dtor
				
				r11 = -1.0*Math.sin(rapole)*Math.sin(lonpole) - 
					Math.cos(rapole)*Math.cos(lonpole)*Math.sin(decpole)
				r12 = Math.cos(rapole)*Math.sin(lonpole) - 
					Math.sin(rapole)*Math.cos(lonpole)*Math.sin(decpole)
				r13 = Math.cos(lonpole)*Math.cos(decpole)

				r21 = Math.sin(rapole)*Math.cos(lonpole) - 
					Math.cos(rapole)*Math.sin(lonpole)*Math.sin(decpole)
				r22 = -1.0*Math.cos(rapole)*Math.cos(lonpole) - 
					Math.sin(rapole)*Math.sin(lonpole)*Math.sin(decpole)
				r23 = Math.sin(lonpole)*Math.cos(decpole)

				r31 = Math.cos(rapole)*Math.cos(decpole)
				r32 = Math.sin(rapole)*Math.cos(decpole)
				r33 = Math.sin(decpole)
				
				mat = [ [r11,r12,r13], [r21,r22,r23], [r31,r32,r33] ]
				
				lp = mat[0][0]*l + mat[1][0]*m + mat[2][0]*n
				mp = mat[0][1]*l + mat[1][1]*m + mat[2][1]*n
				np = mat[0][2]*l + mat[1][2]*m + mat[2][2]*n

				dec[i][j] = Math.asin(np)*rtod
				ra[i][j] = Math.atan(mp,lp)*rtod
				
				if ra[i][j] < 0.0
					ra[i][j] += 360.0
				else if ra[i][j] > 360.0
					ra[i][j] -= 360
				