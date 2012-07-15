#= require WebGL
		
class Map extends WebGL
	
	@VertexPositionBuffer = null
	@VertexColorBuffer = null
	@verts = null
	@color = null
	
	constructor: (@tri, @colors, @Math, @names)->
		
		octamap.canvas = document.getElementById('octamap')
		
		super(octamap)
		
		@rotation = [0.0, 0.0, 0.0]
		@translation = [0.0, 0.0, 0.0]
		
		@centers = []
			
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
	
	makeTriangle: (point, flag)=>	
		
		a = Math.sqrt(Math.pow(point[1][0]-point[2][0],2) + Math.pow(point[1][1]-point[2][1],2))
		b = Math.sqrt(Math.pow(point[0][0]-point[2][0],2) + Math.pow(point[0][1]-point[2][1],2))
		c = Math.sqrt(Math.pow(point[0][0]-point[1][0],2) + Math.pow(point[0][1]-point[1][1],2))

		x = (point[0][0] + point[1][0] + point[2][0])/(a+b+c)
		y = (point[0][1] + point[1][1] + point[2][1])/(a+b+c)
		
#		image = new ImageProxy("./images/square.png","./images/placeholder.jpg")
		
		@centers.push([x,y])
 
		@verts.push((point[0][0]+1))
		@verts.push((point[0][1]+1))
		@verts.push(-5.0)
		@verts.push((point[1][0]+1))
		@verts.push((point[1][1]+1))
		@verts.push(-5.0)
		@verts.push((point[1][0]+1))
		@verts.push((point[1][1]+1))
		@verts.push(-5.0)
		@verts.push((point[2][0]+1))
		@verts.push((point[2][1]+1))
		@verts.push(-5.0)
		@verts.push((point[2][0]+1))
		@verts.push((point[2][1]+1))
		@verts.push(-5.0)
		@verts.push((point[0][0]+1))
		@verts.push((point[0][1]+1))
		@verts.push(-5.0)
		
		color = [
			[[0.0, 0.0, 0.0, 1.0],
			[0.0, 0.0, 0.0, 1.0],
			[0.0, 0.0, 0.0, 1.0]],
		]
		for num in [0..1]
			for j in color
				for k in j
					for l in k
						@color.push(l)
		
		return
		
	octaCurse:(points,level,name,selected)=>
		
		# initialize names and iterator
		
		names = ["#{name}0","#{name}1",
			"#{name}2","#{name}3"]
		
		it = 0
		
		# calculate three points of triangle
		
		p0 = [(points[0][0]+points[1][0])/2, (points[0][1]+points[1][1])/2 ]
		p1 = [(points[1][0]+points[2][0])/2, (points[1][1]+points[2][1])/2 ]
		p2 = [(points[2][0]+points[0][0])/2, (points[2][1]+points[0][1])/2 ]
				
		# create new triangles

		newTri = [
			[p0,points[1],p1]
			[points[0],p0,p2]
			[p2,p1,points[2]]	
			[p0,p1,p2]
		]
		
		# render them or recurse
		
		for tri in newTri
			if level is 0
				if names[it++] == selected
					this.makeTriangle(tri,true)
				else
					this.makeTriangle(tri,false)
			else
				this.octaCurse(tri,level-1,names[it++],selected)
			
	render: (level, selected) =>
		
		# initialize iterators and names
				
		it = 0
		@it = 0
		
		initNames = ["S0","S1","S2","S3","N0","N1","N2","N3"]
				
		@verts = []
		@color = []
				
		# loop over initial triangles
		
		for triangle in @tri
			
			point0 = this.getPoint(triangle[0])
			if @names[it].indexOf("S0") != -1 and @Math.compare(point0,[0,0]) then point0=[1,1]
			if @names[it].indexOf("S1") != -1 and @Math.compare(point0,[0,0]) then point0=[-1,1]
			if @names[it].indexOf("S2") != -1 and @Math.compare(point0,[0,0]) then point0=[-1,-1]
			if @names[it].indexOf("S3") != -1 and @Math.compare(point0,[0,0]) then point0=[1,-1]
			point1 = this.getPoint(triangle[1])
			if @names[it].indexOf("S0") != -1 and @Math.compare(point1,[0,0]) then point1=[1,1]
			if @names[it].indexOf("S1") != -1 and @Math.compare(point1,[0,0]) then point1=[-1,1]
			if @names[it].indexOf("S2") != -1 and @Math.compare(point1,[0,0]) then point1=[-1,-1]
			if @names[it].indexOf("S3") != -1 and @Math.compare(point1,[0,0]) then point1=[1,-1]
			point2 = this.getPoint(triangle[2])
			if @names[it].indexOf("S0") != -1 and @Math.compare(point2,[0,0]) then point2=[1,1]
			if @names[it].indexOf("S1") != -1 and @Math.compare(point2,[0,0]) then point2=[-1,1]
			if @names[it].indexOf("S2") != -1 and @Math.compare(point2,[0,0]) then point2=[-1,-1]
			if @names[it++].indexOf("S3") != -1 and @Math.compare(point2,[0,0]) then point2=[1,-1]
			
			# render triangles
			
			if level is 0
				if selected == initNames[@it++]	
					this.makeTriangle([point0,point1,point2],true)
				else
					this.makeTriangle([point0,point1,point2],false)
			else 
				this.octaCurse([point0,point1,point2],level-1, initNames[@it++], selected)
			
		# create buffers
		
		@VertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@verts), @gl.STATIC_DRAW)
		@VertexPositionBuffer.itemSize = 3
		@VertexPositionBuffer.numItems = 6#8 * Math.pow(4,level) * 6
		
		@VertexColorBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexColorBuffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(@color), @gl.STATIC_DRAW)
		@VertexColorBuffer.itemSize = 4
		@VertexColorBuffer.numItems = 6#8 * Math.pow(4,level) * 6
				
		# bind and draw
		this.preRender()
		this.bind()
		this.postRender(@rotation, @translation)
		this.draw()
		
		return
		
	bind: () =>

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexPositionBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @VertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		@gl.bindBuffer(@gl.ARRAY_BUFFER, @VertexColorBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexColorAttribute, @VertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0)

		return

	draw: () =>

		@gl.drawArrays(@gl.LINES, 0, @VertexPositionBuffer.numItems)

		return