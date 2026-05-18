/// @description Insérez la description ici
// Vous pouvez écrire votre code dans cet éditeur
b_color = #ff953e;
draw_set_color(b_color);
draw_set_font(my_font);

draw_text(room_width - 200, 100, "equipe_pocesseur = "+string(e_pocesseur));
draw_text(room_width - 200, 120, "j_pocess = "+string(pocesseur));
draw_text(room_width - 200, 140, "mpamono = "+string(mpamono));
draw_text(room_width - 200, 160, "x = "+string(x));
draw_text(room_width - 200, 180, "y = "+string(y));

draw_set_font(my_font_big);
draw_set_color(c_white);
