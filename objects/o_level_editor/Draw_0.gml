// ═══════════════════════════════════════════════════════════════
// ÉDITEUR DE NIVEAU — Draw GUI
// ═══════════════════════════════════════════════════════════════

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();

// ── Surface 3D ──────────────────────────────────────────────────
if (!surface_exists(le_surf))
    le_surf = surface_create(le_viewport_w, le_viewport_h);

surface_set_target(le_surf);
draw_clear(#1A1E28);

// Caméra perspective orbitale
var _cr  = degtorad(le_cam_angle);
var _cy2 = degtorad(le_cam_yaw);
var _cdist = le_cam_dist;
var _cam_ex = le_cam_cx + _cdist * cos(_cr) * cos(_cy2);
var _cam_ey = le_cam_cy + _cdist * cos(_cr) * sin(_cy2);
var _cam_ez = le_cam_cz + _cdist * sin(_cr);

var _cam = camera_create();
camera_set_view_mat(_cam, matrix_build_lookat(_cam_ex,_cam_ey,_cam_ez, le_cam_cx,le_cam_cy,le_cam_cz, 0,0,1));
camera_set_proj_mat(_cam, matrix_build_projection_perspective_fov(le_cam_fov, le_viewport_w/le_viewport_h, 1, 20000));
camera_apply(_cam);
camera_destroy(_cam);

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_noculling);

// Shader lumière
// test
shader_set(Shader1);
shader_set_uniform_f_array(le_u_ldir,  le_lit_dir);
shader_set_uniform_f_array(le_u_lcol,  le_lit_color);
shader_set_uniform_f(le_u_lamb, le_lit_amb);
shader_set_uniform_f(le_u_lrim, le_lit_rim);
shader_set_uniform_f_array(le_u_pl0,  [0,0,0]);
shader_set_uniform_f_array(le_u_pl1,  [0,0,0]);
shader_set_uniform_f_array(le_u_plcol,[1,1,1]);
shader_set_uniform_f(le_u_plrad, 0.0);
shader_set_uniform_f_array(le_u_sprpos,[0,0,0]);
shader_set_uniform_f(le_u_flat_normal, 0.0); // normales réelles pour objets 3D

// Dessiner chaque objet
var _nob = array_length(le_objects);
for (var _oi = 0; _oi < _nob; _oi++) {
    var _o = le_objects[_oi];
    if (_o.vb < 0) continue;
    // Couleur via uniform (on teinte avec la couleur de l'objet)
    var _r = color_get_red(_o.col)/255; var _g = color_get_green(_o.col)/255; var _b2 = color_get_blue(_o.col)/255;
    shader_set_uniform_f_array(le_u_lcol, [le_lit_color[0]*_r, le_lit_color[1]*_g, le_lit_color[2]*_b2]);
    matrix_set(matrix_world, matrix_build(_o.x, _o.y, _o.z, _o.rx, _o.ry, _o.rz, _o.sx, _o.sy, _o.sz));
    vertex_submit(_o.vb, pr_trianglelist, -1);
    matrix_set(matrix_world, matrix_build_identity());
    // Restaurer couleur lumière
    shader_set_uniform_f_array(le_u_lcol, le_lit_color);
}

shader_reset();

// Grille (sans shader lumière, juste colorée)
draw_primitive_begin(pr_linelist);
// On dessine la grille manuellement en 2D projeté — trop complexe sans shader,
// on utilise vertex_submit avec pr_linelist et shader de base
draw_primitive_end();

// Grille via vertex buffer (pas de shader = couleurs directes)
vertex_submit(le_grid_vb, pr_linelist, -1);

gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_noculling);

surface_reset_target();

// Dessiner la surface dans le viewport
draw_surface_stretched(le_surf, le_viewport_x + le_viewport_w, 0, -le_viewport_w, le_viewport_h);

