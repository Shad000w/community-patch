//::///////////////////////////////////////////////
//:: Saving Throw
//:: 70_s2_savthrow
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script runs anytime a saving throw is performed by creature.

This allows to modify the various bonuses to saving throws and do stuff like Dexterous Will or Epic Resilience.

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 27-8-2018 rewritten to work without NWNX 12-06-2022
//:://////////////////////////////////////////////

void BroadcastSavingThrowData(object oCreature, object oTarget, int nDifficultyClass, int nBonus, int nRoll, int nSavingThrow, int nSaveType, int nFeat);

int GetTotalEffectBonus(object oTarget, object oVersus, int nSavingThrow, int nSaveType);

void main()
{
    //Declare major variables
    object oSelf = OBJECT_SELF;//creature who performs the saving throw
    int nType = GetLocalInt(oSelf,"SAVINGTHROW_TYPE");
    int nDifficultyClass = GetLocalInt(oSelf,"SAVINGTHROW_DC");
    int nSaveType = GetLocalInt(oSelf,"SAVINGTHROW_SAVETYPE");
    object oSaveVersus = GetLocalObject(oSelf,"SAVINGTHROW_VERSUS");
    object oVersus = GetObjectType(oSaveVersus) == OBJECT_TYPE_AREA_OF_EFFECT ? GetAreaOfEffectCreator(oSaveVersus) : oSaveVersus;
    int nFeat = GetLocalInt(oSelf,"SAVINGTHROW_FEAT");
    int nSpell = GetLocalInt(oSelf,"SAVINGTHROW_SPELL");
    int bPrint = GetLocalInt(oSelf,"SAVINGTHROW_FEEDBACKSHOW");

    if(nDifficultyClass < 1)
    {
        WriteTimestampedLogEntry("70_s2_savthrow: WARNING, negative DC saving throw, self: "+GetName(oSelf)+", nDC: "+IntToString(nDifficultyClass)+", nType: "+IntToString(nType)+", nSaveType: "+IntToString(nSaveType)+", nSpell: "+IntToString(nSpell)+", nFeat: "+IntToString(nFeat)+", oVersus: "+GetName(oSaveVersus));
    }

    int nSave = 0, nUserType = -1;
    if(nSpell > -1) nUserType = StringToInt(Get2DAString("spells","UserType",nSpell));

    if(nType == SAVING_THROW_FORT)
    {
        nSave = GetFortitudeSavingThrow(oSelf);
    }
    else if(nType == SAVING_THROW_WILL)
    {
        nSave = GetWillSavingThrow(oSelf);
    }
    else if(nType == SAVING_THROW_REFLEX)
    {
        nSave = GetReflexSavingThrow(oSelf);
    }
    else
    {
        SetLocalInt(oSelf,"SAVINGTHROW_RETURN",0);
        return;
    }
    int nBonus = nSaveType ? GetTotalEffectBonus(oSelf,oVersus,nType,nSaveType) : 0;//1 - mind, 12 - cold
    if(GetIsObjectValid(oSaveVersus))
    {
        if(nSaveType != SAVING_THROW_TYPE_SPELL && nSpell != -1)
        {
            if(nUserType == 1 /*|| nUserType == 2*/)//1.72: spells only, in vanilla arcane defense applies incorrectly against creature special abilities too
            {
                string sSpellSchool = Get2DAString("spells","School",nSpell);
                int nSpellSchool = SPELL_SCHOOL_GENERAL;
                if(sSpellSchool == "A") nSpellSchool = SPELL_SCHOOL_ABJURATION;
                else if(sSpellSchool == "C") nSpellSchool = SPELL_SCHOOL_CONJURATION;
                else if(sSpellSchool == "D") nSpellSchool = SPELL_SCHOOL_DIVINATION;
                else if(sSpellSchool == "E") nSpellSchool = SPELL_SCHOOL_ENCHANTMENT;
                else if(sSpellSchool == "V") nSpellSchool = SPELL_SCHOOL_EVOCATION;
                else if(sSpellSchool == "I") nSpellSchool = SPELL_SCHOOL_ILLUSION;
                else if(sSpellSchool == "N") nSpellSchool = SPELL_SCHOOL_NECROMANCY;
                else if(sSpellSchool == "T") nSpellSchool = SPELL_SCHOOL_TRANSMUTATION;

                nBonus+= GetTotalEffectBonus(oSelf,oVersus,nType,SAVING_THROW_TYPE_SPELL);
                if(GetHasFeat(FEAT_HARDINESS_VERSUS_SPELLS))
                {
                    nBonus+= 2;
                }
                switch(nSpellSchool)
                {
                    case SPELL_SCHOOL_ABJURATION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_ABJURATION)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_CONJURATION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_CONJURATION)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_DIVINATION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_DIVINATION)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_ENCHANTMENT: if(GetHasFeat(FEAT_ARCANE_DEFENSE_ENCHANTMENT)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_EVOCATION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_EVOCATION)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_ILLUSION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_ILLUSION)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_NECROMANCY: if(GetHasFeat(FEAT_ARCANE_DEFENSE_NECROMANCY)) nBonus+=2;
                        break;
                    case SPELL_SCHOOL_TRANSMUTATION: if(GetHasFeat(FEAT_ARCANE_DEFENSE_TRANSMUTATION)) nBonus+=2;
                        break;
                }
            }
        }
    }

    if(nSaveType == SAVING_THROW_TYPE_MIND_SPELLS)
    {
        if(GetHasFeat(FEAT_PERFECT_SELF) || GetIsImmune(oSelf,IMMUNITY_TYPE_MIND_SPELLS,oVersus))
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);

            return;
        }
        if(GetHasFeat(FEAT_STILL_MIND)) nBonus+=2;
        if(GetHasFeat(FEAT_LLIIRAS_HEART)) nBonus+=2;
        if(GetHasFeat(FEAT_HARDINESS_VERSUS_ENCHANTMENTS) || GetHasFeat(FEAT_HARDINESS_VERSUS_ILLUSIONS)) nBonus+=2;
    }
    else if(nSaveType == SAVING_THROW_TYPE_TRAP)
    {
        if(GetIsImmune(oSelf,IMMUNITY_TYPE_TRAP,oVersus))
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);
            return;
        }
        if(GetHasFeat(FEAT_DENEIRS_EYE)) nBonus+=2;
    }
    else if(nSaveType == SAVING_THROW_TYPE_FEAR)
    {
        if(GetIsImmune(oSelf,IMMUNITY_TYPE_FEAR,oVersus))
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);
            return;
        }
        if(GetHasFeat(FEAT_FEARLESS)) nBonus+=2;
        if(GetHasFeat(FEAT_RESIST_NATURES_LURE)) nBonus+=2;
    }
    else if(nSaveType == SAVING_THROW_TYPE_DISEASE)
    {
        if(GetIsImmune(oSelf,IMMUNITY_TYPE_DISEASE,oVersus))
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);
            return;
        }
        if(nType == SAVING_THROW_FORT && GetHasFeat(FEAT_RESIST_DISEASE)) nBonus+=4;
    }
    else if(nSaveType == SAVING_THROW_TYPE_POISON)
    {
        if(GetHasFeat(FEAT_EPIC_PERFECT_HEALTH) || GetIsImmune(oSelf,IMMUNITY_TYPE_POISON,oVersus))
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);
            return;
        }
        if(GetHasFeat(FEAT_HARDINESS_VERSUS_POISONS)) nBonus+=2;
        if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_EPIC))//assassin poison bonus
        {
            nBonus+= GetLevelByClass(CLASS_TYPE_ASSASSIN)/2;
        }
        else if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_5)) nBonus+=5;//assassin poison bonus
        else if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_4)) nBonus+=4;//assassin poison bonus
        else if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_3)) nBonus+=3;//assassin poison bonus
        else if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_2)) nBonus+=2;//assassin poison bonus
        else if(GetHasFeat(FEAT_PRESTIGE_POISON_SAVE_1)) nBonus+=1;//assassin poison bonus
        if(nType == SAVING_THROW_FORT)
        {
            if(GetHasFeat(FEAT_RESIST_POISON)) nBonus+=4;
            if(GetHasFeat(FEAT_SNAKEBLOOD)) nBonus+=2;
        }
    }
    else if(nSaveType == SAVING_THROW_TYPE_DEATH)
    {
        if(GetIsObjectValid(oSaveVersus) && nSpell != -1 && nSpell != SPELL_IMPLOSION && GetIsImmune(oSelf,IMMUNITY_TYPE_DEATH,oVersus))
        {
            if((nUserType == 1 || nUserType == 2))
            {
                SetLocalInt(oSelf,"SAVINGTHROW_RETURN",2);
                return;
            }
        }
    }
    if(GetIsObjectValid(oSaveVersus) && (nSaveType == SAVING_THROW_TYPE_SPELL || nSpell != -1) && GetSkillRank(SKILL_SPELLCRAFT,oSelf,TRUE) > 0)
    {
        if(nUserType == 1) nBonus+= GetSkillRank(SKILL_SPELLCRAFT,oSelf)/5;
    }
    if(GetIsObjectValid(oSaveVersus) && GetIsTrapped(oSaveVersus))
    {
        if(GetHasFeat(FEAT_PRESTIGE_DEFENSIVE_AWARENESS_3)) nBonus+=1;
        if(GetHasFeat(FEAT_UNCANNY_DODGE_6))
        {
            int nLevelBarbarian = GetLevelByClass(CLASS_TYPE_BARBARIAN);
            int nLevelRogue = GetLevelByClass(CLASS_TYPE_ROGUE);
            if(nLevelBarbarian >= nLevelRogue)
            {
                if(nLevelBarbarian > 21) nBonus+= 5+(nLevelBarbarian-19)/3;
            }
            else if(nLevelRogue > 22) nBonus+= 5+(nLevelRogue-20)/3;
        }
        else if(GetHasFeat(FEAT_UNCANNY_DODGE_5)) nBonus+=4;
        else if(GetHasFeat(FEAT_UNCANNY_DODGE_4)) nBonus+=3;
        else if(GetHasFeat(FEAT_UNCANNY_DODGE_3)) nBonus+=2;
        else if(GetHasFeat(FEAT_UNCANNY_DODGE_2)) nBonus+=1;
    }
    if(nBonus > 20) nBonus = 20;
    while(TRUE)
    {
        int nRoll = d20();
        if(bPrint)
        {
            if(GetIsPC(oSelf))
            {
                BroadcastSavingThrowData(oSelf,oSelf,nDifficultyClass,nSave+nBonus,nRoll,nType,nSaveType,nFeat);
            }
            if(oSelf != oVersus && GetIsPC(oVersus))
            {
                BroadcastSavingThrowData(oVersus,oSelf,nDifficultyClass,nSave+nBonus,nRoll,nType,nSaveType,nFeat);
            }
        }
        if(nRoll == 20 || (nRoll != 1 && nRoll+nSave+nBonus >= nDifficultyClass))//unfortunately NWN-EE still don't allow read settings.tml so this won't respect the natural-ones-fail-saving-throws options but there is no other way
        {
            SetLocalInt(oSelf,"SAVINGTHROW_RETURN",1);
            return;
        }
        if(nType == SAVING_THROW_WILL && nSaveType == SAVING_THROW_TYPE_MIND_SPELLS && nFeat != FEAT_SLIPPERY_MIND && GetHasFeat(FEAT_SLIPPERY_MIND))
        {
            nFeat = FEAT_SLIPPERY_MIND;
            continue;
        }
        break;
    }
    SetLocalInt(oSelf,"SAVINGTHROW_RETURN",0);
}

