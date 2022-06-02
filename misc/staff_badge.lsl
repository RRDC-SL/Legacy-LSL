// <snipped LSL preprocessor text>
float txtCharSpacing = 0.03;
key textFont = "7910e702-2efc-78a5-aa78-ae0cbf3e03d4";

integer primN1;
integer primN2;
integer primP1;
integer primP2;

integer primID;

integer lMode = 0;


string txtChrIndex = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n\n\n\n\n";

offsetTextures(integer prim, vector gO1, vector gO2, vector gO3, vector gO4, vector gO5, vector gO6, vector gO7, vector gO8)
{
    llSetLinkPrimitiveParamsFast(prim, [
        PRIM_TEXTURE, 0, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO1, 0.0,
        PRIM_TEXTURE, 1, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO2, 0.0,
        PRIM_TEXTURE, 2, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO3, 0.0,
        PRIM_TEXTURE, 3, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO4, 0.0,
        PRIM_TEXTURE, 4, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO5, 0.0,
        PRIM_TEXTURE, 5, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO6, 0.0,
        PRIM_TEXTURE, 6, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO7, 0.0,
        PRIM_TEXTURE, 7, textFont, <0.1 - txtCharSpacing, 0.1, 0>, gO8, 0.0
        
    ]);
}

vector getGridOffset(integer i)
{
    integer r = i / 10;
    integer c = i % 10;
    
    float x = -0.4515 + (0.1 * c);
    float y = 0.45 - (0.1 * r) + 0.00;
    
    return <x, y, 0.0>;
}

//#line 1 "D:/SL Stuff\\Scripty Shit\\D Lib\\d_lib_utilsLinkset.lsl"
integer findChildByName(string nName)
{
    integer i;
    for(i=1;i<=llGetNumberOfPrims();i++)
    {
        string pName = llGetLinkName(i);
        if(pName == nName)
            return i;
    }
    return 0; 
}

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
            string nameURI = "secondlife:///app/agent/" + ((string)llGetOwner()) + "/completename";

            llLoadURL(user, "External Character Sheet\n\nID: " + nameURI, note);

            llInstantMessage(user, "External Character Sheet for " + nameURI + ": " + note);
            return;
        }
        // Make sure we can transfer a copy of the notecard to the toucher.
        else if (llGetInventoryPermMask(note, MASK_OWNER) & (PERM_COPY | PERM_TRANSFER))
        {
            llGiveInventory(user, note); // Offer notecard.
            return;
        }
    }
    
    llInstantMessage(user, "No character sheet is available.");
}

