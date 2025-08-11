//::///////////////////////////////////////////////
//:: Spells Include
//:: NW_I0_SPELLS
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 2, 2002
//:: Updated By: 2003/20/10 Georg Zoeller
//:://////////////////////////////////////////////
#include "70_inc_spells"

// GZ: Number of spells in GetSpellBreachProtections
const int NW_I0_SPELLS_MAX_BREACH = 32;//1.72: removed duplicated shadow shield on list

// * Function for doing electrical traps
void TrapDoElectricalDamage(int ngDamageMaster, int nSaveDC, int nSecondary);

// * Used to route the resist magic checks into this function to check for spell countering by SR, Globes or Mantles.
//   Return value if oCaster or oTarget is an invalid object: FALSE
//   Return value if spell cast is not a player spell: - 1
//   Return value if spell resisted: 1
//   Return value if spell resisted via magic immunity: 2
//   Return value if spell resisted via spell absorption: 3
int MyResistSpell(object oCaster, object oTarget, float fDelay = 0.0);

// * Used to route the saving throws through this function to check for spell countering by a saving throw.
//   Returns: 0 if the saving throw roll failed
//   Returns: 1 if the saving throw roll succeeded
//   Returns: 2 if the target was immune to the save type specified
//   Note: If used within an Area of Effect Object Script (On Enter, OnExit, OnHeartbeat), you MUST pass
//   GetAreaOfEffectCreator() into oSaveVersus!!    \
int MySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0);

// * Will pass back a linked effect for all the protection from alignment spells.  The power represents the multiplier of strength.
// * That is instead of +3 AC and +2 Saves a  power of 2 will yield +6 AC and +4 Saves.
effect CreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1);

// * Will pass back a linked effect for all of the doom effects.
effect CreateDoomEffectsLink();

// * Searchs through a persons effects and removes those from a particular spell by a particular caster.
void RemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget);

// * Searchs through a persons effects and removes all those of a specific type.
void RemoveSpecificEffect(int nEffectTypeID, object oTarget);

// * Returns the time in seconds that the effect should be delayed before application.
float GetSpellEffectDelay(location SpellTargetLocation, object oTarget);

// * This allows the application of a random delay to effects based on time parameters passed in.  Min default = 0.4, Max default = 1.1
float GetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1);

// * Get Difficulty Duration
int GetScaledDuration(int nActualDuration, object oTarget);

// * Get Scaled Effect
effect GetScaledEffect(effect eStandard, object oTarget);

// * Remove all spell protections of a specific type
int RemoveProtections(int nSpell_ID, object oTarget, int nCount);

// * Performs a spell breach up to nTotal spells are removed and nSR spell
// * resistance is lowered.
int GetSpellBreachProtection(int nLastChecked);

//* Assigns a debug string to the Area of Effect Creator
void AssignAOEDebugString(string sString);

// * Plays a random dragon battlecry based on age.
void PlayDragonBattleCry();

// * Returns true if Target is a humanoid
int AmIAHumanoid(object oTarget);


// * Performs a spell breach up to nTotal spell are removed and
// * nSR spell resistance is  lowered. nSpellId can be used to override
// * the originating spell ID. If not specified, SPELL_GREATER_SPELL_BREACH
// * is used
void DoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1);


// * Returns true if Target is a humanoid
int AmIAHumanoid(object oTarget)
{
    if(spellsIsRacialType(oTarget, RACIAL_TYPE_DWARF) || spellsIsRacialType(oTarget, RACIAL_TYPE_HALFELF) ||
       spellsIsRacialType(oTarget, RACIAL_TYPE_HALFORC) || spellsIsRacialType(oTarget, RACIAL_TYPE_ELF) ||
       spellsIsRacialType(oTarget, RACIAL_TYPE_GNOME) || spellsIsRacialType(oTarget, RACIAL_TYPE_HUMANOID_GOBLINOID) ||
       spellsIsRacialType(oTarget, RACIAL_TYPE_HALFLING) || spellsIsRacialType(oTarget, RACIAL_TYPE_HUMAN) ||
       spellsIsRacialType(oTarget, RACIAL_TYPE_HUMANOID_MONSTROUS) || spellsIsRacialType(oTarget, RACIAL_TYPE_HUMANOID_ORC) ||
       spellsIsRacialType(oTarget, RACIAL_TYPE_HUMANOID_REPTILIAN))
    {
        return TRUE;
    }
    return FALSE;
}

//::///////////////////////////////////////////////
//:: spellsCure
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Used by the 'cure' series of spells.
    Will do max heal/damage if at normal or low
    difficulty.
    Random rolls occur at higher difficulties.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////