string GetSaveTypeLocalizedString(int nLanguage, int nSaveType)
{
    string sVs,sParse;
    switch(nLanguage)
    {
        case PLAYER_LANGUAGE_FRENCH:
        sParse = "[\"\",\"Affectant l'esprit\",\"Poison\",\"Maladie\",\"Terreur\",\"Son\",\"Acide\",\"Feu\",\"Electricit\u00e9\",\"Energie positive\",\"Energie n\u00e9gative\",\"Mort\",\"Froid\",\"Divin\",\"\",\"\",\"Pi\u010dges\",\"Sorts\",\"Loi\",\"Chaos\",\"Bien\",\"Mal\",\"\",\"\",\"\"]";
        sVs = " vs ";
        break;
        case PLAYER_LANGUAGE_GERMAN:
        sParse = "[\"\",\"Geist beeinflussend\",\"Vergiften\",\"Krankheit\",\"Furcht\",\"Schall\",\"S\u00e4ure\",\"Feuer\",\"Elektrizit\u00e4t\",\"Positive Energie\",\"Negative Energie\",\"Tod\",\"K\u00e4lte\",\"G\u00f6ttlich\",\"\",\"\",\"Fallen\",\"Zauber\",\"Ordnung\",\"Chaos\",\"Gutes\",\"B\u00f6ses\",\"\",\"\",\"\"]";
        sVs = " gegen ";
        break;
        case PLAYER_LANGUAGE_ITALIAN:
        sParse = "[\"\",\"Influenza Mentale\",\"Veleno\",\"Malattia\",\"Paura\",\"Sonoro\",\"Acido\",\"Fuoco\",\"Elettricit\u0155\",\"Energia Positiva\",\"Energia Negativa\",\"Morte\",\"Freddo\",\"Divino\",\"\",\"\",\"Trappole\",\"Incantesimi\",\"Legge\",\"Caos\",\"Bene\",\"Male\",\"\",\"\",\"\"]";
        sVs = " contro ";
        break;
        case PLAYER_LANGUAGE_SPANISH:
        sParse = "[\"\,\"Enajenador\",\"Veneno\",\"Enfermedad\",\"Miedo\",\"S\u00f3nico\",\"\u00c1cido\",\"Fuego\",\"El\u00e9ctrico\",\"Energ\u00eda positiva\",\"Energ\u00eda negativa\",\"Muerte\",\"Fr\u00edo\",\"Divino\",\"\",\"\",\"Trampas\",\"Conjuros\",\"Ley\",\"Caos\",\"Bien\",\"Mal\",\"\",\"\",\"\"]";
        sVs = " contra ";
        break;
        case PLAYER_LANGUAGE_POLISH:
        sParse = "[\"\",\"Umys\u0142owy\",\"Trucizna\",\"Choroba\",\"Strach\",\"D\u017awi\u0119k\",\"Kwas\",\"Ogie\u0144\",\"Elektryczno\u015b\u0107\",\"Pozytywna energia\",\"Negatywna energia\",\"\u015amier\u0107\",\"Zimno\",\"Boski\",\"\",\"\",\"Pu\u0142apki\",\"Zakl\u0119cia\",\"Prawo\",\"Chaos\",\"Dobro\",\"Z\u0142o\",\"\",\"\",\"\"]";
        sVs = " przeciwko: ";
        break;
        default:
        sParse = "[\"\",\"Mind Affecting\",\"Poison\",\"Disease\",\"Fear\",\"Sonic\",\"Acid\",\"Fire\",\"Electrical\",\"Positive Energy\",\"Negative Energy\",\"Death\",\"Cold\",\"Divine\",\"\",\"\",\"Traps\",\"Spells\",\"Law\",\"Chaos\",\"Good\",\"Evil\",\"\",\"\",\"\"]";
        sVs = " vs. ";
        break;
    }
    json jArray = JsonParse(sParse);
    return sVs + JsonGetString(JsonArrayGet(jArray,nSaveType));
}

