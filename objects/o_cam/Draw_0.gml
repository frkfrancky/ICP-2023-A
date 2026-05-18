var camera= camera_get_active();
/*
if(o_target.camera_libre == false){
	x = o_target.x;
}*/
//camera_set_view_mat(camera, matrix_build_lookat(x,y,-200,object3.x,object3.y,0,0,0,1));
/*camera_set_view_mat(camera, matrix_build_lookat(x,y, -300,o_target.x, o_target.y,0,0,0,1));
camera_set_proj_mat(camera, matrix_build_projection_ortho(room_width, room_height,1, 3200));
z_look at = -500;
*/



z_target = zt_p;

camera_set_view_mat(camera, matrix_build_lookat(x,y,-500,o_target.x,o_target.y,-o_b.z/z_target,0,0,1));
var _asp = surface_get_width(application_surface) / surface_get_height(application_surface);
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(fov_y, _asp, 3, 3200));
camera_apply(camera);

// Sauvegarder les matrices pour projection 3D→2D dans Draw GUI
cam_view_mat = camera_get_view_mat(camera);
cam_proj_mat = camera_get_proj_mat(camera);
cam_surf_w   = surface_get_width(application_surface);
cam_surf_h   = surface_get_height(application_surface);



gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);
gpu_set_texrepeat(true);
gpu_set_cullmode(cull_noculling);

