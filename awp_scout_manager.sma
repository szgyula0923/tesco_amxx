#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>

new szMapname[32], mapType, g_sptime, bool:g_bProtectTime[33];

public plugin_init()
{
	register_plugin("AWP/Scout/Knife", "0.3", "RaZ_HU");
	g_sptime = register_cvar("amx_sptime","3")
	RegisterHam(Ham_Spawn, "player", "playerspawn", 1);
	register_forward(FM_TraceLine, "TraceLine");
}

public plugin_cfg()
{
	get_mapname(szMapname, sizeof szMapname);
	
	if(containi(szMapname, "scout") == 0)
		mapType = 0;
	else if(containi(szMapname, "awp") == 0)
		mapType = 1;
	else if(containi(szMapname, "35") == 0 || containi(szMapname, "knife") == 0)
		mapType = 2;
	else if(containi(szMapname, "aim") == 0)
		mapType = 3;
	else
		server_cmd("amx_pausecfg pause awp_scout_manager.amxx")

	log_amx("Awp manager fut");
}

public TraceLine( Float:v1[3], Float:v2[3], noMonsters, pentToSkip )
{
	new iAttacker = pentToSkip;
	new iVictim = get_tr(TR_pHit); 
	
	if (!is_user_connected(iVictim) || !is_user_connected(iAttacker))
		return FMRES_IGNORED;
		
	if(g_bProtectTime[iVictim])
	{
		set_tr( TR_flFraction, 1.0 );
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public playerspawn(id)
{
	if(!is_user_connected(id))
	return PLUGIN_HANDLED;
	
	set_task(0.1, "spawnprot", id);
	
	
	if(mapType == 0)
	{
		set_task(0.4, "scout", id);
	}
	else if(mapType == 1)
	{
		set_task(0.4, "awp", id);
	}
	else if(mapType == 2)
	{
		set_task(0.4, "knife", id);
	}

	return PLUGIN_HANDLED;
}

public spawnprot(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;

	new freeze = get_cvar_num("mp_freezetime");
	new time = get_pcvar_num(g_sptime);
	g_bProtectTime[id] = true;
	
	if(get_user_team(id) == 1)
	{
		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 15)
	}
	else if(get_user_team(id) == 2)
	{
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 15)
	}
	
	set_hudmessage(0,191,255, 0.3, 0.2, 0, 6.0, float(time+freeze), 0.1, 0.2, 4);
	show_hudmessage(id, "Spawn Protection aktív %d másodpercig a kör kezdete után.", time);
	
	set_task(float(freeze)+time, "protect_off", id);
	return PLUGIN_CONTINUE;
}

public protect_off(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	g_bProtectTime[id] = false;
	set_user_rendering(id, kRenderFxGlowShell, 0, 0,0, kRenderNormal, 15);

	return PLUGIN_HANDLED
}

public client_disconnected(id)
{
	g_bProtectTime[id] = false;
}

public scout(id)
{
	if (!is_user_connected(id) && is_user_alive(id))
		return PLUGIN_HANDLED;
	
	strip(id);
	give_item(id,"weapon_knife");
	give_item(id,"item_assaultsuit");
	give_item(id,"item_kevlar");
	give_item(id,"weapon_scout");
	cs_set_user_bpammo(id, CSW_SCOUT, 25);

	return PLUGIN_HANDLED;
}

public awp(id)
{
	if (!is_user_connected(id) && is_user_alive(id))
		return PLUGIN_HANDLED;
	
	strip(id);
	give_item(id,"weapon_knife");
	give_item(id,"item_assaultsuit");
	give_item(id,"item_kevlar");
	give_item(id,"weapon_awp");
	cs_set_user_bpammo(id, CSW_AWP, 20);

	return PLUGIN_HANDLED;
}

public knife(id)
{
	if (!is_user_connected(id) && is_user_alive(id))
		return PLUGIN_HANDLED;
		
	strip(id);
	set_user_health(id,35);
	give_item(id,"weapon_knife");
	
	return PLUGIN_HANDLED;
}

stock strip(id)
{
	if(is_user_alive(id))
		strip_user_weapons(id);
}
