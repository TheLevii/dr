#define KESZITO "Levii"
#define STEAMOM "http://steamcommunity.com/id/stuplevii"
#define Prefx = "[S]tunt*" 

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <sqlx>
#include <ColorChat>
#include <tutor>
#include <dooz_utils>  

#define InfoT engfunc(EngFunc_AllocString, "info_target")
#define MAX 19  		//Max Usp-k  
#define Limit_MAX 4  		//Max L. Usp-k  
#define TASKID	 1337
#define MAX_KNIFE_SNDS 9
#define MAX_USP_SNDS 9
#define MAX_KNIFELEVI_SNDS 9
 
new const v_Knife_Admin[64] = "models/stunt_event/v_kard.mdl"
new const p_Knife_Admin[64] = "models/stunt_event/p_kard.mdl"

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;


//MySql (Adatok)
new const SQL_INFO[][] = { "Host", "db", "pw", "db" };
new Handle:g_SqlTuple;

enum _:Adatok
{
	Szint,
	Xp,
	Pont,
	Olesek,
	Elet,
	Lada,
	Ujra,
	Doboz,
	Tok,
	Hogolyo,
	Dragako,
	Tojas,
};


new Adataim[33][Adatok]  
new kivalasztottUSP[33] , KivalasztottLimit[33],Knife[33] , Atvalt[33] , megkapva[33]
 
//Cslassok
//new Szerencse[33] , Ero[33], Ertekrend[33]

//Piac (Változók)
new kirakva[33],kicucc[33],erteke[33]

//(Bool+Változók)
new bool:CuccFentVan[3][33],g_Perc[33]
new PontIdo[33],XpIdo[33],VipIdo[33]

//HUD
new Huds[2], Kapcsolo[1][33]

//Utolagos Adatok
new Teljesneved[33]

//BAR
new gmsgBarTime2, Ido = 10; 

// Hang változtatás 
new knife_sounds_o[MAX_KNIFE_SNDS][] ={
	"weapons/knife_deploy1.wav","weapons/knife_hit1.wav","weapons/knife_hit2.wav","weapons/knife_hit3.wav","weapons/knife_hit4.wav","weapons/knife_hitwall1.wav","weapons/knife_slash1.wav",
	"weapons/knife_slash2.wav","weapons/knife_stab.wav"
}
new knife_sounds_r[MAX_KNIFE_SNDS][] ={
	"weapons/LeviKes/crow9_draw.wav","weapons/LeviKes/knife_hitwall1.wav","weapons/LeviKes/knife_slash1.wav","weapons/LeviKes/knife_slash2.wav","weapons/LeviKes/knife_stab.wav","weapons/LeviKes/knife_slash2.wav",
	"weapons/LeviKes/knife_slash1.wav","weapons/LeviKes/knife_slash1.wav","weapons/LeviKes/knife_stab.wav"
}
new knife_levi_r[MAX_KNIFELEVI_SNDS][] ={
	"weapons/balrog9_draw.wav","weapons/balrog9_slash1.wav","weapons/balrog9_slash2.wav","weapons/balrog9_hitwall.wav","weapons/balrog9_hit1.wav","weapons/balrog9_hit2.wav","weapons/balrog9_charge_start1.wav",
	"weapons/balrog9_charge_finish1.wav","weapons/balrog9_charge_attack2.wav"
}


new const cPermissions[][] = {
	"",
	"abcdefghijklmnopqrstu",
	"cdefijmu",
	"bcdefghijklmnopqrstu"
}
/* 60mp ciklus hirdetés & Ciklus = Ismétlődő esemény*/
new const cReklam[][] ={
	"!g[S]tunt*!y LĂˇjkolj / kĂ¶vess minket: !twww.facebook.com/stuntweb", 					 //[0]
	"!g[S]tunt*!y konfigos : !tLevii / The Peace!y | Ts3 IP: !t 164.132.201.166:10021",			 //[1]
	"!g[S]tunt*!y A szerveren egyedileg megĂ­rt menu van.", 						 //[2]
	"!g[S]tunt*!y JĂł jĂˇtĂ©kot Ă©s kellemes idĹ‘tĂ¶ltĂ©st kĂ­vĂˇn a !t[S]tunt #KlĂˇn!y.", 			 //[3]
	"!g[S]tunt*!y Facebook csoport  !g(csatlakozz)!y: www.facebook.com/groups/peaceserver", 		 //[4]
	"!g[S]tunt*!y A szabĂˇlyzat megtekintĂ©sĂ©hez Ă­rd be: !t/szabaly", 					 //[5]
	"!g[S]tunt*!y Tulajdonos / Konfigos : !gLevii / The Peace", 						 //[6]
	"!g[S]tunt*!y Ha szeretnĂ©l Ăşj mapot szavaztatni, akkor Ă­rd be: !trtv!y.",				 //[7]
	"!g[S]tunt*!y Ha szeretnĂ©l Ăşj mapot javasolni, akkor Ă­rd be: !tnom!y. ", 				 //[8]
	"!g[S]tunt*!y LehetĹ‘sĂ©ged van ADMINT / VIP / ST pontot vĂˇsĂˇrolni Ts3-on, !t/ts3 ", 			 //[9]
	"!g[S]tunt*!y Csak BankĂˇrtyĂˇs fizetĂ©s van. (!gkeress minket facebook oldalunkon / ts3-on!y)",	 //[10]
	"!g[S]tunt*!y Amikor sokan vannak a szerveren, akkor szokott event lenni. (LADA+PONT+XP)",		 //[11]
	"!g[S]tunt*!y (2018.08.26) !g~ !y bekerultek a !gLIMIT USP!y-k.",      					 //[12]
	"!g[S]tunt*!y !g18:00!y-tĂłl !g22:00!y-ig idĹ‘kĂ¶zĂ¶nkĂ©nti pontot kapsz a szervertĹ‘l. "		 //[13]
}
/* Kések és adatai */
new const cKesek[][][] ={
	// Neve | Kellő érték | elérési út | Szint | Sebesség | Gravity
	{ "Alap KĂ©s","\yMegszerezve",            "models/v_knife.mdl",       "0",    "250.0",    "1.0" },
	{ "Gyors KĂ©s\d(+5% speed)",     "\r5.Lvl",       "models/stunt_deathrun_levi/kes/v_gyors.mdl",  "5",    "260.0",    "1.0" },    			// 0
	{ "GravitĂˇciĂł KĂ©s\d(-20% grav)",       "\r10.Lvl",      "models/stunt_deathrun_levi/kes/v_gravi.mdl",  "10",   "260.0",    "0.87"},		// 1
	{ "SzĂˇguldĂł KĂ©s\d(+15% speed)",   "\r15.Lvl",      "models/stunt_deathrun_levi/kes/v_szaguldo.mdl",    "15",   "260.0",    "1.0"},		// 2
	{ "SebzĂ©s KĂ©s\d(+30% DMG)", "\r20. Lvl",     "models/stunt_deathrun_levi/kes/v_sebzes.mdl", "20",   "250.0",    "1.0"},				// 3
	{ "Metal KĂ©s\d(+18% speed)", "\r22. Lvl",     "models/stunt_deathrun_levi/kes/v_metal.mdl", "22",   "263.0",    "1.0"},				// 4
	{ "ĂtlĂˇtszĂł KĂ©s\d(+22% speed)", "\r24. Lvl",     "models/stunt_deathrun_levi/kes/v_atlatszo.mdl", "24",   "270.0",    "1.0"},			// 5	
	{ "BrutĂˇlis KĂ©s\d(+20% speed, -20%grav)", "\r28. Lvl",     "models/stunt_deathrun_levi/kes/v_brutalis.mdl", "28",   "270.0",    "0.78"},	// 6
	{ "Levii Ă–klei\d(+21% speed, -17%grav)", "\r36. Lvl",  "models/stunt_deathrun_levi/kes/v_levike.mdl", "36",   "265.0",    "0.83"},		// 7
	{ "Kommando KĂ©s *HD*\d(+20% speed)", "\r44. Lvl",     "models/stunt_deathrun_levi/kes/v_kommandohd.mdl", "44",   "265.0",    "1.0"},		// 8
	{ "Ultra KĂ©s\d(+25% speed)", "\r52. Lvl",     "models/stunt_deathrun_levi/kes/v_ultra.mdl", "52",   "270.0",    "1.0"},				// 9
	{ "RagadozĂł KĂ©s\d(+50% DMG)", "\r57. Lvl",     "models/stunt_deathrun_levi/kes/v_ragadozo.mdl", "57",   "250.0",    "1.0"},			// 10
	{ "SĂˇrkĂˇny KĂ©s\d(+50% DMG,-10% grav)", "\r63. Lvl",     "models/stunt_deathrun_levi/kes/v_sarkany.mdl", "63",   "250.0",    "0.78"},		// 11
	{ "Crow-9 KĂ©s\d(+75% DMG,-20% grav)", "\r73. Lvl",     "models/stunt_deathrun_levi/kes/Crow9.mdl", "73",   "250.0",    "0.78"},			// 12
	{ "Vip KĂ©s\d(+22% speed,-22% grav)", "\rCsak a Vipnek",     "models/stunt_deathrun_levi/kes/v_vipkes.mdl", "11111",   "270.0",    "0.83"}	// 13
}
/* Usp-k és adatai */
new const cUsp[][][] ={
	// Usp Neve |    Pont ertek |  Eleresi Ăşt| | Pont  ban | Sebzés 
	{ "Sima USP","\y[Megszerezve]", "models/v_usp.mdl", "0", "1.0", "Alap Usp "},											 // 0 
	{ "Spitfire USP - \y+1.2x DMG" ,"250 Pont", "models/stunt_deathrun_levi/usp/v_spitfire.mdl","250", "1.2" ,   "Spitfire Usp | 1.2x (dmg)"}, 			 // 1
	{ "TĹ±z USP - \y+1.3x DMG" ,"350 Pont", "models/stunt_deathrun_levi/usp/v_tuz.mdl","350","1.3",  "TĹ±z Usp | 1.3x (dmg)"},					 // 2
	{ "TerepMintĂˇs USP - \y+1.5x DMG" ,"750 Pont","models/stunt_deathrun_levi/usp/v_terepmintas.mdl","750","1.5",  "TerepMintĂˇs Usp | 1.5x (dmg)"},		 // 3
	{ "EzĂĽst USP - \y+1.6x DMG" ,"1250 Pont", "models/stunt_deathrun_levi/usp/v_ezust.mdl","1250","1.6",  "EzĂĽst Usp | 1.6x (dmg)" },				 // 4
	{ "Arany USP - \y+1.7x DMG" ,"1400 Pont", "models/stunt_deathrun_levi/usp/v_arany.mdl","1400","1.7" , "Arany Usp | 1.7x (dmg)"}, 				 // 5
	{ "Modern USP - \y+1.8x DMG" ,"1650 Pont", "models/stunt_deathrun_levi/usp/v_modern.mdl","1650","1.8", "Modern Usp | 1.8x (dmg)"},				 // 6
	{ "Katonai USP - \y+1.9x DMG" ,"2000 Pont", "models/stunt_deathrun_levi/usp/v_katonai.mdl","2000","1.9",  "Katonai Usp | 1.9x (dmg)" }, 				 // 7
	{ "Vexter USP - \y+2.0x DMG" ,"2350 Pont", "models/stunt_deathrun_levi/usp/v_vexter.mdl","2350","2.0", "Vexter Usp | 2.0x (dmg)" },				 // 8
	{ "KĂ©khalĂˇl USP - \y+2.1x DMG" ,"2600 Pont", "models/stunt_deathrun_levi/usp/v_kekhalal.mdl","2600","2.1", "KĂ©khalĂˇl Usp | 2.1x (dmg)" },			 // 9
	{ "VĂˇndorlĂł USP - \y+2.2x DMG" ,"3200 Pont", "models/stunt_deathrun_levi/usp/v_vandorlo.mdl","3200","2.2", "VĂˇndorlĂł Usp | 2.2x (dmg)" }, 			 // 10
	{ "SĂˇrkĂˇnyfog USP - \y+2.3x DMG" ,"3600 Pont", "models/stunt_deathrun_levi/usp/v_sarkanyfog.mdl","3600","2.3", "SĂˇrkĂˇnyfog Usp | 2.3x (dmg)" },		 // 11
	{ "Carbon USP - \y+2.4x DMG" ,"4200 Pont", "models/stunt_deathrun_levi/usp/v_carbon.mdl","4200","2.4", "Carbon Usp | 2.4x (dmg)" }, 				 // 12
	{ "Oil USP - \y+2.5x DMG" ,"5100 Pont", "models/stunt_deathrun_levi/usp/v_oil.mdl","5100","2.5", "Oil Usp | 2.5x (dmg)" }, 					 // 13
	{ "VĂ©regzĹ‘ USP - \y+2.6x DMG" ,"7000 Pont", "models/stunt_deathrun_levi/usp/veregzofaszomlevifasz.mdl","7000","2.6", "VĂ©regzĹ‘ Usp | 2.6x (dmg)" },		 // 14
	{ "Fogoly USP - \y+2.7x DMG" ,"10.000 Pont", "models/stunt_deathrun_levi/usp/fogoly.mdl","10000","2.7", "Fogoly Usp | 2.7x (dmg)" },				 // 15
	{ "Orion USP |- \y+2.8x DMG" ,"15.000 Pont", "models/stunt_deathrun_levi/usp/v_orion.mdl","15000","2.8", "Orion Usp | 2.8x (dmg)" },				 // 16
	{ "Ărnyalat USP - \y+2.9x DMG" ,"20.000 Pont", "models/stunt_deathrun_levi/usp/arnyalat.mdl","20000","2.9", "Ărnyalat Usp | 2.9x (dmg)" }, 			 // 17
	{ "Pinky USP - \y+3.0x DMG" ,"25.400 Pont", "models/stunt_deathrun_levi/usp/pinky.mdl","25400","2.9", "Pinky Usp | 3.0x (dmg)" } 				 // 18
	
};

