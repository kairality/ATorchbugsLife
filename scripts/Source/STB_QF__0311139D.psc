;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname STB_QF__0311139D Extends Quest Hidden

;BEGIN ALIAS PROPERTY Jodie
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Jodie Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY JodieHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_JodieHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY JodieDynamicHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_JodieDynamicHome Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN AUTOCAST TYPE PetFramework_PetQuest
Quest __temp = self as Quest
PetFramework_PetQuest kmyQuest = __temp as PetFramework_PetQuest
;END AUTOCAST
;BEGIN CODE
; debug.notification("Jodie enabled?")
Alias_Jodie.getReference().enable()
kmyQuest.MakePetAvailableToPlayer()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property SummonTorchySpell  Auto  
