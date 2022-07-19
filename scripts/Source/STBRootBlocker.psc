Scriptname STBRootBlocker extends ObjectReference  

Event OnActivate(ObjectReference akActionRef)
      debug.trace("tree activated " + akActionRef)
      debug.notification("tree activated " + akActionRef)
      PlayAnimation("Open")
EndEvent