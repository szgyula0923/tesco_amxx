#include <amxmodx>
//#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
//#include <fakemeta_util>
#include <hamsandwich>
#include <colorchat>
#include <csstats>
#include <fvault>

#pragma dynamic 32768/7

#define PLUGIN "Weapon Skin System Fork"
#define VERSION "0.13"
#define AUTHOR "6almasok, RaZ_HU"

#define NORMAL 0

#define IsValidPlayer(%1) (1 <= %1 <= 32)
#define listLenght 48

new oles[33], switchbutton[33],knife[33]
new ModelData[48][64], ModelNum, maximumModels

new const modelFile[] = "addons/amxmodx/configs/wss_models.ini"
new const soundFile[] = "addons/amxmodx/configs/wss_sounds.ini"
new const szVaultName[] = "wss_vault"
new const prefix[] = "te$co"

/*Switch texts*/
new const knifedisenable[2][] = { "Kikapcsolva", "Bekapcsolva" }
/*Pointers*/
new g_hudenable,g_advertmp,g_auth_mode
new akskin[33],m4skin[33],awpskin[33],dgleskin[33],menuOption[33]
new selectionAK,selectionM4,selectionAWP,selectionDE
new sync0bj, bool:freezeover = false

new const menuszoveg[][][] =
{
	{"AK47 Skinek", "\dAK47 Skinek"},
	{"M4A1 Skinek", "\dM4A1 Skinek"},
	{"AWP Skinek", "\dAWP Skinek"},
	{"Deagle Skinek", "\dDeagle Skinek"},
	{"Gyors Kés^n", "\dGyors Kés^n"},
	{"\ySkin Csomagok - \r[KIKAPCSOLVA]", "\ySkin Csomagok - \r[BEKAPCSOLVA]"}
}
new const chatszoveg[7][] =
{
	"^4[%s]^1 Kiválasztottad a(z)^3 %s^1-t!",
	"^4[%s]^1 Sajnos nincs elég ölésed! ^4%i^1/^3%i^1",
	"^4[%s]^1 Kikapcsoltad a Skin Csomagokat!",
	"^4[%s]^1 Bekapcsoltad a Skin Csomagokat!",
	"^4[%s]^1 A Szerveren ^3Weapon Skin System^1 fut. Megnyitáshoz: ^3/menu ^1vagy ^3N ^1gomb.",
	"^4[%s]^1 Bekapcsoltad a gyorskést!",
	"^4[%s]^1 Kikapcsoltad a gyorskést!"
}
new const weaponList[listLenght][22] =
{
	"PLACEHOLDER",
		"AK47",
	"AK47 > Cartel",
	"AK47 > EXE",
	"AK47 > Green",
	"AK47 > Tactical",
	"AK47 > Fuel Injector",
	"AK47 > Gold Hexagon",
	"AK47 > Vulcan",
	"AK47 > Transformers",
	"AK47 > Paladin",
	"AK47 > Clean",
	"AK74U > Classic",
	"AK74U > Black",
		"M4A1",
	"M4A1 > TwoTone",
	"H&K 416",
	"M4A1 > Legend",
	"M4A1 > Vltor SBR",
	"M4A1 > Urban",
	"M4A1 > Havoc",
	"M4A1 > Erica",
	"M4A1 > Lucie",
	"M4A1 > Taoyuanjets",
	"M4A1 > Tactical",
	"AR15 > Lynx",
	"M4A1 > Black",
	"M4A1 > MW2 ADS",
		"AWP",
	"AWP > Hunter",
	"AWP > Artic",
	"AWP > L96",
	"AWP > M200",
	"AWP > MSR",
	"AWP > Asiimov",
	"AWP > Gold & Black",
	"AWP > Infernal Dragon",
	"AWP > Elf Ranger",
	"AWP > Ranger",
	"AWP > Safari",
		"DEAGLE",
	"DEAGLE > M29 Satan",
	"DEAGLE > Emperor",
	"DEAGLE > Silver",
	"DEAGLE > Gold",
	"DEAGLE > Conspiracy",
	"DEAGLE > CZ Rusty",
	"DEAGLE > White Angel"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	/* Cvars */
	g_hudenable = register_cvar("wss_hudenable","1");
	g_advertmp = register_cvar("wss_advertmp","110.0")
	g_auth_mode = register_cvar("wss_auth_mode","1")

	/* Client Command */
	register_clcmd("say /menu" , "fomenu")
	register_clcmd("nightvision", "fomenu")

	/* Events */
	register_event("CurWeapon", "changeKNF", "be", "1=1");
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "changeKNF2", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "changeAK", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "changeM4", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "changeAWP", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "changeDE", 1)
	register_logevent("round_start", 2, "1=Round_Start") 
	register_event("HLTV", "new_round", "a", "1=0", "2=0");


	/* Other */
	RegisterHam(Ham_Spawn, "player", "spawn_event", 1)
	
	sync0bj = CreateHudSyncObj()

	LoadModel()
}
public advertist(){
	client_print_color(0, NORMAL, chatszoveg[4],prefix)
	return PLUGIN_HANDLED
}
public plugin_precache()
{
	precache_model("models/v_knife15.mdl")
	
	new Len, btton[196], Data[72], Letoltes[54][64]
	maximumModels = file_size(modelFile, 1)

	for(new Num = 0; Num < maximumModels; Num++){
		read_file(modelFile, Num, btton, 196, Len)
		parse(btton, Data, 71)
		remove_quotes(btton)
		if(btton[0] == ';')
		{
			continue
		}
		remove_quotes(Data)
		format(Letoltes[Num], 71, "%s", Data)
		precache_model(Letoltes[Num])
	}

	new sBuffer[192], sFile[128], sData[64], pFile
	get_localinfo("amxx_configsdir", sFile, charsmax(sFile))
	format(sFile, charsmax(sFile), "%s/wss_sounds.ini", sFile)
	new count,maximumSounds
	
	pFile = fopen(sFile, "rt");

	if(pFile) {
		maximumSounds = file_size(soundFile, 1)
		while(count < maximumSounds+1 && !feof(pFile)) {
			fgets(pFile, sBuffer, charsmax(sBuffer))
			trim(sBuffer)
			if(sBuffer[0] != ';' && parse(sBuffer, sData, charsmax(sData))) {
				if(contain(sData, ".wav") != -1) {
					precache_sound(sData)
				}
			}
		}
		fclose(pFile)
	}
	else
		write_file(sFile, ";^"weapons/fegyverhang.wav^"")
}
public plugin_cfg()
{
	set_task(get_pcvar_float(g_advertmp), "advertist", 0, "", 0, "b", 0)
}
public LoadModel()
{
	new Len, btton[196], Data[72]
	maximumModels = file_size(modelFile, 1)
	for(new Num; Num < maximumModels; Num++){
		ModelNum++
		read_file(modelFile, Num, btton, 196, Len)
		parse(btton, Data, 71)
		remove_quotes(btton)
		if(btton[0] == ';')
		{
			continue
		}
		remove_quotes(Data)
		format(ModelData[ModelNum], 71, "%s", Data)
	}
}
public round_start()
{
	freezeover = true
	new players[32], num, id;
	get_players(players, num, "a");
	for(new i = 0; i < num; i++)
	{
		id = players[i];
		new weapon = get_user_weapon(id)
		if(weapon == CSW_KNIFE)
		{
			set_user_maxspeed(id, 360.0);
			//set_user_maxspeed(id, 360.0)
			set_task(0.1, "task_speed", id)
		}
	}
}

