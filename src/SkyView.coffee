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
		
	drawTriangle: (point)=>	
		
		@ctx.beginPath()  
		
		@ctx.moveTo((point[0][0]+1)*250,(point[0][1]+1)*250)
		@ctx.lineTo((point[1][0]+1)*250,(point[1][1]+1)*250)
		@ctx.lineTo((point[2][0]+1)*250,(point[2][1]+1)*250)
		
		@ctx.closePath()
		@ctx.stroke()
		
	octaCurse:(points,level)=>
		
		p0 = [(points[0][0]+points[1][0])/2, (points[0][1]+points[1][1])/2 ]
		p1 = [(points[1][0]+points[2][0])/2, (points[1][1]+points[2][1])/2 ]
		p2 = [(points[2][0]+points[0][0])/2, (points[2][1]+points[0][1])/2 ]
		
		console.log "p0", p0
		console.log "p1", p1
		console.log "p2", p2
		
		newTri = [
		
			[p2,p1,points[2]]
			[points[0],p0,p2]
			[p0,points[1],p1]
			[p0,p1,p2]
		]
		
		if level is 0
			this.drawTriangle(newTri[0])
			this.drawTriangle(newTri[1])
			this.drawTriangle(newTri[2])
			this.drawTriangle(newTri[3])
		else
			this.octaCurse(newTri[0],level-1)
			this.octaCurse(newTri[1],level-1)
			this.octaCurse(newTri[2],level-1)
			this.octaCurse(newTri[3],level-1)
			
		
	render: ()=>

		this.preRender() # set up matrices
		@HTM.bind(@gl, @shaderProgram) # bind vertices
		this.postRender(@rotation, @translation) # push matrices to Shader
		@HTM.render(@gl, @renderMode) # render to screen
		
		# OctaMap rendering
				
		tri = @HTM.getInitTriangles()
		names = @HTM.getNames()
		
		@ctx.fillStyle = "red"
		@ctx.fillRect(0,0,500,500)
		
		it = 0
		
		for triangle in tri
			
			point0 = this.getPoint(triangle[0])
			if names[it].indexOf("S3") != -1 and @Math.compare(point0,[0,0]) then point0=[1,-1]
			point1 = this.getPoint(triangle[1])
			if names[it].indexOf("S3") != -1 and @Math.compare(point1,[0,0]) then point1=[1,-1]
			point2 = this.getPoint(triangle[2])
			if names[it++].indexOf("S3") != -1 and @Math.compare(point2,[0,0]) then point2=[1,-1]
			
			console.log "point0: ",point0
			console.log "point1: ",point1
			console.log "point2: ",point2
			console.log "triangle points: ", names,triangle
			
			if @level is 0
				this.drawTriangle([point0,point1,point2])
				
			else 
				this.octaCurse([point0,point1,point2],@level-1)
		 
				
		
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
