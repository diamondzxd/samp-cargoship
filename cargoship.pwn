//  original script by kyle, edited by TheGamer and diamondzxd
//  mapping credits - Sursai_Kosecksi

// was briefly used in pilots life samp server.

// script made



#include <a_samp>
#include <zcmd>
#include "../include/gl_common.inc" // for PlaySoundForPlayersInRange()
#include "../include/color.inc"
#include <streamer>

#define SHIP_HULL_ID          	10230 // massive cargo ship's hull. This is used as the main object
#define SHIP_MOVE_SPEED         20.0
#define SHIP_DRAW_DISTANCE      500.0



#define dialog_route            1500
#define dialog_control          1501


new CurrentRouteID = 0;
new CurrentRoutePoint = 0;

new CurrentShipState = 0;
/*
0 = finished
1 = moving
2 = paused
*/

new Max_Selected_Route_Points = 0;

new UseArrayPoint = 0;



new Float:gShipHullOrigin[6] =
{3066.67, 399.98, 679.9, 0.0, 0.0, 0.0 }; // so we can convert world space to model space for attachment positions

enum AttachmentInfo
{
	objectID,
	Float:Ox,
	Float:Oy,
	Float:Oz,
	Float:rx,
	Float:ry,
	Float:rz,
};
enum RouteInfo
{
	RouteID,
	RoutePoint,
	Float:RX,
	Float:RY,
	Float:RZ,
	Float:RR,
};

enum RouteNames
{
	RouteID,
	RouteName[32],
};


