/// o_cam draw - empty in match room, full render in other rooms
if (room_get_name(room) == "r_match_game") {
	// Match room uses o_match_camera for rendering
	exit;
}

// ========== REGULAR GAME RENDERING (non-match rooms) ==========

var camera= camera_get_active();

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
    var _right_x = _wuy*_fz - _wuz*_fy;
    var _right_y = _wuz*_fx - _wux*_fz;
    var _right_z = _wux*_fy - _wuy*_fx;
    var _r_len = sqrt(_right_x*_right_x + _right_y*_right_y + _right_z*_right_z);
    if (_r_len > 0.001) {
        _right_x /= _r_len; _right_y /= _r_len; _right_z /= _r_len;
        lit_right = [_right_x, _right_y, _right_z];
    }
    var _up_x = _fy*_right_z - _fz*_right_y;
    var _up_y = _fz*_right_x - _fx*_right_z;
    var _up_z = _fx*_right_y - _fy*_right_x;
    lit_up = [_up_x, _up_y, _up_z];
    lit_fwd = [_fx, _fy, _fz];

    // Render shadow map
    surface_set_target(shadow_surf);
    draw_clear_alpha(c_black, 1);
    shader_set(shd_shadow);

    for (var _oi = 0; _oi < array_length(_objs); _oi++) {
        var _o = _objs[_oi];
        if (_o.type == "terrain" && _o.vb >= 0) {
            matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
            vertex_submit(_o.vb, pr_trianglelist, -1);
        }
    }

    shader_reset();
    surface_reset_target();
}

// ═══════════════════════════════════════════════════════
// MAIN RENDER PASS
// ═══════════════════════════════════════════════════════

shader_set(Shader1);
shader_set_uniform_f_array(u_ldir, lit_dir);
shader_set_uniform_f_array(u_lcol, lit_color);
shader_set_uniform_f(u_lamb, lit_amb);
shader_set_uniform_f(u_lrim, lit_rim);
shader_set_uniform_f(u_sprpos, x, y);
shader_set_uniform_f(u_flat_normal, 0.0);

// Setup shadow uniforms
if (shadow_enable && surface_exists(shadow_surf)) {
    shader_set_uniform_f_array(u_litPos, lit_pos);
    shader_set_uniform_f_array(u_litRight, lit_right);
    shader_set_uniform_f_array(u_litUp, lit_up);
    shader_set_uniform_f_array(u_litFwd, lit_fwd);
    shader_set_uniform_f(u_litHW, lit_hw);
    shader_set_uniform_f(u_litHH, lit_hh);
    shader_set_uniform_f(u_litFar, lit_far);
    shader_set_uniform_f(u_shadow_en, shadow_enable);
    shader_set_uniform_f(u_shadow_dark, shadow_darkness);
    shader_set_uniform_f(u_shadow_bias, shadow_bias);
    gpu_set_tex_filter(true);
    texture_set_stage(u_shadow_samp, shadow_surf);
}

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
gpu_set_tex_filter(false);