// ═══════════════════════════════════════════════════════
// SHADOW MAP PASS (si activé)
// ═══════════════════════════════════════════════════════
if (shadow_enable && instance_exists(o_match_setup) && array_length(o_match_setup.level_objects) > 0) {
    if (!surface_exists(shadow_surf))
        shadow_surf = surface_create(shadow_sz, shadow_sz);

    var _objs = o_match_setup.level_objects;
    var _ld = lit_dir;  // direction vers le soleil
    var _sd = 1500;
    lit_pos = [_ld[0]*_sd, _ld[1]*_sd, _ld[2]*_sd];

    // Calculer base orthonormée
    var _fx = -_ld[0]; var _fy = -_ld[1]; var _fz = -_ld[2];
    var _wux = 0.0; var _wuy = 0.0; var _wuz = 1.0;
    if (abs(_ld[2]) > 0.85) { _wux = 1.0; _wuz = 0.0; }

    var _rx = _wuy*_fz - _wuz*_fy;
    var _ry = _wuz*_fx - _wux*_fz;
    var _rz = _wux*_fy - _wuy*_fx;
    var _rlen = sqrt(_rx*_rx + _ry*_ry + _rz*_rz);
    _rx /= _rlen; _ry /= _rlen; _rz /= _rlen;

    var _ux = _fy*_rz - _fz*_ry;
    var _uy = _fz*_rx - _fx*_rz;
    var _uz = _fx*_ry - _fy*_rx;

    lit_right = [_rx, _ry, _rz];
    lit_up = [_ux, _uy, _uz];
    lit_fwd = [_fx, _fy, _fz];

    surface_set_target(shadow_surf);
    draw_clear(c_white);
    gpu_set_zwriteenable(true);
    gpu_set_cullmode(cull_noculling);

    shader_set(shd_shadow);
    shader_set_uniform_f_array(u_sh_litPos, lit_pos);
    shader_set_uniform_f_array(u_sh_litRight, lit_right);
    shader_set_uniform_f_array(u_sh_litUp, lit_up);
    shader_set_uniform_f_array(u_sh_litFwd, lit_fwd);
    shader_set_uniform_f(u_sh_litHW, lit_hw);
    shader_set_uniform_f(u_sh_litHH, lit_hh);
    shader_set_uniform_f(u_sh_litFar, lit_far);

    for (var _si = 0; _si < array_length(_objs); _si++) {
        var _so = _objs[_si];
        if (_so.type != "mesh" || _so.vb < 0) continue;
        matrix_set(matrix_world, matrix_build(_so.x,_so.y,_so.z, _so.rx,_so.ry,_so.rz, _so.sx,_so.sy,_so.sz));
        vertex_submit(_so.vb, pr_trianglelist, -1);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();
    gpu_set_zwriteenable(false);
    surface_reset_target();
}

// ═══════════════════════════════════════════════════════
// Niveau chargé depuis o_match_setup
// ═══════════════════════════════════════════════════════

if (instance_exists(o_match_setup) && array_length(o_match_setup.level_objects) > 0) {
    var _objs = o_match_setup.level_objects;

    // Collecter lumières ponctuelles
    var _pls_pos = [[0,0,100000],[0,0,100000]];
    var _pls_col = [[0,0,0],[0,0,0]];
    var _pls_rad = [1.0, 1.0];
    var _li = 0;
    for (var _oi = 0; _oi < array_length(_objs) && _li < 2; _oi++) {
        var _oo = _objs[_oi];
        if (_oo.type != "light") continue;
        var _inten = variable_struct_exists(_oo, "intensity") ? _oo.intensity : 1.0;
        _pls_pos[_li] = [_oo.x, _oo.y, _oo.z];
        _pls_col[_li] = [color_get_red(_oo.col)/255*_inten, color_get_green(_oo.col)/255*_inten, color_get_blue(_oo.col)/255*_inten];
        _pls_rad[_li] = variable_struct_exists(_oo, "range") ? _oo.range : 500;
        _li++;
    }

    // Rendu objets mesh avec Shader1
    shader_set(Shader1);
    shader_set_uniform_f_array(u_ldir, lit_dir);
    shader_set_uniform_f_array(u_lcol, lit_color);
    shader_set_uniform_f(u_lamb, lit_amb);
    shader_set_uniform_f(u_lrim, lit_rim);
    shader_set_uniform_f_array(u_pl0, _pls_pos[0]);
    shader_set_uniform_f_array(u_pl1, _pls_pos[1]);
    shader_set_uniform_f_array(u_sprpos, [0,0,0]);
    shader_set_uniform_f(u_flat_normal, 0.0);
    // Shadow uniforms
    shader_set_uniform_f(u_shadow_en, shadow_enable ? 1.0 : 0.0);
    shader_set_uniform_f(u_shadow_dark, shadow_darkness);
    shader_set_uniform_f(u_shadow_bias, shadow_bias);
    shader_set_uniform_f(u_shadow_recv, 1.0);
    shader_set_uniform_f_array(u_litPos, lit_pos);
    shader_set_uniform_f_array(u_litRight, lit_right);
    shader_set_uniform_f_array(u_litUp, lit_up);
    shader_set_uniform_f_array(u_litFwd, lit_fwd);
    shader_set_uniform_f(u_litHW, lit_hw);
    shader_set_uniform_f(u_litHH, lit_hh);
    shader_set_uniform_f(u_litFar, lit_far);
    if (shadow_enable && surface_exists(shadow_surf))
        texture_set_stage(u_shadow_samp, surface_get_texture(shadow_surf));

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "mesh" || _o.vb < 0) continue;
        var _r = color_get_red(_o.col)/255;
        var _g = color_get_green(_o.col)/255;
        var _b = color_get_blue(_o.col)/255;
        shader_set_uniform_f_array(u_lcol, [lit_color[0]*_r, lit_color[1]*_g, lit_color[2]*_b]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, -1);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();

    // Rendu personnages
    shader_set(Shader1);
    shader_set_uniform_f_array(u_ldir, lit_dir);
    shader_set_uniform_f_array(u_lcol, lit_color);
    shader_set_uniform_f(u_lamb, lit_amb);
    shader_set_uniform_f(u_lrim, lit_rim);
    shader_set_uniform_f_array(u_pl0, _pls_pos[0]);
    shader_set_uniform_f_array(u_pl1, _pls_pos[1]);
    shader_set_uniform_f_array(u_sprpos, [0,0,0]);
    shader_set_uniform_f(u_flat_normal, 0.0);
    shader_set_uniform_f(u_shadow_en, shadow_enable ? 1.0 : 0.0);
    shader_set_uniform_f(u_shadow_dark, shadow_darkness);
    shader_set_uniform_f(u_shadow_bias, shadow_bias);
    shader_set_uniform_f(u_shadow_recv, 1.0);
    shader_set_uniform_f_array(u_litPos, lit_pos);
    shader_set_uniform_f_array(u_litRight, lit_right);
    shader_set_uniform_f_array(u_litUp, lit_up);
    shader_set_uniform_f_array(u_litFwd, lit_fwd);
    shader_set_uniform_f(u_litHW, lit_hw);
    shader_set_uniform_f(u_litHH, lit_hh);
    shader_set_uniform_f(u_litFar, lit_far);
    if (shadow_enable && surface_exists(shadow_surf))
        texture_set_stage(u_shadow_samp, surface_get_texture(shadow_surf));

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "char" || _o.vb < 0) continue;
        var _r = color_get_red(_o.col)/255;
        var _g = color_get_green(_o.col)/255;
        var _b = color_get_blue(_o.col)/255;
        shader_set_uniform_f_array(u_lcol, [lit_color[0]*_r, lit_color[1]*_g, lit_color[2]*_b]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, -1);
    }

    matrix_set(matrix_world, matrix_build_identity());
    shader_reset();

    // Rendu terrain avec shd_floor
    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type != "terrain" || _o.vb < 0) continue;
        shader_set(shd_floor);
        shader_set_uniform_f_array(u_fldir, lit_dir);
        shader_set_uniform_f_array(u_flcol, lit_color);
        shader_set_uniform_f(u_flamb, lit_amb);
        // Try to set point light uniforms if they exist
        if (u_pl0 >= 0) shader_set_uniform_f_array(u_pl0, _pls_pos[0]);
        if (u_pl1 >= 0) shader_set_uniform_f_array(u_pl1, _pls_pos[1]);
        matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
        vertex_submit(_o.vb, pr_trianglelist, sprite_get_texture(su_ter1, 0));
        matrix_set(matrix_world, matrix_build_identity());
        shader_reset();
    }
}