void spellsCure(int nDamage, int nMaxExtraDamage, int nMaximized, int vfx_impactHurt, int vfx_impactHeal, int nSpellID)
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHeal;
    int nMetaMagic = GetMetaMagicFeat();
    effect eHeal, eDam;

    int nExtraDamage = GetCasterLevel(OBJECT_SELF); // * figure out the bonus damage
    if (nExtraDamage > nMaxExtraDamage)
    {
        nExtraDamage = nMaxExtraDamage;
    }
    // * if low or normal difficulty is treated as MAXIMIZED
    if(GetIsPC(oTarget) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
    {
        nDamage = nMaximized + nExtraDamage;
    }
    else
    {
        nDamage = nDamage + nExtraDamage;
    }


    //Make metamagic checks
    if (nMetaMagic == METAMAGIC_MAXIMIZE)
    {
        // 04/06/2005 CraigW - We should be using the maximized value here instead of 8.
        nDamage = nMaximized + nExtraDamage;
        // * if low or normal difficulty then MAXMIZED is doubled.
        if(GetIsPC(OBJECT_SELF) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
        {
            nDamage = nDamage + nExtraDamage;
        }
    }
    if (nMetaMagic == METAMAGIC_EMPOWER || GetHasFeat(FEAT_HEALING_DOMAIN_POWER))
    {
        nDamage = nDamage + (nDamage/2);
    }


    if (!spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
    {
        //Figure out the amount of damage to heal
        //nHeal = nDamage;  -- this line seemed kinda pointless
        //Set the heal effect
        eHeal = EffectHeal(nDamage);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
        effect eVis2 = EffectVisualEffect(vfx_impactHeal);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID, FALSE));


    }
    //Check that the target is undead
    else
    {
        int nTouch = TouchAttackMelee(oTarget);
        if (nTouch > 0)
        {
            if(!GetIsReactionTypeFriendly(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID));
                if (!MyResistSpell(OBJECT_SELF, oTarget))
                {
                    eDam = EffectDamage(nDamage,DAMAGE_TYPE_POSITIVE);
                    //Apply the VFX impact and effects
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    effect eVis = EffectVisualEffect(vfx_impactHurt);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                }
            }
        }
    }
}

//::///////////////////////////////////////////////
//:: DoSpelLBreach
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Performs a spell breach up to nTotal spells
    are removed and nSR spell resistance is
    lowered.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 2002
//:: Modified  : Georg, Oct 31, 2003
//:://////////////////////////////////////////////
void DoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1)
{
    if (nSpellId == -1)
    {
        nSpellId =  SPELL_GREATER_SPELL_BREACH;
    }
    effect eSR = EffectSpellResistanceDecrease(nSR);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eVis = EffectVisualEffect(VFX_IMP_BREACH);
    int nCnt, nIdx, nSpell;
    string sFeedback,sSpellsRemoved;
    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellId ));
        //Search through and remove protections.
        while(nCnt <= NW_I0_SPELLS_MAX_BREACH && nIdx < nTotal)
        {
            nSpell = GetSpellBreachProtection(nCnt);
            if(RemoveProtections(nSpell, oTarget, nCnt))
            {
                nIdx++;
                sSpellsRemoved+= GetStringByStrRef(StringToInt(Get2DAString("spells","Name",nSpell)))+", ";
            }
            nCnt++;
        }
        if(nIdx > 0)//1.72: breach spells now prints feedback which spells were breached
        {
            sFeedback = "<cÌwþ>"+GetStringByStrRef(StringToInt(Get2DAString("spells","Name",nSpellId)))+"</c> : ";
            sSpellsRemoved = GetStringLeft(sSpellsRemoved,GetStringLength(sSpellsRemoved)-2)+"</c>";
            if(OBJECT_SELF != oTarget && GetIsPC(OBJECT_SELF))
            {
                SendMessageToPC(OBJECT_SELF,sFeedback+"<cÌ™Ì>"+GetName(oTarget)+"</c> : <cÌwþ>"+sSpellsRemoved);
            }
            if(GetIsPC(oTarget))
            {
                SendMessageToPC(oTarget,sFeedback+"<c›þþ>"+GetName(oTarget)+"</c> : <cÌwþ>"+sSpellsRemoved);
            }
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect(eLink);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

}

//::///////////////////////////////////////////////
//:: GetDragonFearDC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Adding a function, we were using two different
    sets of numbers before. Standardizing it to be
    closer to 3e.
    nAge - hit dice
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: Sep 13, 2002
//:://////////////////////////////////////////////
int GetDragonFearDC(int nAge)
{
//hmm... not sure what's up with all these nCount variables, they're not
//actually used... so I'm gonna comment them out
int nDC = 13;
//    int nCount = 1;
    //Determine the duration and save DC
    //wyrmling meant no change from default, so we don't need it
/*
    if (nAge <= 6) //Wyrmling
    {
        nDC = 13;
        nCount = 1;
    }
    else
*/
 if(nAge > 6 && nAge < 10) //Very Young
 {
 nDC = 15;
//        nCount = 2;
 }
 else if(/*nAge >= 10 &&*/ nAge < 13) //Young
 {
 nDC = 17;
//        nCount = 3;
 }
 else if(/*nAge >= 13 &&*/ nAge < 16) //Juvenile
 {
 nDC = 19;
//        nCount = 4;
 }
 else if(/*nAge >= 16 &&*/ nAge < 19) //Young Adult
 {
 nDC = 21;
//        nCount = 5;
 }
 else if(/*nAge >= 19 &&*/ nAge < 22) //Adult
 {
 nDC = 24;
//        nCount = 6;
 }
 else if(/*nAge >= 22 &&*/ nAge < 25) //Mature Adult
 {
 nDC = 27;
//        nCount = 7;
 }
 else if(/*nAge >= 25 &&*/ nAge < 28) //Old
 {
 nDC = 28;
//        nCount = 8;
 }
 else if(/*nAge >= 28 &&*/ nAge < 31) //Very Old
 {
 nDC = 30;
//        nCount = 9;
 }
 else if(/*nAge >= 31 &&*/ nAge < 34) //Ancient
 {
 nDC = 32;
//        nCount = 10;
 }
 else if(/*nAge >= 34 &&*/ nAge < 38) //Wyrm
 {
 nDC = 34;
//        nCount = 11;
 }
 else if(nAge > 37) //Great Wyrm
 {
 nDC = 37;
//        nCount = 12;
 }
return nDC;
}

