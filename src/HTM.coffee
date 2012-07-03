class HTM
	
	@verts = null
	@tri = null
	@names = null
	@VertexPositionBuffer = null
	@VertexColorBuffer = null
	@initTriangles = null
		
	constructor: (@levels, @gl, @Math) ->
		
		@mutableTri = [
			# S0
			[[0.0, 0.0, 1.0],
			[0.0, -1.0, 0.0],
			[1.0, 0.0, 0.0]],
   			# S1
			[[-1.0, 0.0, 0.0],
			[0.0, -1.0, 0.0],
			[0.0, 0.0, 1.0]],
			# S2
			[[0.0, 0.0, -1.0],
			[ 0.0, -1.0, 0.0],
			[ -1.0, 0.0, 0.0]],
			# S3
			[[1.0, 0.0, 0.0],
			[0.0, -1.0, 0.0],
			[0.0, 0.0, -1.0]],		
			# N0
			[[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0]],
			# N1
			[[0.0, 0.0, 1.0],
			[0.0, 1.0, 0.0],
			[-1.0, 0.0, 0.0]],
			# N2
			[[-1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, -1.0 ]],
			# N3
			[[0.0, 0.0, -1.0],
			[0.0, 1.0, 0.0],
			[1.0, 0.0, 0.0 ]] 
		]
		
		@initTriangles = [
			# S0
			[[0.0, 0.0, 1.0],
			[0.0, -1.0, 0.0],
			[1.0, 0.0, 0.0]],
   			# S1
			[[-1.0, 0.0, 0.0],
			[0.0, -1.0, 0.0],
			[0.0, 0.0, 1.0]],
			# S2
			[[0.0, 0.0, -1.0],
			[ 0.0, -1.0, 0.0],
			[ -1.0, 0.0, 0.0]],
			# S3
			[[1.0, 0.0, 0.0],
			[0.0, -1.0, 0.0],
			[0.0, 0.0, -1.0]],
			# N0
			[[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0]],
			# N1
			[[0.0, 0.0, 1.0],
			[0.0, 1.0, 0.0],
			[-1.0, 0.0, 0.0]],
			# N2
			[[-1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, -1.0 ]],
			# N3
			[[0.0, 0.0, -1.0],
			[0.0, 1.0, 0.0],
			[1.0, 0.0, 0.0 ]] 
		]
				
		this.createHTM()
		
	getInitTriangles:()=>
		return @initTriangles
	getTriangles:()=>
		return @tri
	getNames:()=>
		return @names
	getColors:()=>
		return @colors
	
	debugColor: ()=>
		
		color = []
		@colors = [
			[[0.0, 0.0, 0.0, 1.0],
			[0.0, 0.0, 0.0, 1.0],
			[0.0, 0.0, 0.0, 1.0]],
		]
		depth = Math.pow(4, @levels) * 16
		
		for num in [depth..0]
			for j in @colors
				for k in j
					for l in k
						color.push(l)

		@VertexColorBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexColorBuffer)

		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(color), @gl.STATIC_DRAW)
		@VertexColorBuffer.itemSize = 4
		@VertexColorBuffer.numItems = 8 * Math.pow(4,@levels) * 6
					
		return
	
	createHTM: () =>
		
		@verts = []
		@names = []
		@tri = []
		it = 0
		
		initNames = ["S0","S1","S2","S3","N0","N1","N2","N3"]
#		initNames = ["N0","N1","N2","N3"]
#		initNames = ["N3"]
		###
		@initTriangles = [
			# N3
			[[0.0, 0.0, -1.0],
			[0.0, 1.0, 0.0],
			[1.0, 0.0, 0.0 ]]
		]
		
		###	
		
		@names = initNames
		@tri = @initTriangles
		if @levels is 0
						
			for triangles in @mutableTri # iterate over triangles
				triangles.splice(2,0,triangles[1])
				triangles.push triangles[3]
				triangles.push triangles[0]
				for vert in triangles # iterate over vertices
					for component in vert
						@verts.push component
		else
			@tri = []
			@names = []
			for triangles in @initTriangles
				this.subdivide(triangles, @levels-1, initNames[it++])

		@VertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)

		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@verts), @gl.STATIC_DRAW)
		@VertexPositionBuffer.itemSize = 3
		@VertexPositionBuffer.numItems = 8 * Math.pow(4,@levels) * 6
				
		this.debugColor()
				
		return
	
	subdivide: (v,l,name) =>
		
		names = ["#{name}0","#{name}1",
			"#{name}2","#{name}3"]
		it = 0
		# new vertex 1
		mag = @Math.magnitude(v[1], v[2])
		
		w0 = []
		w0.push((v[1][0] + v[2][0]) / mag)
		unless(w0[0]?) then w0[0] = 0
		w0.push((v[1][1] + v[2][1]) / mag)
		unless(w0[1]?) then w0[1] = 0 
		w0.push((v[1][2] + v[2][2]) / mag)
		unless(w0[2]?) then w0[2] = 0 
		
		# new vertex 2
		mag = @Math.magnitude(v[0], v[2])
		
		w1 = [] 
		w1.push((v[0][0] + v[2][0]) / mag)
		unless(w1[0]?) then w1[0] = 0
		w1.push((v[0][1] + v[2][1]) / mag)
		unless(w1[1]?) then w1[1] = 0  	
		w1.push((v[0][2] + v[2][2]) / mag)
		unless(w1[2]?) then w1[2] = 0
		
		# new vertex 3
		mag = @Math.magnitude(v[0], v[1])
		
		w2 = []
		w2.push((v[0][0] + v[1][0]) / mag)
		unless(w2[0]?) then w2[0] = 0
		w2.push((v[0][1] + v[1][1]) / mag)
		unless(w2[1]?) then w2[1] = 0  	
		w2.push((v[0][2] + v[1][2]) / mag)
		unless(w2[2]?) then w2[2] = 0 
		
		newTriangles = [
		
			[v[0], w2, w1], # 0
			[v[1], w0, w2], # 1
			[v[2], w1, w0], # 2
			[w0, w1, w2]   # 3
		]
		
		if l is 0
			for triangle in newTriangles # iterate over triangles
				@tri.push triangle
				triangle.splice(2,0,triangle[1])
				triangle.push triangle[3]
				triangle.push triangle[0]
				for vert in triangle # iterate over vertices
					for component in vert
						@verts.push component
			for name in names
				@names.push name	
		else
			for triangle in newTriangles # iterate over triangles
				this.subdivide(triangle, l-1, names[it++])
		return
	bind: (gl, shaderProgram) =>
	
		gl.bindBuffer(gl.ARRAY_BUFFER, @VertexPositionBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0)
		
		gl.bindBuffer(gl.ARRAY_BUFFER, @VertexColorBuffer)
		gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, @VertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0)
		
		return
		
	render: (gl, renderMode) =>

		gl.drawArrays(renderMode, 0, @VertexPositionBuffer.numItems)
		
		return