/* Limit usp-k és adatai */
new const cLimit[][][] ={	 
	{ "Haloweeni USP | \y(+5 Pont & XP / KILL )" ,"150 tĂ¶k", "models/stunt_deathrun_levi/Limit/hawn.mdl","150", "1.2"}  	,				// 0
	{ "KarĂˇcsonyi USP | \y(+10 Pont & XP / KILL )" ,"150 Hogolyo", "models/stunt_deathrun_levi/Limit/karacsonyi.mdl","150", "1.5"} , 			// 1
	{ "ĂšjĂ©vi USP | \y(+4 XP & Pont / KILL )" ,"50 drĂˇgakĹ‘", "models/stunt_deathrun_levi/Limit/ujevi.mdl","50", "2.5"} ,					// 2
	{ "HĂşsvĂ©ti USP | \y(+8 XP & Elet / KILL )" ,"90 tojĂˇs", "models/stunt_deathrun_levi/Limit/husveti.mdl","90", "2.5"}  					// 3

};

new megerosit_usp[33]
new pistol[sizeof(cUsp)][33]
new limit[sizeof(cLimit)][33]

public plugin_init(){
	register_plugin("DeathRun Menu v3", " 3.0 V", "The Peace");
	
	////	|        3.0 V	           |  ////
	///	|Made By: Levii / ThePeace |  ///
	//	|   			   |  //
	
	register_clcmd("chooseteam","Mymenu" )
	register_clcmd("say /menu","Mymenu" )
	register_clcmd("say /rs","reset")
	register_clcmd("say /piac","vasarlas")

	register_clcmd("Pont", "lekeres")
	register_clcmd("say","handlesay")
	register_clcmd("say_team","handlesay")
	

	register_event( "CurWeapon", "SwitchGuns", "be", "1=1" )
	RegisterHam( Ham_TakeDamage, "player", "damagetake" )
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamagePost", 1)
	
	
	register_touch("lada","player","remove")
	register_touch("xp","player","remove1")
	register_touch("pont","player","remove2")
	
	register_message( get_user_msgid( "ScoreAttrib" ),    "msgScoreAttrib" );
	register_forward(FM_EmitSound , "EmitSound");

	set_task(60.0, "AutomateAdvertisement", 0, "", 0, "b", 0)
	set_task(400.0, "MaximumPoint", 0, "", 0, "b", 0)
	set_task(90.0, "Hirdet", 0, "", 0, "b", 0)
	set_task(120.0, "IdoEllenorzes", 92193, _, _, "b")
	set_task(210.0,"autoSave",.flags="b")
	
 
	new palya[32]
	get_mapname(palya, charsmax(palya))
	
	if(equal("stunt_event", palya)){
		RegisterHam(Ham_Spawn, "player", "csere", 1);
	}
	
	register_logevent("RoundEnd",2,"1=Round_End")
	
	gmsgBarTime2 = get_user_msgid("BarTime2")
	Huds[0] = CreateHudSyncObj();
	Huds[1] = CreateHudSyncObj();
	
	tutorInit();
}
public Hirdet(id) 
	print_color(0, "!g[S]tunt*!y Ă–rĂ¶kĂ¶s VIP Ăˇra a szerverre: !g1000!y FT (banki ĂˇtutalĂˇs).")
