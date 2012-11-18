class Projection
	constructor:(@Math)->
		@parameters = null

	init:(image,fits,Tile,survey)=>

		if survey == "SDSS"
			size = [2048,1489]
			console.log "init"
		else if survey == "LSST"
			size = [4072,4000]
		else if survey == 'FIRST'
			size = [1550,1160]

		FITS = require('fits')

		@parameters = new Object

		if survey == "LSST" || survey == "FIRST"
			#read JPEG headers
			$.ajaxSetup({'async': false})
			# grab the image headers
			$.getJSON("./lib/skyview/imageHeader.php?url=#{image}&survey=#{survey}&type=JPEG", (data) =>
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
					if key == "CTYPE_1"
						@parameters.ctype1 = val
					if key == "CTYPE_2"
						@parameters.ctype2 = val
					if key == "CDELT_1"
						@parameters.cdelt1 = val
					if key == "CDELT_2"
						@parameters.cdelt2 = val
				)
			)
			$.ajaxSetup({'async': true})

			if survey == "LSST"
				coords = this.unprojectTAN(size[0],size[1])
				Tile.initTexture("http://astro.cs.pitt.edu/lsstimages/#{image}")
			else if survey == "FIRST"
				coords = this.unprojectSIN(size[0],size[1])
				Tile.initTexture("http://astro.cs.pitt.edu/FIRST/images/#{image}")

			Tile.createTile(coords[0],coords[1])
			Tile.setFlag()			

		else if survey == "SDSS"

			$.ajaxSetup({'async': false})

			# grab the image headers
			$.getJSON("./lib/skyview/imageHeader.php?url=#{fits}&type=TEXT&survey=SDSS", (data) =>
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
					if key == "CTYPE1"
						@parameters.ctype1 = val
					if key == "CTYPE2"
						@parameters.ctype2 = val
				)
			)
			
			$.ajaxSetup({'async': true})
			
			console.log @parameters
			
			coords = this.unprojectTAN(size[0],size[1])

			Tile.initTexture(image)
			Tile.createTile(coords[0],coords[1])
			Tile.setFlag()

		return
	unprojectSIN: (xsize, ysize) =>

		#console.log @parameters

		rtod = 57.29577951308323
		dtor = 0.0174532925

		xpix = [1..xsize]
		ypix = [1..ysize]

		ra = [0..3]
		dec = [0..3]

		indices = [[0,0],[0,ysize-1],[xsize-1,ysize-1],[xsize-1,0]]

		crval = [@parameters.crval1,@parameters.crval2]

		###
		console.log "crval1,2: ", crval
		console.log "cd11: ",@parameters.cd11
		console.log "cd12: ",@parameters.cd12
		console.log "cd21: ",@parameters.cd21
		console.log "cd22: ",@parameters.cd22
		###

		for index in [0..3]

			i = indices[index][0]
			j = indices[index][1]

			# Step 2 (values check out with mine)

			x = @parameters.cdelt1 * (xpix[i]-@parameters.crpix1)

			y = @parameters.cdelt2 * (ypix[j]-@parameters.crpix2)

			 #FITS 
			#flip for 0,0 region
			if @parameters.ctype1 == "DEC--SIN"
				tmp = x
				x = y
				y = tmp
				if index == 0
				       crval = @Math.rotate(crval)
			###			
			 #JPEG - do manually for some regions
			tmp=x
			x=y
			y=tmp
			if index == 0
				crval = @Math.rotate(crval)
			###

			#console.log "new crval: ", crval
			#console.log "x,y: ", x, y

			# Step 3 Unprojection

			long = @Math.arg(-y,x)  #phi
			r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2))
			lat = Math.acos(r/rtod) #theta

			#console.log "long,lat: ", long,lat

			# Step 4 convert latitude and longitude to ra,dec

			coords = this.convertradec(long,lat,crval)
			ra[index] = coords[0]
			dec[index] = coords[1]	

		#console.log "ra,dec: ",ra, dec

		return [ra,dec]

	unprojectTAN: (xsize, ysize) =>

		#console.log @parameters

		rtod = 57.29577951308323
		dtor = 0.0174532925

		xpix = [1..xsize]
		ypix = [1..ysize]

		ra = [0..3]
		dec = [0..3]

		indices = [[0,0],[0,ysize-1],[xsize-1,ysize-1],[xsize-1,0]]

		crval = [@parameters.crval1,@parameters.crval2]
		###
		console.log "crval1,2: ", crval
		console.log "cd11: ",@parameters.cd11
		console.log "cd12: ",@parameters.cd12
		console.log "cd21: ",@parameters.cd21
		console.log "cd22: ",@parameters.cd22
		###

		for index in [0..3]

			i = indices[index][0]
			j = indices[index][1]

			# Step 2 (values check out with mine)

			x = @parameters.cd11 * (xpix[i]-@parameters.crpix1) +
			        @parameters.cd12 * (ypix[j]-@parameters.crpix2)

			y = @parameters.cd21 * (xpix[i]-@parameters.crpix1) +
			        @parameters.cd22 * (ypix[j]-@parameters.crpix2)

			 #FITS 
			#flip for 0,0 region
			if @parameters.ctype1 == "DEC--TAN"
				tmp = x
				x = y
				y = tmp
				if index == 0
				       crval = @Math.rotate(crval)
			###			
			 #JPEG - do manually for some regions
			tmp=x
			x=y
			y=tmp
			if index == 0
				crval = @Math.rotate(crval)
			###

			#console.log "new crval: ", crval
			#console.log "x,y: ", x, y

			# Step 3 Unprojection

			long = @Math.arg(-y,x)  #phi
			lat = (Math.PI/2.0) * dtor  #theta

			r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2))

			if r > 0.0
			        lat = Math.atan((180.0/Math.PI)/r)

			#console.log "rtod", rtod
			#console.log "r", r

			lat = Math.atan(rtod/r)

			#console.log "long,lat: ", long,lat

			# Step 4 convert latitude and longitude to ra,dec

			coords = this.convertradec(long,lat,crval)
			ra[index] = coords[0]
			dec[index] = coords[1]

		#console.log "ra,dec: ",ra, dec

		return [ra,dec]

	convertradec: (long,lat,crval) =>

		rtod = 57.29577951308323
		dtor = 0.0174532925

		l = Math.cos(lat)*Math.cos(long)
		m = Math.cos(lat)*Math.sin(long)
		n = Math.sin(lat)

		#console.log "l,m,n",l,m,n

		# TAN begin (lonlat pole and radec pole consistent with mine)
		phi = 0.0
		theta = 90.0 * dtor

		lonpole = if crval[1] > theta*rtod then 0.0 else 180.0*dtor
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

		lp = mat[0][0]*l + mat[0][1]*m + mat[0][2]*n
		mp = mat[1][0]*l + mat[1][1]*m + mat[1][2]*n
		np = mat[2][0]*l + mat[2][1]*m + mat[2][2]*n

		#console.log "lp,mp,np: ", lp,mp,np

		dec = Math.asin(np)*rtod
		ra = Math.atan2(mp,lp)*rtod

		if ra < 0.0
		 ra += 360.0
		else if ra > 360.0
			ra -= 360

		#console.log "ra,dec: ",ra, dec

		return [ra,dec]
