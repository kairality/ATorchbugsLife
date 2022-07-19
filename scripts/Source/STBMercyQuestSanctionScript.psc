Scriptname STBMercyQuestSanctionScript extends ActiveMagicEffect  

Perk Property STBMercyQuestStendarrsGazePerk  Auto
Perk Property STBMercyQuestStendarrsSanctionPerk  Auto  
Quest Property STBMercyControlQuest  Auto
Message Property STBMercyQuestSanctionMessageGain  Auto  
Message Property STBMercyQuestSanctionMessageLose  Auto

Int CharityQuestObjective = 10
Int CharityBlockedStage = 10
Int ReturnQuestObjective = 15

; wait to get out of menu before doing quest objective stuff
; when this effect starts we want to make sure we set the return quest objective and register for events that can lose this status
Event OnEffectStart(Actor akTarget, Actor akCaster)
    Utility.Wait(0.1)
    STBMercyControlQuest.SetObjectiveDisplayed(CharityQuestObjective,0,1)
    STBMercyControlQuest.SetObjectiveDisplayed(ReturnQuestObjective,1,1)
    STBMercyQuestSanctionMessageGain.Show()
    RegisterForTrackedStatsEvent()
endEvent

; remove this effect if the player is naughty
Event OnTrackedStatsEvent(string asStatFilter, int aiStatValue)
    If (asStatFilter == "Pockets Picked" || asStatFilter == "Items Pickpocketed"  || asStatFilter == "Murders" || asStatFilter == "Werewolf Transformations" || asStatFilter == "Necks Bitten" || asStatFilter == "Total Lifetime Bounty")
      Game.GetPlayer().RemovePerk(STBMercyQuestStendarrsSanctionPerk)
    endIf
endEvent

; remove this effect if the player becomes a vampire
Event OnVampirismStateChanged(bool abIsVampire)
  If (abIsVampire)
	 Game.GetPlayer().RemovePerk(STBMercyQuestStendarrsSanctionPerk)
  endIf
endEvent

; if we lose this effect and the quest stage is still the charity/return quest then reapply gaze effect
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if (STBMercyControlQuest.GetStage() == CharityBlockedStage)
		Utility.Wait(0.1)
		STBMercyQuestSanctionMessageLose.Show()
		STBMercyControlQuest.SetObjectiveDisplayed(ReturnQuestObjective,0,1)
		Game.GetPlayer().AddPerk(STBMercyQuestStendarrsGazePerk)
       EndIf
	Debug.Notification("Sanction Dispelled")
endEvent