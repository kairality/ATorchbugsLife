scriptname STB_TriggerLightEffect extends ActiveMagicEffect

Spell Property LightEffectSpell auto

Int myKey = 0

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Debug.Notification("OnEffectStart of stb_triggerlighteffect")
    ; Discovery - at first I tried to do this like Chesko's Wearable Lanterns
    ; where they do:
    ;if !akTarget.HasSpell(LightEffectSpell )
    ; akTarget.AddSpell(LightEffectSpell , false)
    ;else
    ; but ^ has a race condition - for the .5 of so sec after you RemoveSpell() the lantern effect, HasSpell() continues to return TRUE while the spell is despawning!!
    ; so it's better just to always add the spell. The game is smart enough not to add duplicate copies of spells.
    akTarget.AddSpell(LightEffectSpell)

    RegisterForSingleUpdate(0.20) 
endEvent

Event OnUpdate()
    myKey = 1
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    ; Debug.Notification("OnEffectFinish of stb_triggerlighteffect")
    ; if (akTarget.HasSpell(LightEffectSpell ))
    if (myKey > 0)
        akTarget.disable()
        akTarget.enable()
    endif
    ;akTarget.RemoveSpell(LightEffectSpell)
endEvent