//------------------------------------------------------------------------------
// GZ: gets rids of temporary hit points so that they will not stack
//------------------------------------------------------------------------------
void RemoveTempHitPoints(object oCreature=OBJECT_SELF)
{
effect eProtection = GetFirstEffect(oCreature);
 while(GetIsEffectValid(eProtection))
 {
  if(GetEffectType(eProtection) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
  {
  RemoveEffect(oCreature,eProtection);
  }
 eProtection = GetNextEffect(oCreature);
 }
}

// * Kovi. removes any effects from this type of spell
// * i.e., used in Mage Armor to remove any previous
// * mage armors
void RemoveEffectsFromSpell(object oTarget, int SpellID)
{
effect eLook = GetFirstEffect(oTarget);
 while(GetIsEffectValid(eLook))
 {
  if(GetEffectSpellId(eLook)==SpellID)
  {
  RemoveEffect(oTarget,eLook);
  }
 eLook = GetNextEffect(oTarget);
 }
}

int MyResistSpell(object oCaster, object oTarget, float fDelay = 0.0)
{
    if(spell.SR == NO) return 0;//dynamic spell resist override feature, -1 = ignore SR for this spell
    if(spell.Level == 0)//1:72: forward-compatibility support; this will happen only in case a vanilla spellscript is compiled with CPP's library
    {
        spell.Level = GetCasterLevel(oCaster);
        spell.Id = GetSpellId();
    }
    int bAOE = GetObjectType(OBJECT_SELF) == OBJECT_TYPE_AREA_OF_EFFECT && !(spell.Id == SPELL_DELAYED_BLAST_FIREBALL || spell.Id == SPELL_GLYPH_OF_WARDING);//1.72: these two spells while AOEs are exception and shouldn't behave as other AOE spells
    if(GetLocalInt(oCaster,"DISABLE_RESIST_SPELL_CHECK"))
    {
        return 0;
    }
    if(fDelay > 0.5)
    {
        fDelay -= 0.1;
    }

    //1.72: added possibility to modify spell resistance penetration strenght
    object oSource = spell.Item != OBJECT_INVALID ? spell.Item : spell.Caster;
    int nPenetrationModifier = GetLocalInt(oSource,IntToString(spell.Id)+"_PENETRATION_MODIFIER");
    string sPrefix = "SPELL";
    if(oSource == spell.Item) sPrefix = "ITEM";
    else if(spell.Class == CLASS_TYPE_INVALID) sPrefix = "SPECIAL_ABILITY";
    nPenetrationModifier+= GetLocalInt(oSource,sPrefix+"_PENETRATION_MODIFIER");

    //1.70: by default in CPP the immunity to spell is checked before spell mantle, unless varible below is set TRUE
    int bVanillaOrder = GetModuleSwitchValue("70_RESISTSPELL_SPELLMANTLE_GOES_FIRST");
    int bAOEIgnoresSRandMantle = spell.SR != YES && bAOE && GetModuleSwitchValue("70_AOE_IGNORE_SPELL_RESISTANCE");

    if(!bAOEIgnoresSRandMantle && bVanillaOrder && SpellAbsorptionLimitedCheck(oTarget,oCaster,spell.Id))
    {
        //since the feedback from this function is missing, we have to send players custom feedback, but only to players
        if(GetIsPC(oTarget) || GetIsPossessedFamiliar(oTarget) || GetIsPC(GetMaster(oTarget)))
        {
            string sFeedback = "<c›þþ>"+GetName(oTarget)+"</c> <cÍþ>";
            if(GetPCPublicCDKey(GetFirstPC()) == "")//single player - use text from player's dialog.tlk which can be in unofficial language like Russian
            {
                string sTlkMessage = GetStringByStrRef(8342);//<CUSTOM0> attempts to resist spell : <CUSTOM1>
                sTlkMessage = GetStringRight(sTlkMessage,GetStringLength(sTlkMessage)-10);//this will remove <CUSTOM0>
                sTlkMessage = GetStringLeft(sTlkMessage,GetStringLength(sTlkMessage)-9);//this will remove <CUSTOM1>
                sFeedback+= sTlkMessage+GetStringByStrRef(8345)+"</c>";//this adds: spell absorbed
            }
            else//if not singleplayer, then there is no other choice but to send the player message based on the language ID he sends to server
            {
                switch(GetPlayerLanguage(oTarget))
                {
                    case PLAYER_LANGUAGE_FRENCH: sFeedback+= "tente de résister au sort : sort absorbé</c>"; break;
                    case PLAYER_LANGUAGE_GERMAN: sFeedback+= " versucht, Zauber zu widerstehen : Zauber absorbiert</c>"; break;
                    case PLAYER_LANGUAGE_ITALIAN: sFeedback+= "tenta di resistere all'incantesimo: incantesimo assorbito</c>"; break;
                    case PLAYER_LANGUAGE_POLISH: sFeedback+= "próbuje odeprzeæ zaklêcie : zaklêcie przerwane</c>"; break;
                    case PLAYER_LANGUAGE_SPANISH: sFeedback+= "intenta resistir el conjuro conjuro absorbido</c>"; break;
                    default: sFeedback+= "attempts to resist spell : spell absorbed</c>"; break;
                }
            }
            SendMessageToPC(oTarget,sFeedback);
        }
        //this also removes the double feedback that is send in vanilla ResistSpell if target and caster is the same creature
        if(oTarget != oCaster && (GetIsPC(oCaster) || GetIsPossessedFamiliar(oCaster) || GetIsPC(GetMaster(oCaster))))
        {
            string sFeedback = "<cÌ™Ì>"+GetName(oTarget)+"</c> <cÍþ>";
            if(GetPCPublicCDKey(GetFirstPC()) == "")
            {
                string sTlkMessage = GetStringByStrRef(8342);
                sTlkMessage = GetStringRight(sTlkMessage,GetStringLength(sTlkMessage)-10);
                sTlkMessage = GetStringLeft(sTlkMessage,GetStringLength(sTlkMessage)-9);
                sFeedback+= sTlkMessage+GetStringByStrRef(8345)+"</c>";
            }
            else
            {
                switch(GetPlayerLanguage(oTarget))
                {
                    case PLAYER_LANGUAGE_FRENCH: sFeedback+= "tente de résister au sort : sort absorbé</c>"; break;
                    case PLAYER_LANGUAGE_GERMAN: sFeedback+= " versucht, Zauber zu widerstehen : Zauber absorbiert</c>"; break;
                    case PLAYER_LANGUAGE_ITALIAN: sFeedback+= "tenta di resistere all'incantesimo: incantesimo assorbito</c>"; break;
                    case PLAYER_LANGUAGE_POLISH: sFeedback+= "próbuje odeprzeæ zaklêcie : zaklêcie przerwane</c>"; break;
                    case PLAYER_LANGUAGE_SPANISH: sFeedback+= "intenta resistir el conjuro conjuro absorbido</c>"; break;
                    default: sFeedback+= "attempts to resist spell : spell absorbed</c>"; break;
                }
            }
            SendMessageToPC(oCaster,sFeedback);
        }
        if(fDelay > 0.5)
        {
            fDelay -= 0.1;
        }
        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE),oTarget));
        return 3;
    }
    else if(SpellImmunityCheck(oTarget,oCaster,spell.Id) || SpellAbsorptionUnlimitedCheck(oTarget,oCaster,spell.Id))
    {
        //since the feedback from this function is missing, we have to send players custom feedback, but only to players
        if(GetIsPC(oTarget) || GetIsPossessedFamiliar(oTarget) || GetIsPC(GetMaster(oTarget)))
        {
            string sFeedback = "<c›þþ>"+GetName(oTarget)+"</c> <cÍþ>";
            if(GetPCPublicCDKey(GetFirstPC()) == "")//single player - use text from player's dialog.tlk which can be in unofficial language like Russian
            {
                string sTlkMessage = GetStringByStrRef(8342);//<CUSTOM0> attempts to resist spell : <CUSTOM1>
                sTlkMessage = GetStringRight(sTlkMessage,GetStringLength(sTlkMessage)-10);//this will remove <CUSTOM0>
                sTlkMessage = GetStringLeft(sTlkMessage,GetStringLength(sTlkMessage)-9);//this will remove <CUSTOM1>
                sFeedback+= sTlkMessage+GetStringByStrRef(8344)+"</c>";//this adds: magic immunity
            }
            else//if not singleplayer, then there is no other choice but to send the player message based on the language ID he sends to server
            {
                switch(GetPlayerLanguage(oTarget))
                {
                    case PLAYER_LANGUAGE_FRENCH: sFeedback+= "tente de résister au sort : immunité contre la magie</c>"; break;
                    case PLAYER_LANGUAGE_GERMAN: sFeedback+= " versucht, Zauber zu widerstehen : Magieimmunität</c>"; break;
                    case PLAYER_LANGUAGE_ITALIAN: sFeedback+= "tenta di resistere all'incantesimo: immunità magica</c>"; break;
                    case PLAYER_LANGUAGE_POLISH: sFeedback+= "próbuje odeprzeæ zaklêcie : niewra¿liwoœæ na magiê</c>"; break;
                    case PLAYER_LANGUAGE_SPANISH: sFeedback+= "intenta resistir el conjuro inmunidad a la magia</c>"; break;
                    default: sFeedback+= "attempts to resist spell : magic immunity</c>"; break;
                }
            }
            SendMessageToPC(oTarget,sFeedback);
        }
        //this also removes the double feedback that is send in vanilla ResistSpell if target and caster is the same creature
        if(oTarget != oCaster && (GetIsPC(oCaster) || GetIsPossessedFamiliar(oCaster) || GetIsPC(GetMaster(oCaster))))
        {
            string sFeedback = "<cÌ™Ì>"+GetName(oTarget)+"</c> <cÍþ>";
            if(GetPCPublicCDKey(GetFirstPC()) == "")
            {
                string sTlkMessage = GetStringByStrRef(8342);
                sTlkMessage = GetStringRight(sTlkMessage,GetStringLength(sTlkMessage)-10);
                sTlkMessage = GetStringLeft(sTlkMessage,GetStringLength(sTlkMessage)-9);
                sFeedback+= sTlkMessage+GetStringByStrRef(8344)+"</c>";
            }
            else
            {
                switch(GetPlayerLanguage(oTarget))
                {
                    case PLAYER_LANGUAGE_FRENCH: sFeedback+= "tente de résister au sort : immunité contre la magie</c>"; break;
                    case PLAYER_LANGUAGE_GERMAN: sFeedback+= " versucht, Zauber zu widerstehen : Magieimmunität</c>"; break;
                    case PLAYER_LANGUAGE_ITALIAN: sFeedback+= "tenta di resistere all'incantesimo: immunità magica</c>"; break;
                    case PLAYER_LANGUAGE_POLISH: sFeedback+= "próbuje odeprzeæ zaklêcie : niewra¿liwoœæ na magiê</c>"; break;
                    case PLAYER_LANGUAGE_SPANISH: sFeedback+= "intenta resistir el conjuro inmunidad a la magia</c>"; break;
                    default: sFeedback+= "attempts to resist spell : magic immunity</c>"; break;
                }
            }
            SendMessageToPC(oCaster,sFeedback);
        }
        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_GLOBE_USE),oTarget));
        return 2;
    }
    else if(!bAOEIgnoresSRandMantle && !bVanillaOrder && SpellAbsorptionLimitedCheck(oTarget,oCaster,spell.Id))
    {
        if(fDelay > 0.5)
        {
            fDelay -= 0.1;
        }
        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE),oTarget));
        return 3;
    }
    else if(!bAOEIgnoresSRandMantle && SpellResistanceCheck(oTarget,oCaster,spell.Id,spell.Level+nPenetrationModifier))
    {
        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE),oTarget));
        return 1;
    }
    return 0;
}

int MySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0)
{
    if(nSavingThrow == 4/*SAVING_THROW_NONE*/) return FALSE;
    // -------------------------------------------------------------------------
    // GZ: sanity checks to prevent wrapping around
    // -------------------------------------------------------------------------
    if (nDC<1)
    {
       nDC = 1;
    }
    else if (nDC > 255)
    {
      nDC = 255;
    }

    effect eVis;
    int bValid = FALSE;
    if((nSaveType == SAVING_THROW_TYPE_FEAR && (GetIsImmune(oTarget,IMMUNITY_TYPE_FEAR,oSaveVersus) || GetIsImmune(oTarget,IMMUNITY_TYPE_MIND_SPELLS,oSaveVersus))) ||
       (nSaveType == SAVING_THROW_TYPE_MIND_SPELLS && GetIsImmune(oTarget,IMMUNITY_TYPE_MIND_SPELLS,oSaveVersus)) ||
       (nSaveType == SAVING_THROW_TYPE_DEATH && GetIsImmune(oTarget,IMMUNITY_TYPE_DEATH,oSaveVersus)) ||
       (nSaveType == SAVING_THROW_TYPE_POISON && GetIsImmune(oTarget,IMMUNITY_TYPE_POISON,oSaveVersus)) ||
       (nSaveType == /*SAVING_THROW_TYPE_PARALYSE*/20 && (GetIsImmune(oTarget,IMMUNITY_TYPE_PARALYSIS,oSaveVersus) || (GetIsImmune(oTarget,IMMUNITY_TYPE_MIND_SPELLS,oSaveVersus) && !GetModuleSwitchValue("72_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY")))) ||//1.72: count with the paralyze module switch
       (nSaveType == SAVING_THROW_TYPE_DISEASE && GetIsImmune(oTarget,IMMUNITY_TYPE_DISEASE,oSaveVersus)))
    {
    //1.70: Engine workaround for bug in saving throw functions, where not all subtypes check the immunity correctly.
    bValid = 2;
    }
    else
    {
        if(oSaveVersus != OBJECT_SELF && GetObjectType(OBJECT_SELF) == OBJECT_TYPE_AREA_OF_EFFECT)//1.72: special AOE handling for new nwnx_patch fix
        {
            //this checks whether is nwnx_patch or nwncx_patch in use; using internal code to avoid including 70_inc_nwnx
            SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!12",".");
            DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!12");
            int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
            DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
            if(retVal >= 201)//in version 2.01 saving throws from AOE spell will count spellcraft, however to make this work requires to put AOE object into the save functions
            {                //there are good reasons why community patch changed all AOE spells to put AOE creator into this function, namely double debug, so this switcheroo
                oSaveVersus = OBJECT_SELF;//will be performed only when nwnx_patch/nwncx_patch is running (which also fixes the double debug along other issues)
            }
        }
        if(nSavingThrow == SAVING_THROW_FORT)
        {
            bValid = SavingThrowSave(oTarget, nSavingThrow, nDC, nSaveType, oSaveVersus);
            if(bValid == 1)
            {
                eVis = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);
            }
        }
        else if(nSavingThrow == SAVING_THROW_REFLEX)
        {
            bValid = SavingThrowSave(oTarget, nSavingThrow, nDC, nSaveType, oSaveVersus);
            if(bValid == 1)
            {
                eVis = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);
            }
        }
        else if(nSavingThrow == SAVING_THROW_WILL)
        {
            bValid = SavingThrowSave(oTarget, nSavingThrow, nDC, nSaveType, oSaveVersus);
            if(bValid == 1)
            {
                eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);
            }
        }
    }

    int nSpellID = GetSpellId();

    /*
        return 0 = FAILED SAVE
        return 1 = SAVE SUCCESSFUL
        return 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
    */
    if(bValid == 0)
    {
        if(nSaveType == SAVING_THROW_TYPE_DEATH && nSpellID != SPELL_HORRID_WILTING && nSpellID != SPELL_DESTRUCTION)
        {
            eVis = EffectVisualEffect(VFX_IMP_DEATH);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
    }
    else //if(bValid == 1 || bValid == 2)
    {
        if(bValid == 2)
        {
            eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
            if(nSaveType == SAVING_THROW_TYPE_DEATH)//1.70: special workaround for action cancel issue
            {
                if(GetSpellId() == -1)
                {
                    object oWorkaround = GetObjectByTag("72_EC_DEATH");
                    if(!GetIsObjectValid(oWorkaround))
                    {
                        oWorkaround = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",GetStartingLocation(),FALSE,"72_EC_DEATH");
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY)),oWorkaround);
                        SetPlotFlag(oWorkaround,TRUE);
                    }
                    SetLocalObject(oWorkaround,"TARGET",oTarget);
                    AssignCommand(oWorkaround,ActionCastSpellAtObject(386,oWorkaround,METAMAGIC_ANY,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE));
                }
                else
                {//this is now fixed in NWN:EE
                    //SetCommandable(FALSE,oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDeath(),oTarget);//1.70: engine hack to get proper feedback
                    //SetCommandable(TRUE,oTarget);
                }
            }
            else
            {
                /*
                If the spell is save immune then the link must be applied in order to get the true immunity
                to be resisted.  That is the reason for returing false and not true.  True blocks the
                application of effects. Shadooow: doesn't work for death in order to fix action cancel bug.
                */
                bValid = FALSE;
            }
        }
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    }
    return bValid;
}

