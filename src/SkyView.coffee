#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	
	constructor: (options) ->
	
		super(options)
		
		@Math = new math()
		@level = 0
		
		@HTM = new HTM(@level, @gl, @Math)
		@rotation = [0.0, 0.0, 0.0,]
		@translation = [0.0, 0.0, 0.0]
		@renderMode = @gl.TRIANGLES
		
		octamap = document.getElementById('octamap')
		@ctx = octamap.getContext('2d')
		
		this.render()
	
	getScale: =>
		(180.0 * (1.0-@translation[2]))/2
	getLevel: =>
		180.0/(Math.pow(2,@level+1))
	getPoint:(vert)=>
		
		denom = Math.abs(vert[0]) + Math.abs(vert[1]) + Math.abs(vert[2])
		p_prime = [vert[0]/denom,vert[1]/denom,vert[2]/denom]
		
		p_dp = [0.0,0.0]
		
		if(p_prime[1] >= 0)
			p_dp = [p_prime[0],p_prime[2]]
		else
			p_dp = [@Math.sign(p_prime[0])*(1-@Math.sign(p_prime[2]))*p_prime[2],
					@Math.sign(p_prime[2])*(1-@Math.sign(p_prime[0]))*p_prime[0]]
		return p_dp
	render: ()=>

		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		@HTM.render(@gl, @renderMode) # render to screen
		
		# OctaMap rendering
				
		tri = @HTM.getTriangles()
		
		@ctx.fillStyle = "red"
		@ctx.fillRect(0,0,500,500)
	
		for triangle in tri
			@ctx.beginPath()  
			
			console.log "triangle points: ", triangle

			console.log "testpoint0: ", this.getPoint([0.0,-0.707,-0.707])
			console.log "testpoint1: ", this.getPoint([0.707,0.0,-0.707])
			console.log "testpoint2: ", this.getPoint([0.707,-0.707,0])

			point = this.getPoint(triangle[0])
			console.log "point0: ",point
			@ctx.moveTo((point[0]+1)*250,(point[1]+1)*250)
			
			point = this.getPoint(triangle[1])
			console.log "point1: ",point
			@ctx.lineTo((point[0]+1)*250,(point[1]+1)*250)
			
			point = this.getPoint(triangle[2])
			console.log "point2: ",point
			@ctx.lineTo((point[0]+1)*250,(point[1]+1)*250)
		     
			@ctx.closePath()
			@ctx.stroke()	
		
		return
	
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
					
			when '0' then @HTM = new HTM(0,@gl,@Math)
			when '1' then @HTM = new HTM(1,@gl,@Math)
			when '2' then @HTM = new HTM(2,@gl,@Math)
			when '3' then @HTM = new HTM(3,@gl,@Math)
			when '4' then @HTM = new HTM(4,@gl,@Math)
			when '5' then @HTM = new HTM(5,@gl,@Math)
			when '6' then @HTM = new HTM(6,@gl,@Math)
			when '7' then @HTM = new HTM(7,@gl,@Math)
			when '8' then @HTM = new HTM(8,@gl,@Math)
			
		this.render()	
		return
	
	mousePress: (key) =>
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
				alert names[it]
				break
			else
				console.log triangle
		return
