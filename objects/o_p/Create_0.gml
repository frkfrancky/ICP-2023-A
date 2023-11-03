//is_bot = false;
//reaction = 0;
//is_react = false;
is_me = false;
depth = -1

//refa bot namana
dest_x = 0;
dest_y = 0;
point_tt = 0;//point de destination coorespondant

dir = 0;
acc = 0.09;//acceleration


//attente avant action
mbol = false;
can_act = true;
miandry = false;
miandry_passe = false;

count_act = 60;
c_a = 0;
///////////////////////

ekipa = 1;
index = -1;
akaiky = false;
//poste = 0;


//touche initiallise any am controller
key_direction = 0;
key_action = 0;

//PARAM DU JOUEUR
sp = 20/20*2;//speed
tec = 20; //technique ou drible
alavany = 120;

limiteur_speed = 0;
image_speed = 0;
image_alpha = 0.9;

afficheo = "";

//point de match
pt3s = true;
last_3pt = pt3s;


//3d ///////////////////
if(ekipa == 1){
	textureTop = sprite_get_texture(olona_3d, 0);
}else{
	textureTop = sprite_get_texture(olona_3d, 1);
}
z = -10;

//touche
up = false;
down = false;
right = false;
left = false;

//run = false;
act1 = false;
act2 = false;

haxis = 0;
vaxis = 0;


//TEST SMF ENGINE ////////////

