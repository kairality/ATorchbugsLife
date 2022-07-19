;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname STB_TIF__042653C8 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Game.GetPlayer().RemoveItem(Gold, 100)
akspeaker.additem(gold, 100)
Game.GetPlayer().RemovePerk(STBMercyQuestStendarrsGazePerk)
Game.GetPlayer().AddPerk(STBMercyQuestStendarrsSanctionPerk)
If akspeaker.GetRelationshipRank(Game.GetPlayer()) == 0
  akspeaker.SetRelationshipRank(Game.GetPlayer(), 1)
Endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Perk Property STBMercyQuestStendarrsGazePerk  Auto  

Perk Property STBMercyQuestStendarrsSanctionPerk  Auto  

MiscObject Property Gold  Auto  
