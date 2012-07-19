<script id="shader-fs" type="x-shader/x-fragment">
 
#ifdef GL_ES
  precision highp float;
  #endif

  varying vec2 vTextureCoord;

  uniform sampler2D uSampler;

  void main(void) {

      vec4 textureColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
      gl_FragColor = vec4(1.0,0.0,0.0,1.0); //vec4(textureColor.rgb, textureColor.a);
 
 }
</script>