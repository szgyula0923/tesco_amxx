/* Sublime AMXX Editor v2.2 */

#include <amxmodx>
#include <fvault>
// #include <amxmisc>
// #include <cstrike>
// #include <engine>
// #include <fakemeta>
// #include <hamsandwich>
// #include <fun>
// #include <xs>
// #include <sqlx>

new const g_sVault[] = "rankpoint";

new Float:g_fScore[33];
new g_iKills[33];
new g_iDeaths[33];

new g_sAuthID[33][35];

public plugin_init()
{
	register_plugin("Point rank - BETA", "0.12", "Beast");
	register_event("DeathMsg", "death_event", "a");
	register_clcmd("say .a", "asdasd");
}

public asdasd(id)
{
	client_print(id, print_chat, "[Debug] %.3f", g_fScore[id]);
	return PLUGIN_HANDLED;
}

public client_authorized(id, const authid[])
{
	get_user_authid(id, g_sAuthID[id], charsmax(g_sAuthID));
	load_stat(id);
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
	save_stat(id);
}

public death_event()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	if (is_user_bot(iKiller) || is_user_bot(iVictim))
		return PLUGIN_HANDLED;

	if (iKiller == iVictim && 1 <= iKiller <= 32)
	{
		new Float:fPoint = g_fScore[iVictim] / 1000.0;
		g_fScore[iVictim] -= fPoint;
		g_iDeaths[iVictim]++;

		return PLUGIN_HANDLED;
	}

	if (!iKiller || iKiller > 32)
	{
		new Float:fPoint = g_fScore[iVictim] / 1000.0;
		g_fScore[iVictim] -= fPoint;
		g_iDeaths[iVictim]++;

		return PLUGIN_HANDLED;
	}

	new Float:fPoint = g_fScore[iVictim] / 1000.0;
	g_fScore[iKiller] += fPoint;
	g_fScore[iVictim] -= fPoint;

	if (g_fScore[iVictim] < 1.0)
		g_fScore[iVictim] = 1.0;

	g_iKills[iKiller]++;
	g_iDeaths[iVictim]++;

	return PLUGIN_CONTINUE;
}

public load_stat(id)
{
	new sData[128];
	if (fvault_get_data(g_sVault, g_sAuthID[id], sData, charsmax(sData)))
	{
		new sName[40], s1[20], s2[15], s3[15];
		parse(sData, charsmax(sData), sName, charsmax(sName), s1, charsmax(s1), s2, charsmax(s2), s3, charsmax(s3));

		g_fScore[id] = str_to_float(s1);
		g_iKills[id] = str_to_num(s2);
		g_iDeaths[id] = str_to_num(s3);
	}
	else
	{
		g_fScore[id] = 0.0;
		g_iKills[id] = 0;
		g_iDeaths[id] = 0;
	}
}

public save_stat(id)
{
	new sData[128];
	new sName[40];
	get_user_name(id, sName, charsmax(sName));
	formatex(sData, charsmax(sData), "%s %.5f %d %d", sName, g_fScore[id], g_iKills[id], g_iDeaths[id]);

	formatex(sName, charsmax(sName), "%s", g_sAuthID[id]);

	fvault_set_data(g_sVault, sName, sData);
}