#= require WebGL

class SkyView extends WebGL

	@MOUSE_DOWN = 1
	@MOUSE_UP = 0
	@mouseState = @MOUSE_UP
	@gridBlocks = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
		
	constructor: (options) ->
	
		#init webgl
		super(options)
		@mouse_coords = {'x':0, 'y':0}	
		#init htm variables
		@translation = [0.0, 0.0, 0.99333]
		@rotation = [0.0, 0.0, 0.0]
		@renderMode = @gl.TRIANGLES
			
		# init math, grid and projection
		@Math = new math()

		# array of overlays
		@overlays = []

		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		
		return
			
	setScale:(value)=>
		$('#Scale').text(((value+1)*15).toFixed(2))
		return
		
	addOverlay: (overlay)=>
		@overlays.push overlay
		return
		
	deleteOverlay: (name)=>
		return

	render: ()=>
		
		console.log "render"
		
		this.preRender(@rotation, @translation) # set up matrices

		for overlay in @overlays
			for tile in overlay.tiles
				if tile.getSet() == true
					tile.bind(@shaderProgram)
					if overlay.survey == "SDSS"
						@gl.enable(@gl.DEPTH_TEST)
						@gl.disable(@gl.BLEND)
						@gl.uniform1f(@shaderProgram.alphaUniform, overlay.alpha)
					else if overlay.survey == "anno"
						@gl.disable(@gl.DEPTH_TEST)
						@gl.enable(@gl.BLEND)
						@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
						@gl.uniform1f(@shaderProgram.alphaUniform, overlay.alpha)
					else if overlay.survey == "LSST"
						@gl.disable(@gl.DEPTH_TEST)
						@gl.enable(@gl.BLEND)
						@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
						@gl.uniform1f(@shaderProgram.alphaUniform, overlay.alpha)
					else if overlay.survey == "FIRST"
						@gl.disable(@gl.DEPTH_TEST)
						@gl.enable(@gl.BLEND)
						@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
						@gl.uniform1f(@shaderProgram.alphaUniform, overlay.alpha)
					tile.render(@renderMode)
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
			
			this.render()

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
		
		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		
		this.render()
		
	mouseHandler:()->
		@hookEvent(@canvas, "mousedown", @panDown)
		@hookEvent(@canvas, "mouseup", @panUp)
		@hookEvent(@canvas, "mousewheel", @panScroll)
		@hookEvent(@canvas, "mousemove", @panMove)
		
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
	

