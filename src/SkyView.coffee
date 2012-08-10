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
		@translation = [0.0, 0.0, 0.3333]
		@rotation = [-52.0, -176.0, 0.0]
		@renderMode = @gl.TRIANGLES
		@level = 0
		
		# init math, grid and projection
		@Math = new math()		
		@gridBlocks = []
		
		$('#RA-Dec').text((-this.rotation[1]).toFixed(8)+", "+ (-this.rotation[0]).toFixed(8))
		
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
			$.getJSON("./SDSSFieldQuery.php?ra=#{ra}&dec=#{dec}&radius=
				#{radius}&zoom=0", (data) =>
					$.each(data, (key, val)=>
						console.log val
						@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "./sdss/#{val}")
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
				this.render(false)	
				
			when 's'
				@translation[2] -= 0.001
				this.render()	
				
			when 'W' 
				@translation[2] += 0.01
				this.render(false)	

			when 'S'
				@translation[2] -= 0.01
				this.render()
		return
	
	mousePress: (key) =>
		
		if key.x > 500 || key.y >500
			return
		
		#get the projection, model-view and viewport
		matrices = this.getMatrices()
		
		#calculate the near and far clipping plane distances
		near = []
		far = []
		
		success = GLU.unProject(key.x, @gl.viewportHeight - key.y,
			0.0, matrices[0], matrices[1], matrices[2], near)
		
		success = GLU.unProject(key.x, @gl.viewportHeight - key.y,
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
		
		# grab the triangles and names and see if ray intersects with them
		tri = @HTM.getTriangles()
		names = @HTM.getNames()
		###		
		it = -1
		for triangle in tri
			it = it + 1
			if @Math.intersectTri(origin, dir, triangle)
				console.log names[it]
				@selected = names[it]
				this.render()
				this.colorClick(triangle)
				break
		###
		return
