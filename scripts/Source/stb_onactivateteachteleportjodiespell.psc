Scriptname stb_onactivateteachteleportjodiespell extends ObjectReference  

SPELL  Property STBSPELTeleportJodie  auto

EVENT onActivate(ObjectReference triggerRef)
    Actor player = game.getPlayer()
    Debug.trace("in onActivate")
    if (triggerRef == player)       
        Debug.trace("in onActivate from player")      
        if (!player.hasSpell(STBSPELTeleportJodie))
            Debug.trace("in onActivate from missing spell")      
            player.addSpell(STBSPELTeleportJodie, true)
        endif
    endif
endEVENT
