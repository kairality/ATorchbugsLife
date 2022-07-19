Scriptname stbtrigtorchbuglight extends ObjectReference  
{A Torchbug's Life - When a torchbug shines its light within this activator:
  - activate(self)
when the torchbug light no longer shines within the activator:
  - GetLinkedRef().activate(self)}

Actor property playerRef Auto;
Race Property STBSummonedGreenTorchbugRace Auto;
Race Property STBSummonedRedTorchbugRace Auto;
Keyword Property STBKEYWTorchbugIllumination Auto;

FormList Property STBFLSTPetTorchbugs  Auto ; List of torchbug ActorBase forms. Summoned green/red torchbug can't be included since they use LeveledActorBases

; For checking whether the pet torchbug is actually illuminated
int summonedTorchbugsInside = 0; count tirgger enter / exits of summoned torchbugs
int petTorchbugsInside = 0 ; count trigger enter / exits of torchbug pets https://www.creationkit.com/index.php?title=OnTriggerEnter_-_ObjectReference
bool petTorchbugIsIlluminated = false ; if the pet torchbug is currently illuminated (all pet torchbugs should be on/off simultaneously)
Float updatePeriod = 1.0 ; How often do we check for illumination?
Float SeekRange = 512.0 ; in skyrim units, a unit is 1/4096th of a map coord. This should be at most as large as the radius of the trigger.

Function doTriggerActivatedActions()
        ; send an activation signal through this activator
        activate(self)
endFunction

Function doTriggerDeactivatedActions() 
        ; send an activation signal through the auxilliary "Deactivate" activator
        GetLinkedRef().activate(self)
endFunction

Function onSummonedTorchbugsInsideChange(int old_summonedTorchbugsInside, int new_summonedTorchbugsInside)
    if (old_summonedTorchbugsInside == 0) ; assume we're going from 0 -> 1
       if (petTorchbugIsIlluminated == false) ; we don't have an illuminated pet torchbug
          doTriggerActivatedActions();
       endif
    endif
    if (new_summonedTorchbugsInside == 0) ; assume we're going from 1 -> 0
       if (petTorchbugIsIlluminated == false) ; we don't have an illuminated pet torchbug
          doTriggerDeactivatedActions();
       endif
    endif
endFunction

Function onPetTorchbugIsIlluminatedChange()
    if (petTorchbugIsIlluminated == true) ; assume we just lit up
        if (summonedTorchbugsInside == 0) ; we don't have any summoned torchbugs
          doTriggerActivatedActions();
       endif
    endif
    if (petTorchbugIsIlluminated == false) ; assume we just went dark
        if (summonedTorchbugsInside == 0) ; we don't have any summoned torchbugs
          doTriggerDeactivatedActions();
       endif
    endif
endFunction

Event OnTriggerEnter(ObjectReference _akActionRef)

    ; https://www.creationkit.com/index.php?title=Cast_Reference
    ;
    Actor akActionRef = _akActionRef as Actor
    if (akActionRef == None)
        return
    endif

    ; We have an actor...

    Race akRace = akActionRef.getRace()

    if (akRace == STBSummonedGreenTorchbugRace || akRace == STBSummonedRedTorchbugRace ) ;
       ; We have a summoned torchbug!
        int old_summonedTorchbugsInside = summonedTorchbugsInside
        summonedTorchbugsInside += 1
        onSummonedTorchbugsInsideChange(old_summonedTorchbugsInside, summonedTorchbugsInside)
        return
    endif

    ActorBase akActorBase = akActionRef.getActorBase()

    if (STBFLSTPetTorchbugs.HasForm(akActorBase)) ;
        ; We have a pet torchbug!
        petTorchbugsInside += 1

        if (petTorchbugIsIlluminated  == false)
            if (akActionRef.HasEffectKeyword(STBKEYWTorchbugIllumination))
                ; We have an illuminated pet torchbug!
                petTorchbugIsIlluminated = true
                onPetTorchbugIsIlluminatedChange()
            endif
        endif

        ; Start polling for illumination change on the pet
        GoToState("waiting")
        RegisterForSingleUpdate(updatePeriod)
    endif
EndEvent

Event OnTriggerLeave(ObjectReference _akActionRef)
    Actor akActionRef = _akActionRef as Actor
    if (akActionRef == None)
        return
    endif

    ; We have an actor

    Race akRace = akActionRef.getRace()

    if (akRace == STBSummonedGreenTorchbugRace || akRace == STBSummonedRedTorchbugRace ) ;
        ; Summoned torchbug left the trigger
        int old_summonedTorchbugsInside = summonedTorchbugsInside
        summonedTorchbugsInside -= 1
        onSummonedTorchbugsInsideChange(old_summonedTorchbugsInside, summonedTorchbugsInside)
        return
    endif

    ActorBase akActorBase = akActionRef.getActorBase()
    if (STBFLSTPetTorchbugs.HasForm(akActorBase )) ;
        petTorchbugsInside -= 1
        if (petTorchbugsInside == 0);             
		if (petTorchbugIsIlluminated  == true)
	           petTorchbugIsIlluminated  = false;
                 onPetTorchbugIsIlluminatedChange()
             endif
            ; empty string goes to the empty 'default' state
            ; Stop polling
            GoToState("")
        endif
    endif
EndEvent

State waiting
    Event OnUpdate()
        ; Skip polling if we already moved the last pet torchbug out of the trigger.
        ; This can happen if OnUpdate is called at ~ the same time the torchbug moves out of the trigger, I guess (maybe this can't happen.)
        if (petTorchbugsInside == 0)
               return
        endif             

        ObjectReference closestTorchbug = Game.FindClosestReferenceOfAnyTypeInListfromRef(STBFLSTPetTorchbugs, Self, SeekRange)

        bool new_petTorchbugIsIlluminated = false       

        if closestTorchbug ; it's possible that there is no target 
            if (closestTorchbug.HasEffectKeyword(STBKEYWTorchbugIllumination))
                new_petTorchbugIsIlluminated = true;
                if (petTorchbugIsIlluminated  == false)
                       ; We found an illuminated pet torchbug
	                petTorchbugIsIlluminated  = true;
       	         onPetTorchbugIsIlluminatedChange()       
                endif
            endif
        endif

        ; If we aren't illuminated close the door
        if (new_petTorchbugIsIlluminated == false)                
		if (petTorchbugIsIlluminated  == true)
	           petTorchbugIsIlluminated  = false;
                  ; Pet torchbug is no longer illuminated
       	    onPetTorchbugIsIlluminatedChange()
             endif
       endif

        ; Keep polling.
        RegisterForSingleUpdate(updatePeriod)
    EndEvent
endState
