// Fragment Shader — Glow outline : dilate la silhouette du sprite
// Principe : si le pixel est transparent MAIS qu'un voisin est opaque → pixel de glow
// Résultat : halo coloré qui sort du contour du sprite
varying vec2 v_vTexcoord;
varying vec4 v_vColour;  // couleur du glow passée via vertex color

uniform vec2  u_texelSize;  // (1/texW, 1/texH)
uniform float u_radius;     // rayon de dilation en pixels

void main() {
    vec2 uv  = v_vTexcoord;
    vec4 self = texture2D(gm_BaseTexture, uv);

    // Si le pixel original est déjà opaque : pas de glow ici
    if (self.a > 0.15) {
        // Légère teinte claire sur le sprite lui-même pour alimenter le bloom
        float lum = dot(self.rgb, vec3(0.299, 0.587, 0.114));
        gl_FragColor = vec4(v_vColour.rgb * lum * 0.4, self.a * 0.0);
        return;
    }

    // Chercher le maximum d'alpha dans le voisinage (dilation)
    float maxAlpha = 0.0;
    vec2 t = u_texelSize * u_radius;

    // 8 directions + diagonales (16 samples pour un halo doux)
    float r = u_radius;
    for (float dx = -r; dx <= r; dx += 1.0) {
        for (float dy = -r; dy <= r; dy += 1.0) {
            if (dx == 0.0 && dy == 0.0) continue;
            float dist = length(vec2(dx, dy));
            if (dist > r) continue;
            vec2 offset = vec2(dx, dy) * u_texelSize;
            float a = texture2D(gm_BaseTexture, uv + offset).a;
            // Atténuation selon distance : glow plus fort près du bord
            float weight = 1.0 - (dist / (r + 1.0));
            maxAlpha = max(maxAlpha, a * weight);
        }
    }

    if (maxAlpha < 0.05) discard;

    // Couleur du glow : couleur de l'équipe, plus lumineux au bord
    float glowStr = smoothstep(0.0, 1.0, maxAlpha);
    gl_FragColor = vec4(v_vColour.rgb, glowStr * v_vColour.a);
}
