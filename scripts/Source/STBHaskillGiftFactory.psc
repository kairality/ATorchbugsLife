Scriptname STBHaskillGiftFactory extends STBTorchbugGiftFactory

Message Property STBSaintsAndSeducersSupportAddedMessage auto
Message Property STBRareCuriosSupportAddedMessage auto
GlobalVariable Property STBTorchbugSASSupportMode auto
GlobalVariable Property STBTorchbugRCSupportMode auto

string SaintsAndSeducersESM = "ccbgssse025-advdsgs.esm"
string AmberFormID = "0xBC6"
string MadnessFormID = "0xBC9"
string RareCuriosESL = "ccbgssse037-curios.esl"

function OnEffectStart(Actor akTarget, Actor akCaster)
	StartRandomTimer()
	RegisterForSingleLOSLost(akTarget, Game.GetPlayer())
       Bool DontAddSaints = STBTorchbugSASSupportMode.GetValue()
	Bool DontAddCurios = STBTorchbugRCSupportMode.GetValue()
       if (!DontAddSaints)
		debug.notification("Trying")
		Form Amber = Game.GetFormFromFile(0xBC6, SaintsAndSeducersESM)
		debug.notification(Amber)
       	Form Madness = Game.GetFormFromFile(0xBC9, SaintsAndSeducersESM)
		debug.notification(Madness)
		if (Amber && Madness)
			STBLvItemTorchbugForageGifts.AddForm(Amber,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Madness,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Amber,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Madness,1,1)
			STBTorchbugSASSupportMode.SetValue(1)
			STBSaintsAndSeducersSupportAddedMessage.Show()
		endIf
	endIf
       if (!DontAddCurios)
		debug.notification("Trying")
		Form Alocasia = Game.GetFormFromFile(0xD62, RareCuriosESL)
		Form Aster = Game.GetFormFromFile(0xD66, RareCuriosESL)
		Form Fungus = Game.GetFormFromFile(0x82B, RareCuriosESL)
		Form Withering = Game.GetFormFromFile(0x824, RareCuriosESL)
		Form WEye = Game.GetFormFromFile(0x821, RareCuriosESL)
		Form BWEye = Game.GetFormFromFile(0x822, RareCuriosESL)
		Form Blister = Game.GetFormFromFile(0xD6A, RareCuriosESL)
		if (Alocasia)
			STBLvItemTorchbugForageGifts.AddForm(Alocasia,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Aster,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Fungus,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Withering,1,1)
			STBLvItemTorchbugForageGifts.AddForm(WEye,1,1)
			STBLvItemTorchbugForageGifts.AddForm(BWEye,1,1)
			STBLvItemTorchbugForageGifts.AddForm(Blister,1,1)
			STBTorchbugRCSupportMode.SetValue(1)
			STBRareCuriosSupportAddedMessage.Show()
		endIf
	endIf
endFunction