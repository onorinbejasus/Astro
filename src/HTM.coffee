class TextureProxy
	###
	A TextureProxy uses an already loaded temporary image while
	another image is loading. 
	###
	constructor: (gl, img_url, temp_img_texture) ->
		@texture = temp_img_texture

		on_texture_load = (texture) ->
			@texture = texture

		@initTexture(gl, img_url, on_texture_load)

	###
	@function: initTexture
	@description: Creates a GL_TEXTURE in GPU using the image specified.
	@param: GL_CONTEXT gl- used to create a texture
	@param: String image - URL of an image to be used.
	@param: function load_callback- Use for callbacks when onload is triggered
			to get the texture, all loaded.
	@return: Nothing. Use the texture callback.
	###
	initTexture: (gl, image, load_callback) ->
		texture = gl.createTexture()
		texture.image = new Image()
		texture.image.onload = ()=> 
			gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
			gl.bindTexture(gl.TEXTURE_2D, texture)
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image)
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			gl.bindTexture(gl.TEXTURE_2D, null)	

			if load_callback
				load_callback(texture)

		texture.image.src = image


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
	
	@survey = null
	@set = null
	@alpha = 1.0
	@name = ''
	
	constructor: (@gl, @Math, type, survey, texture, fits, range, name) ->
		
		@survey = survey

		if type == "sky"
						
			@proj = new Projection(@Math)
			@set = false
			@proj.init(texture,fits,this,survey)
			
		else if type == "anno"
			this.initTexture(texture)
			this.createSphere([range[1], range[0], range[0], range[1]],
				[range[3], range[3], range[2], range[2]])
			this.setFlag()
			
			@alpha = 1.0
			@name = name
		###
		else if type == "sphere"
			this.createSphere()
			this.initTexture(texture)
		###	
		return
	setAlpha:(value)=>
		@alpha = 1.0
	setFlag:()=>
		@set = true
		return
	getSet:()=>
		return @set

<<<<<<< HEAD
	handleLoadedTexture: (texture)=>
||||||| merged common ancestors
	initTexture: (image) =>
		@Texture = new TextureProxy(@gl, image, Config.proxy_default_texture)
    
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
=======
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
>>>>>>> 1113afa44c1601ed460d1e7a1972ea3472215d4d

		@gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)

<<<<<<< HEAD
		@gl.bindTexture(@gl.TEXTURE_2D, texture)
		@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, texture.image)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE);
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE);
		@gl.bindTexture(@gl.TEXTURE_2D, null)
||||||| merged common ancestors
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
=======
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(color), @gl.STATIC_DRAW)
		@VertexColorBuffer.itemSize = 4
		@VertexColorBuffer.numItems = 8 * Math.pow(4,@levels) * 6
					
		return

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
>>>>>>> 1113afa44c1601ed460d1e7a1972ea3472215d4d

	initTexture: (image) =>
		@Texture = @gl.createTexture()
		@Texture.image = new Image()
		@Texture.image.onload = ()=> 
			this.handleLoadedTexture(@Texture)

		@Texture.image.src = image
    
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