void BroadcastSavingThrowData(object oCreature, object oTarget, int nDifficultyClass, int nBonus, int nRoll, int nType, int nSaveType, int nFeat)
{
    int nLanguage = GetPlayerLanguage(oCreature);
    int bResult = nRoll == 20 || (nRoll != 1 && nRoll+nBonus > nDifficultyClass);
    string sResult, sVersusDC, sSlipperyMind, sFortSave, sReflexSave, sWillSave;
    switch(nLanguage)
    {
        case PLAYER_LANGUAGE_FRENCH:
        sResult = bResult ? "réussite" : "échec";
        sVersusDC = " vs. DD : ";
        sSlipperyMind = "Esprit fuyant";
        sFortSave = "Jet de Vigueur";
        sReflexSave = "Jet de Réflexes";
        sWillSave = "Jet de Volonté";
        break;
        case PLAYER_LANGUAGE_GERMAN:
        sResult = bResult ? "Erfolg" : "Misserfolg";
        sVersusDC = " gg. SG: ";
        sSlipperyMind = "Entschlüpfender Geist";
        sFortSave = "Zähigkeitswurf";
        sReflexSave = "Reflexwurf";
        sWillSave = "Willenswurf";
        break;
        case PLAYER_LANGUAGE_ITALIAN:
        sResult = bResult ? "successo" : "fallimento";
        sVersusDC = " contro CD:";
        sSlipperyMind = "Mente Sfuggente";
        sFortSave = "Tiro salvezza Tempra";
        sReflexSave = "Tiro salvezza Riflessi";
        sWillSave = "Tiro salvezza Volontà";
        break;
        case PLAYER_LANGUAGE_SPANISH:
        sResult = bResult ? "éxito" : "fracaso";
        sVersusDC = " contra CD ";
        sSlipperyMind = "Mente escurridiza";
        sFortSave = "Salvación de Fortaleza";
        sReflexSave = "Salvación de Reflejos";
        sWillSave = "Salvación de Voluntad";
        break;
        case PLAYER_LANGUAGE_POLISH:
        sResult = bResult ? "sukces" : "niepowodzenie";
        sVersusDC = " przeciwko ST: ";
        sSlipperyMind = "Elastyczny umys³";
        sFortSave = "Rzut obronny, Wytrwa³";
        sReflexSave = "Rzut obronny, Refleks";
        sWillSave = "Rzut obronny, Si³a Woli";
        break;
        default: sResult = bResult ? "success" : "failure";
        sVersusDC = " vs. DC: ";
        sSlipperyMind = "Slippery Mind";
        sFortSave = "Fortitude Save";
        sReflexSave = "Reflex Save";
        sWillSave = "Will Save";
        break;
    }
    string sName = (oTarget == oCreature ? "<c™ÿÿ>" : "<cÌ™Ì>")+GetName(oTarget)+"</c>";
    string sMessage = " : ";
    switch(nType)
    {
        case SAVING_THROW_FORT: sMessage+= sFortSave; break;
        case SAVING_THROW_REFLEX: sMessage+= sReflexSave; break;
        case SAVING_THROW_WILL: sMessage+= sWillSave; break;
    }
    sMessage+= GetSaveTypeLocalizedString(nLanguage,nSaveType)+" : *"+sResult+"* : ("+IntToString(nRoll)+(nBonus < 0 ? " - " : " + ")+IntToString(nBonus)+" = "+IntToString(nRoll+nBonus)+sVersusDC+IntToString(nDifficultyClass)+")</c>";
    if(nFeat != -1)
    {
        if(nFeat == FEAT_SLIPPERY_MIND) sMessage = " : " + sSlipperyMind + sMessage;
        else sMessage = " : " + GetStringByStrRef(StringToInt(Get2DAString("feat","Name",nFeat))) + sMessage;
    }
    SendMessageToPC(oCreature,sName+"<cfÌÿ>"+sMessage);
}

