/*viewmat = matrix_build_lookat(640, 480, -10, 640, 420, 70, 0, 0, 45);
projmat = matrix_build_projection_ortho(640, 480, 0, 3200.0);
camera_set_view_mat(view_camera[0], viewmat);
camera_set_proj_mat(view_camera[0], projmat);*/

x = object2.x+(object2.sprite_width/2);
y = object2.y+(object2.sprite_height/2)+100;

var camera= camera_get_active();
//camera_set_view_mat(camera, matrix_build_lookat(x,y,-200,object3.x,object3.y,0,0,0,1));
camera_set_view_mat(camera, matrix_build_lookat(x,y,-250,object3.x,object3.y,0,0,0,1));
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(60, 1,1, 3200));

camera_apply(camera);
