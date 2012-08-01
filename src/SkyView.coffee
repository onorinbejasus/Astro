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
		@translation = [0.0, 0.0, 0.968]
		@rotation = [-51.9, -175.99, 0.0]
		@renderMode = @gl.TRIANGLES
		@level = 0
		
		# init math, grid and projection
		@Math = new math()		
		@gridBlocks = []
		
		for i in [1..26]
			@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "./images/#{i}.jpeg")
			
		@gridBlocks.push new HTM(@level, @gl, @Math, "sphere", "./images/toast.png")
		
		#set initial scale
		document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				
		#render
		this.render()
		
		return
		
	setScale: ()=>
		@translation[2] = 1-(document.getElementById("scale").value/45.0)
	setRotation: ()=>
		@rotation[1] = parseFloat(document.getElementById("RA").value)
		@rotation[0] = parseFloat(document.getElementById("Dec").value)
	setLevel: ()=>
		@level = parseInt(document.getElementById("level").value)

	render: ()=>
		
		## retrieve RA and radius ##
		radius = parseFloat(document.getElementById("scale").value)
		ra = parseFloat(document.getElementById("RA").value)
		
		# select the images
		$.get("./SDSSFieldQuery.php?ra=#{ra}&dec=#{@rotation[0]}&radius=
			30&zoom=0");
						
		this.preRender(@rotation, @translation) # set up matrices
		
		for grid in @gridBlocks
			grid.bindSphere(@shaderProgram)
			grid.renderSphere(@renderMode)
				
	colorClick: (triangle)=>
		
		verts = []
		color = []
		
		for vert in triangle # iterate over vertices
			for component in vert
				verts.push component
		
		VertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, VertexPositionBuffer)

		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(verts), @gl.STATIC_DRAW)
		VertexPositionBuffer.itemSize = 3
		VertexPositionBuffer.numItems = 3
		
		colors = [
			[[1.0, 1.0, 0.0, 1.0],
			[1.0, 1.0, 0.0, 1.0],
			[1.0, 1.0, 0.0, 1.0]],
		]
						
		for j in colors
			for k in j
				for l in k
					color.push(l)
		
		VertexColorBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, VertexColorBuffer)

		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(color), @gl.STATIC_DRAW)
		VertexColorBuffer.itemSize = 4
		VertexColorBuffer.numItems = 3
	
		@gl.bindBuffer(@gl.ARRAY_BUFFER, VertexPositionBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, VertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		
		@gl.bindBuffer(@gl.ARRAY_BUFFER, VertexColorBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexColorAttribute, VertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0)
	
		@gl.drawArrays(@gl.TRIANGLES, 0, VertexPositionBuffer.numItems)
	
	keyPressed: (key) =>

		switch String.fromCharCode(key.which)
			
			when 'i'
				@rotation[0] -= 0.1
				document.getElementById("Dec").value = -@rotation[0]
				this.render()
			when 'k'
				@rotation[0] += 0.1
				document.getElementById("Dec").value = -@rotation[0]
				this.render()
			when 'l'
				@rotation[1] += 0.1
				document.getElementById("RA").value = -@rotation[1]
				
				if document.getElementById("RA").value < 0
					document.getElementById("RA").value = 360 - @rotation[1] 
				
				else if document.getElementById("RA").value > 360
					document.getElementById("RA").value = @rotation[1] - 360
				
				this.render() 
			
			when 'j'
				@rotation[1] -= 0.1 
				document.getElementById("RA").value = -@rotation[1]
				
				if document.getElementById("RA").value > 360
					document.getElementById("RA").value = @rotation[1] - 360
				
				else if document.getElementById("RA").value < 0
					document.getElementById("RA").value = 360 - @rotation[1]
				
				this.render()
				
			when 'p'
				@rotation[1] += 1.0
				document.getElementById("RA").value = -@rotation[1]

				if document.getElementById("RA").value < 0
					document.getElementById("RA").value = 360 - @rotation[1] 

				else if document.getElementById("RA").value > 360
					document.getElementById("RA").value = @rotation[1] - 360

				this.render() 

			when 'o'
				@rotation[1] -= 1.0 
				document.getElementById("RA").value = -@rotation[1]

				if document.getElementById("RA").value > 360
					document.getElementById("RA").value = @rotation[1] - 360

				else if document.getElementById("RA").value < 0
					document.getElementById("RA").value = 360 - @rotation[1]

				this.render()
			
			when 'w' 
				@translation[2] += 0.001
				this.render()	
				
			when 's'
				@translation[2] -= 0.001
				this.render()	
				
			when 'W' 
				@translation[2] += 0.01
				this.render()	

			when 'S'
				@translation[2] -= 0.01
				this.render()
				
			when 'x'
				@translation[0] -= 0.001
				this.render()
			when 'X'
				@translation[0] += 0.001
				this.render()
			when 'y'
				@translation[1] -= 0.001
				this.render()
			when 'Y'
				@translation[1] += 0.001
				this.render()
			
				
			when '1'
				@level = 1
				document.getElementById('level').value = 1
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '2'
				@level = 2
				document.getElementById('level').value = 2
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '3'
				@level = 3
				document.getElementById('level').value = 3
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '4'
				@level = 4
				document.getElementById('level').value = 4
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '5'
				@level = 5
				document.getElementById('level').value = 5
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '6'
				@level = 6
				document.getElementById('level').value = 6
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()	
			when '7'
				@level = 7
				document.getElementById('level').value = 7
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '8'
				@level = 8
				document.getElementById('level').value = 8
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '9'
				@level = 9
				document.getElementById('level').value = 9
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when '0'
				@level = 0
				document.getElementById('level').value = 0
				document.getElementById("scale").value = 180.0/Math.pow(2,@level+1)
				this.render()
			when 'r'
				console.log @rotation
				console.log @translation
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
