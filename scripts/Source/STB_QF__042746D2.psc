;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname STB_QF__042746D2 Extends Quest Hidden

;BEGIN ALIAS PROPERTY HaskillDynamicHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_HaskillDynamicHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY HaskillHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_HaskillHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Haskill
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Haskill Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE PetFramework_PetQuest
Quest __temp = self as Quest
PetFramework_PetQuest kmyQuest = __temp as PetFramework_PetQuest
;END AUTOCAST
;BEGIN CODE
debug.notification("Haskill enabled?")
Alias_Haskill.getReference().enable()
kmyQuest.MakePetAvailableToPlayer()
Game.GetPlayer().AddPerk(RewardPerk)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property SummonTorchySpell  Auto

Perk Property RewardPerk  Auto  
