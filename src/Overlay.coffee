class TextureProxy
	
	# A TextureProxy uses an already loaded temporary image while
	# another image is loading. 
	
	constructor: (gl, img_url, temp_img_texture) ->
		@texture = temp_img_texture

		on_texture_load = (texture) ->
			@texture = texture

		@initTexture(gl, img_url, on_texture_load)
	
	# Used for initializing textures.
	#
	# @param [GLRenderingContext] gl - used to create a texture
	# @param [Image] image - URL of an image to be used.
	# @param [Function] load_callback Use for callbacks when onload is triggered to get the texture, all loaded.
	# @return [void] Nothing. Use the texture callback to attach something
	#
	
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

# Tiles are used for individual texture images. Need to project them.
class Tile

	@VertexPositionBuffer = null
	@VertexColorBuffer = null
	@VertexIndexBuffer = null
	@VertexTextureCoordBuffer = null
	@VertexNormalBuffer = null

	@Texture = null
	#
	# @param [WebGLRenderingContext] gl used for creating the textures.
	# @param [Math] math for doing projections on the tile
	# @param [String] type used to tell sky from an annotation
	# @param [GLTexture] texture the texture from the webglcontext
	# @param [?] fits used for initializing the fits file.
	# @param [Array<Int>] range an array of ints saying the min and max ranges of the tile
	# 
	constructor: (@gl, @Math, @survey, type, texture, fits, range) ->

		if type == "sky"

			@proj = new Projection(@Math)
			
			if @survey == "FIRST"
				@proj.init(texture,fits,this,survey)
			
			else if @survey == "SDSS"
				imgURL = "./lib/db/remote/SDSS.php?url=#{texture}"
				@proj.init(imgURL,fits,this,@survey)
				
		else if type == "anno"
			this.initTexture(texture)
			this.createTile([range[1], range[0], range[0], range[1]],
				[range[3], range[3], range[2], range[2]])

		return

	# @private
	handleLoadedTexture: (texture)=>
		
		@gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)

		@gl.bindTexture(@gl.TEXTURE_2D, texture)
		@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, texture.image)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE);
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE);
		@gl.bindTexture(@gl.TEXTURE_2D, null)

	# @private
	initTexture: (image) =>
		
		@Texture = @gl.createTexture()
		@Texture.image = new Image()
		
		@Texture.image.onload = ()=> 
			this.handleLoadedTexture(@Texture)
		
		@Texture.image.src = image

	# What is this actually doing? Horrible name. ~Sean
	# @todo Break apart this ugly function.
	# @param [double] ra herp
	# @param [double] dec derp
	#
	createTile: (ra, dec)=>

		radius = 1

		vertexPositionData = []
		normalData = []

		textureCoordData = []

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

			indexData = [0,3,2, 2,1,0]
		
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
	# Take the tile and put it on a shader.
	#
	# @param [Shader] shaderProgram used to take the vertex info from the texture to the program.
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

	# Renders the program onto the canvas.
	#
	# @param [Integer_constant] renderMode the type of render we want.
	render: (renderMode) =>
		@gl.drawElements(renderMode, @VertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)

#
# Holds a list of tiles for a certain survey or annotations.
#

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

	# Creates a FIRST overlay.
	#
	# @todo make this a friggin factory! ~Sean
	#
	createFIRSTOverlay: ()=>

		@firstflag = false
		temp_this = this
		
		@refresh = () =>
			url = 'lib/db/remote/SPATIALTREE.php' 
			range = @SkyView.getBoundingBox()
			getInfo = {RAMin: range.maxRA, RAMax: range.minRA, DecMin: range.maxDec, DecMax: range.minDec};
			done = (e) =>
				for image, index in e
						name = image.split "../../images/"
						if not temp_this.cache[name]
							@tiles.push new Tile(@SkyView.gl, @SkyView.Math,"FIRST", "sky",
							"#{name[1]}", "", null)
							temp_this.cache[name] = true
				@SkyView.render()
			$.get(url, getInfo, done, 'json')
			
		@refresh()
		
		return

	# Creates an LSST overlay.
	#
	# @todo make this a friggin factory! ~Sean
	# @todo make it freaking work.
	#
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

	# Creates a SDSS overlay.
	#
	# @todo make this a friggin factory! ~Sean
	# @todo fix the SECURITY DOM EXCEPTION
	#
	createSDSSOverlay: ()=>

		## retrieve RA and radius ##
		#radius = 30
		temp_this = this
		radius = ((-@SkyView.translation[2]+1)*15)*360

		if radius < 1.0
			radius = 1.0
		
		ra = -@SkyView.rotation[1]
		dec = -@SkyView.rotation[0]

		# select the images
		
		@refresh = ()=>
			done = (data) =>
					$.each(data, (key, val)=>
						if key % 2 == 0 
							path = val 
							fitsFile = data[key+1]
							fits=fitsFile.split(".")[0].concat(".").concat(fitsFile.split(".")[1])
							if not temp_this.cache[fits]
								temp_this.cache[fits] = true
								@tiles.push  new Tile(@SkyView.gl, @SkyView.Math, "SDSS", "sky",
									path,
									"/afs/cs.pitt.edu/projects/admt/web/sites/astro/headers/#{fits}", null)
					@SkyView.render()
					)
			pos = @SkyView.getPosition()
			$.get("./lib/db/remote/SDSSFieldQuery.php?ra=#{pos.ra}&dec=#{pos.dec}&radius=#{radius}&zoom=00", done, 'json')
		
		@refresh()
		@SkyView.render()

	# Creates an annotation overlay to add to the skyview.
	#
	# @param [int] raDec the table containing the points to plot
	# @param [int] raMin the min for RA value
	# @param [int] raMax the max value for RA
	# @param [int] decMin the min value for DEC
	# @param [int] decMax the max value for DEC
	# @param [String?] label the name for the annotation overlay?
	#
	createAnnoOverlay: (raDec, raMin, raMax, decMin, decMax, color, label)=>

		scale = ((-@SkyView.translation[2]+1)*15) * 3600

		img = ''

		$.ajaxSetup({'async': false})	

		width = Math.abs(raMax)-Math.abs(raMin)
		height = Math.abs(decMax)-Math.abs(decMin)

		width = 2024 * (360.0/width)
		height = 2024 * (360.0/height)
		
		$.ajax(
			type: 'POST',
			url: "./lib/createOverlay.php",
			data: 	
				'width':width,
				'height':height,
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
		
		tile =  new Tile(@SkyView.gl, @SkyView.Math, "anno", "anno", 
			imgURL, null, range)

		@tiles.push tile
		
		@SkyView.render()
		
		return

	# Set's the opacity.
	#
	# @param [double] value new value to set the opacity to.
	#
	setAlpha:(value)=>
		@alpha = value
		@SkyView.render()
		return