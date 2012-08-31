class Overlay
	
	@survey = null
	@set = null
	@alpha = 1.0
	@name = ''
	@set = false
	
	@Textures = null
	
	@VertexPositionBuffer = null
	@VertexIndexBuffer = null
	@VertexTextureCoordBuffer = null
	@VertexTexturePosBuffer = null
		
	@vertexPositionData = null
	@textureCoordData = null
	@indexData = null
	@texturePos = null
	
	@numTextures = 0
	@indexPos = 0
	
	constructor: (@SkyView, survey, range, name) ->
		
		@TexturePos = [
			
			@SkyView.gl.TEXTURE0,@SkyView.gl.TEXTURE1,
			@SkyView.gl.TEXTURE2,@SkyView.gl.TEXTURE3,@SkyView.gl.TEXTURE4,
			@SkyView.gl.TEXTURE5,@SkyView.gl.TEXTURE6,@SkyView.gl.TEXTURE7,
			@SkyView.gl.TEXTURE8,@SkyView.gl.TEXTURE9,@SkyView.gl.TEXTURE10,
			@SkyView.gl.TEXTURE11,@SkyView.gl.TEXTURE12,@SkyView.gl.TEXTURE13,
			@SkyView.gl.TEXTURE14,@SkyView.gl.TEXTURE15
			
		]
		
		@survey = survey
		@Textures = []
		
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
		
		@firstarray = []
		@firstflag = false
		ffile = new XMLHttpRequest()
		ffile.open('GET', '../../first2degree/firstimages.txt',true) 
		ffile.onload = (e) =>
			text = ffile.responseText
			lines = text.split("\n")
			$.each(lines, (key,val) =>
				@firstarray.push val
			)
			for image,index in @firstarray when index < 2
				proj = new Projection(@SkyView.Math)
				proj.init(@SkyView.gl,"","#{image}",this,@survey)
		
		ffile.send()
	
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
				proj = new Projection(@SkyView.Math)
				proj.init(@SkyView.gl,"","#{image}",this,@survey)
		
		lfile.send()
		
		return
		
	createSDSSOverlay: ()=>
	
		## retrieve RA and radius ##
		radius = 15#((-@translation[2]+1)*15)*90
		
		@vertexPositionData = [ ]
		@textureCoordData = [ ]
		@indexData = [ ]
		@texturePos = [ ]
		
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
						
						proj = new Projection(@SkyView.Math)
						proj.init(@SkyView.gl,"http://astro.cs.pitt.edu/sdss2degregion00/#{val}",
							"../../sdss2degregion00/headtext/#{fits}",this, @survey)
				)	
		)
		$.ajaxSetup({'async': true})
		
		@VertexPositionBuffer = @SkyView.gl.createBuffer()
		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@SkyView.gl.bufferData(@SkyView.gl.ARRAY_BUFFER, new Float32Array(@vertexPositionData), @SkyView.gl.STATIC_DRAW)
		@VertexPositionBuffer.itemSize = 3
		@VertexPositionBuffer.numItems = @vertexPositionData.length / 3

		console.log "size",@indexData.length
		
		@VertexIndexBuffer = @SkyView.gl.createBuffer()
		@SkyView.gl.bindBuffer(@SkyView.gl.ELEMENT_ARRAY_BUFFER, @VertexIndexBuffer)
		@SkyView.gl.bufferData(@SkyView.gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(@indexData), @SkyView.gl.STATIC_DRAW)
		@VertexIndexBuffer.itemSize = 1
		@VertexIndexBuffer.numItems = @indexData.length

		@VertexTextureCoordBuffer = @SkyView.gl.createBuffer()
		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexTextureCoordBuffer)
		@SkyView.gl.bufferData(@SkyView.gl.ARRAY_BUFFER, new Float32Array(@textureCoordData), @SkyView.gl.STATIC_DRAW)
		@VertexTextureCoordBuffer.itemSize = 2
		@VertexTextureCoordBuffer.numItems = @textureCoordData.length / 2
		
		@VertexTexturePos = @SkyView.gl.createBuffer()
		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexTexturePos)
		@SkyView.gl.bufferData(@SkyView.gl.ARRAY_BUFFER, new Uint16Array(@texturePos), @SkyView.gl.STATIC_DRAW)
		@VertexTexturePos.itemSize = 1
		@VertexTexturePos.numItems = @texturePos.length
		
	createAnnoOverlay: (raDec, raMin, raMax, decMin, decMax, color, label)=>

		scale = ((-@translation[2]+1)*15) * 3600

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
				'diam':2,
				'color':color,
				'table':JSON.stringify(raDec)
			success:(data)=>
				img = data
				return
		)		

		$.ajaxSetup({'async': true})	

		imgURL = "./lib/overlays/#{img}"

		range = [raMin, raMax, decMin, decMax];

		@Texture.push loadTexture(@SkyView.gl,texture,null)
		this.createTile([range[1], range[0], range[0], range[1]],
			[range[3], range[3], range[2], range[2]])
		this.setFlag()
		
		return overlay

	createTile: (ra, dec)=>

		radius = 1
		
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

				@vertexPositionData.push(radius * x)
				@vertexPositionData.push(radius * y)
				@vertexPositionData.push(radius * z)

				@textureCoordData.push 0.0
				@textureCoordData.push 1.0
				@textureCoordData.push 0.0
				@textureCoordData.push 0.0
				@textureCoordData.push 1.0
				@textureCoordData.push 0.0
				@textureCoordData.push 1.0
				@textureCoordData.push 1.0

			@indexData.push @indexPos+2
			@indexData.push @indexPos+3
			@indexData.push @indexPos
			@indexData.push @indePos+1
			@indexData.push @indexPos+2
			@indexData.push @indexPos
			
			@texturePos.push @numTextures%16
			
			@indexPos += 4
			@numTextures++

		return
		
	bindAttributes: (shaderProgram)=>
		
		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@SkyView.gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, @SkyView.gl.FLOAT, false, 0, 0)

		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexTextureCoordBuffer);
		@SkyView.gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, @VertexTextureCoordBuffer.itemSize, @SkyView.gl.FLOAT, false, 0, 0)
		
		@SkyView.gl.bindBuffer(@SkyView.gl.ARRAY_BUFFER, @VertexTexturePos);
		@SkyView.gl.vertexAttribPointer(shaderProgram.texturePosAttribute, @VertexTexturePos.itemSize, @SkyView.gl.FLOAT, false, 0, 0)

		@SkyView.gl.bindBuffer(@SkyView.gl.ELEMENT_ARRAY_BUFFER, @VertexIndexBuffer)

		return
	bindTextures: (shaderProgram, numTextures, offset)=>
		
		iterator = Math.min(@numTextures,numTextures)
		
		for i in [0..iterator-1]

			@SkyView.gl.activeTexture(@TexturePos[i])
			@SkyView.gl.bindTexture(@SkyView.gl.TEXTURE_2D, @Texture[i+offset])
			@SkyView.gl.uniform1i(shaderProgram.sampler[i], i)
		
		return
		
	render: (renderMode) =>
		@SkyView.gl.drawElements(renderMode, @VertexIndexBuffer.numItems, @SkyView.gl.UNSIGNED_SHORT, 0)

	setFlag:()=>
		@set = true
		return

	getSet:()=>
		return @set
	
	setAlpha:(value)=>
		@alpha = value
		@SkyView.render()
		return