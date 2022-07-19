;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 15
Scriptname STB_QF__041674C8 Extends Quest Hidden

;BEGIN ALIAS PROPERTY STBSecEntranceAutoLoadDoor01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_STBSecEntranceAutoLoadDoor01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY stbsecentrance01extracollision
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_stbsecentrance01extracollision Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY stbsecentrance01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_stbsecentrance01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY STBSecEntranceAutoLoadDoor01EnabledMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_STBSecEntranceAutoLoadDoor01EnabledMarker Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;
Debug.trace("STB Dungeon Quest stage 10")
Debug.notification("STB Dungeon Quest stage 10")
;Alias_STBSecEntrance01.getReference().activate(Alias_STBSecEntrance01.getReference())
Alias_STBSecEntrance01.getReference().playAnimationandWait("Open","Opened")
;Alias_STBSecEntranceAutoLoadDoor01.getReference().enable()
Alias_STBSecEntranceAutoLoadDoor01.getReference().moveTo(Alias_STBSecEntranceAutoLoadDoor01EnabledMarker.getReference())
Alias_STBSecEntrance01ExtraCollision.getReference().disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
; SetObjectiveCompleted(30)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property PetQuest  Auto  

Quest Property PetQuestJodie  Auto  
