;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname STB_QF_STBMercyControlQuest_04241CAA Extends Quest Hidden

;BEGIN ALIAS PROPERTY MercyDynamicHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MercyDynamicHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Mercy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Mercy Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MercyHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MercyHome Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Game.GetPlayer().AddPerk(STBMercyQuestStendarrsGazePerk)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE PetFramework_PetQuest
Quest __temp = self as Quest
PetFramework_PetQuest kmyQuest = __temp as PetFramework_PetQuest
;END AUTOCAST
;BEGIN CODE
debug.notification("Mercy enabled?")
Alias_Mercy.getReference().enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN AUTOCAST TYPE PetFramework_PetQuest
Quest __temp = self as Quest
PetFramework_PetQuest kmyQuest = __temp as PetFramework_PetQuest
;END AUTOCAST
;BEGIN CODE
kmyQuest.MakePetAvailableToPlayer()
Game.GetPlayer().RemovePerk(STBMercyQuestStendarrsGazePerk)
Game.GetPlayer().RemovePerk(STBMercyQuestStendarrsSanctionPerk)
Game.GetPlayer().AddPerk(RewardPerk)
Game.GetPlayer().AddSpell(STBTeleportMercy)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property STBAbMercyQuestStendarrsGaze Auto

Perk Property STBMercyQuestStendarrsGazePerk  Auto

Perk Property RewardPerk  Auto  

Perk Property STBMercyQuestStendarrsSanctionPerk  Auto  

SPELL Property STBTeleportMercy  Auto  
