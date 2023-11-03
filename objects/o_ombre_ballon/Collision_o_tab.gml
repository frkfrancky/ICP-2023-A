if((o_cc.bb.z>=o_tab.z && o_cc.bb.z<= (o_tab.z+o_tab.alavany))){
	/*x = xprevious;
	direction = -direction + point_direction(o_cc.but2.tab.x,o_cc.but2.tab.y,o_cc.bb.xprevious,o_cc.bb.yprevious);
	*/
	move_bounce_solid(true);
	limiteur_speed = abs(limiteur_speed)/(2);
}

