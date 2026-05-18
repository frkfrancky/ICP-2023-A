/// Match Camera - Affiche le niveau chargé + éléments de match avec rendu 3D
depth = -99999;

// Shader uniforms - créer d'abord pour level_loader
if (!variable_global_exists("vFormat")) {
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    global.vFormat = vertex_format_end();
}

// Charger le niveau
match_objects = [];
if (variable_global_exists("level_to_load") && global.level_to_load != "") {
    match_objects = level_loader(global.level_to_load);
    global.level_to_load = "";
}

// Surface 3D
match_surf = -1;

// Éclairage
day_hour = 14.0;
update_lighting = function() {
    var _h = day_hour;
    if (_h >= 5.5 && _h <= 20.5) {
        var _t    = (_h - 5.5) / 15.0;
        var _warm = abs(_t - 0.5) * 2;
        var _elev_rad = _t * pi;
        var _elev = sin(_elev_rad);
        var _horiz = cos(_elev_rad);
        lit_dir   = [0.5 * _horiz, 0.0, max(_elev, 0.02)];
        lit_color = [1.5, 1.5*(1.0-_warm*0.35), 1.5*(1.0-_warm*0.6)];
        lit_amb   = lerp(0.50, 0.18, _warm);
        lit_rim   = lerp(0.20, 0.65, _warm);
    } else {
        lit_dir   = [0.12, 0.0, 0.99];
        lit_color = [0.12, 0.15, 0.30];
        lit_amb   = 0.07;
        lit_rim   = 0.10;
    }
};

lit_dir   = [0, 0, 1];
lit_color = [1, 1, 1];
lit_amb   = 0.4;
lit_rim   = 0.3;
update_lighting();

// Uniforms shaders
u_ldir        = shader_get_uniform(Shader1, "u_lightDir");
u_lcol        = shader_get_uniform(Shader1, "u_lightColor");
u_lamb        = shader_get_uniform(Shader1, "u_ambient");
u_lrim        = shader_get_uniform(Shader1, "u_rimStrength");
u_pl0         = shader_get_uniform(Shader1, "u_pl0");
u_pl1         = shader_get_uniform(Shader1, "u_pl1");
u_pl0col      = shader_get_uniform(Shader1, "u_pl0col");
u_pl1col      = shader_get_uniform(Shader1, "u_pl1col");
u_pl2         = shader_get_uniform(Shader1, "u_pl2");
u_pl2col      = shader_get_uniform(Shader1, "u_pl2col");
u_pl2rad      = shader_get_uniform(Shader1, "u_pl2rad");
u_sprpos      = shader_get_uniform(Shader1, "u_sprpos");
u_flat_normal = shader_get_uniform(Shader1, "u_flat_normal");
u_plcol       = shader_get_uniform(Shader1, "u_plcol");
u_plrad       = shader_get_uniform(Shader1, "u_plrad");

// Floor
u_fldir = shader_get_uniform(shd_floor, "u_lightDir");
u_flcol = shader_get_uniform(shd_floor, "u_lightColor");
u_flamb = shader_get_uniform(shd_floor, "u_ambient");
u_fl_pl0    = shader_get_uniform(shd_floor, "u_pl0");
u_fl_pl1    = shader_get_uniform(shd_floor, "u_pl1");
u_fl_pl2    = shader_get_uniform(shd_floor, "u_pl2");
u_fl_pl3    = shader_get_uniform(shd_floor, "u_pl3");
u_fl_pl0col = shader_get_uniform(shd_floor, "u_pl0col");
u_fl_pl1col = shader_get_uniform(shd_floor, "u_pl1col");
u_fl_pl2col = shader_get_uniform(shd_floor, "u_pl2col");
u_fl_pl3col = shader_get_uniform(shd_floor, "u_pl3col");

// Shadow
shadow_enable = true;
shadow_surf = -1;
shadow_sz = 1024;
shadow_darkness = 0.3;
shadow_bias = 0.005;

lit_pos = [0, 0, 1500];
lit_right = [1, 0, 0];
lit_up = [0, 0, 1];
lit_fwd = [0, 0, -1];
lit_hw = 1100;
lit_hh = 750;
lit_far = 8000;

u_litPos      = shader_get_uniform(Shader1, "u_litPos");
u_litRight    = shader_get_uniform(Shader1, "u_litRight");
u_litUp       = shader_get_uniform(Shader1, "u_litUp");
u_litFwd      = shader_get_uniform(Shader1, "u_litFwd");
u_litHW       = shader_get_uniform(Shader1, "u_litHW");
u_litHH       = shader_get_uniform(Shader1, "u_litHH");
u_litFar      = shader_get_uniform(Shader1, "u_litFar");
u_shadow_samp = shader_get_sampler_index(Shader1, "u_shadowMap");
u_shadow_en   = shader_get_uniform(Shader1, "u_shadowEnable");
u_shadow_dark = shader_get_uniform(Shader1, "u_shadowDarkness");
u_shadow_bias = shader_get_uniform(Shader1, "u_shadowBias");
u_shadow_recv = shader_get_uniform(Shader1, "u_shadowRecv");

// Caméra
fov_y = 35;
z_target = 16;
zt_p = 16;
cam_view_mat = matrix_get(matrix_view);
cam_proj_mat = matrix_get(matrix_projection);
cam_surf_w = 1280;
cam_surf_h = 720;
