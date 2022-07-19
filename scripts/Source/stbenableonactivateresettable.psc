Scriptname stbenableonactivateresettable extends ObjectReference  

; Slightly different than stbenableonactivate, this listens on 3 activators:
;  - an XMarkerActivator disables (resets) + blocks the activator
;  - an STBActivatorDefault enables the activator, unless it's blocked
;  - any other activations unblock the activator but don't enable it

; the "blocked" uses IsActivationBlocked so you can use defaultsetactivationblocked script if you need this activator
; to be initially blocked.

; This can be useful for implementing a "step 2" of a puzzle where if "step 1" fails "step 2" should be reset

Activator property XMarkerActivator auto;
Activator property STBActivatorDefault auto;

EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           ; block and disable
           BlockActivation(true)
           disable()
     elseif (baseObj == STBActivatorDefault);
          ; enable if we aren't blocked
	    if (!IsActivationBlocked()); 
               enable()
           endif
     else           
           BlockActivation(false)
     endif
endEVENT