effect CreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1)
{
    int nFinal = nPower * 2;
    effect eAC = EffectACIncrease(nFinal, AC_DEFLECTION_BONUS);
    eAC = VersusAlignmentEffect(eAC, ALIGNMENT_ALL, nAlignment);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, nFinal);
    eSave = VersusAlignmentEffect(eSave,ALIGNMENT_ALL, nAlignment);
    effect eImmune = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    eImmune = VersusAlignmentEffect(eImmune,ALIGNMENT_ALL, nAlignment);
    effect eDur;
    if(nAlignment == ALIGNMENT_EVIL)
    {
        eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);
    }
    else if(nAlignment == ALIGNMENT_GOOD)
    {
        eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
    }

    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);
    return eLink;
}

effect CreateDoomEffectsLink()
{
//Declare major variables
effect eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL,2);
effect eAttack = EffectAttackDecrease(2);
effect eDamage = EffectDamageDecrease(2,DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
effect eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS,2);
effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

effect eLink = EffectLinkEffects(eAttack,eDamage);
eLink = EffectLinkEffects(eLink,eSaves);
eLink = EffectLinkEffects(eLink,eSkill);
return  EffectLinkEffects(eLink,eDur);
}

void RemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget)
{
//Declare major variables
effect eAOE;
 if(GetHasSpellEffect(nSpell_ID,oTarget))
 {
 //Search through the valid effects on the target.
 eAOE = GetFirstEffect(oTarget);
  while(GetIsEffectValid(eAOE))
  {
   //If the effect was created by the spell then remove it
   if(GetEffectSpellId(eAOE) == nSpell_ID)
   {
    if(GetEffectCreator(eAOE) == oCaster)
    {
    //Get next effect on the target
    RemoveEffect(oTarget,eAOE);
    return;
    }
   }
  eAOE = GetNextEffect(oTarget);
  }
 }
}

