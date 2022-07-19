Scriptname STBNoteTorchyOnRead extends ReferenceAlias  

int Property myStage  Auto  

int RunOnce = 0

event onRead()
    if RunOnce == 0
        GetOwningQuest().setObjectiveDisplayed(25)
        GetOwningQuest().setObjectiveCompleted(25)
        if GetOwningQuest().isObjectiveCompleted(25) && GetOwningQuest().isObjectiveCompleted(20)
            GetOwningQuest().SetStage(30)
        endif
        RunOnce = 1
    endif
endEvent


