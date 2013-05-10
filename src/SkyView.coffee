#= require WebGL
class SkyView extends WebGL
	gridBlocks: 0
	rotation: null
	translation: null
	renderMode: 0
	refresh_timeout: 0
	# @property [Math] Useful for doing matrix math
	Math: null

	constructor: (options) ->

		@empty = ()->return
		#init webgl
		@box_canvas = document.createElement("canvas")
		@box_canvas.width = options.clientWidth
		@box_canvas.height = options.clientHeight
		@box_canvas.style.backgroundColor = ""
		@box_canvas.style.position = "absolute"
		options.appendChild(@box_canvas)
		@event_attach = options
		@mouse_down = @sky_view_mouse_down
		@mouse_up = @sky_view_mouse_up
		@mouse_move = @sky_view_mouse_move
		@_inner_mouse_move = @empty
		@_inner_mouse_up = @panUp
		@_inner_mouse_down = @panDown

		super(options)

		@mouse_coords = {'x':0, 'y':0}
		@handlers = {'translate': @empty, 'scale':@empty, 'box':@empty}
		#init htm variables
		@translation = [0.0, 0.0, 0.99333]
		@rotation = [0.0, -0.4, 0.0]
		@renderMode = @gl.TRIANGLES

		# init math, grid and projection
		@Math = new math()

		# array of overlays
		@overlays = []

		@box = new BoxOverlay(@box_canvas, this)
		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		
		this.render()
		
		return

	# @private
	refresh: ()=>
		for overlay in @overlays
			overlay.refresh()
		@refresh_timeout = setTimeout(@refresh, 500)

	# Updates the scale and notifies all registered scale listeners of the change.
	#
	# @param [double] value what you want to change the scale value to.
	#
	setScale: (value)=>

		$('#Scale').text(value.toFixed(2))
		@translation[2] = (-value/15.0) + 1.0
		@notify('scale', value)
		this.render()
		return

	addOverlay: (overlay)=>
		@overlays.push overlay
		return

	deleteOverlay: (name)=>
		return

	render: ()=>

		this.preRender(@rotation, @translation) # set up matrices

		# Refreshes all the overlay images by requesting them all again (For now it is just FIRST).
		for overlay in @overlays
			for tile in overlay.tiles
				tile.bind(@shaderProgram)
				if overlay.survey == "SDSS"
					@gl.enable(@gl.DEPTH_TEST)
					@gl.disable(@gl.BLEND)
					@gl.uniform1f(@shaderProgram.survey, 0.0)
				else
					@gl.disable(@gl.DEPTH_TEST)
					@gl.enable(@gl.BLEND)
					@gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE)
					@gl.uniform1f(@shaderProgram.survey, 1.0)

				@gl.uniform1f(@shaderProgram.alphaUniform, overlay.alpha)
				tile.render(@renderMode)
		return

	# @private
	panDown:(event)=>
		@_inner_mouse_move = @panMove
		@mouse_coords.x = event.clientX
		@mouse_coords.y = event.clientY
		@refresh()
	# @private
	panMove:(event)=>
		delta_x = event.clientX - @mouse_coords.x
		delta_y = event.clientY - @mouse_coords.y

		# Update mouse coordinates.
		@mouse_coords.x = event.clientX
		@mouse_coords.y = event.clientY

		# Assume this is the mouse going UP
		if delta_y > 0
			@rotation[0] -= delta_y * Config.PAN_SENSITIVITY  # Too much movement?

		# Assume the mouse is going DOWN
		else if delta_y < 0
			@rotation[0] += -delta_y * Config.PAN_SENSITIVITY

		if delta_x > 0
			@rotation[1] -= delta_x * Config.PAN_SENSITIVITY

		else if delta_y < 0
			@rotation[1] += -delta_x * Config.PAN_SENSITIVITY
		#@translate((event.clientX-@mouse_coords.x)/ 1000 * 1.8 / @scale, (-event.clientY+@mouse_coords.y)/ 1000 * 1.8 / @scale)

		# Update the RA-DEC numbers
		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
		this.render()

	# @private
	panUp: (event)=>
		clearTimeout(@refresh_timeout)
		@_inner_mouse_move = @empty

	# @private
	panScroll: (event)=>
		delta = 0;
		if (!event) 
			event = window.event;
		#normalize the delta
		if (event.wheelDelta)
			# Dear Sean, 
			#	IE does not support webGL. 
			#	This will not run regardless. Ha
			#IE and Opera
			delta = event.wheelDelta / 60;
		else if (event.detail) 
			delta = -event.detail / 2;

		# Assume zoom out
		if delta > 0
			@translation[2] -= Config.SCROLL_SENSITIVITY
		# Assume Zoom in
		else
			@translation[2] += Config.SCROLL_SENSITIVITY

		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		this.render()

	jump: (RA,Dec)=>

		@rotation[1] = -RA
		@rotation[0] = -Dec	

		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))

		this.render()

	# @private
	mouseHandler:()->
		@hookEvent(@event_attach, "mousedown", @sky_view_mouse_down)
		@hookEvent(@event_attach, "mouseup", @sky_view_mouse_up)
		@hookEvent(@event_attach, "mousewheel", @panScroll)
		@hookEvent(@event_attach, "mousemove", @sky_view_mouse_move)

	# @private
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

	# @private
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

	# @private
	sky_view_mouse_move: (event)=>
		@_inner_mouse_move(event)

	# @private
	sky_view_mouse_up: (event)=>
		@_inner_mouse_up(event)

	# @private
	sky_view_mouse_down: (event)=>
		@_inner_mouse_down(event)

	register:(type, callback)=>
		oldLoaded = @handlers[type]
		if(@handlers[type])
			@handlers[type] = (view)->
				if(oldLoaded)
					oldLoaded(view)
				callback(view)
		else
			@handlers[type] = callback

	# @private
	notify:(type, info)=>
		if(@handlers[type])
			@handlers[type](info);

	# @private
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

	# Translates a pixel coordinate to RA, DEC space.
	#
	# @param [int] x the x pixel that you want translated.
	# @param [int] y the y pixel that you want translated.
	#
	# @return [object] an object with ra, dec.
	getCoordinate: (x,y) =>
		#get the projection, model-view and viewport
		matrices = this.getMatrices()

		#calculate the near and far clipping plane distances
		near = []
		far = []
		dir = []
		
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

	# @private
	keyPressed: (key) =>
		###
		switch String.fromCharCode(key.which)
		
			when 'i'
				@rotation[0] -= 0.1
				@box.setEvents()
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
			###
		return
		
