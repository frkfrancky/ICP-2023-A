/// @description Insérez la description ici
// Vous pouvez écrire votre code dans cet éditeur
draw_text(x-2000,y,".");



// Dans l'événement Draw
shader_set(shd_blur);
shader_set_uniform_f(shader_get_uniform(shd_blur, "blur_radius"), 20); // Ajustez le rayon du flou selon vos besoins
draw_self();
shader_reset();


