// [SGD] RRDC Cuffs v1.2.2 - Copyright 2020 Alex Pascal (Alex Carpenter).
//  Based on combined Lockmeister and LockGuard script by Felis Darwin.
// ----------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// ========================================================================================

// Modifiable Variables.
// ----------------------------------------------------------------------------------------
integer g_appChan           = -89039937;        // The channel for this application set.

// ========================================================================================
// CAUTION: Modifying anything below this line may cause issues. Edit at your own risk!
// ========================================================================================
string  g_partTex;                              // Current particle texture.
float   g_partSizeX;                            // Current particle X size.
float   g_partSizeY;                            // Current particle Y size.
float   g_partLife;                             // Current particle life.
float   g_partGravity;                          // Current particle gravity.
vector  g_partColor;                            // Current particle color.
float   g_partRate;                             // Current particle rate.
integer g_partFollow;                           // Current particle follow flag.
integer g_outerPartOn;                          // If TRUE, outerLink particles are on.
integer g_innerPartOn;                          // If TRUE, innerLink particles are on.
string  g_outerPartTarget;                      // Key of the target prim for LG/outer.
string  g_innerPartTarget;                      // Key of the target prim for inner.
integer g_outerLink;                            // Link number of the outer/LGLM emitter.
integer g_innerLink;                            // Link number of the inner emitter.
integer g_particleMode;                         // FALSE = LG/LM, TRUE = Intercuff.
list    g_LGTags;                               // List of current LockGuard tags.
list    g_LMTags;                               // List of current LockMeister tags.
// ========================================================================================

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ----------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

// fMin - Given two floats, returns the smallest.
// ----------------------------------------------------------------------------------------
float fMin(float f1, float f2)
{
    if (f2 < f1)
    {
        return f2;
    }
    return f1;
}

// fMax - Given two floats, returns the largest.
// ----------------------------------------------------------------------------------------
float fMax(float f1, float f2)
{
    if (f2 > f1)
    {
        return f2;
    }
    return f1;
}

// outerParticles - Turns outer/LockGuard chain/rope particles on or off.
// ----------------------------------------------------------------------------------------
outerParticles(integer on)
{
    g_outerPartOn = on; // Save the state we passed in.
    
    if(!on) // If LG particles should be turned off, turn them off and reset defaults.
    {
        llLinkParticleSystem(g_outerLink, []); // Stop particle system and clear target.
        g_outerPartTarget   = NULL_KEY;
    }
    else // If LG particles are to be turned on, turn them on.
    {
        llLinkParticleSystem(g_outerLink,
        [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_DROP,
            PSYS_SRC_BURST_PART_COUNT,  1,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          g_partLife,
            PSYS_SRC_BURST_RATE,        g_partRate,
            PSYS_SRC_TEXTURE,           g_partTex,
            PSYS_PART_START_COLOR,      g_partColor,
            PSYS_PART_START_SCALE,      <g_partSizeX, g_partSizeY, 0.0>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, (g_partGravity * -1.0)>,
            PSYS_SRC_TARGET_KEY,        (key)g_outerPartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK                           |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK                      |
                                         PSYS_PART_TARGET_LINEAR_MASK * (g_partGravity == 0) |
                                         PSYS_PART_FOLLOW_SRC_MASK * (g_partFollow == TRUE))
        ]);
    }
}

// innerParticles - Turns inner chain/rope particles on or off.
// ----------------------------------------------------------------------------------------
innerParticles(integer on)
{
    g_innerPartOn = on;

    if (!on) // Turn inner particle system off.
    {
        llLinkParticleSystem(g_innerLink, []); // Stop particle system and clear target.
        g_innerPartTarget   = NULL_KEY;
    }
    else // Turn the inner particle system on.
    {
        llLinkParticleSystem(g_innerLink,
        [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_DROP,
            PSYS_SRC_BURST_PART_COUNT,  1,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          1.2,
            PSYS_SRC_BURST_RATE,        0.01,
            PSYS_SRC_TEXTURE,           "dbeee6e7-4a63-9efe-125f-ceff36ceeed2", // thinchain.
            PSYS_PART_START_COLOR,      <1.0, 1.0, 1.0>,
            PSYS_PART_START_SCALE,      <0.04, 0.04, 0.0>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, -0.3>,
            PSYS_SRC_TARGET_KEY,        (key)g_innerPartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK      |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK |
                                         PSYS_PART_FOLLOW_SRC_MASK)
        ]);
    }
}

