// [SGD] RRDC Baton Holster v1.0.1 - Copyright 2020 Alex Pascal (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_appChan       = 44;           // Channel this app set runs on.
integer g_isHolstered   = TRUE;         // TRUE if the baton is holstered.
integer g_batonPrim     = 0;            // Prim of the baton item for alpha toggle.
// ---------------------------------------------------------------------------------------------------------

// holsterBaton - Holster Effects related to holstering the baton.
// ---------------------------------------------------------------------------------------------------------
holsterBaton()
{
    llTriggerSound("e9421ed0-53fa-0fa9-c3a8-ca01624f12bb", 0.8);
    llWhisper(g_appChan, "baton sling");
    llSetLinkAlpha(g_batonPrim, 1.0, ALL_SIDES);
    llSetAlpha(0.0, 1);
    llSetAlpha(1.0, 2);
}

// drawBaton - Holster effects related to drawing the baton.
// ---------------------------------------------------------------------------------------------------------
drawBaton()
{
    llTriggerSound("e9421ed0-53fa-0fa9-c3a8-ca01624f12bb", 0.8);
    llSetAlpha(0.0, 2);
    llSetAlpha(1.0, 1);
    llSetLinkAlpha(g_batonPrim, 0.0, ALL_SIDES);
    llWhisper(g_appChan, "baton draw");
}

// findBatonPrim - Find the baton prim in the linkset. It must be named 'baton'.
// ---------------------------------------------------------------------------------------------------------
findBatonPrim()
{
    integer i;
    for (i = 1; i <= llGetNumberOfPrims(); i++)
    {
        if (llGetLinkName(i) == "baton")
        {
            g_batonPrim = i;
            return;
        }
    }
}

default
{
    state_entry() // Init.
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        findBatonPrim();
        holsterBaton();
        llListen(g_appChan, "", "", "");
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

    touch_start(integer num) // Toggle holster if the owner touches it.
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            if (g_isHolstered = !g_isHolstered)
            {
                holsterBaton();
            }
            else
            {
                drawBaton();
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
                g_isHolstered = TRUE;                  // /44baton sling
                holsterBaton();
            }
        }
    }
}