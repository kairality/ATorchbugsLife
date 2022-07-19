Scriptname STBQuestTrigger extends ObjectReference

Int RunOnce
Quest Property myQuest Auto
Actor Property PlayerREF Auto

Event OnRead()
    If RunOnce == 0
        debug.notification("Quest started")
        debug.trace("Quest started")
        myQuest.SetStage(10)
        RunOnce = 1
    EndIf
EndEvent
