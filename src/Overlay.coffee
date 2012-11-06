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

class Tile

	@VertexPositionBuffer = null
	@VertexColorBuffer = null
	@VertexIndexBuffer = null
	@VertexTextureCoordBuffer = null
	@VertexNormalBuffer = null

	@Texture = null

	constructor: (@gl, @Math, survey, type, texture, fits, range) ->

		if type == "sky"

			@proj = new Projection(@Math)
			@set = false
			@proj.init(texture,fits,this,survey)

		else if type == "anno"
			this.initTexture(texture)
			this.createTile([range[1], range[0], range[0], range[1]],
				[range[3], range[3], range[2], range[2]])
			this.setFlag()

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

	createTile: (ra, dec)=>

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

	bind: (shaderProgram)=>

		@gl.activeTexture(@gl.TEXTURE0)
		@gl.bindTexture(@gl.TEXTURE_2D, @Texture)
		@gl.uniform1i(shaderProgram.samplerUniform, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexTextureCoordBuffer);
		@gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, @VertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @VertexIndexBuffer)

		return

	render: (renderMode) =>
		@gl.drawElements(renderMode, @VertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)

	setFlag:()=>
		@set = true
		return

	getSet:()=>
		return @set

class Overlay
	
	@survey = null
	@set = null
	@alpha = 1.0
	@name = ''
	@cache = {}

	constructor: (@SkyView, survey, range, name) ->
		@refresh = () -> return 0
		@survey = survey
		@tiles = []
		@cache = {}
		if @survey == "SDSS"
			this.createSDSSOverlay()
		else if @survey == "LSST"
			this.createLSSTOverlay()
		else if @survey == "FIRST"
			this.createFIRSTOverlay()

		@alpha = 1.0
		@name = name

		return

	createFIRSTOverlay: ()=>

		@firstflag = false
		temp_this = this
		@refresh = () =>
			range = @SkyView.getBoundingBox()
			getInfo = {RAMin: range.maxRA, RAMax: range.minRA, DecMin: range.maxDec, DecMax: range.minDec};
			url = 'lib/db/remote/SPATIALTREE.php' 
			done = (e) =>
				for image, index in e
						name = image.split "../../images/"
						if not temp_this.cache[name]
							@tiles.push new Tile(@SkyView.gl, @SkyView.Math,"FIRST",  "sky",
							"#{name[1]}", "", null)
							temp_this.cache[name] = true

			$.get(url, getInfo, done, 'json')
		@refresh()
		return

	createLSSTOverlay: ()=>

		@lsstarray = []
		@lsstflag = false
		lfile = new XMLHttpRequest()
		lfile.open('GET', '../../lsstimages/filelist.txt',true)   #this path should change to the full path on astro server /u/astro/images/LSST/jpegfiles.txt
		lfile.onload = (e) =>
			text = lfile.responseText
			lines = text.split("\n")
			$.each(lines, (key,val) =>
				@lsstarray.push val
			)

			for image in @lsstarray
				@tiles.push new Tile(@SkyView.gl, @SkyView.Math,"LSST", "sky", 
					"#{image}", "", null)

		lfile.send()

		return

	createSDSSOverlay: ()=>

		## retrieve RA and radius ##
		radius = 45#((-@translation[2]+1)*15)*90

		if radius < 1.0
			radius = 1.0

		ra = -@SkyView.rotation[1]
		dec = -@SkyView.rotation[0]

		# select the images

		$.ajaxSetup({'async': false})	

		$.getJSON("./lib/webgl/SDSSFieldQuery.php?ra=#{ra}&dec=#{dec}&radius=
			#{radius}&zoom=0", (data) =>
				$.each(data, (key, val)=>
					if key % 2 == 0
						fitsFile = data[key+1]
						fits=fitsFile.split(".")[0].concat(".").concat(fitsFile.split(".")[1])
						@tiles.push  new Tile(@SkyView.gl, @SkyView.Math, "SDSS", "sky",
							"http://astro.cs.pitt.edu/sdss2degregion00/#{val}",
							"/afs/cs.pitt.edu/projects/admt/web/sites/astro/sdss2degregion00/headtext/#{fits}", null)
				)	
		)
		$.ajaxSetup({'async': true})

	createAnnoOverlay: (raDec, raMin, raMax, decMin, decMax, color, label)=>

		scale = ((-@SkyView.translation[2]+1)*15) * 3600

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
				'diam':1,
				'color':color,
				'table':JSON.stringify(raDec)
			success:(data)=>
				img = data
				return
		)		

		$.ajaxSetup({'async': true})	

		imgURL = "./lib/overlays/#{img}"

		range = [raMin, raMax, decMin, decMax]
		tempRange = [0.0, 1.0, 0.0, 1.0]
		
		tile =  new Tile(@SkyView.gl, @SkyView.Math, "anno", "anno", 
			imgURL, null, tempRange)

		@tiles.push tile

		return

	setAlpha:(value)=>
		@alpha = value
		@SkyView.render()
		return