default
{
    on_rez(integer param)
    {
        llResetScript();
    }
    
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 1024);

        primN1 = findChildByName("n1");
        primN2 = findChildByName("n2");
        primP1 = findChildByName("p1");
        primP2 = findChildByName("p2");

        primID = findChildByName("id");
        
        llListen(524196, "", llGetOwner(), "");
    }
    
    touch_start(integer tNum)
    {
        key toucher = llDetectedKey(0);
        
        if(toucher == llGetOwner())
        {
            llDialog(toucher, "What do.", [
                "Name", "Position", "ID Num", "Image", "Rank", "CharSheet"], 524196);
        }
        else
        {
            giveCharSheet(toucher);
        }
    }
    
    listen(integer chan, string name, key id, string str)
    {
        if(llGetOwnerKey(id) != llGetOwner())
            return;
            
        if (str == "CharSheet")
        {
            giveCharSheet(llGetOwner());
        }
        else if(str == "Image")
        {
            lMode = 0;
            llTextBox(id, "Enter new texture ID:", 524196);
        }
        else if(str == "Name")
        {
            lMode = 1;
            llTextBox(id, "Enter new name:", 524196);
        }
        else if(str == "Position")
        {
            lMode = 2;
            llTextBox(id, "Enter new position:", 524196);
        }
        else if(str == "ID Num")
        {
            lMode = 3;
            llTextBox(id, "Enter new ID number:", 524196);
        }
        
        else if(str == "Rank") //This is new, please help!
        {       
            lMode = 4;
            llDialog(id, "Select the rank you wish to display", [
                "Spacer", "Petty Officer", "Chief Petty Officer", 
                "Lieutenant", "1st Lieutenant", "Lt. Commander", 
                "Captain"], 524196);

        }
        else if (str == "Spacer")
        {
            llSetTexture("18023a59-d67e-d773-4772-05dc372ebf46", 0);
            llListenRemove(524196);
        }
        else if (str == "Petty Officer")
        {
            llSetTexture("1a53510e-c54e-2a32-972c-c9f64cea389d", 0);
            llListenRemove(524196);
        }
        else if (str == "Chief Petty Officer")
        {
            llSetTexture("369764af-469c-923a-f238-7380a548dd95", 0);
            llListenRemove(524196);
        }
        else if (str == "Lieutenant")
        {
            llSetTexture("13fd1d91-eed2-cd6a-b335-fb66d1a2f746", 0);
            llListenRemove(524196);
        }
        else if (str == "1st Lieutenant")
        {
            llSetTexture("e9b9316d-b19c-8fc9-0f3c-e9233a40cc3c", 0);
            llListenRemove(524196);
        }
        else if (str == "Lt. Commander")
        {
            llSetTexture("82614392-1708-156c-cd53-5b38f5281379", 0);
            llListenRemove(524196);
        }
        else if (str == "Captain")
        {
            llSetTexture("0a0543d2-e685-33e0-a52a-eae612a7527f", 0);
            llListenRemove(524196);
        }
        else if(lMode == 0)
        {
            llSetTexture((key)str, 1);
        }
        else if(lMode == 1)
        {
            string line = str;
            integer len = llStringLength(str);
            if(len < 16)
            {
                integer lettersMissing = 16 - len;
                
                integer i;
                for(i=0;i<lettersMissing;i++)
                    line = " "+line;
            }
            
            string partOne = llGetSubString(line, 0, 7);
            string partTwo = llGetSubString(line, 8, -1);
            
            vector gO1 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 0, 0)));
            vector gO2 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 1, 1)));
            vector gO3 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 2, 2)));
            vector gO4 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 3, 3)));
            vector gO5 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 4, 4)));
            vector gO6 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 5, 5)));
            vector gO7 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 6, 6)));
            vector gO8 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 7, 7)));
            offsetTextures(primN1, gO1, gO2, gO3, gO4, gO5, gO6, gO7, gO8);
            
            gO1 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 0, 0)));
            gO2 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 1, 1)));
            gO3 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 2, 2)));
            gO4 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 3, 3)));
            gO5 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 4, 4)));
            gO6 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 5, 5)));
            gO7 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 6, 6)));
            gO8 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 7, 7)));
            offsetTextures(primN2, gO1, gO2, gO3, gO4, gO5, gO6, gO7, gO8);
        }
        else if(lMode == 2)
        {
            string line = str;
            integer len = llStringLength(str);
            if(len < 16)
            {
                integer lettersMissing = 16 - len;
                
                integer i;
                for(i=0;i<lettersMissing;i++)
                    line = " "+line;
            }
            
            string partOne = llGetSubString(line, 0, 7);
            string partTwo = llGetSubString(line, 8, -1);
            
            vector gO1 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 0, 0)));
            vector gO2 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 1, 1)));
            vector gO3 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 2, 2)));
            vector gO4 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 3, 3)));
            vector gO5 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 4, 4)));
            vector gO6 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 5, 5)));
            vector gO7 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 6, 6)));
            vector gO8 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partOne, 7, 7)));
            offsetTextures(primP1, gO1, gO2, gO3, gO4, gO5, gO6, gO7, gO8);
            
            gO1 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 0, 0)));
            gO2 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 1, 1)));
            gO3 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 2, 2)));
            gO4 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 3, 3)));
            gO5 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 4, 4)));
            gO6 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 5, 5)));
            gO7 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 6, 6)));
            gO8 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(partTwo, 7, 7)));
            offsetTextures(primP2, gO1, gO2, gO3, gO4, gO5, gO6, gO7, gO8);
        }
        else if(lMode == 3)
        {
            string line = str;
            integer len = llStringLength(str);
            if(len < 5)
            {
                integer lettersMissing = 5 - len;
                
                integer i;
                for(i=0;i<lettersMissing;i++)
                    line = " "+line;
            }
            
            vector gO1 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(line, 0, 0)));
            vector gO2 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(line, 1, 1)));
            vector gO3 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(line, 2, 2)));
            vector gO4 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(line, 3, 3)));
            vector gO5 = getGridOffset(llSubStringIndex(txtChrIndex, llGetSubString(line, 4, 4)));
            offsetTextures(primID, gO1, gO2, gO3, gO4, gO5, ZERO_VECTOR, ZERO_VECTOR, ZERO_VECTOR);
        }
    }
}
