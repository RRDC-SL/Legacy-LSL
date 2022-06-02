// [SGD] Baton Prop Held v1.0.1 - Copyright 2020 Alex Pascal (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_appChan       = 44;           // Channel this app set runs on.
integer g_isHolstered   = TRUE;         // TRUE if the baton is holstered.
integer g_isOn          = FALSE;        // TRUE if the baton is activated.
integer g_emitterPrim   = 0;            // Link number of the particle emitter.
float   g_curTimer      = 0.0;          // Current delay for the spark timer event.
float   g_backTimer     = 0.0;          // Timer for FX backgrounding.
// ---------------------------------------------------------------------------------------------------------

// doHoldAnimation - Starts or stops the correct animation for the attach point.
// ---------------------------------------------------------------------------------------------------------
doHoldAnimation(integer start)
{
    if (llGetAttached() == ATTACH_LHAND) // Left hand.
    {
        if (start)
        {
            llStartAnimation("holdL");
        }
        else
        {
            llStopAnimation("holdL");
        }
    }
    else if (llGetAttached() == ATTACH_RHAND) // Right hand.
    {
        if (start)
        {
            llStartAnimation("holdR");
        }
        else
        {
            llStopAnimation("holdR");
        }
    } // Other attach points don't have anims.
}

// turnOn - Effects related to turning the baton on.
// ---------------------------------------------------------------------------------------------------------
turnOn()
{
    g_backTimer = 0.0;
    llSetTimerEvent(g_curTimer = 1.0);
    llTriggerSound("d57b8592-b9d7-be1b-25ea-35fcbe4d9070", 1.0);
    llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_TEXTURE, ALL_SIDES, "468d4e68-cbe0-9300-7572-5b2d6faabfcf", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
        PRIM_GLOW, ALL_SIDES, 0.3
    ]);
    llLoopSound("39e5bf0e-cc12-5fb4-0408-0c878cc6c77f", 0.004);
}

// turnOff - Effects related to turning the baton off.
// ---------------------------------------------------------------------------------------------------------
turnOff()
{
    llSetTimerEvent(0.0);
    llTriggerSound("d57b8592-b9d7-be1b-25ea-35fcbe4d9070", 1.0);
    llSetLinkPrimitiveParamsFast(LINK_THIS, [
        PRIM_TEXTURE, ALL_SIDES, "2e231ce1-4634-570f-2e82-5691abc28a42", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0,
        PRIM_GLOW, ALL_SIDES, 0.0
    ]);
    llStopSound();
}

// drawBaton - Baton effects related to drawing the baton.
// ---------------------------------------------------------------------------------------------------------
drawBaton()
{
    llWhisper(g_appChan, "baton draw");
    llSetAlpha(1.0, ALL_SIDES);
    doHoldAnimation(TRUE);
}

// holsterBaton - Baton Effects related to holstering the baton.
// ---------------------------------------------------------------------------------------------------------
holsterBaton()
{
    llWhisper(g_appChan, "baton sling");
    llSetAlpha(0.0, ALL_SIDES);
    doHoldAnimation(FALSE);
}

// findEmitterPrim - Find the particle emitter prim in the linkset. It must be named 'emitter'.
// ---------------------------------------------------------------------------------------------------------
findEmitterPrim()
{
    integer i;
    for (i = 1; i <= llGetNumberOfPrims(); i++)
    {
        if (llGetLinkName(i) == "emitter")
        {
            g_emitterPrim = i;
            return;
        }
    }
}

default
{
    timer() // Handles itermittent sparking.
    {
        g_backTimer += g_curTimer;
        llSetTimerEvent(g_curTimer = 0.2 + llFrand(4.0));
        llTriggerSound("0f5dec85-611f-15ed-1067-9e4e2fce5405", 0.6 - (0.594 * (g_backTimer > 18.0)));
        
        llLinkParticleSystem(g_emitterPrim, [
            PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_EXPLODE,
            PSYS_SRC_BURST_RADIUS,      0.0,
            PSYS_SRC_BURST_SPEED_MIN,   0.1,
            PSYS_SRC_BURST_SPEED_MAX,   0.5,
            PSYS_SRC_BURST_PART_COUNT,  7,
            PSYS_SRC_MAX_AGE,           0.0,
            PSYS_PART_MAX_AGE,          1.0,
            PSYS_SRC_BURST_RATE,        1.0,
            PSYS_PART_START_GLOW,       0.2,
            PSYS_PART_END_GLOW,         0.0,
            PSYS_SRC_TEXTURE,           "",
            PSYS_PART_START_COLOR,      <1.000, 0.707, 0.414>,
            PSYS_PART_START_SCALE,      <0.03125, 0.03125, 0.0000>,
            PSYS_SRC_ACCEL,             <0.0, 0.0, -2.5>,
            PSYS_PART_FLAGS, PSYS_PART_EMISSIVE_MASK
        ]);
        llSleep(0.1);
        llLinkParticleSystem(g_emitterPrim, []);
    }

    moving_end() // Reset the FX backgrounder when the avatar moves.
    {
        g_backTimer = 0.0;
    }

    state_entry() // Init.
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        findEmitterPrim();
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
    }

    run_time_permissions(integer perm) // Init animation perms.
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            holsterBaton();
            llListen(g_appChan, "", "", "");
        }
    }

    on_rez(integer start) // Reset on rez.
    {
        llResetScript();
    }

    changed(integer change) // Reset if we changed the linkset.
    {
        if (change & CHANGED_LINK)
        {
            llResetScript();
        }
    }

    touch_start(integer num) // Toggle on_off state if not holstered.
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            if (!g_isHolstered)
            {
                if (g_isOn = !g_isOn)
                {
                    turnOn();
                }
                else
                {
                    turnOff();
                }
            }
        }
    }

    listen(integer chan, string name, key id, string mesg) // Toggle holster on command.
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            mesg = llToLower(llStringTrim(mesg, STRING_TRIM));

            if (mesg == "baton draw" && g_isHolstered) // /44baton draw
            {
                g_isHolstered = FALSE;
                drawBaton();
            }
            else if ((mesg == "baton sling" || mesg == "baton holster") && !g_isHolstered)
            {                                          // /44baton holster
                if (g_isOn)                            // /44baton sling
                {
                    g_isOn = FALSE;
                    turnOff();
                    llSleep(0.1);
                }
                g_isHolstered = TRUE;
                holsterBaton();
            }
            else if (mesg == "baton on" && !g_isHolstered && !g_isOn)
            {                                          // /44baton on
                g_isOn = TRUE;
                turnOn();
            }
            else if (mesg == "baton off" && !g_isHolstered && g_isOn)
            {                                          // /44baton off
                g_isOn = FALSE;
                turnOff();
            }
        }
    }
}