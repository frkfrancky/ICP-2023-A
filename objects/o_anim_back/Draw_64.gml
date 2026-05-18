var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _bw = 180; var _bh = 36;
var _bx = _gw/2 - _bw/2; var _by = _gh - 50;

var _hover = (device_mouse_x_to_gui(0) >= _bx && device_mouse_x_to_gui(0) <= _bx+_bw
           && device_mouse_y_to_gui(0) >= _by && device_mouse_y_to_gui(0) <= _by+_bh);

draw_set_alpha(0.9);
draw_set_color(_hover ? #445566 : #223344);
draw_rectangle(_bx, _by, _bx+_bw, _by+_bh, false);
draw_set_color(#88BBDD);
draw_rectangle(_bx, _by, _bx+_bw, _by+_bh, true);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_bx+_bw/2, _by+_bh/2, "← Retour menu");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (_hover && mouse_check_button_pressed(mb_left)) {
    room_goto(r_menu1);
}
if (keyboard_check_pressed(vk_escape)) {
    room_goto(r_menu1);
}
