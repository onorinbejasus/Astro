class Texture
	
	@MAX_CACHE_IMAGES = 16
	
	TextureImageLoader:(loadedCallback)->
		
		@image = new Image()
		
		@image.addEventListener("load", ()=>
			
			@gl.bindTexture(@gl.TEXTURE_2D, @texture);
			@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, @image);
			
			releaseImage(this)
			
			if @callback
				@callback(@texture)
		 )
		
	loadTexture:(gl, src, texture,callback)=>
		@gl = gl
		@texture = texture
		@callback = callback
		@image.src = src
		