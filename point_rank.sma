/* Sublime AMXX Editor v2.2 */

#include <amxmodx>
#include <nvault>
// #include <amxmisc>
// #include <cstrike>
// #include <engine>
// #include <fakemeta>
// #include <hamsandwich>
// #include <fun>
// #include <xs>
// #include <sqlx>

new g_iVault;

new Float:g_fScore[33];
new g_sAuthID[33][35];

public plugin_init()
{
	register_plugin("Point rank - BETA", "0.12", "Beast");
	register_event("DeathMsg", "death_event", "a");
	register_clcmd("say .a", "asdasd");

	g_iVault = nvault_open("point_rank");
}

public asdasd(id)
{
	client_print(id, print_chat, "[Debug] %.3f", g_fScore[id]);
	log_amx("Faszkivan3");
}

public plugin_end()
{
	nvault_close(g_iVault);
}

public client_authorized(id, const authid[])
{
	new sData[30];
	new iTimestamp;
	new iDataExists;


	log_amx(authid);
	get_user_authid(id, g_sAuthID[id], charsmax(g_sAuthID));

	iDataExists = nvault_lookup(g_iVault, g_sAuthID[id], sData, charsmax(sData), iTimestamp);
	log_amx("Faszkivan2 %s", g_sAuthID[id]);

	g_fScore[id] = iDataExists ? str_to_float(sData) : 1000.0;
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
	log_amx("Faszkivan");
	new sTemp[32];
	float_to_str(g_fScore[id], sTemp, charsmax(sTemp));
	nvault_set(g_iVault, g_sAuthID[id], sTemp);
}

public death_event()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	if (iKiller == iVictim || !iKiller || iKiller > 32)
		return PLUGIN_HANDLED;

	g_fScore[iKiller]++;

	return PLUGIN_CONTINUE;
}