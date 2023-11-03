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
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(fov_y, 1,3, 3200));
camera_apply(camera);


gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_texrepeat(true);

