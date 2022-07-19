Scriptname stb_triggerfakelighteffect extends ActiveMagicEffect  

Spell Property FakeLightEffectSpell auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Debug.Notification("OnEffectStart of stb_triggerfakelighteffect")
    ; Discovery - at first I tried to do this like Chesko's Wearable Lanterns
    ; where they do:
    ;if !akTarget.HasSpell(FakeLightEffectSpell )
    ; akTarget.AddSpell(FakeLightEffectSpell , false)
    ;else
    ; but ^ has a race condition - for the .5 of so sec after you RemoveSpell() the lantern effect, HasSpell() continues to return TRUE while the spell is despawning!!
    ; so it's better just to always add the spell. The game is smart enough not to add duplicate copies of spells.
    akTarget.AddSpell(FakeLightEffectSpell)
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    ; Debug.Notification("OnEffectFinish of stb_triggerfakelighteffect")
endEvent
