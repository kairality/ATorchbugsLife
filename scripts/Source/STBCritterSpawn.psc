Scriptname STBCritterSpawn extends CritterSpawn
{ version of critter spawn that can be turned on and blocked/unblocked by 3 parent activators.
   Basically the critter spawn equivalent of stbenableonactivateresettable.
   Set iMaxCritterCount to 0 and iSTBMaxCritterCount to the number of critters you want
   when we're turned on.
}

import Critter
import Utility

bool bLooping
bool bPrintDebug = FALSE			; should usually be set to false.
int recursions

Activator property XMarkerActivator auto;
Activator property STBActivatorDefault auto;

int property iSTBMaxCritterCount = 5 auto 
{ The actual number of critters to spawn when we're enabled (iMaxCritterCount should be 0!) }

EVENT onActivate (objectReference triggerRef)
     Form baseObj = triggerRef.GetBaseObject()
     if (baseObj == XMarkerActivator);
           ; block and disable
           BlockActivation(true)
     elseif (baseObj == STBActivatorDefault);
          ; enable if we aren't blocked
	    if (!IsActivationBlocked()); 
              ; if (iMaxCritterCount == 0); 
                  ; Only force-spawn critters the first time we enable.
                  ; Because we never set this back to 0, we can't turn a spawner "off." So as long as you know this...
                  iMaxCritterCount  = iSTBMaxCritterCount 
                  SpawnInitialCritterBatch()
               ; endif
           endif
     else           
           BlockActivation(false)
     endif
endEVENT