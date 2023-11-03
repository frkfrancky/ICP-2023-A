//if(global.playerNumber == 1){
	//show_message(string(index_selected));
	if(index_focused == 0){
		//READY
	}else{
		if(index_selected != index_focused){
			if(index_selected  > 0) {//efa nisy niselectionena
				transfert_joueur(mini_id);
				//////////////////
				bt[index_selected].is_select = false;
				index_selected = -1;
				if(mini_id == 0){
					o_control_menu.mn[2].data2 = 0;
				}else if(mini_id == 1){
					o_control_menu.mn[3].data2 = 0;
				}
			}else{//mbola tsy misy selectionner
				index_selected = index_focused;
				bt[index_selected].is_select = true;
				if(mini_id == 0){
					o_control_menu.mn[2].data2 = bt[index_selected].data;
				}else if(mini_id == 1){
					o_control_menu.mn[3].data2 = bt[index_selected].data;
				}
			}

		}else{
			bt[index_selected].is_select = false;
			index_selected = -1;
			if(mini_id == 0){
				o_control_menu.mn[2].data2 = 0;
			}else if(mini_id == 1){
				o_control_menu.mn[3].data2 = 0;
			}
		}
	}			
//}