int IPSaveVSConstToSavingThrowTypeCosts(int nIPConst)
{
    switch(nIPConst)
    {
        case IP_CONST_SAVEVS_ACID: return SAVING_THROW_TYPE_ACID;
        case IP_CONST_SAVEVS_COLD: return SAVING_THROW_TYPE_COLD;
        case IP_CONST_SAVEVS_DEATH: return SAVING_THROW_TYPE_DEATH;
        case IP_CONST_SAVEVS_DISEASE: return SAVING_THROW_TYPE_DISEASE;
        case IP_CONST_SAVEVS_DIVINE: return SAVING_THROW_TYPE_DIVINE;
        case IP_CONST_SAVEVS_ELECTRICAL: return SAVING_THROW_TYPE_ELECTRICITY;
        case IP_CONST_SAVEVS_FEAR: return SAVING_THROW_TYPE_FEAR;
        case IP_CONST_SAVEVS_FIRE: return SAVING_THROW_TYPE_FIRE;
        case IP_CONST_SAVEVS_MINDAFFECTING: return SAVING_THROW_TYPE_MIND_SPELLS;
        case IP_CONST_SAVEVS_NEGATIVE: return SAVING_THROW_TYPE_NEGATIVE;
        case IP_CONST_SAVEVS_POISON: return SAVING_THROW_TYPE_POISON;
        case IP_CONST_SAVEVS_POSITIVE: return SAVING_THROW_TYPE_POSITIVE;
        case IP_CONST_SAVEVS_SONIC: return SAVING_THROW_TYPE_SONIC;
        case IP_CONST_SAVEVS_UNIVERSAL: return SAVING_THROW_TYPE_ALL;
    }
    return nIPConst;
}

