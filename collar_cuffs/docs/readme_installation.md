# [SGD] RRDC Collar and Cuffs v1.2.2 - Script Installation Manual #

-------------------------------------------------------------------------------------------------------

## Collar and Cuffs Upgrade Instructions ##

**Version 1.0 and Newer**
1. Wear or rez collar and cuff set on the ground.
2. Right click and edit the collar, and go to the Content tab.
3. Delete the old script.
4. Drop in the new script.
5. Repeat steps 2-4 for each cuff.

**Version 0.9 and Older**
1. Wear or rez collar and cuff set on the ground.
2. Delete all scripts from every prim of every object.
3. For each object, go through every prim in the linkset and copy any contents to your inventory.
    * After copying the contents, delete them from the prim.

4. Rename the following animations to make them consistent with the naming scheme:
    * Rename 'cuffedArmsCollar001' to 'cuffedArmsCollar001a'.
    * Rename 'cuffedNeckForward001' to 'cuffedNeckForward001a'.
    
5. Copy assets from the folder you created back into the collar/cuffs.
    * Copy all animations into the root prim of the collar.
    * (OPTIONAL) Copy all sounds into the root prim of the collar.
    * (OPTIONAL) Copy all textures into the root prim of the collar.
    * (OPTIONAL) Copy 'thinchain' into the root prim of each cuff.

6. (OPTIONAL) Remove unnecessary prims from each cuffs linkset.
    * Each cuff should have exactly two transparent spheres. One on each side.
    * Unlink and delete additional spheres. Pay attention to which side 'LM-LG link' spheres are on.
    * Make sure the remaining spheres are centered on the top of the cuff anchor point.

7. Name the spheres on the 'LM-LG link' side of each cuff 'outerLink'.
8. Name the spheres on the opposite side of each cuff 'innerLink'.
9. Set the description of the root prim of the collar and each cuff as follows:
    * Collar should have the description 'collar'.
    * Left wrist cuff should have the description 'lcuff'.
    * Right wrist cuff should have the description 'rcuff'.
    * Left ankle cuff should have the description 'llcuff'.
    * Right ankle cuff should have the descrption 'rlcuff'.

10. Drop the collar.lsl script into the root prim of the collar.
11. Drop the cuff.lsl script into the root prim of each cuff.

-------------------------------------------------------------------------------------------------------

## Leash Handle Script Instructions ##

1. Edit the object you want to act as a leash handle and select the prim you want to receive chains.
2. Drop the leash_handle.lsl script into the prim.

-------------------------------------------------------------------------------------------------------

## Notes for Distributors ##

1. You don't need to put the textures or sounds into the collar and cuffs if you don't want to
   distribute them that way, as the scripts use UUID references for everything but animations. 

2. If you wore the collar and cuffs for installation instead of rezzing, you will need to set
   root prim descriptions using 'Right click -> Properties' or it will reset when you detach them.

3. You can set whatever next owner permissions you would like on the scripts. However, please
   include the version number in the script names if you intend to distribute the scripts as
   'no-modify', so end users can properly fill out bug reports on github if necessary.

4. A copy of leash_handle.lsl should be included in the package distributed to end users. This
   allows for more creative freedom as it enables them to install a leash handle as part of their
   character's uniform. You can inactivate the script within the vendor object by opening it
   from the vendor's inventory and unchecking the 'Running' checkbox.

4. Please include a copy of user_manual.md as a notecard in the folder sent to end users. This
   file contains important information on usage and how to get support. If you made changes to
   the scripts before distribution, however, please modify user_manual.md to include your own 
   support information.

-------------------------------------------------------------------------------------------------------
