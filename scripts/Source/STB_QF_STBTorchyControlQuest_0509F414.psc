;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname STB_QF_STBTorchyControlQuest_0509F414 Extends Quest Hidden

;BEGIN ALIAS PROPERTY TorchyDynamicHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TorchyDynamicHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY TorchyHome
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TorchyHome Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Torchy
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Torchy Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE petframework_petquest
Quest __temp = self as Quest
petframework_petquest kmyQuest = __temp as petframework_petquest
;END AUTOCAST
;BEGIN CODE
; debug.notification("Torchy Enabled?")
Alias_Torchy.getReference().enable()
kmyQuest.MakePetAvailableToPlayer()
kmyQuest.FollowPlayer()
Game.GetPlayer().AddSpell(SummonTorchySpell, true)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SPELL Property SummonTorchySpell  Auto  
