# [SGD] RRDC Collar and Cuffs v1.2.2 - User Manual #

---------------------------------------------------------------------------------------------------

## Basic Usage ##
Wear or add the collar and the 4 cuffs, then touch the collar to access the menu.

## Adding Your Character Sheet ##
1. Edit your collar and navigate to the Content tab of the edit window.
2. Drag your character sheet notecard into the object contents.
    * For best results, make sure your character sheet is the only notecard in the collar.
    * You can set an external character sheet by setting the notecard's name to the URL.

## Leash Handle Script Installation ##
1. Edit the object you want to act as a leash handle and select the prim you want to recieve chains.
2. Drag and drop the 'Leash Handle' script into the prim contents.

## LockGuard and Lockmeister ##
The collar and cuff set are fully capable of _both_ LockGuard and Lockmeister protocols.
* Additionally, LMV2 is supported. However, no third party LM extensions are supported.
* Don't change the descriptions of the objects, as this is where the ID is stored.
* Devices only capable of LMV1 will draw particles to the root prim of the cuffs/collar.

## Troubleshooting and Support ##
If you encounter any issues with the collar and cuff set or would like to request a feature,
you can create an issue on the project GitHub page:

    https://github.com/RRDC-SL/Collar-Cuffs/issues

---------------------------------------------------------------------------------------------------

## CharSheet ##
Gives a copy of your character sheet, if a character sheet has been added.
* This is the only option other avatars can access from anywhere.
* You will receive a message telling you who requested your character sheet.

## Shock ##
Delivers a painful electric shock to your avatar, lasting for about a second.
* The initiating user must be within 6m of you. It will not even appear otherwise.
* You will receive a message telling you who activated the shock feature.
* Your avatar will freeze in place and fall to the ground.
* You will be unable to move until the animation sequence finishes.
* To prevent abuse, there is a cooldown of 15 seconds before you can be shocked again.

## Poses ##
Allows the user to pick from one of five different restraint poses, or release you.
* The initiating user must be within 6m of you. It will not even appear otherwise.
* You will receive a message telling you who is accessing the pose menu.
* The animation will override most AOs, so your wrists will stay bound when walking.
* Appropriate chain particles will be drawn if the cuffs are worn.

## Ankle Chain ##
Toggles drawing a chain from one ankle cuff to the other. This is a purely cosmetic effect.
* The initiating user must be within 6m of you. It will not even appear otherwise.
* You will receive a message telling you who toggled your ankle chain.

## Shackle Link ##
Toggles drawing chains from your wrist cuffs to your ankle cuffs. This is purely cosmetic.
* The initiating user must be within 6m of you. It will not even appear otherwise.
* You will receive a message telling you who toggled your shackle link.

## Chain Gang ##
Toggles whether you are part of a chain gang, e.g. leashed to another inmate's ankle.
* The initiating user must be within 6m of you. It will not even appear otherwise.
* You will receive a message telling you who has added you to the chain gang.
* Being added to a chain gang will force your avatar to stay within 2m of the other inmate.
* Activating chain gang will scan for inmates within 10m who have a left ankle cuff.
* The initiating user is presented with a selection menu of the first 12 inmates found.
* The selection menu expires after 45 seconds to free up the option for others.
* Once selected, a chain will be drawn from your left ankle cuff to that of the other inmate.

## Leash ##
Toggles whether your collar is currently leashed to someone.
* The initiating user must be within 6m of you. The will not even appear otherwise.
* You will receive a message telling you who has grabbed your leash.
* To help keep the script efficient, you cannot grab your own leash.
* Being leashed to someone will force your avatar to stay within 2m of them.
* Activating leash will draw a chain from your collar to the activating user.
* If the user is wearing a leash-handle enabled attachment, the chain will be drawn to it.

## Reports ##
Allows you to access the inmate reports file in the RRDC Database.
* The initiating user must be within 6m of you. The will not even appear otherwise.
* You will recieve a message telling you who has accessed your file.
* You can access your own file by finding this option in Settings.

## Settings ##
Displays the settings menu for the user.
* Only you (the wearer) can access this menu.
* Contains the Inmate #, Textures, and Walk Sound menus/options.

## Inmate # ##
Allows you to select from the inmate numbers associated with your account.
* Only you (the wearer) can access this menu.
* You can only select inmate numbers you have registered with the sim database.
* The inmate number you select can be queried by scripts in-world.

## CharName ##
Allows you to set the name of the character associated with your inmate number.
* Only you (the wearer) can access this option.
* Name field is limited to 30 characters in length.
* The character name you specify can be queried by scripts in-world.

## Version ##
Displays the current version of the collar scripts and checks for updates.
* Only you (the wearer) can access this option.
* If a new version is available, you will be notified about it.

## Textures ##
Allows you to select one of six different metal textures for your collar and cuffs.
* Only you (the wearer) can access this menu.
* Selecting a color will set the texture your collar and cuffs simultaneously.

## Walk Sound ##
Toggles whether to play chain sound effects when you walk with them enabled in any form.
* Only you (the wearer) can access this option.
* Sounds play when you start and stop moving while any chains are active.
* This does not turn off sound effects played on toggling of chains or shock feature.

---------------------------------------------------------------------------------------------------
