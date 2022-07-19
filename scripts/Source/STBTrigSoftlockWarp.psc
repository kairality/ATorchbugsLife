Scriptname STBTrigSoftlockWarp extends ObjectReference  
{A Torchbug's Life - When the player is within this trigger and it is enabled, warp them to the linked reference's location}

Actor property playerRef Auto;

Event OnTriggerEnter(ObjectReference akActionRef)

    if (akActionRef == playerRef)
       playerRef.moveto(GetLinkedRef())
    endif

EndEvent

Event OnTriggerLeave(ObjectReference _akActionRef)
    debug.notification("You were pulled away by a mysterious power.")
EndEvent
