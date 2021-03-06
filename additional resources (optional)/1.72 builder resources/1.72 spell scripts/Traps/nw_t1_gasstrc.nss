//::///////////////////////////////////////////////
//:: Gas Trap
//:: NW_T1_GasStrC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a  5m poison radius gas cloud that
    lasts for 2 rounds and poisons all creatures
    entering the area with Dark Reaver Powder
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- could struck one target multiple times
- gas cloud will now lasts only one round
- poison made extraordinary
*/

void main()
{
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    //There is no acid fog VFX, so empty AOE will workaround it...
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(AOE_PER_FOGACID,"****","****","****"), lTarget, 6.0);

    effect ePoison = EffectPoison(POISON_DARK_REAVER_POWDER);
    ePoison = ExtraordinaryEffect(ePoison);

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE);
    while(oTarget != OBJECT_INVALID)
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget);
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lTarget, TRUE);
    }
}