class BoxOverlay
	# @private
	constructor: (canvas, view)->
		@canvas = canvas
		@ctx = @canvas.getContext('2d')
		@ctx.fillStyle = "rgba(0,0,200,.2)"
		@start = 0
		@draw = false
		@enabled = true
		@end = 0
		@view= view
		@onBox = null
		@canvas.relMouseCoords = (event)->
			totalOffsetX = 0
			totalOffsetY = 0
			canvasX = 0
			canvasY = 0
			currentElement = this
			while currentElement = currentElement.offsetParent
				totalOffsetX += currentElement.offsetLeft
				totalOffsetY += currentElement.offsetTop
			canvasX = event.pageX - totalOffsetX
			canvasY = event.pageY - totalOffsetY
			return {x:canvasX, y:canvasY}

		@boxdown =(event)=>
			@start = @canvas.relMouseCoords(event)
			@draw = true
			@view._inner_mouse_move = @boxmove

		@boxmove =(event)=>
			@end = @canvas.relMouseCoords(event)
			@display()

		@boxup = (event)=>
			@end = @canvas.relMouseCoords(event)
			@view.notify('box', {start: @view.getCoordinate(@start.x, @start.y), end:@view.getCoordinate(@end.x, @end.y)})

			@setPan()
			drawEnd = ()=> 
				@ctx.clearRect(0, 0, @canvas.width, @canvas.height)
			setTimeout(drawEnd, 1000)

	# Will change the event handlers from pan to box. 
	setEvents:()=>
		@view._inner_mouse_up = @boxup
		@view._inner_mouse_down = @boxdown
		@view._inner_mouse_move = ()-> return;

	# @private
	setPan: ()=>
		@view._inner_mouse_up = @view.panUp
		@view._inner_mouse_down = @view.panDown
		@view._inner_mouse_move = @view.panMove

	# Displays the box to the user. Used in the boxdown event.
	display:()->
		@ctx.clearRect(0, 0, @canvas.width, @canvas.height)
		@ctx.fillRect(@start.x, @start.y, @end.x-@start.x, @end.y-@start.y);
