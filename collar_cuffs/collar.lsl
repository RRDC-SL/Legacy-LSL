// [SGD] RRDC Collar v1.2.2 (c) 2020 Alex Pascal (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================

// System Configuration Variables
// ---------------------------------------------------------------------------------------------------------
integer g_appAssetId  = 1;                      // The asset id for the item.
string  g_appVersion  = "1.2.4";                // The current software version for the collar.
integer g_appChan     = -89039937;              // The channel for this application set.

// =========================================================================================================
// CAUTION: Modifying anything below this line may cause issues. Edit at your own risk!
// =========================================================================================================

// Saved Link Numbers.
// ---------------------------------------------------------------------------------------------------------
integer g_ledLink;                              // Link number of the LED light.
integer g_leashLink;                            // Link number of the leashing point prim.
integer g_shackleLink;                          // Link number of the chain to shackles point prim.

// Timer System Variables.
// ---------------------------------------------------------------------------------------------------------
integer g_ledCount;                             // Tracks how long to wait to blink LED.
integer g_shockCount;                           // Tracks how long to keep shock active.
integer g_pingCount;                            // Tracks how long to wait for pong messages.

// Current Particle System Parameters for leashLink.
// ---------------------------------------------------------------------------------------------------------
string  g_partTex;                              // Current particle texture.
float   g_partSizeX;                            // Current particle X size.
float   g_partSizeY;                            // Current particle Y size.
float   g_partLife;                             // Current particle life.
float   g_partGravity;                          // Current particle gravity.
vector  g_partColor;                            // Current particle color.
float   g_partRate;                             // Current particle rate.
integer g_partFollow;                           // Current particle follow flag.

// Leash System Variables.
// ---------------------------------------------------------------------------------------------------------
string  g_leashMode;                            // Tag of the anchor point we're polling for.
string  g_leashUser;                            // Key of the avatar currently polling for leash points.
integer g_followHandle;                         // Handle for the leash follower llTarget.
vector  g_leashTargetPos;                       // Last known position of g_leashPartTarget's owner.

// Particle and Leash Targets.
// ---------------------------------------------------------------------------------------------------------
string  g_leashPartTarget;                      // Key of the target prim for LG/leash.
string  g_shacklePartTarget;                    // Key of the target prim for shackle.

// Data Store Variables.
// ---------------------------------------------------------------------------------------------------------
key     g_requestKey;                           // Inmate numbers request key.
string  g_inmateInfo;                           // The current character's inmate number and name.
string  g_animState;                            // Current AO animation state.
list    g_animList;                             // List of currently playing (base) anim names.
list    g_avList;                               // Tracks leash/chaingang enabled avatars.
list    g_curMenus;                             // Tracks current menu by user.

// Toggle Switch Bitfield.
// ---------------------------------------------------------------------------------------------------------
// OR Mask       AND Mask      Variable
// ---------------------------------------------------------------------------------------------------------
// 0x00000001    0xFFFFFFFE    0  Toggle for anim version. 0=A, 1=B.
// 0x00000002    0xFFFFFFFD    1  Current on/off state for the collar LED.
// 0x00000004    0xFFFFFFFB    2  Controls whether leashLink particles are turned on.
// 0x00000008    0xFFFFFFF7    3  Controls whether shackleLink particles are turned on.
// 0x00000010    0xFFFFFFEF    4  Particle Mode. 0=LG/LM, 1=Intercuff/Leash.
// 0x00000020    0xFFFFFFDF    5  TRUE when ankle chain is active.
// 0x00000040    0xFFFFFFBF    6  TRUE when wrist to ankle shackle chains are active.
// 0x00000080    0xFFFFFF7F    7  TRUE when the wearer is leashed to something.
// 0x00000100    0xFFFFFEFF    8  TRUE when chain walk sounds are muted.
// 0x00000200    0xFFFFFDFF    9  TRUE when shock cooldown is active.
// 0x00000400    0xFFFFFBFF    10 TRUE when requestKey is a version check.
// 0x00000800    0xFFFFF7FF    11 TRUE when version check is supposed to be verbose.
// ---------------------------------------------------------------------------------------------------------
integer g_settings;
// ---------------------------------------------------------------------------------------------------------

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ---------------------------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

// getSetting - Given an index representing how many bits from 2^0 the setting is located, returns
//              the setting as a boolean integer.
// --------------------------------------------------------------------------------------------------------
integer getSetting(integer index)
{
    return (((g_settings & (1 << index)) >> index) == TRUE);
}

// setSetting - Given an index representing how many bits from 2^0 the setting is located, sets the
//              indicated setting to the boolean integer specified.
// --------------------------------------------------------------------------------------------------------
setSetting(integer index, integer setting)
{
    g_settings = ((g_settings & ~(1 << index)) | ((setting == TRUE) << index));
}

// fClamp - Given a number, returns number bounded by lower and upper.
// --------------------------------------------------------------------------------------------------------
float fClamp(float value, float lower, float upper)
{
    if (value < lower)
    {
        return lower;
    }
    else if (value > upper)
    {
        return upper;
    }
    return value;
}

// strIf - If condition is TRUE, returns sTrue, otherwise returns sFalse.
// --------------------------------------------------------------------------------------------------------
string strIf(integer condition, string sTrue, string sFalse)
{
    if (condition)
    {
        return sTrue;
    }
    return sFalse;
}

// inRange - Returns TRUE if the object is less than 6m from our position.
// ---------------------------------------------------------------------------------------------------------
integer inRange(key object)
{
    return (llVecDist(llGetPos(), llList2Vector(llGetObjectDetails(object, [OBJECT_POS]), 0)) < 6.0);
}

// versionCheck - Checks the current version against a remote server.
// ---------------------------------------------------------------------------------------------------------
versionCheck(integer verbose)
{
    setSetting(11, verbose);
    setSetting(10, TRUE); // Set request type flag.

    g_requestKey = llHTTPRequest("https://back.rrdc.xyz/miscapi.php", [HTTP_METHOD, "POST"], 
        "mode=vercheck&tuuid=" + (string)llGetOwner() +
        "&asset=" + (string)g_appAssetId + 
        "&ver=" + (string)g_appVersion);
}

