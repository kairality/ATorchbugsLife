Scriptname stbenableon2activateresettable extends ObjectReference  

; Slightly different than stbenableonactivate, this listens on 4 activators:
;  - an XMarkerActivator disables (resets) + blocks the activator
;  - any STBActivatorDefault adds 1 to a counter, if 2 distinct STBActivatorDefault (by refid) activate while we're unblocked then we activate ourselves
;  - any other activations unblock the activator but don't enable it

; the "blocked" uses IsActivationBlocked so you can use defaultsetactivationblocked script if you need this activator
; to be initially blocked.

; This can be useful for implementing a "step 2" of a puzzle where if "step 1" fails "step 2" should be reset
; and where the "step 2" should actually be composed of 2 parent activators both being enabled in one cycle (i.e. do A AND B)

Activator property XMarkerActivator auto;
Activator property STBActivatorDefault auto;

objectReference priorTriggerRef = None;

FUNCTION actuallyActivate(objectReference triggerRef)
    if (triggerRef == priorTriggerRef)
       ; We already had this one.
    elseif (priorTriggerRef == None)
       ; First activator in this cycle
       priorTriggerRef = triggerRef
       debug.notification("first trigger ref")
    else
        ; two distinct activators => requirement met
       debug.notification("two trigger ref! Yay!")
        enable()
    endif
endFUNCTION

EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           ; block and disable
           BlockActivation(true)
           disable()
           priorTriggerRef = None
     elseif (baseObj == STBActivatorDefault);
          ; if we aren't blocked count this as an activation
	    if (!IsActivationBlocked()); 
              actuallyActivate(triggerRef)
           endif
     else           
           BlockActivation(false)
     endif
endEVENT

