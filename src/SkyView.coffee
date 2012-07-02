#= require WebGL

class SkyView extends WebGL
	
	@HTM = 0
	@rotation = null
	@translation = null
	@renderMode = 0
	@Math = null
	@it = 0
	
	constructor: (options) ->
	
		super(options)
		
		@Math = new math()
		@level = 0
		
		@HTM = new HTM(@level, @gl, @Math)
		@rotation = [0.0, 0.0, 0.0,]
		@translation = [0.0, 0.0, 0.0]
		@renderMode = @gl.TRIANGLES
		@Map = new Map( @HTM.getInitTriangles(), @HTM.getColors(), @Math, @HTM.getNames())
				
		this.render()
	
	getScale: =>
		(180.0 * (1.0-@translation[2]))/2
	getLevel: =>
		180.0/(Math.pow(2,@level+1))
			
	render: ()=>

		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		@HTM.render(@gl, @renderMode) # render to screen
		@it = 0
		
		# OctaMap rendering
		@Map.render(@level)
		
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
					
			when '0' 
				@HTM = new HTM(0,@gl,@Math)
				@level = 0
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)		
			when '1' 
				@HTM = new HTM(1,@gl,@Math)
				@level = 1
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '2'
				@HTM = new HTM(2,@gl,@Math)
				@level = 2
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '3'
				@HTM = new HTM(3,@gl,@Math)
				@level = 3
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '4'
				@HTM = new HTM(4,@gl,@Math)
				@level = 4
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '5'
				@HTM = new HTM(5,@gl,@Math)
				@level = 5
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '6'
				@HTM = new HTM(6,@gl,@Math)
				@level = 6
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '7'
				@HTM = new HTM(7,@gl,@Math)
				@level = 7
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			when '8'
				@HTM = new HTM(8,@gl,@Math)
				@level = 8
				@ctx.fillStyle = "red"
				@ctx.fillRect(0,0,500,500)
			
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
