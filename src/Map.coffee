class Map

	constructor: (@tri, @colors, @Math, @names)->
		
		octamap = document.getElementById('octamap')
		@ctx = octamap.getContext('2d')
		@it = 0
	
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
	
	drawTriangle: (point, iterator)=>	

		@ctx.strokeStyle = @Math.RGBAtoHEX(@colors[0][0])

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

		newTri = [
			[p0,points[1],p1]
			[points[0],p0,p2]
			[p2,p1,points[2]]	
			[p0,p1,p2]
		]

		if level is 0
			this.drawTriangle(newTri[0],@it++)
			this.drawTriangle(newTri[1],@it++)
			this.drawTriangle(newTri[2],@it++)
			this.drawTriangle(newTri[3],@it++)
		else
			this.octaCurse(newTri[0],level-1)
			this.octaCurse(newTri[2],level-1)
			this.octaCurse(newTri[1],level-1)
			this.octaCurse(newTri[3],level-1)
			
	render: (level) =>
		
		@ctx.fillStyle = "red"
		@ctx.fillRect(0,0,500,500)
		
		it = 0
		@it = 0
		
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
			
			#console.log "point0: ",point0
			#console.log "point1: ",point1
			#console.log "point2: ",point2
			#console.log "triangle points: ", @names, triangle
			
			if level is 0
				this.drawTriangle([point0,point1,point2],@it++)
				
			else 
				this.octaCurse([point0,point1,point2],level-1,@it)
		
		return