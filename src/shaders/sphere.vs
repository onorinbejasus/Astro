<script id="shader-vs" type="x-shader/x-vertex">

attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;
attribute float aTexturePos;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNMatrix;

varying vec2 vTextureCoord;
varying float vTexturePos;

void main(void) {
    
	gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    
	vTextureCoord = aTextureCoord;
  vTexturePos = aTexturePos;

}
</script>