public new_round()
{
	freezeover = false;
	
}

public task_speed(id)
{
	new weapon = get_user_weapon(id)
	if(weapon == CSW_KNIFE)
	{
		//set_user_maxspeed(id, 360.0)
		set_user_maxspeed(id, 360.0);
	}
}

public changeKNF(id)
{
	new weapon = get_user_weapon(id)
	if(weapon == CSW_KNIFE)
	{
		if (knife[id] == 1)
			set_pev(id, pev_viewmodel2, "models/v_knife15.mdl");
		if(freezeover == false)
			return PLUGIN_HANDLED
		//set_user_maxspeed(id, 360.0)
		set_user_maxspeed(id, 360.0);
	}

	return PLUGIN_HANDLED
}
public changeKNF2(iEnt)
{
	if( !pev_valid(iEnt) )
		return HAM_IGNORED
		
	if(freezeover == false)
		return HAM_IGNORED

		
	static id
	id = get_pdata_cbase(iEnt, 41, 4)
	if(!is_user_alive(id) || !IsValidPlayer(id) || switchbutton[id] == 1 || knife[id] != 1)
		return HAM_IGNORED
		
	//set_user_maxspeed(id, 360.0)
	set_user_maxspeed(id, 360.0);
	set_pev(id, pev_viewmodel2, "models/v_knife15.mdl")

	return HAM_IGNORED
}
public changeAK(iEnt)
{
	if( !pev_valid(iEnt))
		return HAM_IGNORED
	static id
	id = get_pdata_cbase(iEnt, 41, 4)
	if(!is_user_alive(id) || !IsValidPlayer(id) || switchbutton[id] == 1)
		return HAM_IGNORED
	
	selectionAK = akskin[id]
	if(selectionAK != 0)
		set_pev(id, pev_viewmodel2, ModelData[selectionAK])
	else
		set_pev(id, pev_viewmodel2, "models/v_ak47.mdl")
	return HAM_IGNORED
}
public changeM4(iEnt)
{
	if( !pev_valid(iEnt) )
		return HAM_IGNORED
	static id
	id = get_pdata_cbase(iEnt, 41, 4)
	if(!is_user_alive(id) || !IsValidPlayer(id) || switchbutton[id] == 1)
		return HAM_IGNORED
	
	selectionM4 = m4skin[id]
	if(selectionM4 != 0)
		set_pev(id, pev_viewmodel2, ModelData[selectionM4])
	else
		set_pev(id, pev_viewmodel2, "models/v_m4a1.mdl")
	return HAM_IGNORED
}
public changeAWP(iEnt)
{
	if( !pev_valid(iEnt) )
		return HAM_IGNORED
	static id
	id = get_pdata_cbase(iEnt, 41, 4)
	if(!is_user_alive(id) || !IsValidPlayer(id) || switchbutton[id] == 1)
		return HAM_IGNORED
	
	selectionAWP = awpskin[id]
	if(selectionAWP != 0)
		set_pev(id, pev_viewmodel2, ModelData[selectionAWP])
	else
		set_pev(id, pev_viewmodel2, "models/v_awp.mdl")

	return HAM_IGNORED
}
public changeDE(iEnt)
{
	if( !pev_valid(iEnt) )
		return HAM_IGNORED
	static id
	id = get_pdata_cbase(iEnt, 41, 4)
	if(!is_user_alive(id) || !IsValidPlayer(id) || switchbutton[id] == 1)
		return HAM_IGNORED
	
	selectionDE = dgleskin[id]
	if(selectionDE != 0)
		set_pev(id, pev_viewmodel2, ModelData[selectionDE])
	else
		set_pev(id, pev_viewmodel2, "models/v_deagle.mdl")
	
	return HAM_IGNORED
}
public spawn_event(id)
{
	if(akskin[id] != 0 && akskin[id] > 13)
		akskin[id] = 0
	else if(m4skin[id] != 0 && (m4skin[id] < 14 || m4skin[id] > 27))
		m4skin[id] = 0
	else if(awpskin[id] != 0 && (awpskin[id] < 28 || awpskin[id] > 39))
		awpskin[id] = 0
	else if(dgleskin[id] != 0 && (dgleskin[id] < 40 || dgleskin[id] > sizeof weaponList))
		dgleskin[id] = 0
}
public fomenu(id)
{
	new String[96]
	format(String, charsmax(String), "\r%s \wFőmenü^n\yÖlések: \d%i",prefix, oles[id])
	new menu = menu_create(String, "fomenu_MyMenu")

	menu_additem(menu, "Fegyver Skinek", "0")
	menu_additem(menu, "Játékosok ölései", "1")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(menu, MPROP_EXITNAME, "\rKilépés")

	menu_display(id, menu, 0)

	return PLUGIN_HANDLED
}
public fomenu_MyMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new command[3], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 0: fegymenu(id)
		case 1: playerinfo(id)
	}

	menu_destroy(menu)

	return PLUGIN_HANDLED
}
public playerinfo(id)
{
	new some[256], menu
	static players[32],szTemp[10],pnum
	get_players(players,pnum,"ch")

	formatex(some,255,"\r[%s] \wJátékos \d|\w Ölés \d|\w Kredit",prefix)
	menu = menu_create(some,"pinfo_Handler")

	new player
	for (new i; i < pnum; i++)
	{
		player = players[i]
		formatex(some,256,"%s \r(\yÖlése: \w%i\r)",get_player_name(player), oles[player])
		num_to_str(player,szTemp,charsmax(szTemp))
		menu_additem(menu, some, szTemp)
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL )
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés")
	menu_display(id, menu)
	return PLUGIN_HANDLED
}
public pinfo_Handler(id,menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	playerinfo(id)
	return PLUGIN_HANDLED
}
public fegymenu(id)
{
	new String[96], text[4]
	format(String, charsmax(String), "\r[%s] \wFegyver Skinek",prefix)
	new menu = menu_create(String, "fegymenu_handler" )

	for(new ig=0;ig<(sizeof menuszoveg)-2;ig++)
	{
		format(String, charsmax(String), menuszoveg[ig][0])
		num_to_str(ig,text,3)
		menu_additem(menu, String,text)
	}
	formatex(String, charsmax(String), menuszoveg[4][0])
	menu_additem(menu, String, "4")

	menu_additem(menu, switchbutton[id] == 1 ? (menuszoveg[5][0]):(menuszoveg[5][1]), "5")

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(menu, MPROP_BACKNAME, "Vissza")
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább")
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés")

	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}