int GetTotalEffectBonus(object oTarget, object oVersus, int nSavingThrow, int nSaveType)
{
    int nBonus,nBonusHighest,nPenalty,nVal,nSlot,nLimit = GetSavingThrowBonusLimit();
    int nRace = GetRacialType(oVersus);
    int nLawChaos = GetAlignmentLawChaos(oVersus);
    int nGoodEvil = GetAlignmentGoodEvil(oVersus);
    itemproperty ip;
    object oItem;
    for(;nSlot < NUM_INVENTORY_SLOTS;nSlot++)
    {
        oItem = GetItemInSlot(nSlot,oTarget);
        if(GetIsObjectValid(oItem))
        {
            nBonusHighest = 0;
            ip = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(ip))
            {
                nVal = GetItemPropertyType(ip);
                if(nVal == ITEM_PROPERTY_SAVING_THROW_BONUS)
                {
                    nVal = GetItemPropertySubType(ip);
                    if(nVal != IP_CONST_SAVEVS_UNIVERSAL && IPSaveVSConstToSavingThrowTypeCosts(nVal) == nSaveType)
                    {
                        if(GetItemPropertyCostTableValue(ip) > nBonusHighest) nBonusHighest = GetItemPropertyCostTableValue(ip);
                    }
                }
                else if(nVal == ITEM_PROPERTY_DECREASED_SAVING_THROWS)
                {
                    nVal = GetItemPropertySubType(ip);
                    if(nVal != IP_CONST_SAVEVS_UNIVERSAL && IPSaveVSConstToSavingThrowTypeCosts(nVal) == nSaveType)
                    {
                        nPenalty+= GetItemPropertyCostTableValue(ip);
                    }
                }
                ip = GetNextItemProperty(oItem);
            }
            nBonus+= nBonusHighest;//same bonus type on same item doesn't stack, highest applies
        }
    }
    effect eSearch = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eSearch))
    {
        nVal = GetEffectType(eSearch);
        if(nVal == EFFECT_TYPE_SAVING_THROW_INCREASE)
        {
            nVal = nSavingThrow == GetEffectInteger(eSearch,1);
            if(nVal == SAVING_THROW_TYPE_ALL || nVal == nSavingThrow)
            {
                nVal = GetEffectInteger(eSearch,2);
                if(nVal != SAVING_THROW_TYPE_ALL && nVal == nSaveType)
                {
                    nVal = GetEffectInteger(eSearch,3);
                    if(nVal == RACIAL_TYPE_INVALID || nVal == nRace)
                    {
                        nVal = GetEffectInteger(eSearch,4);
                        if(!nVal || nVal == nLawChaos)
                        {
                            nVal = GetEffectInteger(eSearch,5);
                            if(!nVal || nVal == nGoodEvil)
                            {
                                nBonus+= GetEffectInteger(eSearch,0);
                            }
                        }
                    }
                }
            }
        }
        else if(nVal == EFFECT_TYPE_SAVING_THROW_DECREASE)
        {
            nVal = nSavingThrow == GetEffectInteger(eSearch,1);
            if(nVal == SAVING_THROW_TYPE_ALL || nVal == nSavingThrow)
            {
                nVal = GetEffectInteger(eSearch,2);
                if(nVal != SAVING_THROW_TYPE_ALL && nVal == nSaveType)
                {
                    nVal = GetEffectInteger(eSearch,3);
                    if(nVal == RACIAL_TYPE_INVALID || nVal == nRace)
                    {
                        nVal = GetEffectInteger(eSearch,4);
                        if(!nVal || nVal == nLawChaos)
                        {
                            nVal = GetEffectInteger(eSearch,5);
                            if(!nVal || nVal == nGoodEvil)
                            {
                                nPenalty+= GetEffectInteger(eSearch,0);
                            }
                        }
                    }
                }
            }
        }
        eSearch = GetNextEffect(oTarget);
    }
    if(nBonus > nLimit) nBonus = nLimit;
    return nBonus-nPenalty;
}
