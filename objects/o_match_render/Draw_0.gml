/// Render 3D scene from loaded level objects

// Créer surface si nécessaire
if (!surface_exists(match_surf)) {
    match_surf = surface_create(match_surf_w, match_surf_h);
}

surface_set_target(match_surf);
draw_clear_alpha(c_black, 1);

// Setup 3D
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);

// Setup camera
var _cx = cam_cx;
var _cy = cam_cy;
var _cz = cam_cz;
var _yaw_r = degtorad(cam_yaw);
var _ang_r = degtorad(cam_angle);

var _cam_x = _cx + cos(_yaw_r)*sin(_ang_r)*cam_dist;
var _cam_y = _cy + sin(_yaw_r)*sin(_ang_r)*cam_dist;
var _cam_z = _cz + cos(_ang_r)*cam_dist;

var camera = camera_get_active();
camera_set_view_mat(camera, matrix_build_lookat(_cam_x, _cam_y, _cam_z, _cx, _cy, _cz, 0, 0, 1));
var _asp = surface_get_width(match_surf) / surface_get_height(match_surf);
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(cam_fov, _asp, 1, 8000));

// Sans shader pour l'instant - rendu simple

// Récupérer les objets du niveau
if (instance_exists(o_match_setup)) {
    var _objs = o_match_setup.level_objects;

    // Render objects
    for (var _i = 0; _i < array_length(_objs); _i++) {
        var _o = _objs[_i];

        if (_o.type == "mesh") {
            // Dessiner un simple cube
            draw_set_color(_o.col);
            matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));

            var _s = 50;
            // 6 faces du cube
            // Face avant
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(-_s, -_s, -_s); draw_vertex_3d(_s, -_s, -_s);
            draw_vertex_3d(-_s, _s, -_s); draw_vertex_3d(_s, _s, -_s);
            draw_primitive_end();

            // Face arrière
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(_s, -_s, _s); draw_vertex_3d(-_s, -_s, _s);
            draw_vertex_3d(_s, _s, _s); draw_vertex_3d(-_s, _s, _s);
            draw_primitive_end();

            // Face haut
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(-_s, -_s, _s); draw_vertex_3d(_s, -_s, _s);
            draw_vertex_3d(-_s, -_s, -_s); draw_vertex_3d(_s, -_s, -_s);
            draw_primitive_end();

            // Face bas
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(-_s, _s, -_s); draw_vertex_3d(_s, _s, -_s);
            draw_vertex_3d(-_s, _s, _s); draw_vertex_3d(_s, _s, _s);
            draw_primitive_end();

            // Face gauche
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(-_s, -_s, _s); draw_vertex_3d(-_s, _s, _s);
            draw_vertex_3d(-_s, -_s, -_s); draw_vertex_3d(-_s, _s, -_s);
            draw_primitive_end();

            // Face droite
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(_s, -_s, -_s); draw_vertex_3d(_s, _s, -_s);
            draw_vertex_3d(_s, -_s, _s); draw_vertex_3d(_s, _s, _s);
            draw_primitive_end();
        }
        else if (_o.type == "terrain") {
            // Terrain: simple plane
            draw_set_color(_o.col);
            matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));

            // Simple ground plane
            var _ground_size = 1000;
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_3d(-_ground_size, -_ground_size, 0);
            draw_vertex_3d( _ground_size, -_ground_size, 0);
            draw_vertex_3d(-_ground_size,  _ground_size, 0);
            draw_vertex_3d( _ground_size,  _ground_size, 0);
            draw_primitive_end();
        }
    }
}


surface_reset_target();

// Draw surface to screen
draw_surface(match_surf, 0, 0);

// Reset GPU
gpu_set_ztestenable(false);
