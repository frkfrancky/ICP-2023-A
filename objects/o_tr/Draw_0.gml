/// @description Insérez la description ici
// Vous pouvez écrire votre code dans cet éditeur
draw_self();


//affichage zone 3 points/////////////////////
depth--;
draw_set_color(c_fuchsia);
draw_set_alpha(0.2);

draw_circle(x3pts_1,y3pts,r3pts,false);
draw_circle(x3pts_2,y3pts,r3pts,false);
depth++;
//////////////////////////////////////////////

draw_set_alpha(1)