// playRandomSound - Plays a random chain sound.
// ---------------------------------------------------------------------------------------------------------
playRandomSound(integer play)
{
    if (play || (!getSetting(8) && (g_animList != [] || getSetting(5) || getSetting(6) || getSetting(7))))
    {
        llPlaySound(llList2String([ "f729d711-085e-f899-a723-a4afefd6a7d0", // ChainStep001.
                                    "1f08a669-11ac-96e0-0435-419d2ae01254", // ChainStep002.
                                    "9da21f36-14b1-9e79-3363-fc9d241628ba", // ChainStep003.
                                    "35154062-4f0d-a489-35d3-696d8004b0cc", // ChainStep004.
                                    "93ce44ed-014d-6e58-9d7b-1c9c5242ac6c"  // ChainStep005.
                                ], 
                                (integer)llFrand(5)), 0.2);
    }
}

// doAnimationOverride - Toggles or switches the persistent AO feature.
// ---------------------------------------------------------------------------------------------------------
doAnimationOverride(integer on)
{
    if (g_animList != []) // Activate or swap animations for persistent AO.
    {
        setSetting(!getSetting(0)); // Toggle anim version.

        integer i;
        for (i = 0; i < llGetListLength(g_animList); i++)
        {
            if (on) // Start new versions if on.
            {
                llStartAnimation(llList2String(g_animList, i) + strIf(getSetting(0), "a", "b"));
            }

            llStopAnimation(llList2String(g_animList, i) + strIf(!getSetting(0), "a", "b"));
        }

        if (!on) // Reset list if turned off.
        {
            g_animList = [];
            playRandomSound(TRUE);
        }
    }
}

// leashParticles - Turns outer/LockGuard chain/rope particles on or off.
// ---------------------------------------------------------------------------------------------------------
leashParticles(integer on)
{
    setSetting(2, on); // Set particle state.

    if(!on) // If LG particles should be turned off, turn them off and reset defaults.
    {
        llLinkParticleSystem(g_leashLink, []); // Stop particle system and clear target.
        g_leashPartTarget = NULL_KEY;
    }
    else // If LG particles are to be turned on, turn them on.
    {
        llLinkParticleSystem(g_leashLink,
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
            PSYS_SRC_TARGET_KEY,        (key)g_leashPartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK                           |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK                      |
                                         PSYS_PART_TARGET_LINEAR_MASK * (g_partGravity == 0) |
                                         PSYS_PART_FOLLOW_SRC_MASK * (g_partFollow == TRUE))
        ]);
    }
}

// shackleParticles - Turns inner chain/rope particles on or off.
// ---------------------------------------------------------------------------------------------------------
shackleParticles(integer on)
{
    setSetting(3, on); // Save particle state.

    if (!on) // Turn inner particle system off.
    {
        llLinkParticleSystem(g_shackleLink, []); // Stop particle system and clear target.
        g_shacklePartTarget   = NULL_KEY;
    }
    else // Turn the inner particle system on.
    {
        llLinkParticleSystem(g_shackleLink,
        [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_DROP,
            PSYS_SRC_BURST_PART_COUNT,  1,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          1.2,
            PSYS_SRC_BURST_RATE,        0.01,
            PSYS_SRC_TEXTURE,           "dbeee6e7-4a63-9efe-125f-ceff36ceeed2", // thinchain
            PSYS_PART_START_COLOR,      <1.0, 1.0, 1.0>,
            PSYS_PART_START_SCALE,      <0.04, 0.04, 0.0>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, -0.3>,
            PSYS_SRC_TARGET_KEY,        (key)g_shacklePartTarget,
            PSYS_PART_FLAGS,            (PSYS_PART_TARGET_POS_MASK      |
                                         PSYS_PART_FOLLOW_VELOCITY_MASK |
                                         PSYS_PART_FOLLOW_SRC_MASK)
        ]);
    }
}

// resetParticles - When activated sets current leash particle settings to defaults.
// ---------------------------------------------------------------------------------------------------------
resetParticles()
{
    g_partTex        = "dbeee6e7-4a63-9efe-125f-ceff36ceeed2"; // thinchain
    g_partSizeX      = 0.04;
    g_partSizeY      = 0.04;
    g_partLife       = 1.2;
    g_partGravity    = 0.3;
    g_partColor      = <1.0, 1.0, 1.0>;
    g_partRate       = 0.01;
    g_partFollow     = TRUE;
}

// resetLeash - When activated, turns off all leashing functions and resets variables.
// ---------------------------------------------------------------------------------------------------------
resetLeash()
{
    if (getSetting(7)) // If we're leashed.
    {
        llStopMoveToTarget(); // Stop follow effect.
        llTargetRemove(g_followHandle);

        leashParticles(FALSE);
        llWhisper(getAvChannel(llGetOwner()), "unlink leftankle outer");

        g_followHandle      = 0;
        g_leashTargetPos    = ZERO_VECTOR;
        g_leashUser         = "";
        g_leashMode         = "";
        g_avList            = [];
        g_pingCount         = 0;
        setSetting(7, FALSE);
    }
}

// leashFollow - Controls leash auto-follow functionality.
// ---------------------------------------------------------------------------------------------------------
leashFollow(integer atTarget)
{
    if (getSetting(7) && g_leashPartTarget != NULL_KEY) // We actually leashed to something?
    {
        vector newPos = llList2Vector( // Get the target's owner's position.
            llGetObjectDetails(llGetOwnerKey(g_leashPartTarget), [OBJECT_POS]), 0
        );

        if (newPos == ZERO_VECTOR || newPos.x < -25 || newPos.x > 280 || newPos.y < -25 || 
            newPos.y > 280 || llVecDist(llGetPos(), newPos) > 15.0)
        {
            resetLeash(); // If target's owner is not on the sim and within 15m, stop leash.
        }
        else // Target is within range.
        {
            if (g_leashTargetPos != newPos) // Update target if pos changed.
            {
                llTargetRemove(g_followHandle);
                g_leashTargetPos = newPos;
                g_followHandle = llTarget(g_leashTargetPos, 2.0);
            }

            if (!atTarget) // Only keep moving if we're not at target.
            {
                llMoveToTarget(g_leashTargetPos, 0.85);
            }
            else
            {
                llStopMoveToTarget();
            }
        }
    }
}

// toggleMode - Controls particle system when changing between LG/LM and Interlink.
// ---------------------------------------------------------------------------------------------------------
toggleMode(integer mode)
{
    if ((getSetting(4) && TRUE) != mode) // If the mode actually changed.
    {
        shackleParticles(FALSE); // Clear all particles.
        leashParticles(FALSE);
        resetParticles();
        resetLeash();

        setSetting(4, mode); // Toggle mode.
    }
}