// resetParticles - When activated sets current outer particle settings to defaults.
// ---------------------------------------------------------------------------------------------------------
resetParticles()
{
    g_partTex        = "dbeee6e7-4a63-9efe-125f-ceff36ceeed2"; // thinchain.
    g_partSizeX      = 0.04;
    g_partSizeY      = 0.04;
    g_partLife       = 1.2;
    g_partGravity    = 0.3;
    g_partColor      = <1.0, 1.0, 1.0>;
    g_partRate       = 0.01;
    g_partFollow     = TRUE;
}

// toggleMode - Controls particle system when changing between LG/LM and Interlink.
// ----------------------------------------------------------------------------------------
toggleMode(integer mode)
{
    if (g_particleMode != mode) // If the mode actually changed.
    {
        outerParticles(FALSE); // Clear all particles.
        innerParticles(FALSE);
        resetParticles();

        g_particleMode = mode; // Toggle mode.

        if (!mode) // Send stop poses or stop leash command.
        {
            if (llList2String(g_LMTags, 0) == "lcuff")
            {
                llWhisper(getAvChannel(llGetOwner()), "stopposes collarfrontloop");
            }
            else if (llList2String(g_LMTags, 0) == "llcuff")
            {
                llWhisper(getAvChannel(llGetOwner()), "stopleash collarfrontloop");
            }
        }
    }
}

