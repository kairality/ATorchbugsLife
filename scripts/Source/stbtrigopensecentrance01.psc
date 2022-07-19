Scriptname stbtrigopensecentrance01 extends ObjectReference  

int runOnce = 0 ; whether we opened the door
Quest Property myQuest Auto

Race Property STBSummonedGreenTorchbugRace Auto;
Race Property STBSummonedRedTorchbugRace Auto;
Keyword Property STBKEYWTorchbugIllumination Auto;

FormList Property STBFLSTPetTorchbugs  Auto ; List of torchbug ActorBase forms. Summoned green/red torchbug can't be included since they use LeveledActorBases

; For checking whether the pet torchbug is actually illuminated
int petTorchbugsInside = 0 ; count trigger enter / exits of torchbug pets https://www.creationkit.com/index.php?title=OnTriggerEnter_-_ObjectReference
Float updatePeriod = 1.0 ; How often do we check for illumination?
Float SeekRange = 512.0 ; in skyrim units, a unit is 1/4096th of a map coord. This should be roughly the radius of the trigger.

Function doTriggerActivatedActions() ; open the secret door
    myQuest.Start()
    myQuest.SetStage(10)
    runOnce = 1
endFunction

Event OnTriggerEnter(ObjectReference _akActionRef)
    ; Don't poll once we've run.
    if (runOnce == 1)
        return
    endif

    ; https://www.creationkit.com/index.php?title=Cast_Reference
    ;
    Actor akActionRef = _akActionRef as Actor
    if (akActionRef == None)
        return
    endif


    debug.notification("Have actor...")
    debug.trace("Have actor...")

    Race akRace = akActionRef.getRace()

    if (akRace == STBSummonedGreenTorchbugRace || akRace == STBSummonedRedTorchbugRace ) ;
        debug.notification("Have summoned...")
        debug.trace("Have summoned...")
        doTriggerActivatedActions()
        return
    endif

    ActorBase akActorBase = akActionRef.getActorBase()

    if (STBFLSTPetTorchbugs.HasForm(akActorBase)) ;
        petTorchbugsInside += 1

        if (akActionRef.HasEffectKeyword(STBKEYWTorchbugIllumination))
            debug.notification("Have pet...")
            debug.trace("Have pet...")
            doTriggerActivatedActions()
        else
            GoToState("waiting")
            RegisterForSingleUpdate(updatePeriod)
            debug.notification("Polling...")
            debug.trace("Polling...")
        endif
    endif
EndEvent

Event OnTriggerLeave(ObjectReference _akActionRef)
    Actor akActionRef = _akActionRef as Actor
    if (akActionRef == None)
        return
    endif

    ActorBase akActorBase = akActionRef.getActorBase()
    if (STBFLSTPetTorchbugs.HasForm(akActorBase )) ;
        petTorchbugsInside -= 1
        if (petTorchbugsInside == 0);             
            ; empty string goes to the empty 'default' state
            GoToState("")
            debug.notification("stopped polling...")
            debug.trace("stopped polling...")
        endif
    endif
EndEvent

State waiting
    Event OnUpdate()
        ; Don't loop once we've run.
        if (runOnce == 1)
            return
        endif

        ObjectReference closestTorchbug = Game.FindClosestReferenceOfAnyTypeInListfromRef(STBFLSTPetTorchbugs, Self, SeekRange)
        if closestTorchbug ; it's possible that there is no target 
            if (closestTorchbug.HasEffectKeyword(STBKEYWTorchbugIllumination))
                debug.notification("Have pet 2...")
                debug.trace("Have pet 2...")
                doTriggerActivatedActions()       
                ; empty string goes to the empty 'default' state
                GoToState("")
            endif
        endif
        RegisterForSingleUpdate(updatePeriod)
    EndEvent
endState
