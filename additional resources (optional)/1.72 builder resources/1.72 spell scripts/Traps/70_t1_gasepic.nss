//::///////////////////////////////////////////////
//:: Epic Gas Trap
//:: 70_t1_gasepic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Creates a  5m poison radius gas cloud that poisons all creatures entering
the area with Gargantual spider venom (DC 29, STR decrease).
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

void main()
{
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    //There is no acid fog VFX, so empty AOE will workaround it...
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(AOE_PER_FOGACID,"****","****","****"), lTarget, 6.0);

    effect ePoison = EffectPoison(POISON_GARGANTUAN_SPIDER_VENOM);
    ePoison = ExtraordinaryEffect(ePoison);

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 7.0, lTarget, TRUE);
    while(oTarget != OBJECT_INVALID)
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget);
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 7.0, lTarget, TRUE);
    }
}
