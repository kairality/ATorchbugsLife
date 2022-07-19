;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname QF_STBMainQuest_0804C71C Extends Quest Hidden

;BEGIN ALIAS PROPERTY Note
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Note Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Lucille
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Lucille Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Thyr
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Thyr Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
SetObjectiveDisplayed(20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
debug.trace("Hello world")
Alias_Note.ForceRefTo(Alias_Note.GetReference())
Alias_Note.TryToEnable()
debug.trace("Hellp world 2")
Game.GetPlayer().AddItem(Alias_Note.GetReference())
debug.trace("Hellp world 3")
SetObjectiveCompleted(5)
debug.trace("Hellp world 4")
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
