class math
	constructor: ()->
	# | v1 + v2 | 
	magnitude: (v1, v2) =>
		Math.pow(Math.pow(v1[0] + v2[0], 2) + Math.pow(v1[1] + v2[1], 2) + Math.pow(v1[2] + v2[2], 2), 0.5)
	# | norm v1 |
	norm: (v1) =>
		mag = Math.sqrt(Math.pow(v1[0],2) + Math.pow(v1[1],2) + Math.pow(v1[2],2)+1)
		[v1[0]/mag,v1[1]/mag,v1[2]/mag]
	# v1 - v2
	subtract: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]-v2[0],v1[1]-v2[1]]
		else if v1.length is 3
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2]]
		else if v1.length is 4
			return [v1[0]-v2[0],v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]]	
	# v1 + v2
	add: (v1, v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return [v1[0]+v2[0],v1[1]+v2[1]]
		else if v1.length is 3
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2]]
		else if v1.length is 4
			return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]]
	# v1 dot v2
	dot: (v1,v2)=>
		if v1.length is not v2.length then return null
		else if v1.length is 2
			return v1[0]*v2[0]+v1[1]*v2[1]
		else if v1.length is 3
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]
		else if v1.length is 4
			return v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
	# v1 x v2
	cross: (v1, v2)=>
		[v1[1]*v2[2]-v1[2]*v2[1], v1[2]*v2[0]-v1[0]*v2[2], v1[0]*v2[1]-v1[1]*v2[0]]
	unProj: (winX, winY, winZ, mod_mat, proj_mat, viewport) =>
		inf = []		
		# invert the model view and projection matrices
		m = mat4.set(mod_mat, mat4.create())
		console.log "m set: ", m
		b = mat4.inverse(m)
		console.log "b inverse: ", b
		mat4.multiply(proj_mat, b, b)
		console.log "m mult: ", m
		c = mat4.inverse(b)
		console.log "c inverse: ", c		
				
		inf.push ( (winX - viewport[0])/viewport[2] * 2.0 - 1.0 )
		inf.push ( (winY - viewport[1])/viewport[3] * 2.0 - 1.0 )
		inf.push (2.0 * winZ - 1.0)
		inf.push 1.0
		
		out = [0,0,0,0]
				
		mat4.multiplyVec4(m, inf, out)
							
		if out[3] is 0 then return null
		
		out[3] = 1.0/out[3]
				
		return [out[0]*out[3], out[1]*out[3], out[2]*out[3]]
	
	intersectTri: (orig,dir,verts) =>
		
		a = verts[0]
		b = verts[1]
		c = verts[2]

		eihf = (a[1]-c[1])*dir[2] - dir[1]*(a[2]-c[2])
		gfdi = dir[0]*(a[2]-c[2]) - (a[0]-c[0])*dir[2]
		dheg = (a[0]-c[0])*dir[1] - (a[1]-c[1])*dir[0]
		M = (a[0]-b[0])*eihf + (a[1]-b[1])*gfdi + (a[2]-b[2])*dheg

		akjb = (a[0]-b[0])*(a[1]-orig[1]) - (a[0]-orig[0])*(a[1]-b[1])
		jcal = (a[0]-orig[0])*(a[2]-b[2]) - (a[0]-b[0])*(a[2]-orig[2])
		blkc = (a[1]-b[1])*(a[2]-orig[2]) - (a[1]-orig[1])*(a[2]-b[2])

		betatop = (a[0]-orig[0])*eihf + (a[1]-orig[1])*gfdi + (a[2]-orig[2])*dheg
		gammatop = dir[2]*akjb + dir[1]*jcal + dir[0]*blkc
		ttop = (a[2]-c[2])*akjb + (a[1]-c[1])*jcal + (a[0]-c[0])*blkc

		u = betatop/M
		v = gammatop/M
		t = ttop/M

		console.log "t,u,v: ",t,u,v

		if(u < 0.0 || u > 1.0)
			console.log "no intersection"
		else
			if(v < 0.0 || u+v > 1.0)
				console.log "no intersection"
			else
				console.log "Hit!"
		return
