// [SGD] RRDC Jumpsuit Crotch Modificator v1.0 - Copyright 2021 Sasha Wyrding (Alex Carpenter) @ Second Life.
// Instructions: Make copy of jumpsuit. Drop script into the copy. Presto, crotchless version.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_cLinkNum    = LINK_THIS;              // The link number of the prim that the crotch face is in.
integer g_cFaceNum    = 4;                      // The face number to toggle.

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);
        llSetLinkAlpha(g_cLinkNum, 0.0, g_cFaceNum);
        llSleep(2.0);
        llOwnerSay("Modifications complete!");
        llRemoveInventory(llGetScriptName());
    }
}
