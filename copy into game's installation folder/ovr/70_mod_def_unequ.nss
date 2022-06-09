//::///////////////////////////////////////////////
//:: Default community patch OnPlayerUnEquip module event script
//:: 70_mod_def_unequ
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
The 70_mod_def_* scripts are a new feature of nwn(c)x_patch plugin and will fire
just before normal module events. Note, that this script will run only if game
is loaded via NWNX or NWNCX and Community Patch plugin!

The purpose of this is to automatically enforce fixes/features that requires changes
in module events in any module player will play. Also, PW builders no longer needs
to merge scripts to get these functionalities.

If you are a builder you can reuse these events for your own purposes too. With
this feature, you can make a system like 3.5 ruleset which will work in any module
as long player is using patch 1.72 + NWNCX + nwncx_patch plugin.

Note: community patch doesn't include scripts for all these events, but only for
a few. You can create a script with specified name for other events. There was
just no point of including a script which will do nothing. So here is a list:
OnAcquireItem       - 70_mod_def_aqu
OnActivateItem      - 70_mod_def_act
OnClientEnter       - 70_mod_def_enter
OnClientLeave       - 70_mod_def_leave
OnCutsceneAbort     - 70_mod_def_abort
OnHeartbeat         - not running extra script
OnModuleLoad        - 70_mod_def_load
OnPlayerChat        - 70_mod_def_chat
OnPlayerDeath       - 70_mod_def_death
OnPlayerDying       - 70_mod_def_dying
OnPlayerEquipItem   - 70_mod_def_equ
OnPlayerLevelUp     - 70_mod_def_lvup
OnPlayerRespawn     - 70_mod_def_resp
OnPlayerRest        - 70_mod_def_rest
OnPlayerUnEquipItem - 70_mod_def_unequ
OnUnAcquireItem     - 70_mod_def_unaqu
OnUserDefined       - 70_mod_def_user

It is also possible to bypass the original script, use this command:
SetLocalInt(OBJECT_SELF,"BYPASS_EVENT",1);
This should be used wisely as you don't know what is original module event script
doing so, do this only if running original event has no longer sense.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 31-05-2017
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "70_inc_itemprop"

void main()
{
    object oItem = GetPCItemLastUnequipped();
    object oPC   = GetPCItemLastUnequippedBy();

    //1.71: fix for losing skin in ELC/ILR module settings
    if(GetIsPC(oPC) && GetTag(oItem) == "x3_it_pchide" && GetLocalObject(oPC,"oX3_Skin") == OBJECT_INVALID)
    {
        object oSkin = CopyItem(oItem,oPC,TRUE);
        SetLocalObject(oPC,"oX3_Skin",oSkin);
        DelayCommand(1.0,AssignCommand(GetItemPossessor(oSkin),CPP_SupportEquipSkin(oSkin)));
        SetDroppableFlag(oSkin,FALSE);
    }
    //1.72: OnPolymorph scripted event handler
    else if(!GetLocalInt(oPC,"UnPolymorph") && GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))
    {
        SetLocalInt(oPC,"UnPolymorph",1);
        SetLocalInt(oPC,"UnPolymorph_HP_Setup",TRUE);
        SetLocalInt(oPC,"UnPolymorph_HP",GetCurrentHitPoints(oPC));
        DelayCommand(0.0,ExecuteScript("70_mod_polymorph",oPC));
    }

    string sItemTag = GetTag(oItem);
    // * When wearing Nasher's set of items, get special (Brent)
    // * benefits
    if (GetLocalInt(oPC,"NASHER_SET_FULL") && (sItemTag == "x2_nash_boot" || sItemTag == "x2_nash_cloak" || sItemTag == "x2_nash_glove" || sItemTag == "x2_nash_ring"))
    {
        object oRing1 = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
        object oRing2 = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);
        if(sItemTag == "x2_nash_ring" && GetTag(oRing1) == "x2_nash_ring" && GetTag(oRing2) == "x2_nash_ring")//1.72: special case for player wearing 2 Nasher rings
        {
            itemproperty itProp = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 3);
            IPSafeAddItemProperty(oItem, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
        else
        {
            SetLocalInt(oPC,"NASHER_SET_FULL",FALSE);
            effect eVis = EffectVisualEffect(VFX_IMP_DISPEL);

            // * Do I have them all on?
            object oBoot =  GetItemPossessedBy(oPC, "x2_nash_boot");
            object oCloak = GetItemPossessedBy(oPC, "x2_nash_cloak");
            object oGlove = GetItemPossessedBy(oPC, "x2_nash_glove");
            object oRing = GetItemPossessedBy(oPC, "x2_nash_ring");

            string sBoot = GetTag(oBoot);
            string sCloak = GetTag(oCloak);
            string sGlove = GetTag(oGlove);
            string sRing = GetTag(oRing);

            itemproperty itProp = ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, 3);

            if (GetIsObjectValid(oBoot))
                IPSafeAddItemProperty(oBoot, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            itProp = ItemPropertyACBonus(3);

            if (GetIsObjectValid(oCloak))
                IPSafeAddItemProperty(oCloak, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            itProp = ItemPropertySkillBonus(SKILL_DISCIPLINE, 5);
            if (GetIsObjectValid(oGlove))
                IPSafeAddItemProperty(oGlove, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            itProp = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 3);
            if (GetIsObjectValid(oRing))
                IPSafeAddItemProperty(oRing, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
        }
    }

    //Now execute original script
    string sScript = GetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM");
    if(sScript != "")
    {
        ExecuteScript(sScript,OBJECT_SELF);
    }
}
