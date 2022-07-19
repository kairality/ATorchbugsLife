Scriptname STBDisableOnActivate extends ObjectReference  

Activator property XMarkerActivator auto;

; Opposite action of stbenableonactivate
EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           enable()
     else           
           disable()
     endif
endEVENT