void RemoveSpecificEffect(int nEffectTypeID, object oTarget)
{
//Search through the valid effects on the target.
effect eAOE = GetFirstEffect(oTarget);
 while(GetIsEffectValid(eAOE))
 {
  if(GetEffectType(eAOE)==nEffectTypeID)
  {
  //If the effect was created by the spell then remove it
  RemoveEffect(oTarget,eAOE);
  }
 //Get next effect on the target
 eAOE = GetNextEffect(oTarget);
 }
}

float GetSpellEffectDelay(location SpellTargetLocation, object oTarget)
{
return GetDistanceBetweenLocations(SpellTargetLocation,GetLocation(oTarget))/20;
}

float GetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1)
{
 if(fMinimumTime<MaximumTime)
 {
 float fRandom = MaximumTime-fMinimumTime;
 int nRandom = FloatToInt(fRandom*10.0);
 nRandom = Random(nRandom+1);
 fRandom = IntToFloat(nRandom);
 fRandom /= 10.0;
 return fRandom + fMinimumTime;
 }
return 0.0;
}

int GetScaledDuration(int nActualDuration, object oTarget)
{
object oCaster = OBJECT_SELF;
int nNewDuration = nActualDuration;
 if(GetObjectType(oCaster) == OBJECT_TYPE_AREA_OF_EFFECT)
 oCaster = GetAreaOfEffectCreator();
 if(GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget)))
 {
 int nDifficulty = GetGameDifficulty();
  if(nDifficulty == GAME_DIFFICULTY_VERY_EASY)
  {
  nNewDuration = 1;
  }
  else if(nDifficulty == GAME_DIFFICULTY_EASY)
  {
  nNewDuration = 2;
  }
  else if(nDifficulty == GAME_DIFFICULTY_NORMAL)
  {
  nNewDuration = 3;
  }
  else
  {
   switch(GetModuleSwitchValue("71_SHORTENED_DURATION_OF_DISABLE_EFFECTS"))
   {
   case 1:
    if(GetIsPC(oCaster) || GetIsPC(GetMaster(oCaster)))
    break;
   case 2:
   case 3:
   nNewDuration = 3;
   break;
   }
  }
 }
 else if(GetLocalInt(oTarget,"71_SHORTENED_DURATION_OF_DISABLE_EFFECTS") || GetModuleSwitchValue("71_SHORTENED_DURATION_OF_DISABLE_EFFECTS") == 3)
 {
 nNewDuration = 3;
 }
 if(spell.DurationType == SPELL_DURATION_TYPE_SECONDS) nNewDuration*= 6;//1.72: support for a special case when builder decides to have the duration in seconds and also impose an upper limit
