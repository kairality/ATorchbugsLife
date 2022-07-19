;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname STB_QF__04223694 Extends Quest Hidden

;BEGIN ALIAS PROPERTY MercyHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MercyHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY MercyDynamicHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_MercyDynamicHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Mercy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Mercy Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN AUTOCAST TYPE PetFramework_PetQuest
Quest __temp = self as Quest
PetFramework_PetQuest kmyQuest = __temp as PetFramework_PetQuest
;END AUTOCAST
;BEGIN CODE
; debug.notification("Mercy enabled?")
Alias_Mercy.getReference().enable()
kmyQuest.MakePetAvailableToPlayer()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property SummonTorchySpell  Auto  