// ── Bordures et fond panneaux ───────────────────────────────────
// Panneau gauche
draw_set_color(#1A1E28); draw_set_alpha(0.9);
draw_rectangle(0, 0, le_panel_left_w, _sh, false);
draw_set_color(#2A3040); draw_set_alpha(1.0);
draw_rectangle(le_viewport_x+le_viewport_w, 0, _sw, _sh, false);
draw_set_color(#3D4B6A); draw_set_alpha(1.0);
draw_line(le_panel_left_w, 0, le_panel_left_w, _sh);
draw_line(le_viewport_x+le_viewport_w, 0, le_viewport_x+le_viewport_w, _sh);

// ── Panneau gauche ──────────────────────────────────────────────
draw_set_color(#FFFFFF); draw_set_alpha(1.0);
draw_set_font(my_font);
draw_text(12, 12, "ÉDITEUR DE NIVEAU");
draw_set_color(#8899BB);
draw_text(12, 36, "Clic droit : orbite caméra");
draw_text(12, 54, "Molette : zoom");

draw_set_color(#AABBCC);
draw_text(12, 80, "─── ÉCLAIRAGE ───");

var _np = array_length(le_day_presets);
for (var _i = 0; _i < _np; _i++) {
    var _py = 100 + _i * 44;
    var _psel = (le_preset_sel == _i);
    var _pcol  = _psel ? #5588DD : #2A3A5A;
    draw_set_color(_pcol); draw_set_alpha(0.85);
    draw_rectangle(8, _py, le_panel_left_w-8, _py+36, false);
    draw_set_color(_psel ? #FFFFFF : #AABBCC); draw_set_alpha(1.0);
    draw_text(16, _py+8, le_day_presets[_i].name);
}

draw_set_color(#AABBCC);
draw_text(12, 428, "─── OBJETS ───");

draw_set_color(#2266AA); draw_set_alpha(0.85);
draw_rectangle(8, 440, le_panel_left_w-8, 474, false);
draw_set_color(#FFFFFF); draw_set_alpha(1.0);
draw_text(16, 448, "[ Importer OBJ ]");

draw_set_color(#226633); draw_set_alpha(0.85);
draw_rectangle(8, 484, le_panel_left_w-8, 518, false);
draw_set_color(#FFFFFF); draw_set_alpha(1.0);
draw_text(16, 492, "[ + Ajouter cube ]");

draw_set_color(#662222); draw_set_alpha(0.85);
draw_rectangle(8, 524, le_panel_left_w-8, 558, false);
draw_set_color(#FFFFFF); draw_set_alpha(1.0);
draw_text(16, 532, "[ - Supprimer ]");

// Liste objets
var _nob2 = array_length(le_objects);
draw_set_color(#8899BB); draw_set_alpha(1.0);
draw_text(12, 568, "Scène (" + string(_nob2) + " objets) :");
for (var _i = 0; _i < _nob2; _i++) {
    var _oy = 590 + _i*26;
    if (_oy > _sh-20) break;
    var _osel = (le_sel_obj == _i);
    draw_set_color(_osel ? #3355AA : #1A2235); draw_set_alpha(0.8);
    draw_rectangle(8, _oy, le_panel_left_w-8, _oy+22, false);
    draw_set_color(_osel ? #FFFFFF : #8899BB); draw_set_alpha(1.0);
    draw_text(14, _oy+2, string(_i)+". "+le_objects[_i].name);
}

// ── Panneau droit : propriétés ──────────────────────────────────
var _rx = le_viewport_x+le_viewport_w+8;
draw_set_color(#FFFFFF); draw_set_alpha(1.0);
draw_text(_rx, 12, "PROPRIÉTÉS");

if (le_sel_obj >= 0 && le_sel_obj < array_length(le_objects)) {
    var _o2 = le_objects[le_sel_obj];
    draw_set_color(#AABBCC);
    draw_text(_rx, 48, "Objet : " + _o2.name);

    draw_set_color(#8899BB);
    draw_text(_rx, 68, "── Position ──");
    // X
    draw_set_color(#FF6666); draw_set_alpha(0.85);
    draw_rectangle(_rx, 80, _rx+48, 100, false);
    draw_set_color(#66CC66); draw_set_alpha(0.85);
    draw_rectangle(_rx+96, 80, _rx+144, 100, false);
    draw_set_color(#FFFFFF); draw_set_alpha(1.0);
    draw_text(_rx+8,  82, "X−"); draw_text(_rx+104, 82, "X+");
    draw_set_color(#CCDDEE); draw_text(_rx+54, 82, string(round(_o2.x)));

    draw_set_color(#FF6666); draw_set_alpha(0.85); draw_rectangle(_rx, 106, _rx+48, 126, false);
    draw_set_color(#66CC66); draw_set_alpha(0.85); draw_rectangle(_rx+96, 106, _rx+144, 126, false);
    draw_set_color(#FFFFFF); draw_set_alpha(1.0);
    draw_text(_rx+8,108,"Y−"); draw_text(_rx+104,108,"Y+"); draw_set_color(#CCDDEE); draw_text(_rx+54,108,string(round(_o2.y)));

    draw_set_color(#FF6666); draw_set_alpha(0.85); draw_rectangle(_rx, 132, _rx+48, 152, false);
    draw_set_color(#66CC66); draw_set_alpha(0.85); draw_rectangle(_rx+96, 132, _rx+144, 152, false);
    draw_set_color(#FFFFFF); draw_set_alpha(1.0);
    draw_text(_rx+8,134,"Z−"); draw_text(_rx+104,134,"Z+"); draw_set_color(#CCDDEE); draw_text(_rx+54,134,string(round(_o2.z)));

    draw_set_color(#8899BB); draw_set_alpha(1.0); draw_text(_rx, 164, "── Échelle ──");
    draw_set_color(#FF6666); draw_set_alpha(0.85); draw_rectangle(_rx, 180, _rx+48, 200, false);
    draw_set_color(#66CC66); draw_set_alpha(0.85); draw_rectangle(_rx+96, 180, _rx+144, 200, false);
    draw_set_color(#FFFFFF); draw_set_alpha(1.0);
    draw_text(_rx+8,182,"S−"); draw_text(_rx+104,182,"S+"); draw_set_color(#CCDDEE); draw_text(_rx+54,182,string(round(_o2.sx*10)/10));

    draw_set_color(#8899BB); draw_set_alpha(1.0); draw_text(_rx, 208, "── Rotation Z ──");
    draw_set_color(#FF6666); draw_set_alpha(0.85); draw_rectangle(_rx, 220, _rx+48, 240, false);
    draw_set_color(#66CC66); draw_set_alpha(0.85); draw_rectangle(_rx+96, 220, _rx+144, 240, false);
    draw_set_color(#FFFFFF); draw_set_alpha(1.0);
    draw_text(_rx+8,222,"←"); draw_text(_rx+104,222,"→"); draw_set_color(#CCDDEE); draw_text(_rx+54,222,string(round(_o2.rz))+"°");

    draw_set_color(#8899BB); draw_set_alpha(1.0);
    draw_text(_rx, 260, "Molette = déplacer Z");
} else {
    draw_set_color(#556677); draw_set_alpha(1.0);
    draw_text(_rx, 60, "Sélectionnez un objet");
}

// ── Info barre du bas ───────────────────────────────────────────
draw_set_color(#1A1E28); draw_set_alpha(0.85);
draw_rectangle(le_panel_left_w, _sh-28, le_panel_left_w+le_viewport_w, _sh, false);
draw_set_color(#8899BB); draw_set_alpha(1.0);
draw_text(le_panel_left_w+8, _sh-22, "Yaw: "+string(round(le_cam_yaw))+"°  Pitch: "+string(round(le_cam_angle))+"°  Dist: "+string(round(le_cam_dist)));

// Notif
if (le_notif_time > 0) {
    draw_set_color(#FFEE88); draw_set_alpha(min(1.0, le_notif_time/20.0));
    draw_text(le_panel_left_w+le_viewport_w*0.5-80, _sh-52, le_notif);
}

draw_set_alpha(1.0);

// ── Titre en haut du viewport ───────────────────────────────────
draw_set_color(#FFFFFF); draw_set_alpha(0.7);
draw_text(le_panel_left_w+8, 6, "Ctrl+S: Sauvegarder  |  ESC: Retour  |  Clic droit+drag: Orbite");
draw_set_alpha(1.0);