public vipetad(id){
	VipIdo[id] = get_systime()+60*60*24*666 // 666  | 2 év
	CuccFentVan[2][id] = true  
	
	new Nev[32]
	get_user_name(id, Nev, 31)
	print_color(0, "!g[S]tunt*!t %s!y megkapta az OROKOS VIP-t a szerveren.",Nev)
	
}
public EmitSound(entity,  channel, const sound[])
{
	if(pev_valid(entity) && is_user_alive(entity))
	{
		for(new i = 0; i < MAX_KNIFE_SNDS; i++)
		{
			if(equal(sound , knife_sounds_o[i] ))
			{
				if(Knife[entity] == 13)
				{
					emit_sound(entity, channel, knife_sounds_r[i], 1.0, ATTN_NORM, 0, PITCH_NORM);
					
					return FMRES_SUPERCEDE;
				}
			}
		}	
		for(new i = 0; i < MAX_KNIFELEVI_SNDS; i++)
		{
			if(equal(sound , knife_sounds_o[i] ))
			{
				if(Knife[entity]  == 8)
				{
					emit_sound(entity, channel, knife_levi_r[i], 1.0, ATTN_NORM, 0, PITCH_NORM);
					
					return FMRES_SUPERCEDE;
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}
public OnTakeDamagePost(victim, inflictor, attacker/*, Float:damage, dmgtype*/){
	if(victim == attacker) return HAM_IGNORED; //self damage
	if(inflictor != attacker) return HAM_IGNORED; //prevent from other damage like bazooka, tripmine we need knife damage only
	if(!is_user_connected(attacker)) return HAM_IGNORED; //non-player damage
	if(Knife[attacker] != 13) return HAM_IGNORED; //current weapon is not knife
	
	static Float:fVelocity[3]
	velocity_by_aim(attacker, 1000, fVelocity)
	fVelocity[2] = 500.0
	set_pev(victim, pev_velocity, fVelocity)
	
	return HAM_IGNORED;
}
public ShowHud(taskid) {
	new id = taskid - 1945, Name[32];
	new Target = pev(id, pev_iuser1) == 4 ? pev(id, pev_iuser2) : id;
	
	if(!Kapcsolo[0][id])
		return;
		
	if(is_user_alive(id)){		
		set_hudmessage(255, 211, 0, 0.01, 0.23, 0, 6.0, 2.0)
		ShowSyncHudMsg(id, Huds[0], "Szint: ^nPont: ^nĂ‰let:")
		
		set_hudmessage(137,130,97, 0.01, 0.23, 0, 6.0, 2.0)
		ShowSyncHudMsg(id, Huds[1], "          %d   ( %d%% )^n          %d^n          %d",Adataim[id][Szint],Adataim[id][Xp],Adataim[id][Pont],Adataim[id][Elet])	
	}
	else{
		get_user_name(Target, Name, 31);
		
		set_hudmessage(0, 255, 255, 0.01, 0.23, 0, 6.0, 2.0)
		ShowSyncHudMsg(id, Huds[0], "^nNĂ©zett jĂˇtĂ©kos adatai: ^n^nSzint: ^nPont: ^nFegyver:")
		
		set_hudmessage(192,192,192, 0.01, 0.23, 0, 6.0, 2.0)
		ShowSyncHudMsg(id, Huds[1], "^n                                     %s^n^n          %d   ( %d%% )^n          %d^n                %s", Name, Adataim[Target][Szint],Adataim[Target][Xp],Adataim[Target][Pont],cUsp[kivalasztottUSP[Target]][5])
	}
}	 
public fixed(Killer, Victim){
	
	if(Killer == Victim)
		return PLUGIN_HANDLED;
	
	if(Adataim[Killer][Xp] >= 100){
		Adataim[Killer][Szint]++
		Adataim[Killer][Xp] -= 100
	}
	return PLUGIN_CONTINUE
}	
public MaximumPoint( )
{
	new iPlayers[ 32 ], iPnum, iMax, iMaxPlayer;
	get_players( iPlayers, iPnum, "c" );

	for ( new i; i < iPnum; ++i )
	if ( Adataim[ iPlayers[ i ]] [ Pont ] > iMax ){
		iMax = Adataim[ iPlayers[ i ] ][Pont];
		iMaxPlayer = iPlayers[ i ];
	}
	new sName[ 32 ];
	get_user_name( iMaxPlayer, sName, charsmax( sName ) )
	
	print_color( 0, "!g[S]tunt*!t %s !yvezet !g%i!y ponttal!", sName, iMax-000 )
}
public reset(id){
	cs_set_user_deaths(id, 0);set_user_frags(id, 0)
	cs_set_user_deaths(id, 0);set_user_frags(id, 0)
	print_color(id, "!g[S]tunt*!y Sikeresen nullĂˇztad a statodat!")
}
public AutomateAdvertisement(id) 
	print_color(id,cReklam[random_num(0,13)])

public client_death(Killer, Victim , id)
{
	if(Killer == Victim)
		return PLUGIN_HANDLED;
	
	Adataim[Killer][Olesek]++;

	if(get_pdata_int(Victim, 75) == HIT_HEAD){
		client_cmd(0, "spk ^"sound/events/task_complete.wav^"");
	}
	
	switch(random_num(0,50))
	{
		case 0..9:
		{
			// semmi
		}
		case 10:
		{
			TokAdd(Killer)
		}
		case 11..20:
		{
			// semmi
		}
		case 21:
		{
			HogolyoAdd(Killer)
		}
		case 22..30:
		{
			// semmi
		}
		case 31:
		{
			DragakoAdd(Killer)
		}
		case 32..40:
		{
			// semmi
		}
		case 41:
		{
			TojasAdd(Killer)
		}
		case 42..50:
		{
			// semmi
		}
	
	}
	if(CuccFentVan[2][Killer] == false && CuccFentVan[0][Killer] == false && CuccFentVan[1][Killer] == false) // Nincs semmi dupla cucca 
	{
			new pPont
			pPont += random_num(1, 8);
			Adataim[Killer][Pont] += pPont;
			print_color(Killer, "!g[S]tunt*!y !t+%d!y pont", pPont)
	}
	if(KivalasztottLimit[Killer] == 0) // Tok Limit USP
	{
			Adataim[Killer][Pont] += 5
			Adataim[Killer][Xp] += 5
			print_color(Killer, "!g[S]tunt*!y !t+5!y pont & !t+5!y XP")
			
	}
	if(KivalasztottLimit[Killer] == 1) // Karacsonyi Limit USP
	{
			Adataim[Killer][Pont] += 10
			Adataim[Killer][Xp] += 5
			print_color(Killer, "!g[S]tunt*!y !t+10!y pont & !t+5!y XP")
			
	}
	if(KivalasztottLimit[Killer] == 2) // Ujevi Limit USP
	{
			Adataim[Killer][Pont] += 5
			Adataim[Killer][Xp] += 4
			print_color(Killer, "!g[S]tunt*!y !t+10!y pont & !t+5!y XP")
			
	}
	if(KivalasztottLimit[Killer] == 3) // Ujevi Limit USP
	{
			Adataim[Killer][Pont] += 5
			Adataim[Killer][Xp] += 4
			print_color(Killer, "!g[S]tunt*!y !t+10!y pont & !t+5!y XP")
			
	}
	if(KivalasztottLimit[Killer] == 4) // Husveti Limit USP
	{
			Adataim[Killer][Elet]++
			Adataim[Killer][Xp] += 8
			print_color(Killer, "!g[S]tunt*!y !t+1!y elet & !t+8%!y XP")
			
	}

	if(CuccFentVan[2][Killer] == true && CuccFentVan[0][Killer] == false  && CuccFentVan[1][Killer] == false) 
	{
		new mennyiseg = random_num(1, 15)
		print_color(Killer, "!g[S]tunt*!t+%d!y pontot kaptĂˇl !t+1!y Ă©letet mert VIP vagy!",mennyiseg)
		Adataim[Killer][Pont] += mennyiseg
		Adataim[Killer][Elet] += 1
	}
	if(CuccFentVan[0][Killer] == true ) // Dupla Pont
	{
		new mennyiseg = random_num(1, 25)
		print_color(Killer, "!g[S]tunt*!t+%d!y pontot kaptĂˇl! !g(Dupla Pont)",mennyiseg)
		Adataim[Killer][Pont] += mennyiseg 
	}
	if(CuccFentVan[1][Killer] == true )
	{
		new mennyiseg = random_num(1, 6)
		print_color(Killer, "!g[S]tunt*!t+%d!y XP kaptĂˇl! !g(Dupla XP)",mennyiseg)
		Adataim[Killer][Xp] += mennyiseg 
	}
	
	if(Adataim[Killer][Szint] >= 0 && Adataim[Killer][Szint] < 5 && CuccFentVan[1][Killer] == false)
		Adataim[Killer][Xp] += random_num(20,30)
	else if(Adataim[Killer][Szint] >= 5 && Adataim[Killer][Szint] < 100 && CuccFentVan[1][Killer] == false)
		Adataim[Killer][Xp] += random_num(1,3)
	else if(Adataim[Killer][Szint] >= 0 && Adataim[Killer][Szint] < 100 && CuccFentVan[1][Killer] == false)
		Adataim[Killer][Xp] += random_num(20,40)
	
	
	if(Adataim[Killer][Xp] >= 100)
	{
		new Nev[32]
		get_user_name(Killer, Nev, 31)
		print_color(0, "!g[S]tunt*!t  %s!y  szintet  lĂ©pett!   !g(*)",  Nev)
		
		Adataim[Killer][Szint] ++
		Adataim[Killer][Xp] -= 100
	}
	return PLUGIN_CONTINUE;
}
public TokAdd(id){
	new Nev[32]
	get_user_name(id, Nev, 31)
	print_color(0, "!g[S]tunt*!t  %s!y  kapott az Ă¶lĂ©sĂ©rt !g+1!y tĂ¶kĂ¶t !",  Nev)
	Adataim[id][Tok] ++
}
public TojasAdd(id){
	new Nev[32]
	get_user_name(id, Nev, 31)
	print_color(0, "!g[S]tunt*!t  %s!y  kapott az Ă¶lĂ©sĂ©rt !g+1!y tojast !",  Nev)
	Adataim[id][Tojas] ++
}
public DragakoAdd(id){
	new Nev[32]
	get_user_name(id, Nev, 31)
	print_color(0, "!g[S]tunt*!t  %s!y  kapott az Ă¶lĂ©sĂ©rt !g+1!y dragakovet !",  Nev)
	Adataim[id][Dragako] ++
}
public HogolyoAdd(id){
	new Nev[32]
	get_user_name(id, Nev, 31)
	print_color(0, "!g[S]tunt*!t  %s!y  kapott az Ă¶lĂ©sĂ©rt !g+1!y hogolyot!",  Nev)
	Adataim[id][Hogolyo] ++
}
public openSettings(id){
	new String[121];
	format(String, charsmax(String), "s[T]* \r- \dBeĂˇllĂ­tĂˇsok^n\dby: \rLevii / The Peace");
	new menu = menu_create(String, "Beallitasok_h");

	//menu_additem(menu, Kapcsolo[0][id] == 1 ? "HUD: \rBekapcsolva \y| \wKikapcsolva":"HUD: \wBekapcsolva \y| \rKikapcsolva", "1",0);
	menu_additem(menu, Kapcsolo[0][id] == 1 ? "JĂˇtĂ©kos informĂˇciĂł HUD: \rBekapcsolva \y| \wKikapcsolva":"JĂˇtĂ©kos informĂˇciĂł HUD: \wBekapcsolva \y| \rKikapcsolva", "2",0);
	
	menu_display(id, menu, 0);
}
public Beallitasok_h(id, menu, item)
{
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key) 
	{
		case 2:
			if(Kapcsolo[0][id]  == 1)
				Kapcsolo[0][id] = 0;
			else
				Kapcsolo[0][id] = 1;
			}
	openSettings(id);
}

public Mymenu(id)
{
	if(is_user_logged(id) ){
		static String[512];
		formatex(String, charsmax(String), "\r[S]tunT*  \y(DeathRun) \dBy: The Peace / Levii^n\r Szinted:\d %d | \r Tapasztalat: \d %d%% | \rPont: \d %d", Adataim[id][Szint],Adataim[id][Xp],Adataim[id][Pont]);
		new menu = menu_create(String, "my_handler" );
		
		
		menu_additem(menu, "KĂ©sek", "1", 0);
		menu_additem(menu, "USP", "2", 0);
		menu_additem(menu, "ĂruhĂˇz", "3", 0);
		menu_additem(menu, "LĂˇdĂˇk ", "4", 0);
		menu_additem(menu, "Vip", "5", 0);
		menu_additem(menu, "LevĂˇsĂˇrlĂˇs ", "6", 0);
		
		menu_additem(menu, "KezelĂ©s \d(\rNEW\d) ", "11", 0);
		
		/*
		if(get_user_flags(id)&ADMIN_KICK){
			menu_additem(menu, "\yAdmin dolgok", "8", 0);
		}
		else{
		}
		*/
		menu_display(id, menu, 0);
	}
}
public my_handler(id, menu, item)
{
	switch(item){
			case MENU_EXIT: menu_destroy(menu);
		  
			case 0: MyKnife(id);
			case 1: MyUspValaszt(id);
			case 2: MyShop(id);
			case 3: LadaNyitas(id);
			case 4: MyVip(id);
			case 5: Levasarlas(id);
			case 6: openSettings(id);
	}
} 
public LadaNyitas(id)
{
	new txt[1006]
	new menu = menu_create("\r[S]tunT*  \dBy: The Peace / Levii ^n \yLĂˇdaNyitĂˇs", "ladanyit_h");
	
	formatex(txt, charsmax(txt), "LĂˇda NyitĂˇs  | \y LĂˇdĂˇid \d(\r%d \yDB\d)",Adataim[id][Lada])
	menu_additem(menu, txt, "1", 0)
	
	
	menu_display(id, menu, 0);
}
public ladanyit_h(id, menu, item){
	switch(item){
			case MENU_EXIT: menu_destroy(menu);
		  
			case 1:
			if(Adataim[id][Lada] >= 1 )
				Ladanyit(id);
			
	}
}
public Bar_Start(id){
	if(is_user_alive(id)) {
		Make_BarTime2(id, Ido,  0) // Másodperc || százalék amennyitől kezdje.
	}
	set_task(0.1, "LadaNyitas", id)
}
public Ladanyit(id)
{
	if(Adataim[id][Lada] >= 1 && Ido == 10)
	{
		Adataim[id][Lada] -=1;
		LadaNyitas(id)
	}
	switch(random_num(0,8))
	{
		case 0..5: 
		{
			print_color(id, "!g[S]tunt*!y Sajnos ez a lĂˇda ĂĽres volt!")  
		}
		case 6: {
			Adataim[id][Elet]++;print_color(id, "!g[S]tunt*!y nyitottĂˇl !g+1!y Ă©letet!") 
			
			/*
			if(Ido > 0){
				Ido--
				set_hudmessage(0, 255, 255, -1.0, 0.13, 0, 6.0, 12.0)
				show_hudmessage(0, "%d masodperc van meg hatra",Ido)
				set_task(1.0, "Idozito")
			}
			else{
				set_hudmessage(255, 201, 225, -1.0, 0.13, 0, 6.0, 12.0)
				show_hudmessage(0, "---------------------^n -----------^n Ezt kaptad: +1  Ă©le ^n -----------  ^n ---------------------  ")
				Ido = 10;
			}
			*/
		}
		case 7:{
			Adataim[id][Pont] += 30;print_color(id, "!g[S]tunt*!y nyitottĂˇl !g+30!y pontot!")  
		}
		case 8:{
			Adataim[id][Xp] += 30;print_color(id, "!g[S]tunt*!y nyitottĂˇl !g+30%!y Xp-t!")  
		}
	}
}

public MyShop(id)
{
	static String[512];formatex(String, charsmax(String), "\y[S]tunT* \dBy: The Peace / Levii ^n \r Szinted:\d %d | \r Tapasztalat: \d %d%% | \rPont: \d %d  ",Adataim[id][Szint],Adataim[id][Xp],Adataim[id][Pont]);new menu = menu_create(String, "myshop_handler" );
	
	if(Adataim[id][Szint] <=15){
		menu_additem(menu, "KĂ¶nyv  \r(+1 Szint)  \d 120 Pont", "0", 0);}
	else{
		menu_additem(menu, "KĂ¶nyv  \r(+1 Szint)  \d-- 15 szint fĂ¶lĂ¶tt ZĂRVA --", "99", 0);}
	
	if(get_user_health(id) <= 100){
		menu_additem(menu, "RegenerĂˇciĂł \r(+25HP)  \d 24 Pont", "1", 0);}
	else{
		menu_additem(menu, "RegenerĂˇciĂł \r(+25HP)  \d --MAX HP-d VAN--", "99", 0);}
	
	menu_additem(menu, "FejlettsĂ©g \r(+25AP) \d19 Pont", "2", 0);
	menu_additem(menu, "ĂšjraĂ©ledĂ©s \r(+1 Ă©let) \d 6 Pont^n", "3", 0);
	
	if(CuccFentVan[0][id] == false){
		menu_additem(menu, "\yDupla Pont \r(30percig) \d 100 Pont", "4", 0);}
	else{
		menu_additem(menu, "\yDupla Pont \r(30percig) \d -- MAR HASZNALOD --", "99", 0);menu_display(id, menu, 0);}
	
	if(CuccFentVan[1][id] == false){
		menu_additem(menu, "\yDupla Xp \r(30percig) \d 100 Pont", "5", 0);menu_display(id, menu, 0);}
	else{
		menu_additem(menu, "\yDupla Xp \r(30percig) \d -- MAR HASZNALOD --", "99", 0);menu_display(id, menu, 0);
	}
}
public myshop_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	new data[9], name[64], Gomb;
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data),
	name, charsmax(name), callback);
	
	Gomb = str_to_num(data);
	
	if(Gomb == 0){
		if(Adataim[id][Szint] < 15 && Adataim[id][Pont] >= 120)
		{
			Adataim[id][Szint] += 1;Adataim[id][Pont] -=120
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!") 
			
		}
		else if(Adataim[id][Pont] < 120 && Adataim[id][Szint] < 15)
			print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!")  
		else if(Adataim[id][Szint] >= 15)
			print_color(id, "!g[S]tunt*!y Te nem tudsz tovĂˇbbĂˇ szintet venni, mert elĂ©rted a 15.szintet!")
			}
			
	if(Gomb == 1){
		if(Adataim[id][Pont] >= 24 ){
			Adataim[id][Pont] -= 24;set_user_health(id,get_user_health(id) + 25)
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!") 
			}
		else{ print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!")
		}
	}
	if(Gomb ==2){
		if(Adataim[id][Pont] >= 100){
			Adataim[id][Pont] -= 19;set_user_armor(id,get_user_armor(id) + 25)
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")
			}
		else{ print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!") 
		}
	}
	if(Gomb ==3){
		if(Adataim[id][Pont] >= 6 ){
			Adataim[id][Elet] += 1; Adataim[id][Pont] -= 6
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!") 
			}
		else{ print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!") 
		}
	}
	if(Gomb ==4){
		if(Adataim[id][Pont] >= 100 ){
			Adataim[id][Pont] -= 100
			PontIdo[id] = get_systime()+30*60
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
			tutorMake(id,TUTOR_GREEN,5.0,"+30 percig (Dupla Pont)") 
			}
		else{ print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!")  
		}
	}
	if(Gomb ==5){
		if(Adataim[id][Pont] >= 100 ){
			Adataim[id][Pont] -= 100
			XpIdo[id] = get_systime()+30*60 // 30 perc
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
			tutorMake(id,TUTOR_GREEN,5.0,"+30 percig (Dupla Xp)") 
		}
		else{ print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!")
		}
	}
}
public MyUspValaszt(id)
{
	static String[512];formatex(String, charsmax(String), "\y[S]tunT* \r USP vĂˇlasztĂł \dBy: The Peace / Levii");new menu = menu_create(String, "myuspvalaszt_handler" );
	
	menu_additem(menu, "\wUSP-k", "0", 0);
	menu_additem(menu, "\wLimitĂˇlt USP ^n", "1", 0);
	menu_additem(menu, "\rUSP Piac", "2", 0);
	
	menu_display(id, menu, 0);
}
public myuspvalaszt_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	new data[9], name[64], Gomb;
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data),
	name, charsmax(name), callback);
	
	Gomb = str_to_num(data);
	
	if(Gomb == 0)MyUsp(id)
	if(Gomb == 1)MyLimit(id)
	if(Gomb == 2)vasarlas(id)
}
public MyKnife(id)
{
	new cim[256];new Sor[6];formatex(cim, charsmax(cim), "\y[S]tunT* \r Szinted:\d %d | \r Tapasztalat: \d %d%% | \rPont: \d %d  ^n\wOldal   \r", Adataim[id][Szint],Adataim[id][Xp],Adataim[id][Pont]);new menu = menu_create(cim, "myknife_handler" );
	
	
	for(new i; i < sizeof(cKesek); i++)
	{
		num_to_str(id, Sor, 5);
		formatex(cim, charsmax(cim),  "%s%s\d %s", Knife[id] == i ? "\y" : "\w", cKesek[i][0], Adataim[id][Szint] >= str_to_num(cKesek[i][3]) ? "\d[\yElerve\d]" : cKesek[i][1]);
		menu_additem(menu, cim, Sor);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_NEXTNAME, "Kovetkezo");
	menu_setprop(menu, MPROP_EXITNAME, "Kilepes");
	menu_setprop( menu, MPROP_PERPAGE, 5);
	menu_display(id, menu, 0);
}
public myknife_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(item == 14)
	{
		if(CuccFentVan[2][id] == true ){
			Knife[id] = item;print_color(id, "!g[S]tunt*!y Sikeres VĂˇlasztĂˇs!");MyKnife(id)
		}
		else{
			print_color(id, "!g[S]tunt*!y Ez csak VIP szamara engedelyezett!");MyKnife(id)
			}
	}
	else if(Adataim[id][Szint] >= str_to_num(cKesek[item][3])){
		Knife[id] = item
		print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!"); 
		MyKnife(id)
	}
	else{
		print_color(id, "!g[S]tunt*!y nincs meg az elegendĹ‘ szint!")
		MyKnife(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public MyLimit(id)
{
	new txt[128],txt1[128];static String[512];formatex(String, charsmax(String), "\y[S]tunT* \r TĂ¶kĂ¶k:\d %d  \w|   \r Hogolyo: \d%d  \w | \rDragako: \d %d \w| \rTojas: \d%d ",Adataim[id][Tok],Adataim[id][Hogolyo],Adataim[id][Dragako],Adataim[id][Tojas]);new menu = menu_create(String, "myly_handler" );
	
	for(new i; i<sizeof(cLimit) ; i++)
	{
		formatex(txt1, charsmax(txt1), "\d[Megszerezve]",limit[i][id])
		formatex(txt, charsmax(txt), "%s%s \r%s",KivalasztottLimit[id] == i ? "\r" : "\w",cLimit[i][0], limit[i][id] >= 1 ? txt1 : cLimit[i][1],limit[i][id])
		menu_additem(menu, txt, "", 0)
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");
	menu_setprop(menu, MPROP_NEXTNAME, "KĂ¶vetkezo");
	menu_setprop(menu, MPROP_EXITNAME, "KilĂ©pĂ©s");
	menu_display(id, menu, 0)
	
}
public myly_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	switch(item){
		case 0: {
			if(limit[item][id] == 0)
			{
				if(Adataim[id][Tok] >= str_to_num(cLimit[item][3]))
				{
					
					print_color(id, "!gtunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
					limit[item][id]++;
					Adataim[id][Tok] -= str_to_num(cLimit[item][3])
					MyLimit(id)
				}
				else  print_color(id, "!gtunt*!y SajnĂˇlom,de nincs elegendĹ‘ tokod!")  
			}
			else {
				KivalasztottLimit[id] = item;Atvalt[id] = 1 
				print_color(id, "!gtunt*!y Sikeres vĂˇlasztĂˇs")  
				MyLimit(id)
			}
			
		}
		case 1: {
			if(limit[item][id] == 0)
			{
				if(Adataim[id][Hogolyo] >= str_to_num(cLimit[item][3]))
				{
					
					print_color(id, "!gtunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
					limit[item][id]++;
					Adataim[id][Hogolyo] -= str_to_num(cLimit[item][3])
					MyLimit(id)
				}
				else  print_color(id, "!gtunt*!y SajnĂˇlom,de nincs elegendĹ‘ Hogolyod!")  
			}
			else {
				KivalasztottLimit[id] = item;Atvalt[id] = 1 
				print_color(id, "!gtunt*!y Sikeres vĂˇlasztĂˇs")  
				MyLimit(id)
			}
		}
		case 2: {
			if(limit[item][id] == 0)
			{
				if(Adataim[id][Dragako] >= str_to_num(cLimit[item][3]))
				{
					
					print_color(id, "!gtunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
					limit[item][id]++;
					Adataim[id][Dragako] -= str_to_num(cLimit[item][3])
					MyLimit(id)
				}
				else  print_color(id, "!gtunt*!y SajnĂˇlom,de nincs elegendĹ‘ dragakoved!")  
			}
			else {
				KivalasztottLimit[id] = item;Atvalt[id] = 1 
				print_color(id, "!gtunt*!y Sikeres vĂˇlasztĂˇs")  
				MyLimit(id)
			}
		}
		case 3: {
			if(limit[item][id] == 0)
			{
				if(Adataim[id][Tojas] >= str_to_num(cLimit[item][3]))
				{
					
					print_color(id, "!gtunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
					limit[item][id]++;
					Adataim[id][Tojas] -= str_to_num(cLimit[item][3])
					MyLimit(id)
				}
				else  print_color(id, "!gtunt*!y SajnĂˇlom,de nincs elegendĹ‘ tojasod!")  
			}
			else {
				KivalasztottLimit[id] = item;Atvalt[id] = 1 
				print_color(id, "!gtunt*!y Sikeres vĂˇlasztĂˇs")  
				MyLimit(id)
			}
		}
		 
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public MyUsp(id)
{
	new txt[128],txt1[128];static String[512];formatex(String, charsmax(String), "\y[S]tunT* \r Szinted:\d %d | \r Tapasztalat: \d %d%% | \rPont: \d %d  ^n\wOldal   \r", Adataim[id][Szint],Adataim[id][Xp],Adataim[id][Pont]);new menu = menu_create(String, "myusp_handler" );
	
	for(new i; i<sizeof(cUsp) ; i++)
	{
		formatex(txt1, charsmax(txt1), "\d[Megszerezve]",pistol[i][id])
		formatex(txt, charsmax(txt), "%s%s \r%s",kivalasztottUSP[id] == i ? "\r" : "\w",cUsp[i][0], pistol[i][id] >= 1 ? txt1 : cUsp[i][1],pistol[i][id])
		menu_additem(menu, txt, "", 0)
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Vissza");menu_setprop(menu, MPROP_NEXTNAME, "KĂ¶vetkezo");menu_setprop(menu, MPROP_EXITNAME, "KilĂ©pĂ©s");
	menu_display(id, menu, 0)
	
}
public myusp_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(pistol[item][id] == 0)
	{
		if(Adataim[id][Pont] >= str_to_num(cUsp[item][3]))
		{
			megerosit_usp[id] = item
			megerosit_menu(id)
		}
		else  print_color(id, "!g[S]tunt*!y SajnĂˇlom,de nincs elegendĹ‘ pontod!")  
	}
	else {
		kivalasztottUSP[id] = item;Atvalt[id] = 0;KivalasztottLimit[id] = -1
		print_color(id, "!g[S]tunt*!y Sikeres vĂˇlasztĂˇs")  
		MyUsp(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public megerosit_menu(id)
{
	new String[121]
	format(String, charsmax(String), "s[T]* \r- \dUSP-megerosit^n^nBiztosan megszeretnĂ©d venni a \r%s ?^n^n",cUsp[megerosit_usp[id]][0]);
	new menu = menu_create(String, "uspmegvesz_h");
  
	menu_additem(menu, "\rMegvĂˇsĂˇrlĂˇs", "1", 0);
	menu_additem(menu, "\yNem", "0", 0);
	
	menu_display(id, menu, 0);
}
public uspmegvesz_h(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	
	switch(key) 
	{
		case 1:
		{
			print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!",megerosit_usp[id])  
			pistol[megerosit_usp[id]][id]++;
			Adataim[id][Pont] -= str_to_num(cUsp[megerosit_usp[id]][3])
			MyUsp(id)
		}
	}
}
public lekeres(id) {
	new ertek, adatok[32];
	read_args(adatok, charsmax(adatok));
	remove_quotes(adatok);
	
	ertek = str_to_num(adatok);
	
	new hossz = strlen(adatok);
	
	if(hossz > 7){
		client_cmd(id, "messagemode Pont");
	}
	else if(ertek < 100){
		print_color(id, "!g[S]tunt* !yUSP-t !g100 !yPont alatt nem tudsz eladni! ")
		eladas(id);
	}
	else{
		erteke[id] = ertek;
		eladas(id);
	}
}
public eladas(id) 
{
	new ks1[121], ks2[121]
	new menu = menu_create("\y[S]tunT* \d| \yPiac EladĂˇs", "eladas_h" )
	
	if(kirakva[id] == 0)
	{
		for(new i=0; i < MAX; i++)
		{
			if(kicucc[id] == 0) format(ks1, charsmax(ks1), "VĂˇlaszd ki a TĂˇrgyat!");
			else if(kicucc[id] == i) format(ks1, charsmax(ks1), "\wĂru: \r%s ", cUsp[i][0]);
		}
		menu_additem(menu, ks1 ,"0",0);
	}
	if(kirakva[id] == 0)
	{
		format(ks2, charsmax(ks2), "\wĂr: \r%d Pont^n", erteke[id]);
		menu_additem(menu,ks2,"1",0);
	}
	if(erteke[id] != 0 && kirakva[id] == 0)
	{
		menu_additem(menu,"\yKirakĂˇs","2",0);
	}
	if(erteke[id] != 0 && kirakva[id] == 1)
		menu_additem(menu,"\wLevĂ©tel a piacrĂłl!","-2",0);
	
	
	
	menu_setprop(menu, MPROP_EXITNAME, "KilĂ©pĂ©s");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	
}
public eladas_h(id, menu, item){
	
	if(item == MENU_EXIT ) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[9], szName[64], name[32]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	get_user_name(id, name, charsmax(name))
	new key = str_to_num(data);
	
	switch(key)
	{
		case -2:{
			kirakva[id] = 0
			kicucc[id] = 0
			erteke[id] = 0
		}
		case 0:{
			targyatvalaszt(id)
		}
		case 1:{
			client_cmd(id, "messagemode Pont")
		}
		case 2:{
			if(kicucc[id] >= 1 && kicucc[id] <= 18)
			{
				print_color(0, "!g[S]tunt* !t%s !ykirakott egy  !g%s!y-t a Piacra %i !yPontĂ©rt.../piac",get_player_name(id), cUsp[kicucc[id]][5], erteke[id])
				kirakva[id] = 1
			}
			else if(kicucc[id] == 0){
				print_color(id, "!g[S]tunt* !y Ezt nem rakhatod ki a piacra.")
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public targyatvalaszt(id)
{
	new szMenu[121], String[6]
	new menu = menu_create("\y[S]tunT* \d| \yPiac VĂˇlassz egy tĂˇrgyat", "fvalaszt_h")
	
	for(new i ; i < sizeof(cUsp); i++)
	{
		if(pistol[i][id] > 0)
		{
			num_to_str(i, String, 5);
			formatex(szMenu, charsmax(szMenu), "%s \r%i DB", cUsp[i][0], pistol[i][id]);
			menu_additem(menu, szMenu, String);
		}
	}
	
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}
public fvalaszt_h(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	
	kicucc[id] = key
	
	eladas(id)
	return PLUGIN_HANDLED
}
public vasarlas(id)
{		
	new mpont[512], menu, cim[121],temp[32], g_Maxplayers = get_maxplayers();
	
	format(cim, charsmax(cim), "\y[S]tunT* \d| \yPiac ^n\rPont: \d%i", Adataim[id][Pont])
	menu = menu_create(cim, "piac_h" )

	if(kirakva[id] == 1 && erteke[id] > 0)
		format(mpont, charsmax(mpont), "\ySajĂˇt kirakatom \r| \d%s \r| \y%d P.^n",cUsp[kicucc[id]][5], erteke[id]);
	else
		format(mpont, charsmax(mpont), "\ySajĂˇt kirakatom \r| \dSemmi \r| \y0 Pont^n");
	menu_additem(menu,mpont,"-1");
    
	for(new i; i < g_Maxplayers; i++){
		if(!is_user_connected(i))
			continue;

		if(!kirakva[i])
			continue;  	
		if(id == i)
			continue;	

		num_to_str(i, temp, charsmax(temp)); 
		format(mpont,charsmax(mpont),"\w%s \r| \d%s \r| \y%d Pont", get_player_name(i),cUsp[kicucc[i]][5], erteke[i]);	
		menu_additem(menu,mpont,temp, 0);	
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "KilĂ©pĂ©s")
	menu_setprop(menu, MPROP_BACKNAME, "Vissza")
	menu_setprop(menu, MPROP_NEXTNAME, "TovĂˇbb")	
	menu_display(id, menu, 0); 
	return PLUGIN_HANDLED

}
public piac_h(id,menu, item){
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[6] ,szName[64],access,callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	new player = str_to_num(data);
	
	if(player == -1) //Ha az elso menüpontot választjuk, akkor kidobja az eladás menüt.
	{
		eladas(id);
		return PLUGIN_HANDLED
	}
	
	new name[32],name2[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(player, name2, charsmax(name2))
	
	
	if(kicucc[player] >= 1 && kicucc[player] <= 18 && Adataim[id][Pont] >= erteke[player] && kirakva[player] == 1)
	{
		kirakva[player] = 0
		print_color(0, "!g[S]tunt*!t %s !yvett egy !g%s-t !t%s!y-tĂłl %i PontĂ©rt.../piac",name, cUsp[kicucc[player]][5], name2, erteke[player])
		Adataim[player][Pont] += erteke[player]
		Adataim[id][Pont] -= erteke[player]
		erteke[player] = 0
		pistol[kicucc[player]][id]++
		pistol[kicucc[player]][player]--
		if(pistol[kicucc[player]][player] < 1)
		{
			kivalasztottUSP[player] = 0
		}
		kicucc[player] = 0
	}
	else if(Adataim[id][Pont] < erteke[player])
	{
		print_color(id, "!g[S]tunt*!ySajnos nincs elĂ©g pontod.")
		vasarlas(id)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
public MyVip( id ) 
{
	new cim[121], Text[1337]
	new iMasodperc, iPerc, iOra , iNap
	format(cim, charsmax(cim), "\r[S]tunT*\d VIP \rPontjaim: \d%d", Adataim[id][Pont])
	new menu = menu_create(cim, "vip_ha" )
	
	if(CuccFentVan[2][id] == false)
		menu_additem(menu, "\wVip vĂˇsĂˇrlĂˇs | 1.000 Pont \y(5 nap)^n", "0", 0)
	
	if(CuccFentVan[2][id] == true)
		iMasodperc = (VipIdo[id]-get_systime())
	iPerc = iMasodperc / 60
	iOra = iPerc / 60
	iMasodperc = iMasodperc - iPerc * 60
	iPerc = iPerc - iOra * 60
	
	if((iOra / 24) >0) 
	{
		iNap = iOra / 24
		iOra -= iNap*24
	}
	else  iNap = 0
	
	
	format(Text,charsmax(Text),"VIP Aktiv: \w( \r%2d \d nap \w|  \r%2d\d Ăłra \w| \r%02d\d perc \w)^n",iNap ,iOra, iPerc)
	menu_additem(menu, Text, "3", 0)
	
	
	
	formatex(Text, 125, "\wMit tud a vip?^n^n\d Orokos VIP ara: 1000FT / Banki atutalas")
	menu_additem(menu, Text, "1")
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;	
}

public vip_ha(id, menu, item)
{
	if( item == MENU_EXIT ){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[9], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	new name[33]
	get_user_name(id, name, charsmax(name))
	
	switch(key){
		case 0:{
			if(Adataim[id][Pont] >= 1000 &&CuccFentVan[2][id] == false)
			{
				VipIdo[id] = get_systime()+60*60*24*5 // 5 nap
				CuccFentVan[2][id] = true 
				Adataim[id][Pont] -= 1000
				
				new Nev[32]
				get_user_name(id, Nev, 31)
				print_color(0, "!g[S]tunt*!t %s!y megvette a VIP-t a szerveren.",Nev)
			}
			else{
				print_color(id, "!g[S]tunt*!y Nincs elĂ©g pontod.")
			}
		}
		case 1:{
			show_motd(id,"addons/amxmodx/configs/vip.txt","Mit tud a vip?")
		}
		case 2:MyVip(id)
		}
	menu_destroy(menu)
	return PLUGIN_HANDLED
} 
public SwitchGuns(id) 
{
	
	new Arma = read_data( 2 )
	
	new palya[32]
	get_mapname(palya, charsmax(palya))
	
	if(equal("stunt_event", palya))
	{
		if(Arma == CSW_KNIFE)
		{
			set_pev( id, pev_viewmodel2, v_Knife_Admin )
			set_pev( id, pev_weaponmodel2, p_Knife_Admin )
		}
		else  
		{
			set_pev( id, pev_viewmodel2, v_Knife_Admin )
			set_pev( id, pev_weaponmodel2, p_Knife_Admin )
		}
	}
	
	
	switch(get_user_weapon(id))
	{
	 
		case CSW_KNIFE:{
			
			if(Atvalt[id] == 0 || Atvalt[id] == 1)
			{
				set_pev(id, pev_viewmodel2, cKesek[Knife[id]][2]);
				set_user_maxspeed(id, str_to_float(cKesek[Knife[id]][4]))
				set_user_gravity(id, str_to_float(cKesek[Knife[id]][5]))
			}
		}
		case CSW_USP: {
			
			if(Atvalt[id] == 0){
				set_pev(id, pev_viewmodel2, cUsp[kivalasztottUSP[id]][2])
				set_user_maxspeed(id, 250.0)
				set_user_gravity(id, 1.0)
			}
			else if(Atvalt[id] == 1)
			{
				set_pev(id, pev_viewmodel2, cLimit[KivalasztottLimit[id]][2])
				set_user_maxspeed(id, 250.0)
				set_user_gravity(id, 1.0)
			}
		}
		 
	}
}
public csere(id)
{
	if (is_user_alive(id))
	{
		if (cs_get_user_team(id) == CS_TEAM_CT)
		{
			cs_set_user_model(id, "stunt_event")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
public plugin_precache(){
	for(new i = 0; i < sizeof(cKesek); i++)
		precache_model(cKesek[i][2])
	
	for(new i = 0; i < sizeof(cUsp); i++)
		precache_model(cUsp[i][2])
	
	for(new i = 0; i < sizeof(cLimit); i++)
		precache_model(cLimit[i][2])
	
	for(new i = 0; i < MAX_KNIFE_SNDS; i++)
		precache_sound(knife_sounds_r[i]);
	
	for(new i = 0; i < MAX_KNIFELEVI_SNDS; i++)
		precache_sound(knife_levi_r[i]);
	
	precache_model("models/player/stunt_event/stunt_event.mdl")
	precache_model( v_Knife_Admin )
	precache_model( p_Knife_Admin )
	
	tutorPrecache()
}
public RoundEnd(id)
{
	new jatekos[32], pnum
	get_players(jatekos, pnum, "c" )
	
	for (new i; i < pnum; i++)
		Adataim[jatekos[ i ]][Ujra] = 0
}
public g_UdvozloHud(id)
{
	new client_name[33];
	get_user_name(id, client_name, 32);
	set_hudmessage(random_num(0,255),random_num(0,255),random_num(0,255),-1.0,-1.0, 0, 0.1, 1.0, 0.1, 10.0);
	show_hudmessage(id, "Szia %s!^nĂ‰rezd magad jĂłl a szerveren, Ă©s jĂł jĂˇtĂ©kot!^nFacebook Csoport: www.facebook.com/groups/peaceserver^nSzerver menu: [ M ]", client_name);
}
public client_putinserver(id)
{
	if(!is_user_bot(id))
	{
		kivalasztottUSP[id] = 0
		Knife[id] = 0
		KivalasztottLimit[id] = 0 
	}
	
	 
	set_task(1.0, "g_UdvozloHud", id)
	
	set_task(300.0, "ot_perc", id)
	set_task(600.0, "tiz_perc", id)
	set_task(1200.0, "husz_perc", id)
	
}
public client_disconnected(id)
{
	if(task_exists(id+1945))
		remove_task(id+1945)
	
	if(is_user_logged(id))	
		sql_update_account(id)
		
	 
	kivalasztottUSP[id] = 0;
	KivalasztottLimit[id] = -1;
	Knife[id] = 0;
	kicucc[id] = 0;
	kirakva[id] = 0;
	 
}
public IdoEllenorzes()
{
	new Jatekos[32], Szam, id
	get_players(Jatekos, Szam, "c") //Lekérjük a játékosok aát
	
	for(new i; i < Szam; i++){
		id = Jatekos[i]
		
		if(is_user_connected(id))
		{
			if(get_systime() >= PontIdo[id] && CuccFentVan[0][id] ) 
			{
				PontIdo[id] = 0 
				CuccFentVan[0][id] = false 
				
				new Nev[32]
				get_user_name(id, Nev, 31)
				print_color(0, "!g[S]tunt*!t %s !y-nek lejĂˇrt a !gdupla Pont!y tagsĂˇga.", Nev)  
			}
			else if(get_systime() >= XpIdo[id] && CuccFentVan[1][id] ) 
			{
				XpIdo[id] = 0 
				CuccFentVan[1][id] = false 
				
				new Nev[32]
				get_user_name(id, Nev, 31)
				print_color(0, "!g[S]tunt*!t %s !y-nek lejĂˇrt a !gdupla XP!y tagsĂˇga.", Nev)  
				
			}
			else if(get_systime() >= VipIdo[id] && CuccFentVan[2][id] && megkapva[id] == 1) 
			{
				VipIdo[id] = 0 
				CuccFentVan[2][id] = false 
				megkapva[id] += 2
				
				new Nev[32]
				get_user_name(id, Nev, 31)
				print_color(0, "!g[S]tunt*!t %s !y-nek lejĂˇrt a !gVIP!y tagsĂˇga.", Nev)  				
			}
			
		}
	}
}
public plugin_cfg()
{    
	g_SqlTuple = SQL_MakeDbTuple(SQL_INFO[0],SQL_INFO[1],SQL_INFO[2],SQL_INFO[3]) 
}
public sql_table_create_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
		return 
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
		return 
	}
	
	if(Errcode)
	{
		log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
		return 
	}
	
	return
}
public Load(id){
	new szQuery[2048]
	new len = 0
	
	len += format(szQuery[len], 2048, "SELECT * FROM habile_deathrun ")
	len += format(szQuery[len], 2048-len,"WHERE `Id` = %d;", get_user_id(id))
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_account_load_thread", szQuery, szData, 2)
}

public sql_account_load_thread(FailState,Handle:Query,Error[],Errcode,szData[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED){
		log_amx("%s", Error)
		return
	}
	else
	{
		new id = szData[0];
		
		if (szData[1] != get_user_userid(id))
			return ;

		Adataim[id][Szint] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Szint"));
		Adataim[id][Xp] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Xp"));
		Adataim[id][Pont] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Pont"));
		Adataim[id][Elet] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Elet"));
		Knife[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Knife"));
		kivalasztottUSP[id] =SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kivalasztott"));
		KivalasztottLimit[id] =SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Kivalasztott1"));
		Adataim[id][Lada] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Lada"));
		PontIdo[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "PontIdo"));
		XpIdo[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "XpIdo"));
		VipIdo[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "VipIdo"));
		//LevasarolhatoAdataim[id][Pont] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Levasarlas"));
		Adataim[id][Doboz] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Doboz"));
		g_Perc[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Perc"));
		Adataim[id][Olesek] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Oles"));
		megkapva[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Megkapva"));

 		Adataim[id][Tok] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tokok"));
		Adataim[id][Hogolyo] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Hogolyo"));
		Adataim[id][Dragako] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Dragako"));
		Adataim[id][Tojas] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Tojas"));
		 
		new  aMod
		aMod = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "aMod"));
		
		if(aMod > 0)
		{
			set_user_flags(id, read_flags(adminjogok[aMod]))
			print_color(id, "!g[S]tunt* !ySikeresen bejelentkeztel az adminodba | Jogok: !g%s!y",adminjogok[aMod])
			set_user_rendering(id,kRenderFxGlowShell,0,255,255,kRenderNormal,0)
			GreenScreen();
		}
		
	
		new palya[64]
		get_mapname(palya,63)
		palya[0] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "Palya"));
			
		if(PontIdo[id] > 0)
			CuccFentVan[0][id] = true
		if(XpIdo[id] > 0)
			CuccFentVan[1][id] = true
		if(VipIdo[id] > 0)
			CuccFentVan[2][id] = true
			
		for(new i;i < MAX; i++)
		{
			new String[64];
			formatex(String, charsmax(String), "Usp%d", i);
			pistol[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
		}
			
		for(new i;i < Limit_MAX; i++)
		{
			new String[64];
			formatex(String, charsmax(String), "Limit%d", i);
			limit[i][id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, String));
		}
			
		Kapcsolo[0][id] = 1
		cs_set_user_money(id, Adataim[id][Pont], 0)			
		
		Knife[id] = 0
		kivalasztottUSP[id] = 0
		KivalasztottLimit[id] = -1
		get_logged(id);
	}
}

public Logined(id){
	if(CuccFentVan[2][id] == true){
			new Nev[32]
			get_user_name(id, Nev, 31)
			tutorMake(0 ,TUTOR_GREEN,5.0,"' %s '   -  (VIP tag) bejelentkezett!",Nev) 
			client_cmd(0, "spk ^"sound/events/tutor_msg.wav^"");
			megkapva[id]++ 
	}
	BlackScreen(id)
	set_task(2.0, "ShowHud", id+1945, _, _, "b")
	
	if(Adataim[id][Xp] >= 100)
	{
			Adataim[id][Szint]++
			Adataim[id][Xp] -= 100
	}
	
	if(CuccFentVan[2][id] == false && megkapva[id] == 0)
	{
		VipIdo[id] = get_systime() + 7*24*60*60 // 1 het masodpercekben
		CuccFentVan[2][id] = true  
	
		new Nev[32]
		get_user_name(id, Nev, 31)
		print_color(0, "!g[S]tunt*!t %s!y kapott4 !g7!y nap ingyenes !gVIP!y-t .",Nev)
		print_color(id, "!g[S]tunt*!y Azért kaptad a !gVIP!y-t mert a szerver 3 napig nem futott, és kárpótlásul.")
		megkapva[id]++
	}
}
public sql_update_account(id){	
	new szQuery[2508]
	new len = 0
	new palya[64]
	get_mapname(palya,63)
 
	
	new c[191]
	new client_name[33]
	get_user_name(id, client_name, 32)
	
	format(c, 190, "%s", client_name)
	replace_all(c, 190, "\", "\\")
	replace_all(c, 190, "'", "\'") 
	
	len += format(szQuery[len], 2508, "UPDATE habile_deathrun SET ")
	len += format(szQuery[len], 2508-len,"Szint = '%d', ", Adataim[id][Szint])
	len += format(szQuery[len], 2508-len,"Xp = '%d', ", Adataim[id][Xp])
	len += format(szQuery[len], 2508-len,"Pont = '%d', ", Adataim[id][Pont])
	len += format(szQuery[len], 2508-len,"Elet = '%d', ", Adataim[id][Elet])
	len += format(szQuery[len], 2508-len,"Knife = '%d', ", Knife[id])
	len += format(szQuery[len], 2508-len,"Kivalasztott = '%d', ", kivalasztottUSP[id])
	len += format(szQuery[len], 2508-len,"Kivalasztott1 = '%d', ", KivalasztottLimit[id])
	len += format(szQuery[len], 2508-len,"Lada = '%d', ", Adataim[id][Lada])
	len += format(szQuery[len], 2508-len,"PontIdo = '%d', ", PontIdo[id])
	len += format(szQuery[len], 2508-len,"XpIdo = '%d', ", XpIdo[id])
	len += format(szQuery[len], 2508-len,"VipIdo = '%d', ", VipIdo[id])
	//len += format(szQuery[len], 2508-len,"Levasarlas = '%d', ", LevasarolhatoAdataim[id][Pont])
	len += format(szQuery[len], 2508-len,"Doboz = '%d', ", Adataim[id][Doboz])
	len += format(szQuery[len], 2508-len,"Perc = '%d', ", g_Perc[id])
	len += format(szQuery[len], 2508-len,"Oles = '%d', ", Adataim[id][Olesek])
	len += format(szQuery[len], 2508-len,"Megkapva = '%d', ", megkapva[id])
	
	len += format(szQuery[len], 2508-len,"Tokok = '%d', ", Adataim[id][Tok])
	len += format(szQuery[len], 2508-len,"Hogolyo = '%d', ", Adataim[id][Hogolyo])
	len += format(szQuery[len], 2508-len,"Dragako = '%d', ", Adataim[id][Dragako])
	len += format(szQuery[len], 2508-len,"Tojas = '%d', ", Adataim[id][Tojas])
	
	len += format(szQuery[len], 2508-len,"Palya = '%s', ", palya)
	
	for(new i;i < MAX; i++)
		len += formatex(szQuery[len], charsmax(szQuery)-len, "Usp%d = ^"%i^", ", i, pistol[i][id]);
	
	for(new i;i < Limit_MAX; i++)
		len += formatex(szQuery[len], charsmax(szQuery)-len, "Limit%d = ^"%i^", ", i, limit[i][id]);

	len += format(szQuery[len], 2508-len,"Jatekosnev = '%s'", c)
	len += format(szQuery[len], 2508-len,"WHERE Id = '%d'", get_user_id(id))
	
		
	new Data[2];
	
	Data[0] = id;
	Data[1] = get_user_userid(id);
	
	SQL_ThreadQuery(g_SqlTuple,"sql_update_account_thread", szQuery, Data, 2)
}


public sql_update_account_thread(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("[ *HIBA* ] NEM LEHET KAPCSOLODNI AZ ADATBAZISHOZ!")
	else if(FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("[ *HIBA* ] A LEKERDEZES MEGSZAKADT!")
	
	if(Errcode)
		return log_amx("[ *HIBA* ] PROBLEMA A LEKERDEZESNEL! ( %s )",Error)
	
	new id = Data[0]
	
	if(Data[1] != get_user_userid(id))
		return PLUGIN_HANDLED;
	
	return PLUGIN_HANDLED;
	
 
}
public BlackScreen(id)
{
	if(is_user_logged(id))
	{
		message_begin(MSG_ONE, 98, {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255) // szín erőssége ( 255 = maximum, 0 = átlátszó )
		message_end() 
	}
	else
	{
		message_begin(MSG_ONE, 98, {0,0,0}, id)
		write_short(1<<12)
		write_short(1<<12)
		write_short(0x0004)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		message_end()
		 
    }
}
public GreenScreen() //iar asta o pui toata sub public Alegeri(id) sau oriunde vrei mai jos
{

	new players[32], num, id;
	get_players(players, num);

	for(new i = 0 ; i < num ; i++)

	{
		id = players[i];
  		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
   		write_short(1<<10)
   		write_short(1<<10)
   		write_short(0x0000)
   		write_byte(0) // rosu
   		write_byte(200) // verde
   		write_byte(0) // albastru
   		write_byte(75)// contrast
   		message_end();
	}
}
public autoSave()
{
	new players[32], pnum, id
	get_players(players, pnum)
	
	for(new i; i<pnum; i++)
	{
		id = players[i]
		if(is_user_logged(id)) 
			set_task(random_float(0.2, 5.0), "sql_update_account", id)
	}
	return PLUGIN_HANDLED
}

public handlesay(id)
{
	new message[192], alive[16], msgc[4];
	new strName[191], strText[191];
	read_args (message, 191)
	remove_quotes (message)
	new MsG = strlen(message);
	
	new args[64]
	
	read_args(args, charsmax(args))
	remove_quotes(args)
	
	new arg1[16]
	new arg2[32]
	
	strbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2))
	
	if (equal(arg1,"/ujra", 7))
	{
		if(!is_user_alive( id ))
			if(Adataim[id][Ujra]< 2){
			if(Adataim[id][Elet] >= 1 && get_user_team(id) != 3) {
			ExecuteHam(Ham_CS_RoundRespawn, id)
			Adataim[id][Elet] -=1
			Adataim[id][Ujra] +=1
			print_color(id, "!g[S]tunt*!y !t-1!y Ă©let")
		}
		}
	}
	
	
	if (equal(arg1,"/elet", 7))
		print_color(id, "!g[S]tunt*!y !t%d!y Ă©leted van mĂ©g.",Adataim[id][Elet])
	
	if (equal(arg1,"/szabaly", 7))
		show_motd(id,"addons/amxmodx/configs/szabaly.txt","Szabalyzat")
	
	if (equal(arg1,"/ts3", 7))
		print_color(id, "!g[S]tunt*!y TeamSpeak3 IP: !t164.132.201.166:10021")
	
	if (equal(arg1,"/id", 7))
		print_color(id, "!g[S]tunt*!y Id: %d",get_user_id(id));
	
	new i = 0;msgc[0] = 0;msgc[1] = 0;msgc[2] = 0;msgc[3] = 0; 

	
	while(i<MsG){
		if(message[i] == '.')
			msgc[1] ++;
		if(message[i] == ':')
			msgc[2] ++;
		if(message[i] == '1' || message[i] == '2' || message[i] == '3' || message[i] == '4' || message[i] == '5'
		|| message[i] == '6' || message[i] == '7' || message[i] == '8' || message[i] == '9' || message[i] == '0')
		msgc[0] ++;
		
		++i;
	}
	
	if((contain(message, "www.") != -1)|| (contain(message, "http://") != -1)|| (contain(message, "smmg.hu") != -1)|| (contain(message, "diwat26.hu") != -1)|| (contain(message, "magyaronlydust2.com") != -1))
	msgc[3] = 1;
	
	if((msgc[1] >= 3 && msgc[2] >= 1 && msgc[0] >= 5) || (msgc[3])){
		print_color(id, "!g[S]tunt*!y Tilos a Hirdetes!")
		return PLUGIN_HANDLED;
	}
	
	if (message[0] == '@' || equal (message, "") || message[0] == '/' )//|| !is_user_logged(id))
	
	return PLUGIN_HANDLED;
	
	new name[32];
	get_user_name (id, name, 31);
	
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	if (is_user_alive(id))
		alive = "^x01"
	else
		alive = "^x01*Halott* "
	
		
		 
	if(!is_user_logged(id)){
		format (strName, 191, "%s^x04[Nincs Bejelentkezve]^x03 %s", alive, name)
		format (strText, 191, "^x01%s", message)
	}
	else if(get_user_flags(id)&ADMIN_IMMUNITY){
		format (strName, 191, "%s^x04[KĂĽlĂ¶nleges][Rendszergazda][Lv%d]^x03 %s ", alive,Adataim[id][Szint], name)
		format (strText, 191, "^x04%s", message)
	} 
	else if(get_user_flags(id)&ADMIN_IMMUNITY && CuccFentVan[2][id] == true){
		format (strName, 191, "%s^x04[KĂĽlĂ¶nleges][Rendszergazda][%s][VIP][Lv%d]^x03  %s", alive,Adataim[id][Szint], name)
		format (strText, 191, "^x04%s", message)
	} 
	else if(get_user_flags(id)&ADMIN_KICK){
		format (strName, 191, "%s^x04[Admin][Lv%d]^x03 %s", alive, Adataim[id][Szint], name)
		format (strText, 191, "^x04%s", message)
	}  
	else if(get_user_flags(id)&ADMIN_KICK && CuccFentVan[2][id] == true){
		format (strName, 191, "%s^x04[Admin][VIP][Lv%d]^x03 %s", alive,  Adataim[id][Szint], name)
		format (strText, 191, "^x04%s", message)
	}     
	else if(CuccFentVan[2][id] == true)
	{
		format (strName, 191, "%s^4%s[Lv%d]^3%s:", alive, CuccFentVan[2][id] == true ? "[Vip]" : "" ,Adataim[id][Szint], name)
		format (strText, 191, "^4%s", message)
	}
	else {
		format (strName, 191, "%s^x04[Lv%d]^x03 %s", alive,Adataim[id][Szint], name)
		format (strText, 191, "^x01%s", message)
	}
	format (message, 191, "%s: %s", strName, strText)
	
	new players[32], pnum, is;
	get_players(players, pnum);
	
	for(new i; i<pnum; i++)
	{
		is = players[i];
		
		if(cs_get_user_team(id) == CS_TEAM_CT)
			ColorChat(is, BLUE, message)
		else if(cs_get_user_team(id) == CS_TEAM_T)
			ColorChat(is, RED, message)
		else
			ColorChat(is, GREY, message)
	}
	
	return PLUGIN_HANDLED;
}
public client_connect(id) 
{
	if(is_user_bot(id) || is_user_hltv(id))
	{
		server_cmd("kick #%i",get_user_userid(id))
	}
}
stock get_player_name(id){
	static name[32]
	get_user_name(id,name,31)
	return name
}
public remove(ent, id){
	if(is_user_alive(id)) 
	{
		new nev[32]
		get_user_name(id, nev, 31);Adataim[id][Lada]++;
		print_color(0, "!g[s]T*!t %s!y talĂˇlt!t +1!y Lada-t.", nev)
	}
	return PLUGIN_HANDLED
}
public remove1(ent, id){
	if(is_user_alive(id)) {
		new nev[32]
		get_user_name(id, nev, 31);
		Adataim[id][Xp]+= 5;
		print_color(0, "!g[s]T* |EVENT|*!t %s!y talĂˇlt!t +5%!y XP-t.", nev)
		
	}
	return PLUGIN_HANDLED
}
public remove2(ent, id){
	if(is_user_alive(id)) {
		new nev[32]
		get_user_name(id, nev, 31);Adataim[id][Pont]+= 5;
		print_color(0, "!g[s]T* |EVENT|*!t %s!y talĂˇlt!t +5!y Pontot.", nev)
	}
	return PLUGIN_HANDLED
}
public ot_perc(id)
{
	static ora[5]
	format_time(ora, sizeof(ora) - 1, "%H")
 
	new ido = str_to_num(ora)
 
	if(get_user_team(id) != 3 && ido >= 18 && ido < 22)
	{
		Adataim[id][Pont] += 5;
		print_color(id, "!g*[Event]*!y KaptĂˇl !g+5!y Pontot, mert mĂˇr 5 perce a szerveren vagy.")
	}
}
public tiz_perc(id)
{
	static ora[5]
	format_time(ora, sizeof(ora) - 1, "%H")
 
	new ido = str_to_num(ora)
	
	if(get_user_team(id) != 3 && ido >= 18 && ido < 22)
	{
		Adataim[id][Pont] += 10;
		print_color(id, "!g*[Event]*!y KaptĂˇl !g+10!y Pontot, mert mĂˇr 10 perce a szerveren vagy.")
	}
}
public husz_perc(id)
{
	static ora[5]
	format_time(ora, sizeof(ora) - 1, "%H")
 
	new ido = str_to_num(ora)
	
	if(get_user_team(id) != 3 && ido >= 18 && ido < 22){
		Adataim[id][Pont] += 20;
		print_color(id, "!g*[Event]*!y KaptĂˇl !g+20!y Pontot !y, mert mĂˇr 20 perce a szerveren vagy.")
	}
}

public msgScoreAttrib( const MsgId, const MsgType, const MsgDest ) 
{
	static id;
	id = get_msg_arg_int( 1 );
	
	if( ( !CuccFentVan[2][id] == false ) && ( get_user_team( id ) == 2 || 3 ) && !get_msg_arg_int( 2 ))
		set_msg_arg_int( 2, ARG_BYTE, ( 1 << 2 ) );
}  
stock print_color(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[2048]
	vformat(msg, 2047, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}
	return PLUGIN_HANDLED
}


public Levasarlas(id)
{
	new txt[1006]
	
	
	new menu = menu_create("\r[S]tunT*  \rLevasarolhato Pontok *  \dBy: The Peace / Levii", "szerencse_h");
	
	formatex(txt, charsmax(txt), "\wĂ–rĂ¶kĂ¶s VIP: \r15  \yST Pont")
	menu_additem(menu, txt, "0", 0)
	formatex(txt, charsmax(txt), "\w+3.000 Pont: \r30  \yST Pont" )
	menu_additem(menu, txt, "0", 0)
	formatex(txt, charsmax(txt), "\w+5 Napig dupla Pont: \r10  \yST Pont" )
	menu_additem(menu, txt, "2", 0)
	formatex(txt, charsmax(txt), "\w+5 Napig dupla XP: \r10  \yST Pont" )
	menu_additem(menu, txt, "3", 0)
	
	formatex(txt, charsmax(txt), "\wPrefix: \r15 \yST Pont ^n^n\dST Pontjaid: \r0 ^n\dĂrak:  30 ST Pont (BankĂˇrtya) = 700 ft")
	menu_additem(menu, txt, "0", 0)
	
	menu_display(id, menu, 0);
}

public szerencse_h(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[9], access, callback, szName[64]
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 0: 
		{
			/*
			if(LevasarolhatoAdataim[id][Pont] >= 15 )
			{
				LevasarolhatoAdataim[id][Pont]-= 15;
				
			}
			else{
				print_color(id, "!g[S]tunt*!y Sajnos nincs elegenedĹ‘ ST pontod! vĂˇsĂˇrlĂˇs: !t/ts3")  
			}  
		}
		case 1: 
		{
			if(LevasarolhatoAdataim[id][Pont] >= 30)
			{
				LevasarolhatoAdataim[id][Pont]-= 30;
				Adataim[id][Pont] += 3000
				print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
			}
			else{
				print_color(id, "!g[S]tunt*!y Sajnos nincs elegenedĹ‘ ST pontod! vĂˇsĂˇrlĂˇs: !t/ts3")  
			}  
		}
		case 2: 
		{
			if(LevasarolhatoAdataim[id][Pont] >= 10)
			{
				LevasarolhatoAdataim[id][Pont]-= 10;
				PontIdo[id] = get_systime()+60*60*24*5
				print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
				tutorMake(id,TUTOR_GREEN,5.0,"+5 nap (Dupla Pont)") 
				
			}
			else{
				print_color(id, "!g[S]tunt*!y Sajnos nincs elegenedĹ‘ ST pontod! vĂˇsĂˇrlĂˇs: !t/ts3")  
			}  
		}
		case 3: 
		{
			if(LevasarolhatoAdataim[id][Pont] >= 10)
			{
				LevasarolhatoAdataim[id][Pont]-= 10;
				XpIdo[id] = get_systime()+60*60*24*5
				print_color(id, "!g[S]tunt*!y Sikeres vĂˇsĂˇrlĂˇs!")  
				tutorMake(id,TUTOR_GREEN,5.0,"+5 nap(XP Pont)") 
				
			}
			else{
				print_color(id, "!g[S]tunt*!y Sajnos nincs elegenedĹ‘ ST pontod! vĂˇsĂˇrlĂˇs: !t/ts3")  
			}  
			*/
		}
		
	}
	return PLUGIN_HANDLED
}
Make_BarTime2(id, iSeconds, iPercent){
	message_begin(MSG_ONE_UNRELIABLE, gmsgBarTime2, _, id)
	write_short(iSeconds)
	write_short(iPercent)
	message_end()
}

