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
		
		#for i in [1..26]	
			#console.log i
			#@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "./images/#{i}.jpeg")
		
#		@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "./images/test1.jpeg", "./fitsFiles/test1.fit")
#		@gridBlocks.push new HTM(@level, @gl, @Math, "sky", "./images/test2.jpeg", "./fitsFiles/test2.fit")
			
#		@gridBlocks.push new HTM(@level, @gl, @Math, "sphere", "./images/toast.png")
		
		#set initial scale
#		document.getElementById("scale").value = (1)*3600
				
		#render
		this.render(true)
		
		return
		
	setScale: ()=>
		@translation[2] = 1-(document.getElementById("scale").value/45.0)
	setRotation: ()=>
		@rotation[1] = parseFloat(document.getElementById("RA").value)
		@rotation[0] = parseFloat(document.getElementById("Dec").value)
	setLevel: ()=>
		@level = parseInt(document.getElementById("level").value)
		
	render: (flag)=>
		
		if flag? and flag is true
		
			## retrieve RA and radius ##
			radius = 30#parseFloat(document.getElementById("scale").value) / 60.0
			if radius < 1.0
				radius = 1.0
			ra = 176#parseFloat(document.getElementById("RA").value)
			dec = 52#parseFloat(document.getElementById("Dec").value)
		
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
