Scriptname STBNoteTorchyOnAcquire extends ReferenceAlias  

auto State waiting  
    Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
        ;       Debug.Trace("OnContainerChanged received.")
        if (Game.GetPlayer() == akNewContainer)
            Quest qst = GetOwningQuest()
            qst.SetObjectiveDisplayed(25)
            GoToState("inactive")
        endif
    EndEvent
EndState

State inactive
EndState

