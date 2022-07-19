Scriptname STBDecoctionOnAcquire extends ReferenceAlias  

auto State waiting    
    Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
        ;         Debug.Trace("OnContainerChanged received.")
        if (Game.GetPlayer() == akNewContainer)
            Quest qst = GetOwningQuest()
            qst.SetObjectiveCompleted(20)
            qst.SetObjectiveDisplayed(25)
            if GetOwningQuest().isObjectiveCompleted(25) && GetOwningQuest().isObjectiveCompleted(20)
                GetOwningQuest().SetStage(30)
            endif
            GoToState("inactive")
        endif
    EndEvent
EndState

State inactive
EndState