return nNewDuration < nActualDuration ? nNewDuration : nActualDuration;//1.72: fix for extending duration to 3 rounds if the original duration was 1 or 2 rounds
}

effect GetScaledEffect(effect eStandard, object oTarget)
{
object oCaster = OBJECT_SELF;
 if(GetObjectType(oCaster) == OBJECT_TYPE_AREA_OF_EFFECT)
 oCaster = GetAreaOfEffectCreator();
int nDiff = GetGameDifficulty();
 if(GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget)))
 {
  if(GetEffectType(eStandard) == EFFECT_TYPE_FRIGHTENED)
  {
   if(nDiff <= GAME_DIFFICULTY_EASY)
   {
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_FEAR, oCaster) || GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, oCaster))
    {
    return eStandard;//1.70: fix for the MySavingThrow and immunity problem
    }
    //not immune, and either easy or very easy difficulty
    if(nDiff == GAME_DIFFICULTY_EASY)
    {
    return EffectAttackDecrease(4);//easy
    }
   return EffectAttackDecrease(2);//very easy then
   }
  }
  if(nDiff == GAME_DIFFICULTY_VERY_EASY && (GetEffectType(eStandard) == EFFECT_TYPE_PARALYZE ||
                                            GetEffectType(eStandard) == EFFECT_TYPE_STUNNED ||
                                            GetEffectType(eStandard) == EFFECT_TYPE_CONFUSED))
  {
  return EffectDazed();
  }
  if(GetEffectType(eStandard) == EFFECT_TYPE_CHARMED || GetEffectType(eStandard) == EFFECT_TYPE_DOMINATED)
  {
  return EffectDazed();
  }
 }
return eStandard;
}

int RemoveProtections(int nSpell_ID, object oTarget, int nCount)
{
//Declare major variables
effect eProtection;
int nCnt;
 if(GetHasSpellEffect(nSpell_ID, oTarget))
 {
 //Search through the valid effects on the target.
 eProtection = GetFirstEffect(oTarget);
  while (GetIsEffectValid(eProtection))
  {
   //If the effect was created by the spell then remove it
   if(GetEffectSpellId(eProtection) == nSpell_ID)
   {
   RemoveEffect(oTarget, eProtection);
   //return 1;
   nCnt++;
   }
  //Get next effect on the target
  eProtection = GetNextEffect(oTarget);
  }
 }
return nCnt > 0;
}

