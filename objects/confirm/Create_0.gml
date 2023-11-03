load = true;
alpha = 0;
alpha2 =0;
image_alpha = 0;
sens = 1;
mpamorona=0;

bt[0] = instance_create_depth(x-(sprite_width/2)+16, y+(sprite_height/2)-50, -201, o_bt3);
bt[1] = instance_create_depth(x+(sprite_width/2)-16, y+(sprite_height/2)-50, -201, o_bt3);
bt[1].x -= bt[1].sprite_width;
bt[0].soratra = "cancel";
bt[1].soratra = "ok";
bt[0].image_index = 1;
bt[0].mpamorona = id;
bt[1].mpamorona = id;
