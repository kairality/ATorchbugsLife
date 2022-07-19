Scriptname STBEnableOnActivate extends ObjectReference  

Activator property XMarkerActivator auto;

EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           disable()
     else           
           enable()
     endif
endEVENT