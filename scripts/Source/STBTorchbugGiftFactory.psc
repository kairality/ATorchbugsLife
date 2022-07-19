ScriptName STBTorchbugGiftFactory extends ActiveMagicEffect

LeveledItem Property STBLvItemTorchbugForageGifts auto
Message Property STBTorchyGiftMsg auto

Int BaseItemChance = 50
Int RandomItemChance = 2
Int ForceItemChance = 100
Int TimeItemChanceVariable =  100
Float GiveItemTimeMin = 6.0
Float GiveItemTimeMax = 12.0

function OnEffectStart(Actor akTarget, Actor akCaster)
	StartRandomTimer()
	RegisterForSingleLOSLost(akTarget, Game.GetPlayer())
endFunction

function StartRandomTimer()
	Float RandomTimer = utility.RandomFloat(GiveItemTimeMin, GiveItemTimeMax)
	RegisterForSingleUpdateGameTime(RandomTimer)
endFunction

function OnUpdateGameTime()
	Int RandomRoll = utility.RandomInt(0, 100)
	if (RandomRoll <= TimeItemChanceVariable)
		STBTorchyGiftMsg.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
		game.GetPlayer().AddItem(STBLvItemTorchbugForageGifts as form, 1, false)
		TimeItemChanceVariable = BaseItemChance
	else
		TimeItemChanceVariable *= 1.5 as int
	endIf
	StartRandomTimer()
endFunction

event OnLostLOS(Actor akViewer, ObjectReference akTarget)
    RegisterForSingleLOSGain(akViewer, akTarget)
endEvent

event OnGainLOS(Actor akViewer, ObjectReference akTarget)
    if (!akViewer.IsInInterior())
		Int RandomRoll = utility.RandomInt(0, 100)
		if (RandomRoll <= RandomItemChance)
			STBTorchyGiftMsg.Show(0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000)
			Game.GetPlayer().AddItem(STBLvItemTorchbugForageGifts, 1, false)
		endIf
	endIf
    RegisterForSingleLOSLost(akViewer, akTarget)
endEvent