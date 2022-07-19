Scriptname STBLeverResettable extends ObjectReference  
{A ghostly lever script that can be reset and enabled/disabled by a pair of activators.}

Activator Property XMarkerActivator Auto;
Actor Property PlayerRef Auto;

bool busy = false 
bool isInPullPosition = true

; Known states:
;   FullPush -> FullPushedUp
;   FullPull -> FullPulledDown

; This is inspired by the SetOpen in default2StateActivator but this is cleaned up and we allow dropping "pushes"
function MySetInPullPosition(bool abInPullPosition)
       while (busy); spin
             if (!abInPullPosition); fast path, drop pushes if we're busy 
                  return;
             endif
		utility.wait(1)
	endWhile
      busy = true

      ;;; critical section
	if (abInPullPosition && !isInPullPosition); we should pull
 	     playAnimationAndWait("FullPull", "FullPulledDown") ; 
            isInPullPosition= true
	elseif (!abInPullPosition && isInPullPosition); we should push
           playAnimationAndWait("FullPush", "FullPushedUp") ; 
           ; Fire the "push" activator. We do this inside the critical section to avoid duplicate push signals and also to time it so that it "feels" like it's a result of the push
           GetLinkedRef().activate(self)
           isInPullPosition= false
	endif
       ;;; end critical section

       busy = false
endFunction

EVENT OnLoad()
	MySetInPullPosition(isInPullPosition)
endEVENT

EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           ; pull the lever (reset to default position) and then disable it
           MySetInPullPosition(true)
           disable();
     elseif (triggerRef == PlayerRef);
           ; Hm, do a toggle.
           if (IsDisabled())
                 Debug.notification("lever somehow activated despite disabled")
           endIf
           if (isInPullPosition); we are pushing
	           MySetInPullPosition(false)
           else; we are pulling
	           MySetInPullPosition(true)
           endif
     else           
           ; enable the lever
           enable()
     endif
endEVENT
