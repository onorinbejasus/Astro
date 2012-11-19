<script id="shader-fs" type="x-shader/x-fragment">
 
#ifdef GL_ES
  precision highp float;
  #endif

  varying vec2 vTextureCoord;

  uniform sampler2D uSampler;
	uniform float alpha;

  void main(void) {

      gl_FragColor = alpha*texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
 
 }
</script>