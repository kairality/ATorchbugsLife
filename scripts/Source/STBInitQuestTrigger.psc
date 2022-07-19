Scriptname STBInitQuestTrigger extends ObjectReference  

Int RunOnce
Quest Property myQuest Auto
ObjectReference Property BookRef Auto
Actor Property PlayerREF Auto

Event OnTriggerEnter(ObjectReference akActionRef)
    If akActionRef == PlayerREF
        If RunOnce == 0
            debug.notification("Quest initialized")
            debug.trace("Quest initialized")
            myQuest.Start()
            BookRef.enable()
            RunOnce = 1
        EndIf
    EndIf
EndEvent
