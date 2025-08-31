//::///////////////////////////////////////////////
//:: Community Patch OnPolymorph module event script
//:: 70_mod_polymorph
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script uses unique concept to determine OnPolymorph and OnUnPolymorph events.

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.71
//:: Created On: 14-10-2013
//:://////////////////////////////////////////////

#include "70_inc_shifter"
#include "70_inc_spells"
#include "x3_inc_skin"
#include "x0_i0_spells"

void main()
{
    object oPC = OBJECT_SELF;
    object oCreator = GetLocalObject(oPC,"Polymorph_Creator");
    int nEvent = GetLastPolymorphEventType();
    if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph event: "+IntToString(nEvent));

    if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_PREPOLYMORPH)//in this event type OBJECT_SELF is the creator!
    {
        oCreator = OBJECT_SELF;
        oPC = GetLocalObject(oCreator,"Polymorph_Target");
        if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph event: "+IntToString(nEvent));//debug again as the last one was sent to oCreator instead
        int nPolymorph = GetLocalInt(oPC,"Polymorph_ID")-1;
        int nHP = GetLocalInt(oPC,"Polymorph_HP");
        int bLocked = GetLocalInt(oPC,"Polymorph_Locked");
        int spell1 = GetLocalInt(oPC,"Polymorph_SPELL1");
        int spell2 = GetLocalInt(oPC,"Polymorph_SPELL2");
        int spell3 = GetLocalInt(oPC,"Polymorph_SPELL3");
        int bAll = GetModuleSwitchValue("72_POLYMORPH_MERGE_EVERYTHING");
        int bItems = bAll || GetLocalInt(oPC,"Polymorph_MergeI");
        int bArmor = bAll || GetLocalInt(oPC,"Polymorph_MergeA");
        int bWeapon = bAll || GetLocalInt(oPC,"Polymorph_MergeW");
        int bArms = bAll || (bItems && (GetLocalInt(oPC,"71_POLYMORPH_MERGE_ARMS") || GetModuleSwitchValue("71_POLYMORPH_MERGE_ARMS")));

        //this allows to dynamically override polymorph ID, temp HP and whether player can cancel it or now
        SetLocalInt(oPC,"Polymorph_ID",nPolymorph+1);
        SetLocalInt(oPC,"Polymorph_Locked",bLocked);
        SetLocalInt(oPC,"Polymorph_HP",nHP);

        object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
        object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
        object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
        object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
        object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
        object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
        object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
        object oBeltOld = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
        object oArmsOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);
        object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
        object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
        if(GetIsObjectValid(oShield))
        {   //1.71: this is now custom content compatible, polymorph will merge custom left-hand only items such as flags
            if (GetWeaponRanged(oShield) || IPGetIsMeleeWeapon(oShield))
            {
                oShield = OBJECT_INVALID;
            }
        }
        //stores current items into variable to access later when polymorphed
        SetLocalObject(oPC,"Polymorph_WeaponOld",oWeaponOld);
        SetLocalObject(oPC,"Polymorph_ArmorOld",oArmorOld);
        SetLocalObject(oPC,"Polymorph_Ring1Old",oRing1Old);
        SetLocalObject(oPC,"Polymorph_Ring2Old",oRing2Old);
        SetLocalObject(oPC,"Polymorph_AmuletOld",oAmuletOld);
        SetLocalObject(oPC,"Polymorph_CloakOld",oCloakOld);
        SetLocalObject(oPC,"Polymorph_BoootsOld",oBootsOld);
        SetLocalObject(oPC,"Polymorph_BeltOld",oBeltOld);
        SetLocalObject(oPC,"Polymorph_ArmsOld",oArmsOld);
        SetLocalObject(oPC,"Polymorph_HelmetOld",oHelmetOld);
        SetLocalObject(oPC,"Polymorph_ShieldOld",oShield);
        //1.72: engine markers for correct handling spell slots from items in NWNX_Patch
        SetLocalInt(oWeaponOld,"MERGED",bWeapon);
        SetLocalInt(oHelmetOld,"MERGED",bArmor);
        SetLocalInt(oArmorOld,"MERGED",bArmor);
        SetLocalInt(oShield,"MERGED",bArmor);
        SetLocalInt(oRing1Old,"MERGED",bItems);
        SetLocalInt(oRing2Old,"MERGED",bItems);
        SetLocalInt(oAmuletOld,"MERGED",bItems);
        SetLocalInt(oCloakOld,"MERGED",bItems);
        SetLocalInt(oBootsOld,"MERGED",bItems);
        SetLocalInt(oBeltOld,"MERGED",bItems);
        SetLocalInt(oArmsOld,"MERGED",bArms);

        effect eNull, eAdditional;
        if(nPolymorph == 76)
        {
            //added benefits of being incorporeal into polymorph effect for spectre shape
            eAdditional = EffectLinkEffects(EffectCutsceneGhost(),EffectConcealment(50));
        }

        if(eAdditional != eNull)
        {
            //Apply any additional effects coming along with given shape - keep this visible in effect list
            eAdditional = ExtraordinaryEffect(eAdditional);
            //note all additional effects are permanent since new "engine" will handle them automatically after polymorph ends
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eAdditional,oPC);
        }
    }
    else if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_UNPOLYMORPH)
    {
        SetLocalInt(oPC,"Polymorphed",0);//system variable do not remove
        //clean all additional effects, if any
        int nSpellId = GetLocalInt(oPC,"Polymorph_SpellID");
        DeleteLocalInt(oPC,"Polymorph_SpellID");
        effect eSearch = GetFirstEffect(oPC);
        while(GetIsEffectValid(eSearch))
        {
            if((oCreator != OBJECT_INVALID && GetEffectCreator(eSearch) == oCreator) || (nSpellId > 0 && GetEffectSpellId(eSearch) == nSpellId))
            {
                RemoveEffect(oPC,eSearch);
            }
            eSearch = GetNextEffect(oPC);
        }
        DestroyObject(oCreator);
        //1.72: workaround for skin issue with polymorph and relog
        object oSkin = GetLocalObject(oPC,"oX3_Skin");
        if(GetIsObjectValid(oSkin) && GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC) == OBJECT_INVALID)
        {
            AssignCommand(oPC,SKIN_SupportEquipSkin(oSkin));
        }
    }
    else if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_ONPOLYMORPH)
    {
        SetLocalInt(oPC,"UnPolymorph",0);//system variable do not remove
        object oWeaponNew, oArmorNew = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);
        //retrieve polymorph spell id
        int nSpellId = GetLocalInt(oPC,"Polymorph_SpellID");
        if(!nSpellId)
        {
            effect eSearch = GetFirstEffect(oPC);
            while(GetIsEffectValid(eSearch))
            {
                if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
                {
                    //reset if not valid spell id to provide "addition effect cleaning" functionality for spells without 1.72 polymorph engine
                    SetLocalInt(oPC,"Polymorph_SpellID",GetEffectSpellId(eSearch));
                    break;
                }
                eSearch = GetNextEffect(oPC);
            }
        }
        //determine all current polymorph informations
        int nPolymorph = GetLocalInt(oPC,"Polymorph_ID")-1;
        int nHP = GetLocalInt(oPC,"Polymorph_HP");
        int spell1 = GetLocalInt(oPC,"Polymorph_SPELL1");
        int spell2 = GetLocalInt(oPC,"Polymorph_SPELL2");
        int spell3 = GetLocalInt(oPC,"Polymorph_SPELL3");
        int bAll = GetModuleSwitchValue("72_POLYMORPH_MERGE_EVERYTHING");
        int bItems = bAll || GetLocalInt(oPC,"Polymorph_MergeI");
        int bArmor = bAll || GetLocalInt(oPC,"Polymorph_MergeA");
        int bWeapon = bAll || GetLocalInt(oPC,"Polymorph_MergeW");
        int bArms = bAll || (bItems && (GetLocalInt(oPC,"71_POLYMORPH_MERGE_ARMS") || GetModuleSwitchValue("71_POLYMORPH_MERGE_ARMS")));

        object oWeaponOld = GetLocalObject(oPC,"Polymorph_WeaponOld");
        object oArmorOld = GetLocalObject(oPC,"Polymorph_ArmorOld");
        object oRing1Old = GetLocalObject(oPC,"Polymorph_Ring1Old");
        object oRing2Old = GetLocalObject(oPC,"Polymorph_Ring2Old");
        object oAmuletOld = GetLocalObject(oPC,"Polymorph_AmuletOld");
        object oCloakOld = GetLocalObject(oPC,"Polymorph_CloakOld");
        object oBootsOld = GetLocalObject(oPC,"Polymorph_BoootsOld");
        object oBeltOld = GetLocalObject(oPC,"Polymorph_BeltOld");
        object oArmsOld = GetLocalObject(oPC,"Polymorph_ArmsOld");
        object oHelmetOld = GetLocalObject(oPC,"Polymorph_HelmetOld");
        object oShield = GetLocalObject(oPC,"Polymorph_ShieldOld");
        //now re-merge itemproperties into new shape
        if(bWeapon)
        {
            oWeaponNew = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
            if(!GetIsObjectValid(oWeaponNew)) oWeaponNew = oArmorNew;//if weapon is allowed to merge but shape has no weapon, then merge itemproperties to skin instead
            else SetIdentified(oWeaponNew, TRUE);//identify weapon
            IPWildShapeMergeItemProperties(oWeaponOld,oWeaponNew, TRUE);
        }
        if(bArmor)
        {
            IPWildShapeMergeItemProperties(oHelmetOld,oArmorNew);
            IPWildShapeMergeItemProperties(oArmorOld,oArmorNew);
            IPWildShapeMergeItemProperties(oShield,oArmorNew);
        }
        if(bItems)
        {
            IPWildShapeMergeItemProperties(oRing1Old,oArmorNew);
            IPWildShapeMergeItemProperties(oRing2Old,oArmorNew);
            IPWildShapeMergeItemProperties(oAmuletOld,oArmorNew);
            IPWildShapeMergeItemProperties(oCloakOld,oArmorNew);
            IPWildShapeMergeItemProperties(oBootsOld,oArmorNew);
            IPWildShapeMergeItemProperties(oBeltOld,oArmorNew);
        }
        if(bArms)
        {
            IPWildShapeMergeItemProperties(oArmsOld,oArmorNew);
        }
        //1.72: custom effect icon to describe polymorph special qualities to player
        if(spellsIsFlying(oPC))
        {
            if(Get2DAString("effecticons","Icon",151) == "ief_fly")//this will make sure the 2DA files are merged and icon is the correct one, if not, do nothing
            {
                ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectIcon(151)),oPC);
            }
        }
        if(spellsIsImmuneToDrown(oPC))
        {
            if(Get2DAString("effecticons","Icon",152) == "ief_bubble")//this will make sure the 2DA files are merged and icon is the correct one, if not, do nothing
            {
                ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectIcon(152)),oPC);
            }
        }

        //1.71: code to allow stack multiple bonuses on a same item
        if(GetLocalInt(GetItemPossessor(oArmorNew),"71_POLYMORPH_STACK_ABILITY_BONUSES") || GetModuleSwitchValue("71_POLYMORPH_STACK_ABILITY_BONUSES"))
        {
            //recalculate ability increase/decrease itemproperties
            IPWildShapeHandleAbilityBonuses(oWeaponNew);
            IPWildShapeHandleAbilityBonuses(oArmorNew);
        }
    }
}
