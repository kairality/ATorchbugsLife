Scriptname STBScriptPortcullis extends ObjectReference 

Activator Property XMarkerActivator Auto;

bool busy = false 
bool isOpen = false

; Known states:
;   open 
;   opening
;   opened ; somewhat unreliable
;   closing
;   closed ; VERY unreliable
; (You can see these by opening portcullis' behavior00.hkx.)

; This is inspired by the SetOpen in default2StateActivator but this is cleaned up and we allow dropping opens
function MySetOpen(bool abOpen)
       while (busy); spin
             if (abOpen); fast path, drop opens if we're busy 
                  return;
             endif
		utility.wait(1)
	endWhile
      busy = true

      ;;; critical section
	if (abOpen && !isOpen); we should open
 	     playAnimationAndWait("Open", "Opening") ; there is an opened state but it seems like you can't rely on it being hit (sometimes it just isn't ???) Accomodate with extra wait below.
            utility.wait(1.0) 
            isOpen = true
	elseif (!abOpen && isOpen); we should close
           playAnimationAndWait("Close", "Closing") ; there is a closed state defined in the behaviors00.hkx but it seems to be inaccessible. Accomodate with extra wait below.
           debug.notification("Done closing!")
           utility.wait(1.0) 
           isOpen = false
	endif
       ;;; end critical section

       busy = false
endFunction


EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           debug.trace("closing door")
           debug.notification("closing door")
           MySetOpen(false)
           debug.notification("done closing!")
     else           
           debug.trace("opening door")
           debug.notification("opening door")
           MySetOpen(true)
           debug.notification("done opening!")
     endif
endEVENT