new RouteNameList[][RouteNames] = {
{1, "Alcatraz Bayside - PLR HQ"}

};
// these are world space positions used on the original cargo ship in the game
// they will be converted to model space before attaching
new gShipAttachmentPos[][AttachmentInfo] = {
{19333, 	3108.8, 	398.6, 		686.391, 	0.0, 		0.0, 		0.0			},
{1683, 		3113.0, 	397.14, 	678.313, 	0.0, 		0.0, 		180.0		},
{19333, 	3108.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3098.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3088.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3078.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3068.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3058.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{19333, 	3048.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{9558, 		3066.88, 	408.784, 	688.419, 	90.06, 		-1.02,		12.2905		},
{10231, 	3065.76, 	398.47, 	681.36, 	0.0, 		0.0, 		0.0			},
{19333, 	3118.46, 	398.6, 		706.0, 		0.0, 		-90.0, 		0.0			},
{9558, 		3066.88, 	388.0, 		688.419, 	90.06, 		-1.02, 		192.29		},
{19333, 	3089.46, 	398.6, 		706.0, 		0.0, 		90.0, 		0.0			},
{3115, 		3026.63, 	398.481, 	684.02, 	0.0, 		0.0, 		180.0		},
{3115, 		3090.0, 	398.481, 	684.02, 	0.0, 		0.0, 		0.0			},
{3115, 		3068.87, 	398.481, 	684.02, 	0.0, 		0.0, 		0.0			},
{3115, 		3047.74, 	398.481, 	684.02, 	0.0, 		0.0, 		0.0			},
{1681, 		3028.0, 	406.8, 		676.481, 	0.0, 		0.0, 		90.0		},
{1681, 		3028.0, 	390.3, 		676.481, 	0.0, 		0.0, 		90.0		},
{10140, 	3081.38, 	398.93, 	680.05, 	0.0, 		0.0, 		0.0			},
{18694, 	3126.52, 	395.258,	675.317, 	0.0, 		0.0, 		-90.0		},
{18694, 	3131.07, 	398.503, 	675.144, 	0.0, 		0.0, 		-90.0		},
{18694, 	3126.62, 	401.928, 	675.342, 	0.0, 		0.0, 		-90.0		},
{3526, 		3016.89, 	407.398, 	684.302, 	0.0, 		0.0, 		0.0			},
{3526, 		3016.63, 	389.523, 	684.308, 	0.0, 		0.0, 		0.0			},
{1215, 		3111.62, 	388.574, 	683.58, 	0.0, 		0.0, 		0.0			},
{1215, 		3111.61, 	408.564, 	683.579, 	0.0, 		0.0, 		0.0			},
{18656, 	3009.0, 	398.6, 		678.4, 		0.0, 		0.0, 		90.0		},
{18657, 	3017.57, 	389.85, 	682.666, 	0.0, 		0.0, 		90.0		},
{18657, 	3017.57, 	407.07, 	682.666, 	0.0, 		0.0, 		90.0		},
{18658, 	3021.66, 	398.6, 		705.0, 		0.0, 		0.0, 		90.0		},
//New Objects from here
{8615, 		3031.0,		388.81, 	682.5,		0.0,		0.0,		0.0			},
{10244,		3101.5,		399.32,		680.7,		0.0,		0.0,		90.0		},
{1215,		3099.24,	401.77,		684.85,		0.0,		0.0,		0.0			},
{1215, 3099.4, 405.8, 684.85, 0.0, 0.0, 0.0},
{3374, 3098.28, 391.41, 685.81, 0.0, 0.0, 0.0},
{3374, 3098.28, 395.41, 685.81, 0.0, 0.0, 0.0},
{3374, 3098.28, 399.41, 685.81, 0.0, 0.0, 0.0},
{12950, 3096.87, 405.16, 682.8, 0.0, 0.0, -90.0},
{8572, 3115.34, 396.92, 684.788, 0.0, 0.0, 90.0},
{3526, 3026.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3036.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3046.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3056.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3066.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3076.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3086.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3096.41, 389.36, 684.38, 0.0, 0.0, 0.0},
{3526, 3026.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3036.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3046.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3056.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3066.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3076.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3086.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3526, 3096.41, 407.59, 684.38, 0.0, 0.0, 0.0},
{3657, 3010.86, 395.98, 680.7, 0.0, 0.0, -45.0},
{3657, 3010.86, 400.98, 680.7, 0.0, 0.0, -135.0}
};

// Pirate ship route points (position/rotation)
new Float:gShipRoutePoints[][RouteInfo] = {
{1,		1,		3066.67, 		399.98, 	679.9,      90.0},
{1,		2,		2847.4912,		404.0015,	674.9000,	90.3083},
{1,		3,		2309.6443,		472.1051,	572.9000,	85.3081},
{1,		4,		1883.3553,		486.4071,	461.9000,	89.3080},
{1,		5,		1410.5485,		508.2477,	317.9000,	89.3077},
{1,		6,		930.7766,		506.2667,	150.9000,	93.3077},
{1,		7,		170.9255,		453.3034,	106.9000,	94.3074},
{1,		8,		-277.6332,		445.0703,	39.9000,	90.3073},
{1,		9,		-623.6337,		486.9799,	2.0000,		81.3071},
{1,		10,		-805.7458,		512.7575,	2.0000,		79.3071},
{1,		11,		-1005.0413,		589.8727,	2.0000,		57.3069},
{1,		12,		-1182.4730,		720.5936,	2.0000,		47.3069},
{1,		13,		-1266.3774,		812.7768,	2.0000,		33.3069},
{1,		14,		-1333.5023,		942.6936,	2.0000,		17.3069},
{1,		15,		-1349.1571,		1018.0620,	2.0000,		11.3069},
{1,		16,		-1369.4960,		1152.3961,	2.0000,		12.3068},
{1,		17,		-1413.1537,		1291.6290,	2.0000,		22.3068},
{1,		18,		-1468.4274,		1412.3337,	2.0000,		33.3068},
{1,		19,		-1601.1370,		1541.0226,	2.0000,		52.3068},
{1,		20,		-1763.9138,		1717.2325,	2.0000,		38.3067},
{1,		21,		-1942.3354,		1928.8419,	2.0000,		41.3067},
{1,		22,		-2094.1912,		2097.4426,	2.0000,		41.3067},
{1,		23,		-2190.1477,		2166.8347,	2.0000,		67.3065},
{1,		24,		-2275.6333,		2174.1079,	2.0000,		94.3064},
{1,		25,		-2418.6614,		2144.3411,	2.0000,		120.3062},
{1,		26,		-2497.6296,		2078.9719,	2.0000,		147.3060},
{1,		27,		-2537.7754,		1980.1005,	2.0000,		171.3058},
{1,		28,		-2529.2327,		1844.9510,	2.0000,		187.3058},
{1,		29,		-2458.5786,		1482.8363,	114.9000,	191.3058},
{1,		30,		-2269.0139,		1096.9358,	225.9000,	206.3060},
{1,		31,		-2117.0256,		837.5345,	249.9000,	211.3062},
{1,		32,		-1933.9698,		617.2012,	238.9000,	224.3065},
{1,		33,		-1848.5704,		513.3226,	238.9000,	224.3066},
{1,		34,		-1682.5062,		351.4304,	238.9000,	227.3067},
{1,		35,		-1536.3120,		322.9853,	238.9000,	274.3067},
{1,		36,		-860.9827,		463.9510,	259.9000,	293.3067},
{1,		37,		-238.6695,		700.5912,	305.9000,	289.3067},
{1,		38,		316.0478,		897.7669,	412.9000,	287.3067},
{1,		39,		829.3284,		988.0482,	412.9000,	273.3067},
{1,		40,		1192.7749,		1004.6728,	401.9000,	272.3067},
{1,		41,		1692.3477,		1024.7850,	487.9000,	272.3067},
{1,		42,		2071.2297,		1022.8085,	608.9000,	270.3067},
{1,		43,		2570.5447,		1056.1204,	608.9000,	277.3067},
{1,		44,		2943.5349,		1087.8811,	623.9000,	273.3067},
{1,		45,		3312.3655,		1059.9139,	646.9000,	258.3067},
{1,		46,		3547.0557,		914.6071,	646.9000,	210.3069},
{1,		47,		3624.3938,		655.9766,	671.9000,	172.3071},
{1,		48,		3558.2629,		492.9380,	671.9000,	142.3068},
{1,		49,		3379.8450,		349.9338,	671.9000,	106.3065},
{1,		50,		3204.7527,		356.0876,	684.9000,	56.3062},
{1,		51,		3141.1477,		393.5843,	682.9000,	69.3061},
{1,		52,		3066.67, 		399.98, 	679.9,      90.0}
};





// SA-MP objects
new gMainShipObjectId;
new gShipsAttachments[sizeof(gShipAttachmentPos)];

// Icon
new icon;

//Coordinates for MapIcon
new Float:ix, Flot:iy, Float:iz;

//Declaring variable for Vehicle to attached

//Declaring map timers
new maptimer;

forward StartMovingTimer();
forward CheckpointTimer();

//-------------------------------------------------
public OnFilterScriptInit()
{

	gMainShipObjectId = CreateObject(SHIP_HULL_ID, gShipRoutePoints[0][RX], gShipRoutePoints[0][RY], gShipRoutePoints[0][RZ], 0, 0, gShipRoutePoints[0][RR]-90, SHIP_DRAW_DISTANCE);



	for(new x=0;x<sizeof(gShipAttachmentPos); x++)
	{

	    gShipsAttachments[x] = CreateObject(gShipAttachmentPos[x][objectID], gShipAttachmentPos[x][Ox], gShipAttachmentPos[x][Oy], gShipAttachmentPos[x][Oz], gShipAttachmentPos[x][rx], gShipAttachmentPos[x][ry], gShipAttachmentPos[x][rz], SHIP_DRAW_DISTANCE);

		AttachObjectToObject(gShipsAttachments[x], gMainShipObjectId,
					gShipAttachmentPos[x][Ox] - gShipHullOrigin[0],
					gShipAttachmentPos[x][Oy] - gShipHullOrigin[1],
					gShipAttachmentPos[x][Oz] - gShipHullOrigin[2],


					gShipAttachmentPos[x][rx],
					gShipAttachmentPos[x][ry],
					gShipAttachmentPos[x][rz], 1);



	}
	GetObjectPos(gMainShipObjectId, Float:ix, Float:iy, Float:iz);
	new pool = GetPlayerPoolSize();
	for(new i=0; i<=pool; i++)
	{
		SetPlayerMapIcon(i, icon, Float:ix, Float:iy, Float:iz, 5, 0xFFFF0000, 1);
	}
	maptimer = SetTimer("CheckpointTimer", 1000, 1);
	printf("Cargo ship loaded succesfully!");
	return 1;
}

//-------------------------------------------------

public OnFilterScriptExit()
{
    DestroyObject(gMainShipObjectId);
	KillTimer(maptimer);
    
	for(new x=0;x<sizeof(gShipAttachmentPos);x++)
	{
        DestroyObject(gShipsAttachments[x]);
	}

	new pool = GetPlayerPoolSize();
	for(new i=0; i<=pool; i++)
	{
		RemovePlayerMapIcon(i, icon);
	}
	printf("Cargo ship unloaded succesfully!");
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetObjectPos(gMainShipObjectId, Float:ix, Float:iy, Float:iz);
	SetPlayerMapIcon(playerid, icon, Float:ix, Float:iy, Float:iz, 5, 0xFFFF0000, 1);
}

//-------------------------------------------------
/*
new CurrentRouteID = 0;
new CurrentRoutePoint = 0;
*/

public StartMovingTimer()
{
	for(new i=0; i<sizeof(gShipRoutePoints); i++)
	{
	    if(gShipRoutePoints[i][RouteID] == CurrentRouteID && gShipRoutePoints[i][RoutePoint] == CurrentRoutePoint+1)
	    {
            UseArrayPoint = i;
		}
	}
	MoveObject(gMainShipObjectId,gShipRoutePoints[UseArrayPoint][RX], gShipRoutePoints[UseArrayPoint][RY], gShipRoutePoints[UseArrayPoint][RZ], SHIP_MOVE_SPEED / 2.0, 0, 0, gShipRoutePoints[UseArrayPoint][RR]-90);
    CurrentShipState = 1; // set state to moving
}

public CheckpointTimer()
{
	new pool = GetPlayerPoolSize();
	for(new i=0; i<=pool; i++)
		{
			RemovePlayerMapIcon(i, icon);
			GetObjectPos(gMainShipObjectId, Float:ix, Float:iy, Float:iz);
			SetPlayerMapIcon(i, icon, Float:ix, Float:iy, Float:iz, 5, 0xFFFF0000, 1);
		}
}

//-------------------------------------------------

public OnObjectMoved(objectid)
{
	if(objectid != gMainShipObjectId) return 0;



    CurrentRoutePoint++;

    if(CurrentRoutePoint == Max_Selected_Route_Points) {
		CurrentRoutePoint = 0;
		StopObject(gMainShipObjectId);
		CurrentShipState = 0; // set state to finished
        return 1;
	}



	for(new i=0; i<sizeof(gShipRoutePoints); i++)
	{
	    if(gShipRoutePoints[i][RouteID] == CurrentRouteID && gShipRoutePoints[i][RoutePoint] == CurrentRoutePoint+1)
	    {
            UseArrayPoint = i;
		}
	}
	MoveObject(gMainShipObjectId,gShipRoutePoints[UseArrayPoint][RX], gShipRoutePoints[UseArrayPoint][RY], gShipRoutePoints[UseArrayPoint][RZ], SHIP_MOVE_SPEED / 2.0, 0, 0, gShipRoutePoints[UseArrayPoint][RR]-90);

 	return 1;
}


//-------------------------------------------------
// command stuff
CMD:controltheship(playerid, params[])
{
	ShowPlayerDialog(playerid, dialog_control, DIALOG_STYLE_LIST, "Airship control menu", "Select route\nReset ship\nPause ship\nContinue ship", "Execute", "Cancel");
	return 1;
}

// CMD:flytheship(playerid, params[])
// {
// 	maptimer = SetTimer("CheckpointTimer", 1000, 1);
// 	// AttachObjectToVehicle(objectid, vehicleid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:RotX, Float:RotY, Float:RotZ)
// 	return 1;
// }


//-------------------------------------------------

// dialog handling stuff
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == dialog_control)
    {
        if(response)
        {
            switch(listitem)
            {
            
                case 0: // select route
                {
				    if(CurrentRoutePoint == 0 && CurrentShipState == 0)
					{
						new str[1500],temp[1500];
				   		for(new i = 0; i < sizeof(RouteNameList);i++)
				   		{

					   		format(temp, sizeof(temp), "%i \t%s", RouteNameList[i][RouteID], RouteNameList[i][RouteName]);
					   		strcat(str, temp);
					   		if(i < sizeof(RouteNameList)-1)strcat(str, "\n");
						}
					    ShowPlayerDialog(playerid, dialog_route, DIALOG_STYLE_LIST, "Airship route selection", str, "Select", "Cancel");

					}
					else
					{
					    SendClientMessage(playerid, 0xFFFF0000, "You can't start the ship right now! It's already moving");
					    return 1;
					}
                }
                case 1: // reset the ship
				{
				    SendClientMessage(playerid, 0xFFFF0000, "You have chosen to reset the ships position! The current route has been canceled");

				    StopObject(gMainShipObjectId);
				    SetObjectPos(gMainShipObjectId, gShipHullOrigin[0], gShipHullOrigin[1], gShipHullOrigin[2]);
				    SetObjectRot(gMainShipObjectId, gShipHullOrigin[3], gShipHullOrigin[4], gShipHullOrigin[5]);
				    CurrentShipState = 0; // set the state to finished, as we've reset it
				    CurrentRoutePoint = 0; //ship also has reset so no route point

				    
				}
                case 2: // pause the ship
                {
                    if(CurrentShipState != 1 && CurrentShipState == 0) return SendClientMessage(playerid, 0xFFFF0000, "The ship isn't moving at this moment. Please select a route first!");
					if(CurrentShipState != 1 && CurrentShipState == 2) return SendClientMessage(playerid, 0xFFFF0000, "The ship isn't moving at this moment. Please continue it first!");
					
				    SendClientMessage(playerid, 0xFFFF0000, "You have ordered the ship to cease its movement!");
					StopObject(gMainShipObjectId);
					CurrentShipState = 2; // setting the state to paused
					new  Float:pos[3];
					GetObjectPos(gMainShipObjectId, pos[0], pos[1], pos[2]);
		  	        new pool = GetPlayerPoolSize();
					for(new i=0; i<=pool; i++)
					{
						if(IsPlayerInRangeOfPoint(i, 100, pos[0], pos[1], pos[2]))
						{
							SendClientMessage(i, 0xFFFF0000, "The ship has been paused at this moment! Please be patient, the journey will continue later!");
						}
					}
                    
				}
				case 3: // continue the ship
				{
				    if(CurrentShipState == 0) return SendClientMessage(playerid, 0xFFFF0000, "The ship isn't in a route! Please select a route first!");
				    if(CurrentShipState == 1) return SendClientMessage(playerid, 0xFFFF0000, "The ship currently isn't paused! You can't continue it.");
                    SendClientMessage(playerid, 0xFFFF0000, "You have ordered the ship to continue its route!");

					for(new i=0; i<sizeof(gShipRoutePoints); i++)
					{
					    if(gShipRoutePoints[i][RouteID] == CurrentRouteID && gShipRoutePoints[i][RoutePoint] == CurrentRoutePoint+1)
					    {
				            UseArrayPoint = i;
						}
					}
					MoveObject(gMainShipObjectId,gShipRoutePoints[UseArrayPoint][RX], gShipRoutePoints[UseArrayPoint][RY], gShipRoutePoints[UseArrayPoint][RZ], SHIP_MOVE_SPEED, 0, 0, gShipRoutePoints[UseArrayPoint][RR]-90);
					CurrentShipState = 1; // setting the state to moving
					
		  	        new  Float:pos[3];
					GetObjectPos (gMainShipObjectId, pos[0], pos[1], pos[2]);
		  	        new pool = GetPlayerPoolSize();
					for(new i=0; i<=pool; i++)
					{
						if(IsPlayerInRangeOfPoint(i, 100, pos[0], pos[1], pos[2]))
						{
							SendClientMessage(i, 0xFFFF0000, "Buckle up! The ship is continuing its route!");
						}
					}
					
				}
            }
        }
        return 1;
	}
    if(dialogid == dialog_route)
    {
        if(response) // If they clicked 'Yes' or pressed enter
        {


            new src[128];

            format(src,sizeof(src), "%s", inputtext);

            strdel(src,strlen(src)-(strlen(src)-1),strlen(src));

            new routeid = strval(src);

            CurrentRouteID = routeid;


            Max_Selected_Route_Points = 0;
			for(new i=0; i<sizeof(gShipRoutePoints); i++)
			{
			    if(gShipRoutePoints[i][RouteID] == CurrentRouteID)
			    {
                    Max_Selected_Route_Points++;
				}
			}

  	        new  Float:pos[3];
			GetObjectPos (gMainShipObjectId, pos[0], pos[1], pos[2]);
		  	new pool = GetPlayerPoolSize();
			for(new i=0; i<=pool; i++)
			{
				if(IsPlayerInRangeOfPoint(i, 100, pos[0], pos[1], pos[2]))
				{
					SendClientMessage(i, 0xFFFF0000, "All aboard! The ship is leaving in 15 seconds!");
				}
			}
            SetTimer("StartMovingTimer",15000,0);
        }
        else
        {
            return 1;
        }
        return 1;
    }

    return 0;
}
//-------------------------------------------------