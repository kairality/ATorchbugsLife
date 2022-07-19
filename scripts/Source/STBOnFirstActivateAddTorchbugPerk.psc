Scriptname STBOnFirstActivateAddTorchbugPerk extends ObjectReference  

Perk  Property TorchbugPerk  auto

int RunOnce = 1

EVENT onActivate(ObjectReference triggerRef)
   if (RunOnce == 1)
   	 Actor Player = game.getPlayer()
   	 if (triggerRef == Player)    
       	 if (!Player.HasPerk(TorchbugPerk))
			Player.AddPerk(TorchbugPerk)
			RunOnce = 0
			debug.trace("Enabling crimson torchbug perks and shutting down")
		endIf
        endif
    endif
endEVENT