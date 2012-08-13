class Projection
	constructor:(@Math)->
		@parameters = null

	init:(image,fits,HTM, survey)=>
		
		if survey == "SDSS"
			size = [1984,1361]
		else if survey == "LSST"
			size = [4072,4000]
			
		FITS = require('fits')
		
		@parameters = new Object
		###
		$.ajaxSetup({'async': false})
		# grab the image headers
		$.getJSON("../Astro/imageHeader.php?url=#{image}", (data) =>
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
		$.ajaxSetup({'async': true})
		
		###
		
		xhr = new XMLHttpRequest()
		
		xhr.responseType = 'arraybuffer';
		xhr.open('GET', fits)

		xhr.onload = (e) =>

			fits = new FITS.File(xhr.response)
			hdu = fits.getHDU()
			
			@parameters.ctype1 = hdu.getCard("CTYPE1")
			@parameters.ctype1 = hdu.header["CTYPE1"]
			
			@parameters.ctype2 = hdu.getCard("CTYPE2")
			@parameters.ctype2 = hdu.header["CTYPE2"]
			
			@parameters.crpix1 = hdu.getCard("CRPIX1")
			@parameters.crpix1 = hdu.header["CRPIX1"]

			@parameters.crpix2 = hdu.getCard("CRPIX2")
			@parameters.crpix2 = hdu.header["CRPIX2"]

			@parameters.crval1 = hdu.getCard("CRVAL1")
			@parameters.crval1 = hdu.header["CRVAL1"]

			@parameters.crval2 = hdu.getCard("CRVAL2")
			@parameters.crval2 = hdu.header["CRVAL2"]

			@parameters.cd11 = hdu.getCard("CD1_1")
			@parameters.cd11 = hdu.header["CD1_1"]

			@parameters.cd12 = hdu.getCard("CD1_2")
			@parameters.cd12 = hdu.header["CD1_2"]

			@parameters.cd21 = hdu.getCard("CD2_1")
			@parameters.cd21 = hdu.header["CD2_1"]

			@parameters.cd22 = hdu.getCard("CD2_2")
			@parameters.cd22 = hdu.header["CD2_2"]
		
			coords = this.unproject(size[0],size[1])
			
			HTM.initTexture(image)
			HTM.createSphere(coords[0],coords[1])
			HTM.setFlag()
			
		xhr.send()
		
		return
	
	unproject: (xsize, ysize) =>

		#console.log @parameters
	
		rtod = 57.29577951308323
		dtor = 0.0174532925

		xpix = [1..xsize]
		ypix = [1..ysize]

		ra = [0..3]
		dec = [0..3]

		indices = [[0,0],[0,ysize-1],[xsize-1,ysize-1],[xsize-1,0]]

		crval = [@parameters.crval1,@parameters.crval2]

		#console.log "crval1,2: ", crval
		#console.log "cd11: ",@parameters.cd11
		#console.log "cd12: ",@parameters.cd12
		#console.log "cd21: ",@parameters.cd21
		#console.log "cd22: ",@parameters.cd22

		for index in [0..3]

			i = indices[index][0]
			j = indices[index][1]

			# Step 2 (values check out with mine)

			x = @parameters.cd11 * (xpix[i]-@parameters.crpix1) +
			        @parameters.cd12 * (ypix[j]-@parameters.crpix2)

			y = @parameters.cd21 * (xpix[i]-@parameters.crpix1) +
			        @parameters.cd22 * (ypix[j]-@parameters.crpix2)

			#flip for 0,0 region
			#tmp = x
			#x = y
			#y = tmp
			#if index == 0
			#       crval = @Math.rotate(crval)
			
			if @parameters.ctype1 == "DEC--TAN"
				tmp = x
				x = y
				y = tmp
				if index == 0
					crval = @Math.rotate(crval)
			
			#console.log "new crval: ", crval

			#console.log "x,y: ", x, y

			# Step 3 (long checks out, lat does not)

			long = @Math.arg(-y,x)
			lat = (Math.PI/2.0) * dtor

			r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2))

			if r > 0.0
			        lat = Math.atan((180.0/Math.PI)/r)

			#console.log "rtod", rtod
			#console.log "r", r

			lat = Math.atan(rtod/r)

			#console.log "long,lat: ", long,lat

			# Step 4 (l,m,n off)

			l = Math.cos(lat)*Math.cos(long)
			m = Math.cos(lat)*Math.sin(long)
			n = Math.sin(lat)

			#console.log "l,m,n",l,m,n

			# TAN begin (lonlat pole and radec pole consistent with mine)
			phi = 0.0
			theta = 90.0 * dtor

			lonpole = if crval[1] > theta*rtod then 0.0 else 180.0*dtor
			#lonpole = 180.0*dtor
			latpole = 90.0 * dtor
			rapole = crval[0] * dtor
			decpole = crval[1] * dtor

			#console.log "lonlatpole,thetaphi: ",lonpole,latpole,theta,phi
			#console.log "ra,dec pole: ", rapole, decpole

			# (all r values consistent with mine)
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

			#console.log "r11,12,13: ", r11, r12, r13
			#console.log "r21,22,23: ", r21, r22, r23
			#console.log "r31,32,33: ", r31, r32, r33

			mat = [ [r11,r21,r31], [r12,r22,r32], [r13,r23,r33] ]

			# (lp,mp,np values off)
			lp = mat[0][0]*l + mat[0][1]*m + mat[0][2]*n
			mp = mat[1][0]*l + mat[1][1]*m + mat[1][2]*n
			np = mat[2][0]*l + mat[2][1]*m + mat[2][2]*n

			#console.log "lp,mp,np: ", lp,mp,np

			dec[index] = Math.asin(np)*rtod
			ra[index] = Math.atan2(mp,lp)*rtod

			if ra[index] < 0.0   
			        ra[index] += 360.0
			else if ra[index] > 360.0
			        ra[index] -= 360 

		console.log "ra,dec: ",ra, dec

		return [ra,dec]