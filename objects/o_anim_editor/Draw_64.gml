draw_set_alpha(1);
draw_set_color(#FF0000);
draw_rectangle(0, 0, 500, 60, false);
draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(8, 8,  "DRAW_GUI OK   char_parts=" + string(variable_global_exists("char_parts"))
               + "   anim_lib=" + string(variable_global_exists("anim_lib")));
draw_text(8, 30, "show_editor=" + string(show_editor) + "   room=" + string(room_get_name(room)));
