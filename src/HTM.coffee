class HTM
	
	@verts = null
	@tri = null
	@names = null
	
	@VertexPositionBuffer = null
	@VertexColorBuffer = null
	@VertexIndexBuffer = null
	@VertexTextureCoordBuffer = null
	@VertexNormalBuffer = null
	
	@Texture = null
	
	@initTriangles = null
	
	@set = null
		
	constructor: (@levels, @gl, @Math, type, texture, fits) ->
				
		if type == "sky"
			@proj = new Projection(@Math)
			
			init = this.initTexture
			create = this.createSphere
			set = this.setFlag()
			
			@set = false
			@proj.init(texture,fits,this)
			
		###
		else if type == "sphere"
			this.createSphere()
			this.initTexture(texture)
		###	
		return
		
	getInitTriangles:()=>
		return @initTriangles
	getTriangles:()=>
		return @tri
	getNames:()=>
		return @names
	getColors:()=>
		return @colors
	setFlag:()=>
		@set = true
		return
	getSet:()=>
		return @set
	handleLoadedTexture: (texture)=>
		
		@gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)
		
		@gl.bindTexture(@gl.TEXTURE_2D, texture)
		@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, texture.image)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE);
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE);
		@gl.bindTexture(@gl.TEXTURE_2D, null)

	initTexture: (image) =>
		@Texture = @gl.createTexture()
		@Texture.image = new Image()
		@Texture.image.onload = ()=> 
			this.handleLoadedTexture(@Texture)
		
		@Texture.image.src = image
    
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
		
		mutTriangles = [
		
			[v[0], w2, w1], # 0
			[v[1], w0, w2], # 1
			[v[2], w1, w0], # 2
			[w0, w1, w2]   # 3
		]
		
		it = 0
		
		if l is 0
			for triangle in mutTriangles # iterate over triangles
				@tri.push newTriangles[it++]
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
	
	createSphere: (ra, dec)=>
		
		latitudeBands = 30
		longitudeBands = 30
		radius = 1

		vertexPositionData = []
		normalData = []
		
		textureCoordData = []
		
		### if ra and dec are specified for the sphere, 
			use them ###		
		if ra? and dec?
						
			coords = [
				
				[ra[0],dec[0]]
				[ra[1],dec[1]]
				[ra[2],dec[2]]
				[ra[3],dec[3]]
			]
			
			for coord in coords
				
				phi = (90-coord[1]) * Math.PI/180.0 
				theta = 0
				
				if coord[0] > 270 
					theta = (270-coord[0]+360) * Math.PI/180.0 
				else 
					theta = (270-coord[0]) * Math.PI/180.0 

				sinTheta = Math.sin(theta)
				cosTheta = Math.cos(theta)
				
				sinPhi = Math.sin(phi)
				cosPhi = Math.cos(phi)
				
				z = sinPhi * sinTheta
				y = cosPhi
				x = sinPhi * cosTheta
				
				console.log x,y,z
						
				vertexPositionData.push(radius * x)
				vertexPositionData.push(radius * y)
				vertexPositionData.push(radius * z)
						
				textureCoordData = [
					
					0.0, 1.0,
					0.0, 0.0,
					1.0, 0.0,
					1.0, 1.0,
					
					
					
				]
			
			indexData = [2,3,0, 1,2,0]

		# else create a normal sphere
		
		else
		
			radius = 1.1
		
			for latNumber in [0..latitudeBands]

				for longNumber in [0..longitudeBands]
					
					theta = longNumber * 2 * Math.PI / longitudeBands
					sinTheta = Math.sin(theta)
					cosTheta = Math.cos(theta)
					
					phi = latNumber * Math.PI / latitudeBands
					sinPhi = Math.sin(phi)
					cosPhi = Math.cos(phi)

					z = sinPhi * sinTheta
					y = cosPhi
					x = sinPhi * cosTheta
					
					u = 1 - (longNumber / longitudeBands)
					v = 1 - (latNumber / latitudeBands)
					
					textureCoordData.push(u)
					textureCoordData.push(v)
					
					vertexPositionData.push(radius * x)
					vertexPositionData.push(radius * y)
					vertexPositionData.push(radius * z)

			indexData = []
			for latNumber in [0..latitudeBands-1]
				for longNumber in [0..longitudeBands-1]
				
					first = (latNumber * (longitudeBands + 1)) + longNumber
					second = first + longitudeBands + 1
					indexData.push(first)
					indexData.push(second)
					indexData.push(first + 1)

					indexData.push(second)
					indexData.push(second + 1)
					indexData.push(first + 1)
				
		@VertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertexPositionData), @gl.STATIC_DRAW)
		@VertexPositionBuffer.itemSize = 3
		@VertexPositionBuffer.numItems = vertexPositionData.length / 3
						
		@VertexIndexBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @VertexIndexBuffer)
		@gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indexData), @gl.STATIC_DRAW)
		@VertexIndexBuffer.itemSize = 1
		@VertexIndexBuffer.numItems = indexData.length
				
		@VertexTextureCoordBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexTextureCoordBuffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(textureCoordData), @gl.STATIC_DRAW)
		@VertexTextureCoordBuffer.itemSize = 2
		@VertexTextureCoordBuffer.numItems = textureCoordData.length / 2
		
		return
	
	bindHTM: (shaderProgram) =>
	
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexColorBuffer)
		@gl.vertexAttribPointer(shaderProgram.vertexColorAttribute, @VertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		
		return
	
	bindSphere: (shaderProgram)=>
		
		@gl.activeTexture(@gl.TEXTURE0)
		@gl.bindTexture(@gl.TEXTURE_2D, @Texture)
		@gl.uniform1i(shaderProgram.samplerUniform, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexTextureCoordBuffer);
		@gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, @VertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @VertexIndexBuffer)
	
		return
	
	renderHTM: (renderMode) =>

		@gl.drawArrays(renderMode, 0, @VertexPositionBuffer.numItems)
		
		return
	renderSphere: (renderMode) =>
		@gl.drawElements(renderMode, @VertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)