//------------------------------------------------------------------------------
// Returns the nLastChecked-nth highest spell on the creature for use in
// the spell breach routines
// Please modify the constatn NW_I0_SPELLS_MAX_BREACH at the top of this file
// if you change the number of spells.
//------------------------------------------------------------------------------
int GetSpellBreachProtection(int nLastChecked)
{
    //--------------------------------------------------------------------------
    // GZ: Protections are stripped in the order they appear here
    //--------------------------------------------------------------------------
    if(nLastChecked == 1) {return SPELL_GREATER_SPELL_MANTLE;}
    else if (nLastChecked == 2){return SPELL_PREMONITION;}
    else if(nLastChecked == 3) {return SPELL_SPELL_MANTLE;}
    else if(nLastChecked == 4) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 5) {return SPELL_GREATER_STONESKIN;}
    else if(nLastChecked == 6) {return SPELL_ETHEREAL_VISAGE;}
    else if(nLastChecked == 7) {return SPELL_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 8) {return SPELL_ENERGY_BUFFER;}
    else if(nLastChecked == 9) {return SPELL_ETHEREALNESS;} // greater sanctuary
    else if(nLastChecked == 10) {return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 11) {return SPELL_SPELL_RESISTANCE;}
    else if(nLastChecked == 12) {return SPELL_STONESKIN;}
    else if(nLastChecked == 13) {return SPELL_LESSER_SPELL_MANTLE;}
    else if(nLastChecked == 14) {return SPELL_MESTILS_ACID_SHEATH;}
    else if(nLastChecked == 15) {return SPELL_MIND_BLANK;}
    else if(nLastChecked == 16) {return SPELL_ELEMENTAL_SHIELD;}
    else if(nLastChecked == 17) {return SPELL_PROTECTION_FROM_SPELLS;}
    else if(nLastChecked == 18) {return SPELL_PROTECTION_FROM_ELEMENTS;}
    else if(nLastChecked == 19) {return SPELL_RESIST_ELEMENTS;}
    else if(nLastChecked == 20) {return SPELL_DEATH_ARMOR;}
    else if(nLastChecked == 21) {return SPELL_GHOSTLY_VISAGE;}
    else if(nLastChecked == 22) {return SPELL_ENDURE_ELEMENTS;}
    else if(nLastChecked == 23) {return SPELL_SHADOW_CONJURATION_MAGE_ARMOR;}
    else if(nLastChecked == 24) {return SPELL_NEGATIVE_ENERGY_PROTECTION;}
    else if(nLastChecked == 25) {return SPELL_SANCTUARY;}
    else if(nLastChecked == 26) {return SPELL_MAGE_ARMOR;}
    else if(nLastChecked == 27) {return SPELL_STONE_BONES;}
    else if(nLastChecked == 28) {return SPELL_SHIELD;}
    else if(nLastChecked == 29) {return SPELL_SHIELD_OF_FAITH;}
    else if(nLastChecked == 30) {return SPELL_LESSER_MIND_BLANK;}
    else if(nLastChecked == 31) {return SPELL_IRONGUTS;}
    else if(nLastChecked == 32) {return SPELL_RESISTANCE;}
    return nLastChecked;
}

void AssignAOEDebugString(string sString)
{
object oTarget = GetAreaOfEffectCreator();
AssignCommand(oTarget, SpeakString(sString));
}


void PlayDragonBattleCry()
{
PlayVoiceChat(d100()>50 ? VOICE_CHAT_BATTLECRY1 : VOICE_CHAT_BATTLECRY2);
}

void TrapDoElectricalDamage(int ngDamageMaster, int nSaveDC, int nSecondary)
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
    location lTarget = GetLocation(oTarget);
    int nCount = 0;
    //Adjust the trap damage based on the feats of the target
    int nDamage = GetReflexAdjustedDamage(ngDamageMaster, oTarget, nSaveDC, SAVING_THROW_TYPE_TRAP);

    if (nDamage > 0)
    {
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }

    object o2ndTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    while (GetIsObjectValid(o2ndTarget) && nCount <= nSecondary)
    {
        //check to see that the original target is not hit again.
        if(o2ndTarget != oTarget && !GetIsReactionTypeFriendly(oTarget))
        {
            //Adjust the trap damage based on the feats of the target
            nDamage = GetReflexAdjustedDamage(ngDamageMaster, o2ndTarget, nSaveDC, SAVING_THROW_TYPE_TRAP);

            if (nDamage > 0)
            {
                //Set the damage effect
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
                //Apply the VFX impact and damage effect
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, o2ndTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o2ndTarget);
            }

            //Connect the lightning stream from one target to another.
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, o2ndTarget, 0.75);
            //Set the last target as the new start for the lightning stream
            eLightning = EffectBeam(VFX_BEAM_LIGHTNING, o2ndTarget, BODY_NODE_CHEST);
            //Increment the count
            nCount++;
        }
        //Get next target in the shape.
        o2ndTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    }
}