default
{
    // Initialize the script.
    // ----------------------------------------------------------------------------------------
    state_entry()
    {
        integer i; // Find the emitter links.
        string tag;
        for (i = 1; i <= llGetNumberOfPrims(); i++)
        {
            tag = llToLower(llStringTrim(llGetLinkName(i), STRING_TRIM));
            if (tag == "innerlink")
            {
                g_innerLink = i;
            }
            else if (tag == "outerlink")
            {
                g_outerLink = i;
            }
        }
        
        // Parse the description field for potential LM tags.
        list l = llParseString2List(llGetObjectDesc(),[":"],[]);
        
        if(l == []) // If we have ZERO config information, make a guess based on attach point.
        {
            l = llList2List(["","collar","thead","lblade","rblade","lhand","rhand","llcuff",
                             "rlcuff","collar","pelvis","lbit","rbit","","","","","nose",
                             "rbiceps","rcuff","lbiceps","lcuff","rfbelt","rtigh","rlcuff",
                             "lfbelt","ltigh","llcuff","fbelt","lnipple","rnipple","","","",
                             "","","","","","collar","fbelt"],
                llGetAttached(),llGetAttached());
        }
        
        integer j; // Parse all the LM tags found.
        list tList;
        for(i = 0; i < llGetListLength(l); i++)
        {
            tag = llToLower(llStringTrim(llList2String(l,i), STRING_TRIM)); // Clean tag name.
            
            j = llListFindList(
                ["rcuff","rbiceps","lbiceps","lcuff","lblade","rblade","rnipple",
                "lnipple","rtigh","ltigh","rlcuff","llcuff","pelvis","fbelt","bbelt",
                "rcollar","lcollar","thead","collar","lbit","rbit","nose","bcollar",
                "back"], [tag]
            );
            if (j > -1) // LM tag. Add if not already present.
            {
                if (llListFindList(g_LMTags, [tag]) <= -1)
                {
                    g_LMTags += [tag];
                }

                // Add corresponding LG tags, if not present.
                tList = llParseString2List(llList2String(
                    ["rightwrist|wrists|allfour","rightupperarm|arms","leftupperarm|arms",
                    "leftwrist|wrists|allfour","harnessleftshoulderloop",
                    "harnessrightshoulderloop","rightnipplering|nipples",
                    "leftnipplering|nipples","rightupperthigh|thighs","leftupperthigh|thighs",
                    "rightankle|ankles|allfour","leftankle|ankles|allfour",
                    "clitring|cockring|ballring","frontbeltloop","backbeltloop",
                    "collarrightloop","collarleftloop","topheadharness", "collarfrontloop",
                    "leftgag","rightgag","nosering","collarbackloop","harnessbackloop"], j), ["|"], []
                );
                if (llListFindList(g_LGTags, [llList2String(tList, 0)]) <= -1)
                {
                    g_LGTags += tList;
                }
            }
        }

        llSetMemoryLimit(llGetUsedMemory() + 2048); // Limit script memory consumption.

        if (g_LMTags == [] || g_innerLink <= 0 || g_outerLink <= 0)
        {
            llOwnerSay("FATAL: Unknown anchor and/or missing chain emitters!");
            return;
        }

        resetParticles();
        innerParticles(FALSE); // Stop any particle effects and init.
        outerParticles(FALSE);

        llListen(-8888,"",NULL_KEY,""); // Open up LockGuard and Lockmeister listens.
        llListen(-9119,"",NULL_KEY,"");

        llListen(getAvChannel(llGetOwner()), "", "", ""); // Open collar/cuffs avChannel.
    }

    // Reset the script on rez.
    // ----------------------------------------------------------------------------------------
    on_rez(integer param)
    {
        llResetScript();
    }

    // Listen for LG and LM commands.
    // ----------------------------------------------------------------------------------------
    listen(integer chan, string name, key id, string mesg)
    {
        if (chan == getAvChannel(llGetOwner()) && llGetOwnerKey(id) != id) // Process RRDC commands.
        {
            list l = llParseString2List(mesg, [" "], []);
            if (llListFindList(g_LGTags, [llList2String(l, 1)]) > -1) // LG tag match.
            {
                name = llToLower(llList2String(l, 0));
                if (name == "unlink") // unlink <tag> <inner|outer>
                {
                    if (llToLower(llList2String(l, 2)) == "inner")
                    {
                        innerParticles(FALSE);
                    }
                    else if (g_particleMode) // Outer.
                    {
                        resetParticles();
                        outerParticles(FALSE);
                    }
                }
                else if (name == "link") // link <tag> <inner|outer> <dest-uuid>
                {
                    toggleMode(TRUE);
                    if (llToLower(llList2String(l, 2)) == "inner")
                    {
                        g_innerPartTarget = llList2Key(l, 3);
                        innerParticles(TRUE);
                    }
                    else // Outer.
                    {
                        g_outerPartTarget = llList2Key(l, 3);
                        outerParticles(TRUE);
                    }
                }       // linkrequest <dest-tag> <inner|outer|x> <src-tag> <inner|outer>
                else if (name == "linkrequest")
                {
                    if (llToLower(llList2String(l, 2)) == "inner") // Get the link UUID.
                    {
                        name = (string)llGetLinkKey(g_innerLink);
                    }
                    else // Outer.
                    {
                        name = (string)llGetLinkKey(g_outerLink);
                    }

                    llWhisper(getAvChannel(llGetOwnerKey(id)), "link " + // Send link message.
                        llList2String(l, 3) + " " +
                        llList2String(l, 4) + " " + name
                    );
                }           // leashto <src-tag> <inner|outer> <uuid> <dest-tag> <inner|outer|x>
                else if (name == "leashto")
                {
                    toggleMode(TRUE);
                    g_partLife = 2.4;     // Make the chain a little longer for leash/chain gang.
                    g_partGravity = 0.15;

                    if (llToLower(llList2String(l, 2)) == "inner") // Make a temp link.
                    {
                        g_innerPartTarget = llList2Key(l, 3);
                        innerParticles(TRUE);
                    }
                    else // Outer.
                    {
                        g_outerPartTarget = llList2Key(l, 3);
                        outerParticles(TRUE);
                    }

                    llWhisper(getAvChannel(llList2Key(l, 3)), "linkrequest " +
                        llList2String(l, 4) + " " +
                        llList2String(l, 5) + " " +
                        llList2String(l, 1) + " " +
                        llList2String(l, 2)
                    );
                }
                else if (name == "ping") // ping <dest-tag> <src-tag>
                {
                    llWhisper(getAvChannel(llGetOwnerKey(id)), "pong " + 
                        llList2String(l, 2) + " " +
                        llList2String(l, 1)
                    );
                }
                else if (name == "settexture") // settexture <tag> <uuid>
                {
                    llSetLinkPrimitiveParamsFast(LINK_THIS, [
                        PRIM_TEXTURE, 1, llList2String(l, 2), <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                    ]);
                }
            }
        }
        else if(chan == -8888 && llGetSubString(mesg, 0, 35) == ((string)llGetOwner())) // Process LM.
        {
            if(llListFindList(g_LMTags, [llGetSubString(mesg, 36, -1)]) > -1)
            {
                toggleMode(FALSE);
                llRegionSayTo(id, -8888, mesg + " ok");
            }
            else if (llGetSubString(mesg, 36, 54) == "|LMV2|RequestPoint|" &&      // LMV2.
                     llListFindList(g_LMTags, [llGetSubString(mesg, 55, -1)]) > -1)
            {
                llRegionSayTo(id, -8888, ((string)llGetOwner()) + "|LMV2|ReplyPoint|" + 
                    llGetSubString(mesg, 55, -1) + "|" + ((string)llGetLinkKey(g_outerLink))
                );
            }
        }                                                                          // Process LG.
        else if(chan == -9119 && llSubStringIndex(mesg, "lockguard " + ((string)llGetOwner())) == 0)
        {
            list tList = llParseString2List(mesg, [" "], []);
            
            // lockguard [avatarKey/ownerKey] [item] [command] [variable(s)] 
            if(llListFindList(g_LGTags, [llList2String(tList, 2)]) > -1 || llList2String(tList, 2) == "all")
            {
                integer i = 3; // Start at the first command position and parse the commands.
                while(i < llGetListLength(tList))
                {                    
                    name = llList2String(tList, i);
                    if(name == "link")
                    {
                        toggleMode(FALSE);
                        g_outerPartTarget = llList2Key(tList, (i + 1));
                        outerParticles(TRUE);
                        i += 2;
                    }
                    else if(name == "unlink" && !g_particleMode)
                    {
                        resetParticles();
                        outerParticles(FALSE);
                        tList = [];
                        return;
                    }
                    else if(name == "gravity")
                    {
                        toggleMode(FALSE);
                        g_partGravity = fMax(0.0, fMin(llList2Float(tList, (i + 1)), 100.0));
                        i += 2;
                    }
                    else if(name == "life")
                    {
                        toggleMode(FALSE);
                        g_partLife = fMax(0.0, llList2Float(tList, (i + 1)));
                        i += 2;
                    }
                    else if(name == "texture")
                    {
                        toggleMode(FALSE);
                        name = llList2String(tList, (i + 1));
                        if(name != "chain" && name != "rope")
                        {
                            g_partTex = name;
                        }
                        i += 2;
                    }
                    else if(name == "rate")
                    {
                        toggleMode(FALSE);
                        g_partRate = fMax(0.0, llList2Float(tList, (i + 1)));
                        i += 2;
                    }
                    else if(name == "follow")
                    {
                        toggleMode(FALSE);
                        g_partFollow = (llList2Integer(tList, (i + 1)) > 0);
                        i += 2;
                    }
                    else if(name == "size")
                    {
                        toggleMode(FALSE);
                        g_partSizeX = fMax(0.03125, fMin(llList2Float(tList, (i + 1)), 4.0));
                        g_partSizeY = fMax(0.03125, fMin(llList2Float(tList, (i + 2)), 4.0));
                        i += 3;
                    }
                    else if(name == "color")
                    {
                        toggleMode(FALSE);
                        g_partColor.x = fMax(0.0, fMin(llList2Float(tList, (i + 1)), 1.0));
                        g_partColor.y = fMax(0.0, fMin(llList2Float(tList, (i + 2)), 1.0));
                        g_partColor.z = fMax(0.0, fMin(llList2Float(tList, (i + 3)), 1.0));
                        i += 4;
                    }
                    else if(name == "ping")
                    {
                        llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " +
                            llList2String(g_LGTags, 0) + " okay"
                        );
                        i++;
                    }
                    else if(name == "free")
                    {
                        if(g_outerPartOn)
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " + 
                                llList2String(g_LGTags, 0) + " no"
                            );
                        }
                        else
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " + 
                                llList2String(g_LGTags, 0) + " yes"
                            );
                        }
                        i++;
                    }
                    else // Skip unknown commands.
                    {
                        i++;
                    }
                }
                
                outerParticles(g_outerPartOn); // Refresh particles.
            }
        }
    }
}
