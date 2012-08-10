#= require WebGL

class SkyView extends WebGL
	
	@gridBlocks = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	@it = 0
	@selected = "none"
	
	constructor: (options) ->
	
		#init webgl
		super(options)
		
		#init htm variables
		@translation = [0.0, 0.0, 0.93333]
		@rotation = [0.0, 0.0, 0.0]
		@renderMode = @gl.TRIANGLES
		@level = 0
		
		# init math, grid and projection
		@Math = new math()		
		@gridBlocks = []
		
		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
		
		#render
		this.render(true)
		
		return
		
	setScale: ()=>
		@translation[2] = 1-(document.getElementById("scale").value/45.0)
	jump: (RA,Dec)=>
		@rotation[1] = -RA
		@rotation[0] = -Dec	

	render: (flag)=>
		
		if flag? and flag is true
		
			## retrieve RA and radius ##
			radius = 30#parseFloat(document.getElementById("scale").value) / 60.0
			
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
							@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "SDSS", 
								"../timProduction/lib/webgl/sdss/#{val}","../timProduction/lib/webgl/sdss/#{fits}")
					)	
			)
			$.ajaxSetup({'async': true})
		
		this.preRender(@rotation, @translation) # set up matrices
				
		for grid in @gridBlocks
			if grid.getSet() == true
				console.log "render"
				grid.bindSphere(@shaderProgram)
				grid.renderSphere(@renderMode)
				
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
					$('#RA-Dec').text((this.rotation[1] - 360).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				this.render() 
			
			when 'j'
				@rotation[1] -= 0.1 
				$('#RA-Dec').text((this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				if -@rotation[1] > 360
					$('#RA-Dec').text((this.rotation[1]-360).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				else if @rotation[1] < 0
					$('#RA-Dec').text((360-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
				
				this.render()
			
			when 'w' 
				@translation[2] += 0.001
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render(false)	
				
			when 's'
				@translation[2] -= 0.001
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()	
				
			when 'W' 
				@translation[2] += 0.01
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render(false)	

			when 'S'
				@translation[2] -= 0.01
				$('#Scale').text(((-@translation[2]+1)*15).toFixed(2))
				this.render()
		return
	
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
		b = @Math.dot([dir[0], dir[1],dir[2],1.0],[origin[0],origin[1],origin[2],0.0]) * 2.0
		c = @Math.dot([origin[0],origin[1],origin[2],0.0],[origin[0],origin[1],origin[2],0.0]) - 1
		
		t = [0,0]
		
		descrim = Math.pow(b,2)-(4.0*a*c)
		console.log "descrim", descrim
		console.log "b",b
		
		if descrim >= 0
		
			t[0] = (-b - Math.sqrt(descrim))/(2.0*a)
			t[1] = (-b + Math.sqrt(descrim))/(2.0*a)
		
		intersection = @Math.mult(@Math.add(origin, dir), t[1])
		console.log intersection
		
		theta = Math.atan(intersection[0]/intersection[2]) * 57.29577951308323
		console.log "theta",theta
		
		RA = theta
		
		if theta < 0
			RA = 360 + theta
			console.log "less"
			
		phi = Math.acos(intersection[1]) * 57.29577951308323
		Dec = 90 - phi
		
		console.log "RA",RA, "Dec",Dec
		
		raDec = new Object()
		raDec.x = RA
		raDec.y = Dec
		
		return raDec
