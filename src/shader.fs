<script id="shader-fs" type="x-shader/x-fragment">
    #ifdef GL_ES
    precision highp float;
    #endif
    
		varying vec4 vColor;

    void main(void) {
        gl_FragColor = vColor;
    }
</script>