// TODO: syncInmateInfo() to replace updateInmateInfo.
// updateInmateInfo - Sets inmate info or defaults if not present.
// ---------------------------------------------------------------------------------------------------------
updateInmateInfo(string inmateNum, string inmateName)
{
    list l = llParseString2List(llBase64ToString(llList2String(
        llGetLinkPrimitiveParams(g_leashLink, [PRIM_DESC]), 0)), [" "], []);
    
    if (((integer)inmateNum) > 0 && llStringLength(inmateNum) == 5) // Set inmate number.
    {
        l = llListReplaceList(l, [inmateNum], 0, 0);
    }
    else if (((integer)llList2String(l, 0)) <= 0 || llStringLength(llList2String(l, 0)) != 5)
    {
        l = llListReplaceList(l, ["00000"], 0, 0);

        llOwnerSay( // Null inmate number nag message.
            "Warning: You must assign an Inmate ID to your collar or certain features may not work.\n" +
            "To fix this, touch your collar and visit: 📜 Settings -> 📜 InmateID"
        );
    }

    if (inmateName != "") // Set inmate name.
    {
        l = llListReplaceList(l, [inmateName], 1, 1);
    }
    else if (llList2String(l, 1) == "")
    {
        l = llListReplaceList(l, ["(No Name)"], 1, 1);
    }

    // Replace spaces in charname with special characters to ensure parse compatibility.
    l = llListReplaceList(l,
        [llDumpList2String(llParseString2List(llList2String(l, 1), [" "], []), " ")], 1, 1);

    llSetLinkPrimitiveParamsFast(g_leashLink, [ // Save updated inmate info.
        PRIM_DESC, llStringToBase64(g_inmateInfo = llDumpList2String(l, " "))
    ]);
}

// TODO: Update to use the website profile links.
// giveCharSheet - Gives a copy of the character sheet to the user, if present.
// ---------------------------------------------------------------------------------------------------------
giveCharSheet(key user)
{
    if (llGetInventoryNumber(INVENTORY_NOTECARD)) // Notecard is present.
    {
        string note = llGetInventoryName(INVENTORY_NOTECARD, 0);

        llOwnerSay("secondlife:///app/agent/" + ((string)user) + "/completename" +
            " has requested your character sheet.");

        // If name is a URL, do a load URL to external instead of notecard vend.
        if (llGetSubString(note, 0, 6) == "http://" || llGetSubString(note, 0, 7) == "https://")
        {
            string inmateID = llGetSubString(g_inmateInfo, 0, 4);

            llLoadURL(user, "External Character Sheet\n\nID: " + inmateID +
                "   Name: " + llGetSubString(g_inmateInfo, 6, -1), note);

            llInstantMessage(user, "External Character Sheet for P-" + inmateID + ": " + note);

            llSleep(4.0); // Slow down reappearance of the menu.
            return;
        }
        // Make sure we can transfer a copy of the notecard to the toucher.
        else if (llGetInventoryPermMask(note, MASK_OWNER) & (PERM_COPY | PERM_TRANSFER))
        {
            llGiveInventory(user, note); // Offer notecard.
            llSleep(3.0);
            return;
        }
    }

    llInstantMessage(user, "No character sheet is available.");
}

// showMenu - Given a menu name string, shows the appropriate menu.
// ---------------------------------------------------------------------------------------------------------
showMenu(string menu, key user)
{
    if (!inRange(user) && user != llGetOwner()) // User out of range?
    {
        if (menu == "main") // Only CharSheet option in menu, so just give CharSheet.
        {
            giveCharSheet(user);
        }
        return; // Just return in other cases, to avoid spamming with notecards.
    }

    integer i;
    for (i = 0; i < llGetListLength(g_curMenus); i += 3) // Update existing entries and remove old.
    {
        if (llList2Key(g_curMenus, i) == user) // We found the current user.
        {
            if (menu == "") // Access last used menu if menu argument is empty.
            {
                menu = llList2String(g_curMenus, (i + 2));
            }

            g_curMenus = llListReplaceList(g_curMenus, [llGetTime(), menu], (i + 1), (i + 2));
        }
        else if (llList2Key(g_curMenus, i) != llGetOwner() &&
                 (llGetTime() - llList2Float(g_curMenus, (i + 1))) > 60.0)
        {
            g_curMenus = llDeleteSubList(g_curMenus, i, (i + 2)); // Prune old entries.
            i -= 3;
        }
    }

    if (menu == "") // Ensure we always have a menu name.
    {
        menu = "main";
    }

    if (llListFindList(g_curMenus, [(string)user]) <= -1) // Add user if they are new.
    {
        g_curMenus += [(string)user, llGetTime(), menu];
    }

    string text = "\n\nChoose an option:";
    list buttons = [];
    if (menu == "main") // Show main menu. ▩☐☒↺☠☯📜★✖
    {
        // Wearer Menu. (Others see this minus Settings)
        // -----------------------------------------------
        // ☯ CharSheet     ☠ Shock        📜 Poses
        // ☐ ChainGang     ☐ AnkleChain    ☐ Shackled
        // ☐ Leash         📜 Settings     ✖ Close
        //                 ✎ Reports

        text = "Main Menu" + text;

        if (user == llGetOwner()) // Settings and close button for owner.
        {
            buttons = ["📜 Settings", "✖ Close"];
        }
        else // Blank and close button for others.
        {
            buttons = ["☎ Reports", "✖ Close"];
        }

        if (getSetting(7) && g_leashMode == "leashanchor") // Leash toggle.
        {
            buttons = ["☒ Leash"] + buttons;
        }
        else
        {
            buttons = ["☐ Leash"] + buttons;
        }

        if (getSetting(7) && g_leashMode == "leftankle") // Chain gang toggle.
        {
            buttons += ["☒ ChainGang"];
        }
        else
        {
            buttons += ["☐ ChainGang"];
        }

        if (getSetting(5)) // Ankle chain toggle.
        {
            buttons += ["☒ AnkleChain"];
        }
        else
        {
            buttons += ["☐ AnkleChain"];
        }

        if (getSetting(6)) // Shackle link toggle.
        {
            buttons += ["☒ Shackles"];
        }
        else
        {
            buttons += ["☐ Shackles"];
        }

        buttons += ["☯ CharSheet", "☠ Shock", "📜 Poses"];
    }
    else if (menu == "poses") // Poses menu.
    {
        text = "Pose Selection Menu" + text;
        buttons = [" ", " ", "↺ Main", "웃 Back U", "✖ Release", "웃 ComboSet", 
                   "웃 Front X", "웃 Front V", "웃 Back V"];
    }
    else if (menu == "settings") // Settings menu.
    {
        buttons = [" ", " ", "↺ Main", "✎ CharName", "★ Version", "☎ Reports",
                   "📜 InmateID", "📜 Textures"];

        if (!getSetting(8))
        {
            buttons += ["☒ WalkSound"];
        }
        else
        {
            buttons += ["☐ WalkSound"];
        }
    }
    else if (menu == "textures") // Textures menu.
    {
        text = "Texture Select Menu" + text;
        buttons = [" ", " ", "↺ Settings", "▩ Red", "▩ Blue", "▩ Black", 
                   "▩ White", "▩ Orange", "▩ Lilac"];
    }
    llDialog(user, text, buttons, getAvChannel(llGetOwner()));
}