public fegymenu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new command[6], name[64], access, callback
	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback)

	switch(item)
	{
		case 0: {
			menuOption[id] = 1
			alMenu(id,0)
		}
		case 1: {
			menuOption[id] = 2
			alMenu(id,1)
		}
		case 2: {
			menuOption[id] = 3
			alMenu(id,2)
		}
		case 3: {
			menuOption[id] = 4
			alMenu(id,3)
		}
		case 4: {
			if(knife[id] == 0)
			{
				knife[id] = 1
				client_print_color(id, NORMAL, chatszoveg[5],prefix)
				new weapon = get_user_weapon(id)
				if(weapon == CSW_KNIFE)
				{
					set_user_maxspeed(id, 360.0);
					set_pev(id, pev_viewmodel2, "models/v_knife15.mdl")
				}
			}
			else
			{
				knife[id] = 0
				client_print_color(id, NORMAL, chatszoveg[6],prefix)

				new weapon = get_user_weapon(id)
				if(weapon == CSW_KNIFE)
				{
					set_user_maxspeed(id, 250.0);
					set_pev(id, pev_viewmodel2, "models/v_knife.mdl")
				}
			}
		}
		case 5: {
			if(switchbutton[id] == 0){
				switchbutton[id] = 1
				client_print_color(id, NORMAL, chatszoveg[2],prefix)
			}
			else {
				switchbutton[id] = 0
				client_print_color(id, NORMAL, chatszoveg[3],prefix)
			}
		}
	}

	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public alMenu(id,weapon)
{
	new String[128],text[4]
	new menu = menu_create("Weapon Skin System - te$co", "alMenuH")
	
	switch(weapon)
	{
		case 0: //AK
		{
			for(new iw=1;iw<14;iw++)
			{
				format(String, charsmax(String), weaponList[iw])
				num_to_str(iw,text,3)
				menu_additem(menu, String,text)
			}
		}
		case 1: //M4
		{
			for(new iw=14;iw<28;iw++)
			{
				format(String, charsmax(String), weaponList[iw])
				num_to_str(iw,text,3)
				menu_additem(menu, String,text)
			}
		}
		case 2: //AWP
		{
			for(new iw=28;iw<40;iw++)
			{
				format(String, charsmax(String), weaponList[iw])
				num_to_str(iw,text,3)
				menu_additem(menu, String,text)
			}
		}
		case 3: //DEAGLE
		{
			for(new iw=40;iw<sizeof weaponList;iw++)
			{
				format(String, charsmax(String), weaponList[iw])
				num_to_str(iw,text,3)
				menu_additem(menu, String,text)
			}
		}
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop(menu, MPROP_BACKNAME, "Vissza")
	menu_setprop(menu, MPROP_NEXTNAME, "Tovább")
	menu_setprop(menu, MPROP_EXITNAME, "Kilépés")

	menu_display(id, menu)
}
public alMenuH(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}

	new data[9], szName[64], access, callback
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)

	if(menuOption[id] == 1)
		akskin[id] = key
	else if(menuOption[id] == 2)
		m4skin[id] = key
	else if(menuOption[id] == 3)
		awpskin[id] = key
	else if(menuOption[id] == 4)
		dgleskin[id] = key
	client_print_color(id, NORMAL, chatszoveg[0],prefix, weaponList[key])

	menu_destroy(menu)
}
public infohud(id)
{
	if(!get_pcvar_num(g_hudenable)) return PLUGIN_HANDLED

	if(is_user_alive(id) && !is_user_bot(id))
	{
		oles[id] = get_player_kills(id)
		set_hudmessage(0, 127, 255, 0.01, 0.25, 0, 2.0, 3.0, 0.0, 0.0, -1)
		ShowSyncHudMsg(id, sync0bj,"|Ölés: %i|^n|Gyors Kés: %s|", oles[id],knife[id] == 1 ? (knifedisenable[1]):(knifedisenable[0]))
	}
	else
	{
		//new target = entity_get_int(id, EV_INT_iuser2)
		new target = pev(id, pev_iuser2)

		if(!target)
		return PLUGIN_CONTINUE
		oles[target] = get_player_kills(target)

		set_hudmessage(255, 255, 255, 0.01, 0.25, 0, 2.0, 3.0, 0.0, 0.0, -1)
		ShowSyncHudMsg(id, sync0bj,"|Megfigyelt játékos: %s|^n|Ölései: %i|^n|Gyors Kése: %s|",get_player_name(target),oles[target],knifedisenable[knife[target]])
	}

	return PLUGIN_CONTINUE
}
public client_disconnected(id)
{
	if(is_user_bot(id)) return

	save(id)

	switchbutton[id] = 0
	akskin[id] = 0
	m4skin[id] = 0
	awpskin[id] = 0
	dgleskin[id] = 0
	knife[id] = 0
	oles[id] = 0
}
public client_putinserver( id )
{
	if(is_user_bot(id)) return
	if(!id || id == 0) return

	load(id)
	set_task(3.0, "infohud", id, _, _, "b")
}
public plugin_end()
{
	for(new i=1;i<32;i++)
	{
		if(is_user_connected(i))
			save(i)
	}
	return PLUGIN_HANDLED
}
load(id)
{
	new szAuthid[32], szData[32]
	if(get_pcvar_num(g_auth_mode))
		get_user_authid(id,szAuthid,charsmax(szAuthid))
	else
		get_user_name(id,szAuthid,charsmax(szAuthid))

	new s1[16],s2[16],s3[16],s4[16],s5[8],s6[8]
	fvault_get_data( szVaultName, szAuthid, szData, 31 )
	parse( szData, s1, 15, s2, 15, s3, 15, s4, 15, s5, 7, s6, 3)
	oles[id] = get_player_kills(id)
	switchbutton[id] = str_to_num(s1)

	akskin[id] = str_to_num(s2)
	m4skin[id] = str_to_num(s3)
	awpskin[id] = str_to_num(s4)
	dgleskin[id] = str_to_num(s5)
	knife[id] = str_to_num(s6)
}
save(id)
{
	if(id == 0) return
	
	new szAuthid[ 32 ], szData[ 32 ]

	if(get_pcvar_num(g_auth_mode))
		get_user_authid( id, szAuthid, charsmax(szAuthid))
	else
		get_user_name( id, szAuthid, charsmax(szAuthid))
	formatex( szData,31, "%i %i %i %i %i %i",switchbutton[id],akskin[id],m4skin[id],awpskin[id],dgleskin[id],knife[id])
	fvault_set_data( szVaultName, szAuthid, szData )
}

/*Stocks*/
stock get_player_name(id)
{
	static szName[32]
	get_user_name(id,szName,31)
	return szName
}
stock get_player_kills(id)
{
	static stats[8]
	static bodyhits[8]
	get_user_stats(id, stats, bodyhits)

	return stats[0]
}
