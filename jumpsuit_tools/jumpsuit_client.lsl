// [SGD] RRDC Jumpsuit Mini-HUD - Client v1.0 - Copyright 2021 Sasha Wyrding (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_appChan     = -78398383;              // The channel for this application set.
integer g_cLinkNum    = LINK_THIS;              // The link number of the prim that the crotch face is in.
integer g_cFaceNum    = 4;                      // The face number to toggle.

// getAvChannel - Given an avatar key, returns a static channel XORed with g_appChan.
// ---------------------------------------------------------------------------------------------------------
integer getAvChannel(key av)
{
    return (0x80000000 | ((integer)("0x"+(string)av) ^ g_appChan));
}

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        llListen(getAvChannel(llGetOwner()), "", "", "");
    }

    listen(integer chan, string name, key id, string mesg)
    {
        if (llGetOwnerKey(id) == llGetOwner())
        {
            if (mesg == "JUMPSUIT_CROTCH_HIDE")
            {
                llSetLinkAlpha(g_cLinkNum, 0.0, g_cFaceNum);
            }
            else if (mesg == "JUMPSUIT_CROTCH_SHOW")
            {
                llSetLinkAlpha(g_cLinkNum, 1.0, g_cFaceNum);
            }
        }
    }
}
