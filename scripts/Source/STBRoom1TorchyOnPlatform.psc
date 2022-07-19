Scriptname STBRoom1TorchyOnPlatform extends stbtrigtorchbuglight 
{Room 1 - torch is on platform (linked activator)}

ObjectReference property myTree auto;

Function doTriggerActivatedActions()
        debug.notification("custom doTriggerActivatedActions")
        debug.trace("custom doTriggerActivatedActions")
        ; animation names are case sensitive, it's lower case for this.
        myTree.playAnimation("open")
endFunction

Function doTriggerDeactivatedActions() 
        ; TODO wait until open animation finishes to ensure close happens
        debug.notification("custom doTriggerDeactivatedActions")
        debug.trace("custom doTriggerDeactivatedActions")
       ; animation names are case sensitive, it's lower case for this.
        myTree.playAnimation("close")
endFunction