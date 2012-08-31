<script id="shader-fs" type="x-shader/x-fragment">
 
#ifdef GL_ES
  precision highp float;
  #endif

  varying vec2 vTextureCoord;
  varying float vTexturePos;

  uniform sampler2D sampler1;
  uniform sampler2D sampler2;
  uniform sampler2D sampler3;
  uniform sampler2D sampler4;
  uniform sampler2D sampler5;
  uniform sampler2D sampler6;
  uniform sampler2D sampler7;
  uniform sampler2D sampler8;
  uniform sampler2D sampler9;
  uniform sampler2D sampler10;
  uniform sampler2D sampler11;
  uniform sampler2D sampler12;
  uniform sampler2D sampler13;
  uniform sampler2D sampler14;
  uniform sampler2D sampler15;
  uniform sampler2D sampler16;

  uniform float alpha;
  
  void main(void) {

	  gl_FragColor = vec4(0.0,0.0,0.0,0.0);
	  
	if(vTexturePos == 1.0){
      	gl_FragColor += alpha*texture2D(sampler1, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 2.0){
      	gl_FragColor += alpha*texture2D(sampler2, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 3.0){
      	gl_FragColor += alpha*texture2D(sampler3, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 4.0){
      	gl_FragColor += alpha*texture2D(sampler4, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 5.0){
      	gl_FragColor += alpha*texture2D(sampler5, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 6,0){
      	gl_FragColor += alpha*texture2D(sampler6, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 7.0){
      	gl_FragColor += alpha*texture2D(sampler7, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 8.0){
      	gl_FragColor += alpha*texture2D(sampler8, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 9.0){
      	gl_FragColor += alpha*texture2D(sampler9, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 10.0){
      	gl_FragColor += alpha*texture2D(sampler10, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 11.0){
      	gl_FragColor += alpha*texture2D(sampler11, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 12.0){
      	gl_FragColor += alpha*texture2D(sampler12, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 13.0){
      	gl_FragColor += alpha*texture2D(sampler13, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 14.0){
      	gl_FragColor += alpha*texture2D(sampler14, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 15.0){
      	gl_FragColor += alpha*texture2D(sampler15, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
	else if(vTexturePos == 16.0){
      	gl_FragColor += alpha*texture2D(sampler16, vec2(vTextureCoord.s, vTextureCoord.t));
	  }
 }
</script>