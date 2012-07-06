#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	@it = 0
	@selected = "none"
	
	constructor: (options) ->
	
		super(options)
		
		@Math = new math()
		@level = 0
		
		@HTM = new HTM(@level, @gl, @Math)
		@rotation = [0.0, 0.0, 0.0,]
		@translation = [0.0, 0.0, 0.0]
		@renderMode = @gl.LINES
		
		@Map = new Map( @HTM.getInitTriangles(), @HTM.getColors(), @Math, @HTM.getNames())
		
		document.getElementById("scale").value = (1-@translation[2])*45.0
		
		newurl ="./lib/db/remote/SDSS.php?scale=#{1.8}&ra=#{degX}&dec=#{degY}&width=1024&height=1024&opt="
		
		
		this.render()
	
	setScale: ()=>
		@translation[2] = 1-(document.getElementById("scale").value/45.0)
	setRotation: ()=>
		@rotation[1] = parseFloat(document.getElementById("RA").value)
		@rotation[0] = parseFloat(document.getElementById("Dec").value)
	setLevel: ()=>
		@level = parseInt(document.getElementById("level").value)
		@HTM = new HTM(@level, @gl, @Math)

	render: ()=>
				
		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		
		@HTM.render(@gl, @renderMode) # render to screen
		
		# OctaMap rendering
		@Map.render(@level, @selected)
	
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
			
			when 'i' then @rotation[0]++ 
			when 'k' then @rotation[0]-- 
			when 'l' then @rotation[1]++ 
			when 'j' then @rotation[1]-- 
			
			when 'w' 
				@translation[2] += 0.1
				
			when 's'
				@translation[2] -= 0.1
		
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
				
		it = -1
		for triangle in tri
			it = it + 1
			if @Math.intersectTri(origin, dir, triangle)
				console.log names[it]
				@selected = names[it]
				this.render()
				this.colorClick(triangle)
				break
		return
