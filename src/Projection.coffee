class Projection
	constructor:(@Math)->
		@parameters = null

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
		
		xpix = [1..xsize]
		ypix = [1..ysize]
		
		ra = [0..1] 
		dec = [0..1] 		
			
		indices = [[0,0],[xsize-1,ysize-1]]
		console.log @parameters
		
		for index in [0..1]
			
			i = indices[index][0]
			j = indices[index][1]
			
			console.log i, j
			
			# Step 2
				
			y = @parameters.cd11 * (xpix[i]-@parameters.crpix1) +
				@parameters.cd12 * (ypix[j]-@parameters.crpix2)
				
			x = @parameters.cd21 * (xpix[i]-@parameters.crpix1) +
				@parameters.cd22 * (ypix[j]-@parameters.crpix2)
			
			# Step 3
			
			long = @Math.arg(-y,x)
			lat = (Math.PI/2.0) * dtor
			
			r = Math.sqrt(Math.pow(x,2),Math.pow(y,2))
			
			if r > 0.0
				lat = Math.atan((180.0/Math.PI)/r)
			
			# Step 4
			
			l = Math.cos(lat)*Math.cos(long)
			m = Math.cos(lat)*Math.sin(long)
			n = Math.sin(lat)
			
			# TAN begin
			
			phi = 0.0 
			theta = 90.0 * dtor
			
			lonpole = if @parameters.crval1 > theta then 0.0 else 180.0*dtor
			latpole = 90.0 * dtor
			rapole = @parameters.crval2 * dtor
			decpole = @parameters.crval1 * dtor
							
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
			
			mat = [ [r11,r21,r31], [r12,r22,r32], [r13,r23,r33] ]
			
			lp = mat[0][0]*l + mat[0][1]*m + mat[0][2]*n
			mp = mat[1][0]*l + mat[1][1]*m + mat[1][2]*n
			np = mat[2][0]*l + mat[2][1]*m + mat[2][2]*n
							
			dec[index] = Math.asin(np)*rtod
			ra[index] = Math.atan2(mp,lp)*rtod
			
			if ra[index] < 0.0
				ra[index] += 360.0
			else if ra[index] > 360.0
				ra[index] -= 360
				
		return [ra,dec]