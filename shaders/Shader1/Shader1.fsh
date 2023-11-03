// Fragment Shader

varying vec2 v_vTexcoord;

uniform sampler2D u_BaseTexture;
uniform vec2 u_texelSize;

const float blurSize = 5.0; // Change this value to adjust the amount of blur

void main()
{
    vec4 sum = vec4(0.0);
    vec2 texcoord = v_vTexcoord;
    vec4 color = texture2D(u_BaseTexture, texcoord);
    
    // Apply horizontal blur
    for (float i = -blurSize; i < blurSize; i++)
    {
        float offset = i * u_texelSize.x;
        sum += texture2D(u_BaseTexture, vec2(texcoord.x + offset, texcoord.y)) / (2.0 * blurSize + 1.0);
    }
    
    // Apply vertical blur
    for (float i = -blurSize; i < blurSize; i++)
    {
        float offset = i * u_texelSize.y;
        sum += texture2D(u_BaseTexture, vec2(texcoord.x, texcoord.y + offset)) / (2.0 * blurSize + 1.0);
    }
    
    // Set the output color
	gl_FragColor = sum / (2.0 * blurSize + 1.0);
	//gl_FragColor = 1;
}


