Scriptname STBMercyCharityScript extends ActiveMagicEffect 

Quest Property STBMercyControlQuest  Auto
Message Property STBMercyQuestGazeMessage  Auto
Message Property STBMercyQuestGazeUndeadMessage Auto
Keyword Property ActorTypeUndead Auto
  

Int CharityQuestObjective = 10
Int ReturnQuestObjective = 15

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Debug.Notification("OnEffectStart of STBMercyCharityScript")
    Utility.Wait(0.1)
    STBMercyQuestGazeMessage.Show()
    STBMercyControlQuest.SetObjectiveDisplayed(ReturnQuestObjective,0,1)
    STBMercyControlQuest.SetObjectiveCompleted(CharityQuestObjective,0)
    STBMercyControlQuest.SetObjectiveDisplayed(CharityQuestObjective,1,1)
endEvent

Event OnVampirismStateChanged(bool abIsVampire)
	If (abIsVampire)
         STBMercyQuestGazeUndeadMessage.Show()
      Else
	     STBMercyQuestGazeMessage.Show()
      endIf
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If (!Game.GetPlayer().HasKeyWord(ActorTypeUndead))
	  STBMercyControlQuest.SetObjectiveCompleted(CharityQuestObjective,1)
      EndIf
	  Debug.Notification("Gaze Dispelled")
endEvent
