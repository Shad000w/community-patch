//::///////////////////////////////////////////////
//:: default.nss
//:://////////////////////////////////////////////
/*
This is a workaround created to automatically run specific script in any loaded
module.

Player characters will run this script for many events, so loading up old game or
stating up new will execute this code which will then make sure that the 70_mod_def_load
is/was executed. Which then allows for many module-events script based fixes to
work in any module automatically.

This was handled by NWN(C)X_Patch nwnx plugin in past, but since client-modding isn't
allowed now, I had to resort into this old trick.

Unfortunately, since some other projects uses this, like PRC or 3.5 Ruleset, this won't
work in combation with those projects, but that is to be expected.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72 Enhanced Edition
//:: Created On: 10-06-2022
//:://////////////////////////////////////////////

void main()
{
    if(GetLocalInt(GetModule(),"70_mod_def_load_DOONCE")) return;//70_mod_def_load already ran once, abort
    else if(GetLocalInt(OBJECT_SELF,"default_DOONCE")) return;//this script already ran once, abort
    SetLocalInt(OBJECT_SELF,"default_DOONCE",TRUE);

    string sScript = GetEventScript(GetModule(),EVENT_SCRIPT_MODULE_ON_MODULE_LOAD);
    if(sScript != "70_mod_def_load")
    {
        ExecuteScript("70_mod_def_load",GetModule());
    }
}