// The main event state/thread of the collar program.
// ---------------------------------------------------------------------------------------------------------
default
{
    // Initialize collar. Stage 1.
    // -----------------------------------------------------------------------------------------------------
    state_entry()
    {
        llRequestPermissions(llGetOwner(),
            (PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION)
        );
    }

    // Initialize collar. Stage 2.
    // -----------------------------------------------------------------------------------------------------
    run_time_permissions(integer perm)
    {
        if (perm & (PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION))
        {
            versionCheck(FALSE); // Do initial startup version check.

            // Set the texture anim for the electric effects on the collar base.
            llSetLinkTextureAnim(LINK_THIS, ANIM_ON | LOOP, 2, 32, 32, 0.0, 64.0, 20.4);

            integer i; // Find the prims we will work with.
            string tag;
            for (i = 1; i <= llGetNumberOfPrims(); i++)
            {
                tag = llGetLinkName(i);
                if (tag == "powerCore")
                {
                    // Set texture anim for the power core.
                    llSetLinkTextureAnim(i, ANIM_ON | LOOP, ALL_SIDES, 20, 20, 0.0, 64.0, 30.4);
                }
                else if (tag == "LED")
                {
                    g_ledLink = i;
                }
                else if (tag == "leashingPoint")
                {
                    g_leashLink = i;
                }
                else if (tag == "chainToShacklesPoint")
                {
                    g_shackleLink = i;
                }
            }

            if (g_shackleLink <= 0 || g_leashLink <= 0)
            {
                llOwnerSay("FATAL: Missing chain emitters!");
                return;
            }

            // Quick and stupid way to make walk sounds settings persist through resets.
            setSetting(8, (integer)llList2String(llGetLinkPrimitiveParams(g_shackleLink, [PRIM_DESC]), 0));
            llSetLinkPrimitiveParamsFast(g_shackleLink, [PRIM_DESC, (string)i]);

            updateInmateInfo("", ""); // Update inmate info from link description.

            llMinEventDelay(0.2); // Slow events to reduce lag.

            resetParticles();
            shackleParticles(FALSE); // Stop any particle effects and init.
            leashParticles(FALSE);

            llListen(-8888,"",NULL_KEY,""); // Open up LockGuard and Lockmeister listens.
            llListen(-9119,"",NULL_KEY,"");

            llListen(getAvChannel(llGetOwner()), "", "", ""); // Open collar/cuffs avChannel.
            
            llSetTimerEvent(0.2); // Start the timer.
        }
    }

    // Reset the script on rez.
    // ---------------------------------------------------------------------------------------------------------
    on_rez(integer param)
    {
        llResetScript();
    }
    
    // Show the menu to the user on touch.
    // ---------------------------------------------------------------------------------------------------------
    touch_start(integer num)
    {
        showMenu("main", llDetectedKey(0));
    }

    // Parse and interpret commands.
    // ---------------------------------------------------------------------------------------------------------
    listen(integer chan, string name, key id, string mesg)
    {
        if (chan == getAvChannel(llGetOwner())) // Process RRDC Menu/Commands.
        {
            // RRDC Collar/Cuff Protocol Commands.
            // -------------------------------------------------------------------------------------------------
            if (llGetOwnerKey(id) != id) // Process RRDC commands.
            {
                list l = llParseString2List(mesg, [" "], []);
                if (llList2String(l, 1) == (string)llGetOwner()) // Sanity check for inmate/remote protocol.
                {
                    if (llToLower(llList2String(l, 0)) == "inmatequery") // inmatequery <user-key>
                    {
                        llRegionSayTo(id, g_appChan, "inmatereply " + // inmatereply <user-key> <inmate-number>
                            (string)llGetOwner() + " " + g_inmateInfo
                        );
                    }
                    else if (llToLower(llList2String(l, 0)) == "getmenu") // getmenu <user-key>
                    {
                        showMenu("", llGetOwnerKey(id)); // Blank menu stops charsheet spam when out of range.
                    }
                }
                else if (llList2String(l, 1) == "collarfrontloop") // LG tag match.
                {
                    name = llToLower(llList2String(l, 0));
                    if (name == "unlink") // unlink collarfrontloop <leash|shackle>
                    {
                        if (llToLower(llList2String(l, 2)) == "shackle")
                        {
                            shackleParticles(FALSE);
                        }
                        else if (getSetting(4)) // Leash.
                        {
                            resetParticles();
                            leashParticles(FALSE);
                        }
                    }
                    else if (name == "link") // link collarfrontloop <leash|shackle> <dest-uuid>
                    {
                        toggleMode(TRUE);
                        if (llToLower(llList2String(l, 2)) == "shackle")
                        {
                            g_shacklePartTarget = llList2Key(l, 3);
                            shackleParticles(TRUE);
                        }
                        else // Leash.
                        {
                            g_leashPartTarget = llList2Key(l, 3);
                            leashParticles(TRUE);
                        }
                    }       // linkrequest collarfrontloop <leash|shackle> <src-tag> <inner|outer>
                    else if (name == "linkrequest")
                    {
                        if (llToLower(llList2String(l, 2)) == "shackle") // Get the link UUID.
                        {
                            name = (string)llGetLinkKey(g_shackleLink);
                        }
                        else // Leash.
                        {
                            name = (string)llGetLinkKey(g_leashLink);
                        }

                        llWhisper(getAvChannel(llGetOwnerKey(id)), "link " + // Send link message.
                            llList2String(l, 3) + " " +
                            llList2String(l, 4) + " " + name
                        );
                    }
                    else if (name == "ping") // ping <dest-tag> <src-tag>
                    {
                        llWhisper(getAvChannel(llGetOwnerKey(id)), "pong " + 
                            llList2String(l, 2) + " " +
                            llList2String(l, 1)
                        );
                    }           // pong collarfrontloop <my-tag>
                    else if (name == "pong" && llList2String(l, 2) == g_leashMode)
                    {
                        id = llGetOwnerKey(id); // Add responder av keys to list.
                        if (id != llGetOwner() && llGetListLength(g_avList) <= 12 && 
                            llListFindList(g_avList, [(string)id]) <= -1)
                        {
                            g_avList += [(string)id];
                            g_pingCount = 5;
                        }
                    }
                    else if (name == "stopposes") // stopposes collarfrontloop
                    {
                        doAnimationOverride(FALSE);
                    }
                    else if (name == "stopleash") // stopleash collarfrontloop
                    {
                        resetLeash();
                    }
                }
                return;
            }
            // Misc Menu Commands.
            // -------------------------------------------------------------------------------------------------
            else if (mesg == "↺ Main") // Show main menu.
            {
                showMenu("main", id);
                return;
            }
            else if (mesg == "↺ Settings") // Show settings menu.
            {
                showMenu("settings", id);
                return;
            }
            else if (mesg == "✖ Close") // Close button does nothing but return.
            {
                return;
            }
            else if (mesg == "☯ CharSheet") // Give notecard.
            {
                giveCharSheet(id);
            }
            else if (inRange(id) || id == llGetOwner()) // Only parse these if we're in range/the wearer.
            {
                // Report Website Link
                // ---------------------------------------------------------------------------------------------
                if (mesg == "☎ Reports")
                {
                    llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                        " is accessing your file.");

                    string inmateID = llGetSubString(g_inmateInfo, 0, 4);
                    string inmateURL = "https://rrdc.xyz/inmate/" + inmateID;

                    llLoadURL(id, "RRDC Database Inmate Lookup\n\nID: " + inmateID +
                        "   Name: " + llGetSubString(g_inmateInfo, 6, -1), inmateURL);

                    llInstantMessage(id, "RRDC Database Lookup for P-" + inmateID + ": " + inmateURL);

                    llSleep(4.0); // Slow down reappearance of the menu.
                }
                // Shock Command.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "☠ Shock") // Shock feature.
                {
                    if (getSetting(9))
                    {
                        llInstantMessage(id, "The shock collar's capacitors are still recharging. " +
                            "Please try again in a moment.");
                    }
                    else
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " just activated your shock collar!");

                        llSetTimerEvent(0.0);
                        llTakeControls(
                                        CONTROL_FWD |
                                        CONTROL_BACK |
                                        CONTROL_LEFT |
                                        CONTROL_RIGHT |
                                        CONTROL_ROT_LEFT |
                                        CONTROL_ROT_RIGHT |
                                        CONTROL_UP |
                                        CONTROL_DOWN |
                                        CONTROL_LBUTTON |
                                        CONTROL_ML_LBUTTON,
                                        TRUE, FALSE
                        );
                        llStartAnimation("animCollarZap");
                        llLoopSound("27a18333-a425-30b1-1ab6-c9a3a3554903", 0.5); // soundZapLoop.
                        g_shockCount = 12; // 0.8 seconds, then 2.0 seconds.
                        doAnimationOverride(TRUE); // Ensure poses remain in effect despite shock.
                        llSetTimerEvent(0.2);
                    }
                }
                // Ankle Chain Toggle.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "☐ AnkleChain" || mesg == "☒ AnkleChain") // Toggle chain between ankles.
                {
                    setSetting(5, !getSetting(5));
                    if (getSetting(5))
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " attached your ankle chain.");

                        llWhisper(getAvChannel(llGetOwner()), "linkrequest rightankle inner leftankle inner");
                    }
                    else
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " removed your ankle chain.");

                        llWhisper(getAvChannel(llGetOwner()), "unlink leftankle inner");
                    }
                    playRandomSound(TRUE);
                }
                // Shackle Link Toggle.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "☐ Shackles" || mesg == "☒ Shackles") // Chains from wrists to ankles.
                {
                    setSetting(6, !getSetting(6));
                    if (getSetting(6))
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " attached your shackle links.");

                        llWhisper(getAvChannel(llGetOwner()), "linkrequest leftankle outer leftwrist outer");
                        llWhisper(getAvChannel(llGetOwner()), "linkrequest rightankle outer rightwrist outer");
                    }
                    else
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " removed your shackle links.");

                        llWhisper(getAvChannel(llGetOwner()), "unlink leftwrist outer");
                        llWhisper(getAvChannel(llGetOwner()), "unlink rightwrist outer");
                    }
                    playRandomSound(TRUE);
                }
                // Leash Commands.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "☐ Leash" || mesg == "☒ Leash")
                {
                    if (id == llGetOwner())
                    {
                        llInstantMessage(id, "No matter where you go, there you are.");
                    }
                    else if (getSetting(7) && g_leashMode == "leashanchor") // Turn off leash.
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " removed your leash.");

                        resetLeash();
                        playRandomSound(TRUE);
                    }
                    else // Grab leash.
                    {
                        if (getSetting(7)) // Switch to leash from chain gang.
                        {
                            resetLeash();
                        }

                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " attached your leash.");
                    
                        toggleMode(TRUE);

                        setSetting(7, TRUE);
                        g_leashMode       = "leashanchor";
                        g_leashPartTarget = (string)id;
                        g_partLife     = 2.4;
                        g_partGravity  = 0.15;

                        llWhisper(getAvChannel(id), "linkrequest leashanchor x collarfrontloop leash");
                        leashParticles(TRUE);
                        leashFollow(FALSE); // Start follow effect on id.
                        playRandomSound(TRUE);
                    }
                }
                // Chain Gang Commands.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "☐ ChainGang" || mesg == "☒ ChainGang")
                {
                    if (getSetting(7) && g_leashMode == "leftankle") // Turn off chain gang.
                    {
                        llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " removed you from the chain gang.");

                        resetLeash();
                        playRandomSound(TRUE);
                    }
                    else // Poll for Chain Gang.
                    {
                        if (getSetting(7)) // Switch to chain gang from leash.
                        {
                            resetLeash();
                        }

                        if (g_leashUser == "" || g_leashUser == (string)id)
                        {
                            llInstantMessage(id, "Scanning for nearby inmates. Please wait...");

                            g_leashUser = (string)id; // Start scan for chain gang anchors.
                            g_leashMode = "leftankle";
                            g_pingCount = 5;

                            llSensor("", NULL_KEY, AGENT, 10.0, PI);
                        }
                        else
                        {
                            llInstantMessage(id, "Someone else is currently using this feature. " +
                                "Please wait a moment and try again.");
                        }
                    }
                }
                // Chain Gang Inmate Selector.
                // ---------------------------------------------------------------------------------------------
                else if ((integer)mesg >= 1 && (integer)mesg <= llGetListLength(g_avList))
                {
                    llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                            " added you to a chain gang.");

                    name = llList2String(g_avList, ((integer)mesg - 1));

                    g_avList          = [];
                    g_leashUser       = "";
                    g_pingCount       = 0;
                    setSetting(7, TRUE);
                    g_leashPartTarget = name;

                    llWhisper(getAvChannel(llGetOwner()), "leashto leftankle outer " +
                        name + " " + "leftankle outer"
                    );

                    leashFollow(FALSE); // Start follow effect on id.
                    playRandomSound(TRUE);
                }
                // Pose Commands.
                // ---------------------------------------------------------------------------------------------
                else if (mesg == "📜 Poses") // Pose selection menu.
                {
                    llOwnerSay("secondlife:///app/agent/" + ((string)id) + "/completename" +
                        " is interacting with your handcuffs.");

                    showMenu("poses", id);
                    return;
                }
                else if (mesg == "웃 Back U") // Emitter is always leftwrist inner or collar shacklesPoint.
                { // linkrequest <dest-tag> <inner|outer> <src-tag> <inner|outer>
                    doAnimationOverride(FALSE);
                    g_animList = ["cuffedArmsBackU_001"];
                    shackleParticles(FALSE);
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest rightwrist outer leftwrist inner");
                    doAnimationOverride(TRUE);
                }
                else if (mesg == "웃 Back V")
                {
                    doAnimationOverride(FALSE);
                    g_animList = ["cuffedArmsBackV_001"];
                    shackleParticles(FALSE);
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest rightwrist inner leftwrist inner");
                    doAnimationOverride(TRUE);
                }
                else if (mesg == "웃 Front X")
                {
                    doAnimationOverride(FALSE);
                    g_animList = ["cuffedArmsFrontX_001"];
                    shackleParticles(FALSE);
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest rightwrist outer leftwrist inner");
                    doAnimationOverride(TRUE);
                }
                else if (mesg == "웃 Front V")
                {
                    doAnimationOverride(FALSE);
                    g_animList = ["cuffedArmsFrontV_002"];
                    shackleParticles(FALSE);
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest rightwrist inner leftwrist inner");
                    doAnimationOverride(TRUE);
                }
                else if (mesg == "웃 ComboSet") // Combination two poses.
                {
                    doAnimationOverride(FALSE);
                    g_animList = ["cuffedArmsCollar001", "cuffedNeckForward001"];
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest leftwrist inner collarfrontloop shackle");
                    llWhisper(getAvChannel(llGetOwner()), "linkrequest rightwrist inner leftwrist inner");
                    doAnimationOverride(TRUE);
                }
                else if (mesg == "✖ Release") // Release from pose.
                {
                    doAnimationOverride(FALSE);
                    shackleParticles(FALSE);
                    llWhisper(getAvChannel(llGetOwner()), "unlink leftwrist inner");
                }
                else if (id == llGetOwner()) // Sound and texture commands are owner locked.
                {
                    // Settings Commands.
                    // -----------------------------------------------------------------------------------------
                    if (mesg == "📜 Settings") // Settings menu.
                    {
                        showMenu("settings", id);
                        return;
                    }
                    else if (mesg == "📜 InmateID") // Inmate number select.
                    {
                        setSetting(10, FALSE); // Unset request type flag.
                        g_requestKey = llHTTPRequest("https://rrdc.xyz/json/UUID/" + (string)llGetOwner(), [], "");
                        return;
                    }
                    else if (mesg == "✎ CharName") // Set character name.
                    {
                        llTextBox(id, "\nWhat is your inmate character's name?\n\nCurrent value: " +
                            llList2String(llParseString2List(g_inmateInfo, [" "], []), 1),
                            getAvChannel(llGetOwner()));
                        return;
                    }
                    else if (mesg == "★ Version") // Version Check.
                    {
                        versionCheck(TRUE);
                    }
                    // Texture Commands.
                    // -----------------------------------------------------------------------------------------
                    else if (mesg == "📜 Textures") // Texture select.
                    {
                        showMenu("textures", id);
                        return;
                    }
                    else if (mesg == "▩ Blue") // Set textures.
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Blue.
                            PRIM_TEXTURE, 0, "7add76cf-24f4-a2d3-6102-c6338db891fc",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "e84a056b-f95f-a0db-acf0-7354749bbc03" // RRDC_Cuff_Diffuse_Blue.
                        );
                    }
                    else if (mesg == "▩ Black")
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Blk.
                            PRIM_TEXTURE, 0, "8c61b3ad-2723-cc83-c454-e602a8258ed7",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "04c857b4-78d1-8add-3d45-c134e70afa8f" // RRDC_Cuff_Diffuse_Black.
                        );
                    }
                    else if (mesg == "▩ White")
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Wte.
                            PRIM_TEXTURE, 0, "aaff45c0-a0ef-c00d-58cb-bff31860d7be",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "700b9155-5138-e4c7-d194-1db9a6c09861" // RRDC_Cuff_Diffuse_Basic.
                        );
                    }
                    else if (mesg == "▩ Orange")
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Orange.
                            PRIM_TEXTURE, 0, "658f1177-cede-3ea2-57f9-d50e2b1402e4",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "ec94158c-2455-be49-a07d-7604be76c933" // RRDC_Cuff_Diffuse_Orange.
                        );
                    }
                    else if (mesg == "▩ Lilac")
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Lilac.
                            PRIM_TEXTURE, 0, "25be29e2-cc69-1559-4ad9-511d130554b9",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "93628600-5364-0a17-fcd8-e617ddd731e5" // RRDC_Cuff_Diffuse_Lilac.
                        );
                    }
                    else if (mesg == "▩ Red")
                    {
                        llSetLinkPrimitiveParamsFast(LINK_THIS, [ // RRDC_Collar_Metals_Diffuse_Red.
                            PRIM_TEXTURE, 0, "bfea9b1f-5860-0bff-0382-baa00c00172f",
                            <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
                        ]);
                        llWhisper(getAvChannel(llGetOwner()), "settexture allfour " +
                            "cc6ec646-cdc4-44b7-9df3-fc7ba33764d3" // RRDC_Cuff_Diffuse_Red.
                        );
                    }
                    // Sound Commands.
                    // -----------------------------------------------------------------------------------------
                    else if (mesg == "☐ WalkSound" || mesg == "☒ WalkSound" ) // Turn chain walk sounds on/off.
                    {
                        setSetting(8, !getSetting(8));
                        llSetLinkPrimitiveParamsFast(g_shackleLink, 
                            [PRIM_DESC, (string)getSetting(8)]);
                    }
                    // Set Inmate Number.
                    // -----------------------------------------------------------------------------------------
                    else if (((integer)mesg) > 0 && llStringLength(mesg) == 5)
                    {
                        updateInmateInfo(mesg, ""); // Update inmate number.
                        llOwnerSay("Your inmate number has been set to: " +
                            llList2String(llParseString2List(g_inmateInfo, [" "], []), 0));
                    }
                    // Set Inmate Name.
                    // -----------------------------------------------------------------------------------------
                    else if (llStringLength(mesg) <= 30)
                    {
                        updateInmateInfo("", llStringTrim(mesg, STRING_TRIM));
                        llOwnerSay("Your character name has been set to: " +
                            llList2String(llParseString2List(g_inmateInfo, [" "], []), 1));
                    }
                }
            }
            showMenu("", id); // Reshow current menu. Whitespace menu items end up here.
        }
        // Lockmeister Protocol Commands.
        // -----------------------------------------------------------------------------------------------------
        else if(chan == -8888 && llGetSubString(mesg, 0, 35) == ((string)llGetOwner()))
        {
            if(llGetSubString(mesg, 36, -1) == "collar") // Talking to us?
            {
                toggleMode(FALSE);
                llRegionSayTo(id, -8888, mesg + " ok");
            }
            else if (llGetSubString(mesg, 36, 54) == "|LMV2|RequestPoint|" && // LMV2.
                     llGetSubString(mesg, 55, -1) == "collar")
            {
                llRegionSayTo(id, -8888, ((string)llGetOwner()) + "|LMV2|ReplyPoint|" + 
                    llGetSubString(mesg, 55, -1) + "|" + ((string)llGetLinkKey(g_leashLink))
                );
            }
        }
        // LockGuard Protocol Commands.
        // -----------------------------------------------------------------------------------------------------
        else if(chan == -9119 && llSubStringIndex(mesg, "lockguard " + ((string)llGetOwner())) == 0)
        {
            list tList = llParseString2List(mesg, [" "], []);
            
            // lockguard [avatarKey/ownerKey] [item] [command] [variable(s)] 
            if(llList2String(tList, 2) == "collarfrontloop" || llList2String(tList, 2) == "all")
            {
                integer i = 3; // Start at the first command position and parse the commands.
                while(i < llGetListLength(tList))
                {                    
                    name = llList2String(tList, i);
                    if(name == "link")
                    {
                        toggleMode(FALSE);
                        g_leashPartTarget = llList2Key(tList, (i + 1));
                        leashParticles(TRUE);
                        i += 2;
                    }
                    else if(name == "unlink" && !getSetting(4)) // If in LM/LG mode.
                    {
                        resetParticles();
                        leashParticles(FALSE);
                        tList = [];
                        return;
                    }
                    else if(name == "gravity")
                    {
                        toggleMode(FALSE);
                        g_partGravity = fClamp(llList2Float(tList, (i + 1)), 0.0, 100.0);
                        i += 2;
                    }
                    else if(name == "life")
                    {
                        toggleMode(FALSE);
                        g_partLife = fClamp(llList2Float(tList, (i + 1)), 0.0, 30.0);
                        i += 2;
                    }
                    else if(name == "texture")
                    {
                        toggleMode(FALSE);
                        name = llList2String(tList, (i + 1));
                        if (name != "chain" && name != "rope")
                        {
                            g_partTex = name;
                        }
                        i += 2;
                    }
                    else if(name == "rate")
                    {
                        toggleMode(FALSE);
                        g_partRate = fClamp(llList2Float(tList, (i + 1)), 0.0, 60.0);
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
                        g_partSizeX = fClamp(llList2Float(tList, (i + 1)), 0.03125, 4.0);
                        g_partSizeY = fClamp(llList2Float(tList, (i + 2)), 0.03125, 4.0);
                        i += 3;
                    }
                    else if(name == "color")
                    {
                        toggleMode(FALSE);
                        g_partColor.x = fClamp(llList2Float(tList, (i + 1)), 0.0, 1.0);
                        g_partColor.y = fClamp(llList2Float(tList, (i + 2)), 0.0, 1.0);
                        g_partColor.z = fClamp(llList2Float(tList, (i + 3)), 0.0, 1.0);
                        i += 4;
                    }
                    else if(name == "ping")
                    {
                        llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " +
                            "collarfrontloop  okay"
                        );
                        i++;
                    }
                    else if(name == "free")
                    {
                        if(getSetting(2))
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " + 
                                "collarfrontloop no"
                            );
                        }
                        else
                        {
                            llRegionSayTo(id, -9119, "lockguard " + ((string)llGetOwner()) + " " + 
                                "collarfrontloop yes"
                            );
                        }
                        i++;
                    }
                    else // Skip unknown commands.
                    {
                        i++;
                    }
                }
                
                leashParticles(getSetting(2)); // Refresh particles.
            }
        }
    }

    // Event for getting a response from the inmate number API.
    // ---------------------------------------------------------------------------------------------------------
    http_response(key reqID, integer stat, list m, string body)
    {
        if (reqID == g_requestKey) // We requested this?
        {
            body = llStringTrim(body, STRING_TRIM); // Trim and parse the response.

            if (getSetting(10)) // Is it a version check response?
            {
                string v = llJsonGetValue(body, ["collarVersion"]);
                if (v == JSON_INVALID || v == JSON_NULL)
                {
                    llOwnerSay("Could not retrieve version information. Please contact staff.");
                }
                else // Determine which version is the oldest.
                {
                    stat = (g_appVersion == llList2String(llListSort([g_appVersion, v], 1, TRUE), 0) &&
                            g_appVersion != v);

                    if (getSetting(11) || stat) // Verbose or update required?
                    {
                        llOwnerSay("Current Version: " + g_appVersion + " Latest version: " + v);

                        if (stat)
                        {
                            llOwnerSay("A new version is available. Please visit a collar vendor to update.");
                        }
                        else
                        {
                            llOwnerSay("Your collar is up to date.");
                        }
                    }
                }
            }
            else // Inmate number response.
            {
                m = llJson2List(body); // Convert to a list of objects.

                integer i = 0;
                list l = [];
                for (i = 0; i < llGetListLength(m) && i < 9; i++) // Get all valid inmateIDs.
                {
                    string num = llJsonGetValue(llList2String(m, i), ["inmateID"]);
                    if (num != JSON_INVALID && num != JSON_NULL)
                    {
                        l += [num];
                    }
                }

                if (llGetListLength(l) > 0) // If the list is non-zero in size, show a menu.
                {
                    llDialog(llGetOwner(), 
                        "\nWhat inmate number do you want to use?\n\nCurrent value: " + 
                        llList2String(llParseString2List(g_inmateInfo, [" "], []), 0),
                        [" ", " ", "↺ Settings"] + l, getAvChannel(llGetOwner())
                    );
                }
                else // Tell the user they have no inmate ids.
                {
                    llInstantMessage(llGetOwner(),
                        "No inmate numbers could be found. Please contact staff for assistance."
                    );
                    showMenu("", llGetOwner());
                }
            }
        }
        g_requestKey = NULL_KEY;
    }

    // Controls timed effects such as blinking light and shock.
    // ---------------------------------------------------------------------------------------------------------
    timer()
    {
        // Persistent AO (0.2 seconds).
        // -----------------------------------------------------------------------------------------------------
        if (g_animState != llGetAnimation(llGetOwner()))
        {
            g_animState = llGetAnimation(llGetOwner());
            doAnimationOverride(TRUE);
        }

        // Shock effects.
        // -----------------------------------------------------------------------------------------------------
        if (g_shockCount > 1)
        {
            if (g_shockCount == 11) // Ending effect.
            {
                llStopSound();
                llPlaySound("a4602ead-96f3-ee86-5e0f-63faeb1ed7cf", 0.5); // soundZapStop.
            }
            g_shockCount--;
        }
        else if (g_shockCount == 1) // Release controls when the anim is done.
        {
            g_shockCount = -76;                       // 15 seconds timer.
            setSetting(9, TRUE); // Set cooldown bit.

            llTakeControls(
                            CONTROL_FWD |
                            CONTROL_BACK |
                            CONTROL_LEFT |
                            CONTROL_RIGHT |
                            CONTROL_ROT_LEFT |
                            CONTROL_ROT_RIGHT |
                            CONTROL_UP |
                            CONTROL_DOWN |
                            CONTROL_LBUTTON |
                            CONTROL_ML_LBUTTON,
                            TRUE, TRUE
            );
        }
        else if (g_shockCount == -1) // Release cooldown.
        {
            setSetting(9, FALSE);
            g_shockCount = 0;
        }
        else if (g_shockCount < 0) // Cooldown wait.
        {
            g_shockCount++;
        }

        // Pong message wait timer.
        // -----------------------------------------------------------------------------------------------------
        if (g_pingCount == 1)
        {
            integer i; // Show the chain gang selection dialog.
            string text  = "Select an Inmate by number below:\n\n";
            list buttons = [];
            for (i = 0; i < llGetListLength(g_avList); i++)
            {
                text += ((string)(i + 1)) + ". " + llKey2Name(llList2Key(g_avList, i));
                buttons += [((string)(i + 1))];
            }

            if (buttons != [])
            {
                llDialog(g_leashUser, text, buttons, getAvChannel(llGetOwner()));
                g_pingCount = -225; // 45 seconds.
            }
            else
            {
                llInstantMessage(g_leashUser, "There aren't any other inmates around.");
                g_leashUser = "";
                g_pingCount = 0;
            }
        }
        else if (g_pingCount > 0)
        {
            g_pingCount--;
        }
        else if (g_pingCount == -1 && !getSetting(7)) // To clear the leash user.
        {
            llInstantMessage(g_leashUser, "Inmate selection menu has expired.");
            g_leashUser = "";
            g_pingCount = 0;
        }
        else if (g_pingCount < 0)
        {
            g_pingCount++;
        }

        // Blinking LED effects (1.0 seconds).
        // -----------------------------------------------------------------------------------------------------
        if (g_ledCount++ >= 4)
        {
            setSetting(1, !getSetting(1));
            if (getSetting(1)) 
            {
                llSetLinkPrimitiveParamsFast(g_ledLink, [
                    PRIM_COLOR, ALL_SIDES, <0.3, 0.0, 0.0>, llGetAlpha(0), 
                    PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0.5, 0.5, 0.1,
                    PRIM_GLOW, ALL_SIDES, 0.0
                ]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(g_ledLink, [
                    PRIM_COLOR, ALL_SIDES, <1.0, 0.0, 0.0>, llGetAlpha(0), 
                    PRIM_POINT_LIGHT, TRUE, <1.0, 0.0, 0.0>, 0.35, 0.075, 0.1,
                    PRIM_GLOW, ALL_SIDES, 1.0
                ]);
            }
            g_ledCount = 0;
        }
    }

    // Finds nearby avatars and queries them for chain gang anchors.
    // ---------------------------------------------------------------------------------------------------------
    sensor(integer num)
    {
        integer i;
        for (i = 0; i < num; i++)
        {
            if (llDetectedKey(i) != llGetOwner()) // Exclude the wearer.
            {
                llWhisper(getAvChannel(llDetectedKey(i)), "ping leftankle collarfrontloop");
            }
        }
        g_pingCount = 5;
    }

    // Controls random chain sound effects.
    // ---------------------------------------------------------------------------------------------------------
    moving_start()
    {
        playRandomSound(FALSE);
    }

    moving_end()
    {
        playRandomSound(FALSE);
    }

    // Tells the leash follow system whether the avatar needs to move or not.
    // ---------------------------------------------------------------------------------------------------------
    at_target(integer tnum, vector targetpos, vector ourpos)
    {
        leashFollow(TRUE); // Let the follow system know we've reached our target.
    }

    not_at_target()
    {
        leashFollow(FALSE); // Let the follow system know we're not at target yet.
    }
}
