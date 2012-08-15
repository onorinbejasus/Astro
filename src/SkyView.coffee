#= require WebGL

class SkyView extends WebGL
	
	@gridBlocks = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	@it = 0
	@selected = "none"
	@SDSSalpha = null
	
	@lsstarray = null
	@firstarray = null
		
	constructor: (options) ->
	
		#init webgl
		super(options)
		
		#init htm variables
		@translation = [0.0, 0.0, 0.99333]
		@rotation = [0.0, 0.0, 0.0]
		@renderMode = @gl.TRIANGLES
		@SDSSalpha = 1.0
		@FIRSTalpha = 1.0
		@LSSTalpha = 1.0
			
		# init math, grid and projection
		@Math = new math()
		@gridBlocks = []

		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		###
		@firstarray = []
		@firstflag = false
		ffile = new XMLHttpRequest()
		ffile.open('GET', './firstimages/filelist.txt',true) 
		ffile.onload = (e) =>
			text = ffile.responseText
			lines = text.split("\n")
			$.each(lines, (key,val) =>
				@firstarray.push val
			)
			@firstflag = true
			#console.log "first,lsst flags 1: ", @firstflag, @lsstflag
			if @firstflag == true && @lsstflag == true
				this.render(true)
		ffile.send()
		###
		
		@firstflag = true
		
		#init lsst array of path names
		@lsstarray = []
		@lsstflag = false
		lfile = new XMLHttpRequest()
		lfile.open('GET', '../lsstimages/filelist.txt',true)   #this path should change to the full path on astro server /u/astro/images/LSST/jpegfiles.txt
		lfile.onload = (e) =>
			text = lfile.responseText
			lines = text.split("\n")
			$.each(lines, (key,val) =>
				@lsstarray.push val
			)

			@lsstflag = true
			#console.log "first,lsst flags 2: ", @firstflag, @lsstflag
			if @firstflag == true && @lsstflag == true
				this.render(true)
		lfile.send()
		
	setSDSSAlpha :(value)=>
	
		@SDSSalpha = value
		this.render()
	setFIRSTAlpha :(value)=>

		@SDSSalpha = value
		this.render()
	setLSSTAlpha :(value)=>

		@LSSTalpha = value
		this.render()
	
	setScale:(value)=>
		$('#Scale').text(((value+1)*15).toFixed(2))
		return
		
	createOverlay: (raDec, raMin, raMax, decMin, decMax, color, label)=>
			
		scale = ((-@translation[2]+1)*15) * 3600
				
		img = ''
		
		$.ajaxSetup({'async': false})	
		
		$.ajax(
			type: 'POST',
			url: "./lib/createOverlay.php",
			data: 	
				'width':512,
				'height':512
				'RAMin':raMin,
				'RAMax':raMax,
				'DecMin':decMin,
				'DecMax':decMax,
				'scale':1.8,
				'diam':2,
				'color':color,
				'table':JSON.stringify(raDec)
			success:(data)=>
				img = data
				return
		)		
		
		$.ajaxSetup({'async': true})	
		
		imgURL = "./lib/overlays/#{img}"
		
		###
		imgURL = "./lib/createOverlay.php?width=1024&height=1024
			&RAMin=#{raMin}&RAMax=#{raMax}&DecMin=#{decMin}&DecMax=#{decMax}&scale=1.8&diam=4
				&color=#{color}&table="+JSON.stringify(raDec)
		###
		range = [raMin, raMax, decMin, decMax];
		overlay =  new HTM(@gl, @Math, "anno", "anno", 
			imgURL, null, range, label)
		
		@gridBlocks.push overlay
			
		return overlay
	deleteOverlay: (name)=>
		i = 0
		for grid in @gridBlocks
			if grid.name == name
				@gridblocks.splice(i,1)
			i++
		return
				
	panDown:(event)=>
		@mouseState = @MOUSE_DOWN
		@mouse_coords.x = event.clientX
		@mouse_coords.y = event.clientY

	panMove: (event)=>
				
		if @mouseState == @MOUSE_DOWN
			delta_x = event.clientX - @mouse_coords.x
			delta_y = event.clientY - @mouse_coords.y

			# Update mouse coordinates.
			@mouse_coords.x = event.clientX
			@mouse_coords.y = event.clientY

			# Assume this is the mouse going UP
			if delta_y <= 0
				@rotation[0] -= Config.pan_sensitivity  # Too much movement?

			# Assume the mouse is going DOWN
			else
				@rotation[0] += Config.pan_sensitivity

			if delta_x <= 0
				@rotation[1] -= Config.pan_sensitivity

			else
				@rotation[1] += Config.pan_sensitivity
			#@translate((event.clientX-@mouse_coords.x)/ 1000 * 1.8 / @scale, (-event.clientY+@mouse_coords.y)/ 1000 * 1.8 / @scale)

			# Update the RA-DEC numbers
			$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
			
			this.render(true)

	panUp: (event)=>
		@mouseState = 0

	panScroll: (event)=>
		delta = 0;
		if (!event) 
			event = window.event;
		#normalize the delta
		if (event.wheelDelta)
			#IE and Opera
			delta = event.wheelDelta / 60;
		else if (event.detail) 
			delta = -event.detail / 2;

		# Assume zoom out
		if delta > 0
			@translation[2] -= Config.scroll_sensitivity
		# Assume Zoom in
		else
			@translation[2] += Config.scroll_sensitivity
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		this.render()

	jump: (RA,Dec)=>
		@rotation[1] = -RA
		@rotation[0] = -Dec	

	render: (flag)=>
				
		if flag? and flag is true
		
			## retrieve RA and radius ##
			radius = 45#((-@translation[2]+1)*15)*90
			
			if radius < 1.0
				radius = 1.0
			
			ra = -@rotation[1]
			dec = -@rotation[0]
						
			# select the images
			
			$.ajaxSetup({'async': false})	
			
			$.getJSON("./lib/webgl/SDSSFieldQuery.php?ra=#{ra}&dec=#{dec}&radius=
				#{radius}&zoom=0", (data) =>
					$.each(data, (key, val)=>
						if key % 2 == 0
							fitsFile = data[key+1]
							fits=fitsFile.split(".")[0].concat(".").concat(fitsFile.split(".")[1])
							@gridBlocks.push  new HTM(@gl, @Math, "sky", "SDSS", 
								"./lib/webgl/sdss/#{val}","/afs/cs.pitt.edu/projects/admt/web/sites/astro/sdss2degregion00/headtext/#{fits}")
					)	
			)
			$.ajaxSetup({'async': true})
			
		
			for image in @lsstarray
				console.log "lsst image: ", image
				@gridBlocks.push new HTM(@gl, @Math, "sky", "LSST", "../../../lsstimages/#{image}", "")
			###
			for image,index in @firstarray when index < 2
				#console.log "first image: ", image
				@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "FIRST", "./firstimages/#{image}", "")
			###
		this.preRender(@rotation, @translation) # set up matrices
				
		for grid in @gridBlocks
			if grid.getSet() == true
				grid.bindSphere(@shaderProgram)
				if grid.survey == "SDSS"
					@gl.enable(@gl.DEPTH_TEST)
					@gl.disable(@gl.BLEND)
					@gl.uniform1f(@shaderProgram.alphaUniform, @SDSSalpha)
				else if grid.survey == "anno"
					@gl.disable(@gl.DEPTH_TEST)
					@gl.enable(@gl.BLEND)
					@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
					@gl.uniform1f(@shaderProgram.alphaUniform, grid.alpha)
				else if grid.survey == "LSST"
					@gl.disable(@gl.DEPTH_TEST)
					@gl.enable(@gl.BLEND)
					@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
					@gl.uniform1f(@shaderProgram.alphaUniform, @LSSTalpha)
				###
				else if grid.survey == "FIRST"
					@gl.disable(@gl.DEPTH_TEST)
					@gl.enable(@gl.BLEND)
					@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
					@gl.uniform1f(@shaderProgram.alphaUniform, @FIRSTalpha)
				###
				grid.renderSphere(@renderMode)
		return

	mouseHandler:(canvas)->
		@hookEvent(canvas, "mousedown", @panDown)
		@hookEvent(canvas, "mouseup", @panUp)
		@hookEvent(canvas, "mousewheel", @panScroll)
		@hookEvent(canvas, "mousemove", @panMove)

		
	hookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element)
		if(element == null)
			return
		if(element.addEventListener)
			if(eventName == 'mousewheel')
				element.addEventListener('DOMMouseScroll', callback, false)  
			element.addEventListener(eventName, callback, false)
		else if(element.attachEvent)
			element.attachEvent("on" + eventName, callback)

	unhookEvent:(element, eventName, callback)->
		if(typeof(element) == "string")
			element = document.getElementById(element)
		if(element == null)
			return
		if(element.removeEventListener)
			if(eventName == 'mousewheel')
				element.removeEventListener('DOMMouseScroll', callback, false) 
			element.removeEventListener(eventName, callback, false)
		else if(element.detachEvent)
			element.detachEvent("on" + eventName, callback)	
		return
		
	keyPressed: (key) =>

		switch String.fromCharCode(key.which)
			
			when 'i'
				@rotation[0] -= 0.1
				$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				this.render()
			when 'k'
				@rotation[0] += 0.1
				$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				this.render()
			when 'l'
				@rotation[1] += 0.1
				$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				if -@rotation[1] < 0
					$('#RA-Dec').text((360-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				else if -@rotation[1] > 360
					$('#RA-Dec').text((this.rotation[1] + 360).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				this.render() 
			
			when 'j'
				@rotation[1] -= 0.1 
				$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				if -@rotation[1] > 360
					$('#RA-Dec').text((this.rotation[1]+360).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				else if -@rotation[1] < 0
					$('#RA-Dec').text((360-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				this.render()
			
			when 'w' 
				@translation[2] += 0.001
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()	
				
			when 's'
				@translation[2] -= 0.001
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()	
				
			when 'W' 
				@translation[2] += 0.01
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()	

			when 'S'
				@translation[2] -= 0.01
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()
				
			when 't'
				this.getBoundingBox()
				
		return
	getBoundingBox:()=>

		max = this.getCoordinate(@canvas.width, @canvas.height)
		min = this.getCoordinate(0,0)
		
		range = new Object()
		
		range.maxRA = max.x
		range.minRA = min.x
		range.maxDec = max.y
		range.minDec = min.y
				
		return range
	
	getPosition: ()=>
		pos = new Object;
		pos.ra = -@rotation[1]
		pos.dec = -@rotation[0]
		return pos
		
	getCoordinate: (x,y) =>
		
		#get the projection, model-view and viewport
		matrices = this.getMatrices()
		
		#calculate the near and far clipping plane distances
		near = []
		far = []
		
		success = GLU.unProject(x, @gl.viewportHeight - y,
			0.0, matrices[0], matrices[1], matrices[2], near)
		
		success = GLU.unProject(x, @gl.viewportHeight - y,
			1.0, matrices[0], matrices[1], matrices[2], far)
		
		#calculate the direction vector
		dir = @Math.subtract(far,near)
				
		# set up the origin
		origin = [0.0,0.0,0.0,1.0]
		
		# unproject the origin to the scene
		inverse = mat4.set(matrices[0],mat4.create())
		inverse = mat4.inverse(inverse)
						
		origin = @Math.multiply(origin,inverse)
		
		#normalize direction vector
		dir = @Math.norm(dir)
		
		# new
		
		a = @Math.dot([dir[0],dir[1],dir[2],1.0],[dir[0], dir[1],dir[2],1.0])
		b = @Math.dot([origin[0],origin[1],origin[2],0.0],[dir[0], dir[1],dir[2],1.0]) * 2.0
		c = @Math.dot([origin[0],origin[1],origin[2],0.0],[origin[0],origin[1],origin[2],0.0]) - 1
		
		t = [0,0]
		
		descrim = Math.pow(b,2)-(4.0*a*c)
		
		if descrim >= 0
		
			t[0] = (-b - Math.sqrt(descrim))/(2.0*a)
			t[1] = (-b + Math.sqrt(descrim))/(2.0*a)
		
		intersection = @Math.add(origin,@Math.mult(dir,t[1]))
		
		theta = Math.atan(intersection[0]/intersection[2]) * 57.29577951308323
		
		RA = theta
		###
		if theta < 270
			RA = 270 - RA
		else
			theta = 360 + (RA-270)
		###	
		phi = Math.acos(intersection[1]) * 57.29577951308323
		Dec = 90 - phi
				
		raDec = new Object()
		raDec.x = RA
		raDec.y = Dec
		
		return raDec
