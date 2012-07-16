<script id="shader-vs" type="x-shader/x-vertex">

attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNMatrix;

varying vec2 vTextureCoord;

void main(void) {
    
	gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    
	vTextureCoord = aTextureCoord;

	vec3 transformedNormal = uNMatrix * aVertexNormal;
  
}
</script>