scriptName Critter extends ObjectReference
{THIS SCRIPT HAS BUGFIXES BY STEVE40 and additional fixes by USKP}

; Imported for RandomFloat()
import Utility
import debug

;----------------------------------------------
; Properties to be set for this Critter
;----------------------------------------------

; Randomness added to location and orientation at a plant
float Property fPositionVarianceX = 20.0 auto
{When picking a destination reference, how much variance in he X coordinate the critter to travel to.}
float Property fPositionVarianceY = 20.0 auto
{When picking a destination reference, how much variance in he Y coordinate the critter to travel to.}
float Property fPositionVarianceZMin = 50.0 auto
{When picking a destination reference, how much variance in he Z coordinate the critter to travel to, lower bound}
float Property fPositionVarianceZMax = 100.0 auto
{When picking a destination reference, how much variance in he Z coordinate the critter to travel to, upper bound}
float Property fAngleVarianceZ = 90.0 auto
{When picking a destination reference, how much variance from the ref's Z angle the critter can end at}
float Property fAngleVarianceX = 20.0 auto
{When picking a destination reference, how much variance from the ref's X angle the critter can end at}

; Path Curviness
float Property fPathCurveMean = 100.0 auto
{When moving, how "curvy" the path can be, mean (see associated Variance)}
float Property fPathCurveVariance = 200.0 auto
{When moving, how "curvy" the path can be, variance (see associated Mean)}

; For bell-shaped paths, where along the path to place waypoints
float Property fBellShapedWaypointPercent = 0.2 auto
{When moving on a bell-shaped path, how far along the path to place the bell waypoint (so that the critter doesn't go straight up, but up and forward)}

; Animation events to be sent to the graph, and associated delays
string Property PathStartGraphEvent = "" auto
{Animation event to send when starting a path}
float Property fPathStartAnimDelay = 1.0 auto
{Duration of the path start animation (delay used before the critter actually moves)}
string Property PathEndGraphEvent = "" auto
{Animation event to send when ending a path}
float Property fPathEndAnimDelay = 1.0 auto
{Duration of the path end animation (delay used before the critter returns path complete)}

; properties relevant to collection items
ingredient property lootable auto
{ingredient gathered from this critter}
formlist property nonIngredientLootable auto
{Optional: If our loot item is not an ingredient, use this instead.}
formlist  property fakeCorpse auto
{Optional: If we want to leave a fake "Corpse" behind, point to it here.}
bool property bPushOnDeath = FALSE auto
{apply a small push on death to add english to ingredients?  Default: False}
explosion property deathPush auto
{a small explosion force to propel wings on death}
int property lootableCount = 1 auto
{How many lootables do I drop on Death? Default: 1}
bool property bIncrementsWingPluckStat = FALSE auto
{do I count towards the wings plucked misc stat?  will be false for majority}

; properties relevant to landing behavior
Static property LandingMarkerForm auto
{What landing marker to use to compute offsets from landing position}
float property fLandingSpeedRatio = 0.33 auto
{The speed percentage to use when landing, Default = 0.33 (or 33% of flight speed)}
string property ApproachNodeName = "ApproachSmall01" auto
{The name of the approach node in the landing marker, Default=ApproachSmall01}


;----------------------------------------------
; Hidden Properties for AI Sim
;----------------------------------------------
bool property reserved auto hidden
{should this object be invalidated for searches?}
objectReference property hunter auto hidden
{if being hunted, by whom?}
bool bKilled = false
; if been killed once, don't do Die() a second time

;----------------------------------------------
; Properties set by the spawner
;----------------------------------------------

; The distance from the spawner this critter can be
float Property fLeashLength auto hidden
; The distance from the player this critter can be
float Property fMaxPlayerDistance auto hidden
; The Height above the spawner that critters be move to (when applicable: dragonfly)
float Property fHeight auto hidden
; The Depth below the spawner that critters be move to (when applicable: fish)
float Property fDepth auto hidden
; The spawner that owns this critter
CritterSpawn Property Spawner auto hidden

;----------------------------------------------
; Debugging
;----------------------------------------------
bool Property bCritterDebug = false auto hidden

;----------------------------------------------
; USKP Properties
;----------------------------------------------
Actor Property PlayerRef  auto hidden
;{set by SetSpawnerProperties, cleared by DisableAndDelete}
ObjectReference property Follower = none auto hidden
;{if being followed, by whom?}
float Property fSpawnerX auto hidden
;{set by SetSpawnerProperties}
float Property fSpawnerY auto hidden
;{set by SetSpawnerProperties}
float Property fSpawnerZ auto hidden
;{set by SetSpawnerProperties}

bool property bCalculating = false auto hidden
; don't do DisableAndDelete() during calculations

bool bDeleting = false
; don't do DisableAndDelete() a second time

;----------------------------------------------
; Events
;----------------------------------------------

FUNCTION Die()
    if bKilled == false
    ;!  bKilled = true; now in disableAndDelete [USKP 2.0.1]
disableAndDelete(false)
    int i = 0
    while i < lootableCount
    i += 1
    objectReference createdLootable
    if fakeCorpse ; do we have the optional fakeCorpse parameter? 
    ; we have to jump through a hoop here to get the more open-ended functionality of using a formlist
    int total = fakeCorpse.getSize()  ; it would unusual if this was > 1, but just in case...
    int current = 0
    while current < total
createdLootable = placeAtMe(fakeCorpse.getAt(current), 1)
    current += 1
    endWhile
    else
createdLootable = placeatMe(lootable, 1)
    endif
createdLootable.moveTo(createdLootable, randomFloat(self.getWidth(), 2*self.getWidth()), randomFloat(self.getWidth(), 2*self.getWidth()), -1*(randomFloat(self.getHeight(), 2*self.getHeight())), false)
    endWhile
    if bPushOnDeath == TRUE         
placeatMe(deathPush)
    endif
    endif
    endFUNCTIOn

    EVENT onActivate(objectReference actronaut)
if (bKilled == false)
    ;!  bKilled = true; now in disableAndDelete [USKP 2.0.1]
    disableAndDelete(false) ; Nuke the critter as early as possible so the player knows something happened
    ;Player receives loot for direct activation?  Probably need a bool here for other critters in future
    if nonIngredientLootable ; do I have the optional non-ingredient lootable parameter set?
    ;!  actronaut.additem(nonIngredientLootable, lootableCount)
    ; [USKP 1.2] fix list
Int iIndex = NonIngredientLootable.GetSize()
    While iIndex > 0
    iIndex -= 1
Actronaut.AddItem(NonIngredientLootable.GetAt(iIndex), lootableCount)
    EndWhile
    ; ^^ FROM USKP
    else
actronaut.addItem(lootable, lootableCount)
    endif
    if bIncrementsWingPluckStat == TRUE
    game.IncrementStat("Wings Plucked", lootableCount)
    endif
    endIf
    endEVENT

EVENT onHit(ObjectReference akAggressor, Form akWeapon, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    ;   debug.trace(self + " got hit by " + akAggressor)
Die()
    endEVENT

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
    ;   debug.trace(self + " got hit by magic of " + akCaster)
Die()
    EndEvent

    ; This event is called once the Critter is ready to kick off its processing
Event OnStart()
    ; moved from KickOffOnStart OnUpdate [USKP 2.0.1]
Enable()
    endEvent

    ; Triggered when the critter is about to reach its destination
Event OnCritterGoalAlmostReached()
    endEvent

    ; Triggered when the critter reaches its destination
Event OnCritterGoalReached()
    endEvent

    ; Triggered if critter failed reaching the destination
Event OnCritterGoalFailed()
    ; kick the OnUpdate in hopes it will clean up. [USKP 2.0.1]
    ; less than OnCellAttach RegisterForSingleUpdate(0.70711)
    RegisterForSingleUpdate(0.15); [USKP 2.0.3]
    endEvent

    ; Indicates whether the critter has had everything  initialized
    ;bool b3DInitialized = false
    bool bDefaultPropertiesInitialized = false
    bool bSpawnerVariablesInitialized = false

    ; Prevent getting event for 3D loaded after move to
    bool bfirstOnStart = true

    ; These are used to store location/orientation
    ObjectReference landingMarker = none
    ObjectReference dummyMarker = none

    ;/ Catch default, copied from critterMoth and FireFly [USKP 2.0.1]
    /;
Event OnUpdate()
    Trace(self + "OnUpdate() in the default state, killing itself", 2)
DisableAndDelete(true)
    endEvent

    ;/ Backup for deletions that happen during calculations [USKP 2.0.3]
    /;
Event OnUpdateGameTime()
    Trace(self + "OnUpdateGameTime() killing itself", 2)
DisableAndDelete(false)
    endEvent

    ;/ Match OnCellDetach() for all critters, to clean up old critters [USKP 2.0.1]
    /;
EVENT OnCellAttach()
    Trace(self + "OnCellAttach() had failed to kill self OnCellDetach", 2)
    ; kick the OnUpdate in hopes it will clean up.
    RegisterForSingleUpdate(0.70711); [USKP 2.0.3]
if isDeleted()
    Trace(self + "OnCellAttach() isDeleted", 2)
elseIf isDisabled()
    Trace(self + "OnCellAttach() isDisabled", 2)
    else
    ; possibly trigger shorter OnUpdate time in Critter OnCritterGoalFailed()
StopTranslation()
    endIf
    endEVENT

    ;/ Safety measure - when my cell is detached, for whatever reason, kill me.
    ;   duplicate code from various critters moved here. [USKP 2.0.3]
    /;
EVENT OnCellDetach()
    Trace(self + "OnCellDetach() Killing self", 2)
    ;!  DisableAndDelete()
    ; Parentcell usually removed by the time this event triggers,
    ; so StopTranslation() doesn't work. Schedule cleanup after a
    ; longer time than any possible TranslateTo. [USKP 2.0.3]
    RegisterForSingleUpdateGameTime(0.31831); 1/pi hours
    endEVENT

    ; Called as soon as the critter is loaded
    ;Event OnLoad()
    ; ; ;   Debug.TraceConditional("Critter " + self + " OnLoad() called!", bCritterDebug)
    ;   if (bfirstOnStart)
    ;       ; We know the 3D is good
    ;       b3DInitialized = true
    ;       ; If everything else is also good, start doing stuff
    ;       CheckStateAndStart()
    ;       bfirstOnStart = false
    ;   endIf
    ;endEvent

    ; Called when properties for this object have been initialized
Event OnInit()
    ; We know default properties are good
    bDefaultPropertiesInitialized = true
    ; If everything else is also good, start doing stuff
CheckStateAndStart()
    endEvent

    ; Called by the spawner when it has set the initial variables
    float fradiusPropVal
    float fmaxPlayerDistPropVal
    float fheightPropVal
    float fdepthPropVal
    CritterSpawn spawnerPropVal
Function SetInitialSpawnerProperties(float afRadius, float afHeight, float afDepth, float afMaxPlayerDistance, CritterSpawn arSpawner)
    ; Set initial variables to be set once default properties have been set
    fradiusPropVal = afRadius
    fheightPropVal = afHeight
    fdepthPropVal = afDepth
    fmaxPlayerDistPropVal = afMaxPlayerDistance
    spawnerPropVal = arSpawner
    ; We know spawner-set variables are good now
    bSpawnerVariablesInitialized = true
    ; If everything else is also good, start doing stuff
CheckStateAndStart()
    endFunction

    ; Stores initial spawner properties temporarily until object is ready to have them overwritten
Function SetSpawnerProperties()
    fLeashLength = fradiusPropVal
    fHeight = fheightPropVal
    fDepth = fDepthPropVal
    fMaxPlayerDistance = fmaxPlayerDistPropVal
    Spawner = spawnerPropVal
    ; [USKP 2.0.1]
    fSpawnerX = Spawner.X
    fSpawnerY = Spawner.Y
    fSpawnerZ = Spawner.Z
PlayerRef = Game.GetPlayer()
    endFunction

    ; Checks that the critter is all initialized, and if so, kick off the behavior
Function CheckStateAndStart()
    ; ;     Debug.TraceConditional("Critter " + self + "bDefaultPropertiesInitialized=" + bDefaultPropertiesInitialized + ", bSpawnerVariablesInitialized=" + bSpawnerVariablesInitialized, bCritterDebug)

if (bDefaultPropertiesInitialized && bSpawnerVariablesInitialized)

    ; Set actual properties from the spawner
SetSpawnerProperties()

    ; Do the next part asynchronously, to allow the spawner to keep creating more critters
    GotoState("KickOffOnStart")
RegisterForSingleUpdate(0.0)
    endIf
    endFunction

    state KickOffOnStart
    ;!Function OnUpdate()
    Event OnUpdate()    ; BUGFIX BY STEVE40
    GotoState("")
    ; ;     Debug.TraceConditional("Critter " + self + " is creating landing markers", bCritterDebug)

    ; Create our landing and dummy markers
    landingMarker = PlaceAtMe(LandingMarkerForm)
dummyMarker = PlaceAtMe(LandingMarkerForm)
    ; delay all 3D checks until immediately before usage [USKP 2.0.1]

    ; We're all set to go, start doing stuff
    ; ;     Debug.TraceConditional("Critter " + self + " is triggering OnStart", bCritterDebug)
    Debug.Trace("Critter " + self + " is triggering OnStart")

    ; STEVE40+USKP consolidate duplicated code for most critters
    if landingMarker && dummyMarker && CheckCellAttached(self) ;/&& Game.GetPlayer().GetDistance(self) <= fMaxPlayerDistance/;
OnStart()
    else
    Debug.Trace(self + " Unable to place any markers.")
    ; Kill this critter
DisableAndDelete()
    endif

    ; possible conflicting Enable after OnStart DisableAndDelete,
    ; moved to stub OnStart [USKP 2.0.1]
    ;!  Enable()
    ;!endFunction
    endEvent    ; BUGFIX BY STEVE40
    endState

    ;/ clear Follower stub [USKP 2.0.1]
    /;
Function FollowClear()
    endFunction

    ;/ set Follower [USKP 2.0.1]
    /;
    Bool Function FollowSet(ObjectReference Following)
if Follower == None && !IsDisabled()
    Follower = Following
    return true
    endIf
    return false
    endFunction

    ;/ clear Leader and Follower and Target stub [USKP 2.0.1]
    /;
Function TargetClear()
    endFunction

    ; Called to remove the critter
    ; This should be called when a critter is too far from the player to be seen for instance
Function DisableAndDelete(bool abFadeOut = true)
    bKilled = true  ; BUGFIX BY STEVE40+USKP

    Trace("disableanddelete")

    if bCalculating && abFadeOut
    ; interlock [UKSP 2.0.3]
    TraceStack(self + " bCalculating && abFadeOut true")
    RegisterForSingleUpdateGameTime(0.367879); 1/e hours
    return
    endif

    if bDeleting
    ; interlock [UKSP 2.0.1]
    TraceStack(self + " bDeleting true")
    return
    endif
    bDeleting = true

    ; Nota Bene: The following notDisabled checks for failure to
    ; clear temporarily persistent variables, and failure to delete
    ; prior to USKP 1.3.3 [USKP 2.0.1]
bool notDisabled = !isDisabled()

    ; Disable the critter - don't wait if we aren't fading
    if abFadeOut
Disable(true)
    else
DisableNoWait()
    endIf

    ; vanilla code doesn't have this variable. Use it to detect
    ; earlier partially disabled/deleted critters, and also as the 
    ; StopNowWeReallyMeanIt flag! The advantage over isDisabled() is
    ; non-interruptible idempotent run-time testing.
    PlayerRef = None

    ; Stop Any movement
    CurrentMovementState = "Idle"

    if (GetParentCell())
StopTranslation()
    endIf

    ; give self some time to process/register updates [USKP 2.0.4]
    ; may occur during harvesting, or after StopTranslation()
    Float delay = 0.016667; 1 frame
    while bCalculating && delay < 1.1
Wait(delay)
    delay += delay
    endWhile

    ; give others plenty of time to clear leaders and followers [USKP 2.0.3]
    ; 3 times maximum above for looped chain of 3 followers.
    ; total not unreasonable for delayed display of harvest.
TargetClear()
    while Follower && delay < 3.3
Wait(delay)
    delay += delay
    endWhile
    if Follower
    Critter FollowedBy = Follower as Critter
    if FollowedBy
FollowedBy.FollowClear()
    endIf
    endIf
    Follower = none

    ; Notify spawner
    if Spawner && notDisabled
Spawner.OnCritterDied()
    endIf
    ; USKP fix persistent reference, don't repeatedly decrement
    Spawner = none

    ; Delete dummy marker
    if landingMarker && notDisabled
landingMarker.Delete()
    endIf
    ; STEVE40+USKP fix persistent reference to deleted object
    landingMarker = none

    if dummyMarker && notDisabled
dummyMarker.Delete()
    endIf
    ; STEVE40+USKP fix persistent reference to deleted object
    dummyMarker = none

    ; StopTranslation must be called before UnregisterForUpdate,
    ; because OnCritterGoalFailed() can now RegisterForSingleUpdate()
    ; Unregister for any kind of update
    UnregisterForUpdate()
UnregisterForUpdateGameTime()

    ; And delete ourselves
    Debug.Trace("Critter " + self + " will kill itself.")
    ; Delete must be called, is not dependent on parent cell [USKP 1.3.3]
    ;!  if getParentCell()
Delete()
    ;!  endif
    endFunction 

    ; Variable used to store the desired state after translation
    string CurrentTargetState = ""

    ; Target Node name
    string CurrentTargetNode = ""

    ; Internal state used when moving
    string CurrentMovementState = "Idle"

    ;/  PlaceLandingMarker
    ;   Returns true when DisableAndDelete [USKP 2.0.1]
    /;
Bool Function PlaceLandingMarker(ObjectReference arTarget, string asTargetNode)
    ; ;     Debug.TraceConditional("Critter " + self + " placing landing marker " + landingMarker, bCritterDebug)
    if !(PlayerRef && CheckFor3D( landingMarker ) && CheckFor3D( arTarget ))
DisableAndDelete(false)
    return true
    endIf

    if (asTargetNode != "")
landingMarker.MoveToNode(arTarget, asTargetNode)
    else
    ; Use random offset from ref pivot point
    landingMarker.SetPosition(arTarget.X + RandomFloat(-fPositionVarianceX, fPositionVarianceX), arTarget.Y + RandomFloat(-fPositionVarianceY, fPositionVarianceY), arTarget.Z + RandomFloat(fPositionVarianceZMin, fPositionVarianceZMax))
landingMarker.SetAngle(arTarget.GetAngleX() + RandomFloat(-fAngleVarianceX, fAngleVarianceX), arTarget.GetAngleY(), arTarget.GetAngleZ() + RandomFloat(-fAngleVarianceZ, fAngleVarianceZ))
    endIf

    ; MoveTo might have temporarily disabled 3D
    ; delay all 3D checks until immediately before usage [USKP 2.0.1]
    return false
    endFunction

    ;/  PlaceDummyMarker
    ;   Returns true when DisableAndDelete [USKP 2.0.1]
    /;
Bool Function PlaceDummyMarker(ObjectReference arTarget, string asTargetNode)
    ; ;     Debug.TraceConditional("Critter " + self + " placing Dummy marker " + dummyMarker, bCritterDebug)
    if !(PlayerRef && CheckFor3D( dummyMarker ) && CheckFor3D( arTarget ))
DisableAndDelete(false)
    return true
    endIf

dummyMarker.MoveToNode(arTarget, asTargetNode)

    ; MoveTo might have temporarily disabled 3D
    ; delay all 3D checks until immediately before usage [USKP 2.0.1]
    return false
    endFunction

    ; Variables used during spline paths
    float fStraightLineTargetX
    float fStraightLineTargetY
    float fStraightLineTargetZ
    float fStraightLineTargetAngleX
    float fStraightLineTargetAngleY
    float fStraightLineTargetAngleZ
    float fStraightLineSpeed
    float fStraightLineMaxRotationSpeed

    ; Travel to the given reference at a given speed
    ; This function will call the OnCritterGoalReached() event upon completion
    Function SplineTranslateToRefAtSpeed(ObjectReference arTarget, float afSpeed, float afMaxRotationSpeed)
if CheckViability()
    return
    endIf

    ; Make sure we're keyframed so we can be moved around
SetMotionType(Motion_Keyframed, false)

    ; If applicable, play animation
DoPathStartStuff()

    ; We're about to kick off a standard spline stranslation, so switch to that state
    ; ;     Debug.TraceConditional("Critter " + self + " going to state SplineTranslation", bCritterDebug)
    CurrentMovementState = "SplineTranslation"

    ; Compute target location
    float ftargetX
    float ftargetY
    float ftargetZ

    ; Use a dummy marker to get the node location
if PlaceLandingMarker(arTarget, CurrentTargetNode)
    ; extra safeguard here - STEVE40
    return
    endif

    ; Place a dummy marker to store the position / orientation
if PlaceDummyMarker(landingMarker, ApproachNodeName)
    ; extra safeguard here - STEVE40
    return
    endif

    if !(PlayerRef && CheckFor3D( dummyMarker ))
DisableAndDelete(false)
    return
    endIf

    ; Use the X,Y and Z of the dummy marker
    fStraightLineTargetX = dummyMarker.X
    fStraightLineTargetY = dummyMarker.Y
    fStraightLineTargetZ = dummyMarker.Z
    fStraightLineTargetAngleX = dummyMarker.GetAngleX()
    fStraightLineTargetAngleY = dummyMarker.GetAngleY()
fStraightLineTargetAngleZ = dummyMarker.GetAngleZ()

    float fdeltaX = fStraightLineTargetX - X
    float fdeltaY = fStraightLineTargetY - Y
    float fdeltaZ = fStraightLineTargetZ - Z
    ftargetX = X + fdeltaX * 0.9
    ftargetY = Y + fdeltaY * 0.9
    ftargetZ = Z + fdeltaZ * 0.9

    ; Clear target node for next time
    CurrentTargetNode = ""

    fStraightLineSpeed = afSpeed
    fStraightLineMaxRotationSpeed = afMaxRotationSpeed

    ; Kick off the the translation
if CheckViability()
    return
    endIf
SplineTranslateTo(ftargetX, ftargetY, ftargetZ, fStraightLineTargetAngleX, fStraightLineTargetAngleY, fStraightLineTargetAngleZ, RandomFloat(fPathCurveMean - fPathCurveVariance, fPathCurveMean + fPathCurveVariance), afSpeed, afMaxRotationSpeed)
    bCalculating = False; [USKP 2.0.4]
    endFunction

    ; Travel to the given reference's named node
    ; This function will call the OnCritterGoalReached() event upon completion
Function SplineTranslateToRefNodeAtSpeed(ObjectReference arTarget, string arNode, float afSpeed, float afMaxRotationSpeed)
    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
SplineTranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function SplineTranslateToRefAtSpeedAndGotoState(ObjectReference arTarget, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Call base version
SplineTranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference's named node and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function SplineTranslateToRefNodeAtSpeedAndGotoState(ObjectReference arTarget, string arNode, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
SplineTranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction


    ; Travel to the given reference at a given speed
    ; This function will call the OnCritterGoalReached() event upon completion
    Function TranslateToRefAtSpeed(ObjectReference arTarget, float afSpeed, float afMaxRotationSpeed)
if CheckViability()
    return
    endIf

    ; Make sure we're keyframed so we can be moved around
SetMotionType(Motion_Keyframed, false)

    ; If applicable, play animation
DoPathStartStuff()

    ; We're about to kick off a standard spline stranslation, so switch to that state
    ; ;     Debug.TraceConditional("Critter " + self + " going to state SplineTranslation", bCritterDebug)
    CurrentMovementState = "Translation"

    ; Compute target location
    float ftargetX
    float ftargetY
    float ftargetZ

    ; Use a dummy marker to get the node location
if PlaceLandingMarker(arTarget, CurrentTargetNode)
    ; extra safeguard here - STEVE40
    return
    endif

    ; Place a dummy marker to store the position / orientation
if PlaceDummyMarker(landingMarker, ApproachNodeName)
    ; extra safeguard here - STEVE40
    return
    endif

    if !(PlayerRef && CheckFor3D( dummyMarker ))
DisableAndDelete(false)
    return
    endIf

    ; Use the X,Y and Z of the dummy marker
    fStraightLineTargetX = dummyMarker.X
    fStraightLineTargetY = dummyMarker.Y
    fStraightLineTargetZ = dummyMarker.Z
    fStraightLineTargetAngleX = dummyMarker.GetAngleX()
    fStraightLineTargetAngleY = dummyMarker.GetAngleY()
fStraightLineTargetAngleZ = dummyMarker.GetAngleZ()

    float fdeltaX = fStraightLineTargetX - X
    float fdeltaY = fStraightLineTargetY - Y
    float fdeltaZ = fStraightLineTargetZ - Z
    ftargetX = X + fdeltaX * 0.9
    ftargetY = Y + fdeltaY * 0.9
    ftargetZ = Z + fdeltaZ * 0.9

    ; Clear target node for next time
    CurrentTargetNode = ""

    fStraightLineSpeed = afSpeed

    ; Kick off the the translation
if CheckViability()
    return
    endIf
TranslateTo(ftargetX, ftargetY, ftargetZ, fStraightLineTargetAngleX, fStraightLineTargetAngleY, fStraightLineTargetAngleZ, afSpeed, afMaxRotationSpeed)
    bCalculating = False; [USKP 2.0.4]
    endFunction

    ; Travel to the given reference's named node
    ; This function will call the OnCritterGoalReached() event upon completion
Function TranslateToRefNodeAtSpeed(ObjectReference arTarget, string arNode, float afSpeed, float afMaxRotationSpeed)
    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
TranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function TranslateToRefAtSpeedAndGotoState(ObjectReference arTarget, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Call base version
TranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference's named node and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function TranslateToRefNodeAtSpeedAndGotoState(ObjectReference arTarget, string arNode, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
TranslateToRefAtSpeed(arTarget, afSpeed, afMaxRotationSpeed)
    endFunction


    ; Variables used during bell-shaped paths
    ObjectReference BellShapeTarget = none
    float fBellShapeSpeed
    float fBellShapeMaxRotationSpeed
    float fBellShapeStartX
    float fBellShapeStartY
    float fBellShapeStartZ
    float fBellShapeStartLandingPointX
    float fBellShapeStartLandingPointY
    float fBellShapeStartLandingPointZ
    float fBellShapeTargetPointX
    float fBellShapeTargetPointY
    float fBellShapeTargetPointZ
    float fBellShapeTargetAngleX
    float fBellShapeTargetAngleY
    float fBellShapeTargetAngleZ
    float fBellShapeDeltaX
    float fBellShapeDeltaY
    float fBellShapeDeltaZ
    float fBellShapeHeight

    ; Travel to the given reference in a bell-shaped path
    ; This function will call the OnCritterGoalReached() event upon completion
    Function BellShapeTranslateToRefAtSpeed(ObjectReference arTarget, float afBellHeight, float afSpeed, float afMaxRotationSpeed)
if CheckViability()
    return
    endIf

    ; Make sure we're keyframed so we can be moved around
SetMotionType(Motion_Keyframed, false)

    ; If applicable, play animation
DoPathStartStuff()

    ; We're about to kick off a bell-shaped stranslation, so switch to the first state
    ; ;     Debug.TraceConditional("Critter " + self + " going to state BellShapeGoingUp", bCritterDebug)
    CurrentMovementState = "BellShapeGoingUp"

    fBellShapeStartX = self.X
    fBellShapeStartY = self.Y
    fBellShapeStartZ = self.Z

    ; Use a dummy marker to get the node location
if PlaceLandingMarker(arTarget, CurrentTargetNode)
    ; extra safeguard here - STEVE40
    return
    endif

    ; Place a dummy marker to store the position / orientation
if PlaceDummyMarker(landingMarker, ApproachNodeName)
    ; extra safeguard here - STEVE40
    return
    endif

    if !(PlayerRef && CheckFor3D( dummyMarker ))
DisableAndDelete(false)
    return
    endIf

    ; Use the X,Y and Z of the dummy marker
    fBellShapeStartLandingPointX = dummyMarker.X
    fBellShapeStartLandingPointY = dummyMarker.Y
    fBellShapeStartLandingPointZ = dummyMarker.Z
    fBellShapeTargetPointX = landingMarker.X
    fBellShapeTargetPointY = landingMarker.Y
    fBellShapeTargetPointZ = landingMarker.Z
    fBellShapeTargetAngleX = landingMarker.GetAngleX()
    fBellShapeTargetAngleY = landingMarker.GetAngleY()
fBellShapeTargetAngleZ = landingMarker.GetAngleZ()

    ; Clear target node for next time
    CurrentTargetNode = ""

    ; Compute location for the "UP" portion of the path
    fBellShapeDeltaX = fBellShapeTargetPointX - fBellShapeStartX
    fBellShapeDeltaY = fBellShapeTargetPointY - fBellShapeStartY
    fBellShapeDeltaZ = fBellShapeTargetPointZ - fBellShapeStartZ

    ; Remember the bell height and the target
    fBellShapeHeight = afBellHeight
    BellShapeTarget = arTarget
    fBellShapeSpeed = afSpeed
    fBellShapeMaxRotationSpeed = afMaxRotationSpeed

    ; Compute point 1/5th of the way along (1/5 is an example, the percentage is defined by a property)
    float fFirstWaypointX = fBellShapeStartX + fBellShapeDeltaX * fBellShapedWaypointPercent
    float fFirstWaypointY = fBellShapeStartY + fBellShapeDeltaY * fBellShapedWaypointPercent    
    float fFirstWaypointZ = fBellShapeStartZ + fBellShapeDeltaZ * fBellShapedWaypointPercent    + fBellShapeHeight

    ; Kick off the the translation
if CheckViability()
    return
    endIf
SplineTranslateTo(fFirstWaypointX, fFirstWaypointY, fFirstWaypointZ, GetAngleX(), GetAngleY(), GetAngleZ(), fPathCurveMean, fBellShapeSpeed, afMaxRotationSpeed)
    bCalculating = False; [USKP 2.0.4]
    endFunction

    ; Travel to the given reference's named node in a bell-shaped path
    ; This function will call the OnCritterGoalReached() event upon completion
Function BellShapeTranslateToRefNodeAtSpeed(ObjectReference arTarget, string arNode, float afBellHeight, float afSpeed, float afMaxRotationSpeed)
    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
BellShapeTranslateToRefAtSpeed(arTarget, afBellHeight, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference in a bell-shaped path and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function BellShapeTranslateToRefAtSpeedAndGotoState(ObjectReference arTarget, float afBellHeight, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Call base version
BellShapeTranslateToRefAtSpeed(arTarget, afBellHeight, afSpeed, afMaxRotationSpeed)
    endFunction

    ; Travel to the given reference's named node in a bell-shaped path and then switch to the given state
    ; This function will call the OnCritterGoalReached() event upon completion
Function BellShapeTranslateToRefNodeAtSpeedAndGotoState(ObjectReference arTarget, string arNode, float afBellHeight, float afSpeed, float afMaxRotationSpeed, string arTargetState)
    ; Set target state for the OnTranslationComplete event
    CurrentTargetState = arTargetState

    ; Set target node name
    CurrentTargetNode = arNode

    ; Call base version
BellShapeTranslateToRefAtSpeed(arTarget, afBellHeight, afSpeed, afMaxRotationSpeed)
    endFunction

Function WarpToRefAndGotoState(ObjectReference arTarget, string asState)
    if PlaceLandingMarker(arTarget, "")
    ; extra safeguard here - STEVE40
    return
    endif
    MoveTo(landingMarker);

    ; Switch state
    ; ;     Debug.TraceConditional("Critter " + self + " Warping to ref (and switching to " + CurrentTargetState + " )", bCritterDebug)
GotoState(asState)
    ;!  CurrentMovementState == "Idle"
    CurrentMovementState = "Idle"   ; BUGFIX BY STEVE40
    endFunction

    Function WarpToRefNodeAndGotoState(ObjectReference arTarget, string asNode, string asState)
if PlaceLandingMarker(arTarget, asNode)
    ; extra safeguard here - STEVE40
    return
    endif
    MoveTo(landingMarker);

    ; Switch state
    ; ;     Debug.TraceConditional("Critter " + self + " Warping to ref (and switching to " + CurrentTargetState + " )", bCritterDebug)
GotoState(asState)
    ;!  CurrentMovementState == "Idle"
    CurrentMovementState = "Idle"   ; BUGFIX BY STEVE40
    endFunction

    ;----------------------------------------------
    ; Internal bell-shaped path management
    ;----------------------------------------------

    ; Handle translation complete event
Event OnTranslationComplete()
    ; prevent DisableAndDelete during calculations [USKP 2.0.3]
    bCalculating = True

    if (CurrentMovementState == "BellShapeGoingUp")
    ; Switch state to the next segment
    ; ;         Debug.TraceConditional("Critter " + self + " going to state BellShapeGoingAcross", bCritterDebug)
    CurrentMovementState = "BellShapeGoingAcross"

    ; Move to the 2nd waypoint
    float fsecondWaypointPercent = 1.0 - fBellShapedWaypointPercent
    float fSecondWaypointX = fBellShapeStartX + fBellShapeDeltaX * fsecondWaypointPercent
    float fSecondWaypointY = fBellShapeStartY + fBellShapeDeltaY * fsecondWaypointPercent
    float fSecondWaypointZ = fBellShapeStartZ + fBellShapeDeltaZ * fsecondWaypointPercent + fBellShapeHeight

    ; Kick off the the translation
if CheckViability()
    return
    endIf
SplineTranslateTo(fSecondWaypointX, fSecondWaypointY, fSecondWaypointZ, GetAngleX(), GetAngleY(), GetAngleZ(), fPathCurveMean, fBellShapeSpeed, fBellShapeMaxRotationSpeed)
    elseif (CurrentMovementState == "BellShapeGoingAcross")
    ; Switch state to the last segment
    ; ;         Debug.TraceConditional("Critter " + self + " going to state BellShapeGoingDown", bCritterDebug)
    CurrentMovementState = "BellShapeGoingDown"

    ; Move to the goal
if CheckViability()
    return
    endIf
SplineTranslateTo(fBellShapeStartLandingPointX, fBellShapeStartLandingPointY, fBellShapeStartLandingPointZ, fBellShapeTargetAngleX, fBellShapeTargetAngleY, fBellShapeTargetAngleZ, fPathCurveMean, fBellShapeSpeed, fBellShapeMaxRotationSpeed)
    elseif (CurrentMovementState == "BellShapeGoingDown")

    ; Wait for the end event
    ; ;         Debug.TraceConditional("Critter " + self + " going to state BellShapeLanding", bCritterDebug)

    ; Play landing animation if applicable
DoPathEndStuff()

    CurrentMovementState = "BellShapeLanding"

    ; Move to the destination
if CheckViability()
    return
    endIf
TranslateTo(fBellShapeTargetPointX, fBellShapeTargetPointY, fBellShapeTargetPointZ, fBellShapeTargetAngleX, fBellShapeTargetAngleY, fBellShapeTargetAngleZ, fBellShapeSpeed * fLandingSpeedRatio, fBellShapeMaxRotationSpeed)
    elseif (CurrentMovementState == "BellShapeLanding")

    ; Switch state
    ; ;         Debug.TraceConditional("Critter " + self + " going to state Idle (and switching to " + CurrentTargetState + " )", bCritterDebug)
    if (CurrentTargetState != "")
    ; ;             Debug.TraceConditional("Critter " + self + " going to state " + CurrentTargetState, bCritterDebug)
GotoState(CurrentTargetState)
    endIf
    ;!      CurrentMovementState == "Idle"
    CurrentMovementState = "Idle"   ; BUGFIX BY STEVE40

    ; Clear all global variables that we shouldn't use anymore, just for safety's sake
    BellShapeTarget = none
    CurrentTargetState = ""

    ; Trigger event for derived script to handle
OnCritterGoalReached()
    elseif (CurrentMovementState == "SplineTranslation")
    ; Play landing animation if applicable
DoPathEndStuff()

    CurrentMovementState = "StraightLineLanding"

    ; Move to the destination
if CheckViability()
    return
    endIf
SplineTranslateTo(fStraightLineTargetX, fStraightLineTargetY, fStraightLineTargetZ, fStraightLineTargetAngleX, fStraightLineTargetAngleY, fStraightLineTargetAngleZ, RandomFloat(fPathCurveMean - fPathCurveVariance, fPathCurveMean + fPathCurveVariance), fStraightLineSpeed * fLandingSpeedRatio, fStraightLineMaxRotationSpeed)
    elseif (CurrentMovementState == "StraightLineLanding")
    ; Switch state
    if (CurrentTargetState != "")
    ; ;             Debug.TraceConditional("Critter " + self + " going to state " + CurrentTargetState, bCritterDebug)
GotoState(CurrentTargetState)
    endIf
    ;!      CurrentMovementState == "Idle"
    CurrentMovementState = "Idle"   ; BUGFIX BY STEVE40
    CurrentTargetState = ""

    ; Trigger event for derived script to handle
OnCritterGoalReached()
    elseif (CurrentMovementState == "Translation")
    ; Play landing animation if applicable
DoPathEndStuff()

    ; Switch state
    if (CurrentTargetState != "")
    ; ;             Debug.TraceConditional("Critter " + self + " going to state " + CurrentTargetState, bCritterDebug)
GotoState(CurrentTargetState)
    endIf
    ;!      CurrentMovementState == "Idle"
    CurrentMovementState = "Idle"   ; BUGFIX BY STEVE40
    CurrentTargetState = ""

    ; Trigger event for derived script to handle
OnCritterGoalReached()
    else
    ; Don't know this state, just trigger event for derived script to handle
OnCritterGoalReached()
    endif
    bCalculating = False; [USKP 2.0.4]
    endEvent


Event OnTranslationAlmostComplete()
    if ((CurrentMovementState != "BellShapeGoingUp") && (CurrentMovementState != "BellShapeGoingAcross") && (CurrentMovementState != "BellShapeGoingDown") && (CurrentMovementState != "SplineTranslation"))
    ; Trigger custom event
OnCritterGoalAlmostReached()
    endif
    endEvent


    ; Regardless of state, handle the translation failed event
Event OnTranslationFailed()
    ; Trigger event
    ;   Debug.Trace("Critter " + self + " Translation Failed", 1)
OnCritterGoalFailed()
    endEvent

    ; Debugging
Function PrintInitialProperties()
    ;   Debug.Trace("Critter " + self + " initial properties")
    ;   Debug.Trace("\tfRadius = " + fLeashLength)
    ;   Debug.Trace("\tfMaxPlayerDistance = " + fMaxPlayerDistance)
    ;   Debug.Trace("\tSpawner = " + Spawner)
    endFunction


Function DoPathStartStuff()
    ; Transition to the flight state
    ;!  SetAnimationVariableFloat("fTakeOff", 1.0); moved to Moth [USKP 2.0.1]
    endFunction

Function DoPathEndStuff()
    ; Transition to the hover/landed state
    ;!  SetAnimationVariableFloat("fTakeOff", 0.0); moved to Moth [USKP 2.0.1]
    endFunction

    ;----------------------------------------
    ; Fly to a random point within the leash radius
    ;----------------------------------------------
FUNCTION flyAroundSpawner(float fminTravel, float fMaxTravel, float fSpeed, float afMaxRotationSpeed, bool bflyBelowSpawner = false)
{this function chooses and flies to a new, nearby point}
    ; if flybelowSpawner is 
if CheckViability()
    return
    endIf
    float fMinHeight = fSpawnerZ
float fMaxheight = fMinHeight + (0.5*fLeashLength)
    float oldX = self.x
    float oldY = self.y
    float oldZ = self.z
    float newX = (self.x + randomFloat(fminTravel, fMaxTravel))
    float newY = (self.Y + randomFloat(fminTravel, fMaxTravel))
    float newZ = (self.Z + randomFloat(fminTravel, fMaxTravel))
doPathStartStuff()
    ; some safety checks to keep him from flying far from home
    if newX > fSpawnerX
    if newX > fSpawnerX + fLeashLength
    newX = fSpawnerX + fLeashLength
    endif
    else
    if newX < fSpawnerX - fLeashLength
    newX = fSpawnerX - fLeashLength
    endif
    endif

    if newY > fSpawnerY
    if newY > fSpawnerY + fLeashLength
    newY = fSpawnerY + fLeashLength
    endif
    else
    if newY < fSpawnerY - fLeashLength
    newY = fSpawnerY - fLeashLength
    endif 
    endif

    if bFlyBelowSpawner == true
    if newZ < fMinHeight
    newZ = fMinHeight
    endif   
    if newZ > fMaxHeight
    newZ = fMaxHeight
    endif
    endif
    ; now fly to that spot!
if CheckViability()
    return
    endIf
    ;gotoMarker.setPosition(newX, newY, newZ)
TranslateTo(newX, newY, newZ, self.getAngleX(), self.getAngleY(), self.getAngleZ(), fSpeed, afMaxRotationSpeed)
    ;   traceConditional(self + " flying to point at: " + newX as int + ", " + newY as int + ", " + newZ as int, bCritterDebug) 
    bCalculating = False; [USKP 2.0.4]
    endFunction

    ;/-----------------------------------------
    Checks for this reference still in attached cell.

    Returns false when GetParentCell is "None" or when not attached.
    /;
Bool Function CheckCellAttached(ObjectReference AnyItemRef)

Cell parentCell = AnyItemRef.GetParentCell()

    If parentCell == None
    Trace(Self + "CheckCellAttached() " + AnyItemRef + " GetParentCell == None")
    return False
    EndIf

Return parentCell.IsAttached()

    EndFunction

    ;/-----------------------------------------
    Waits for a reference's 3D to load, with exponential backoff.

    Returns false when not loaded or when the reference is "None".
    /;
Bool Function CheckFor3D(ObjectReference AnyItemRef)

    Float delay = 0.016667; one frame

While AnyItemRef && !AnyItemRef.Is3DLoaded()
    if delay < 8.5; 9 times
Wait(delay)
    delay += delay
    else
    TraceStack(Self + "CheckFor3D() " + AnyItemRef + " 3D failed, delay = " + ((delay - 0.016667) as float))
    Return False
    endif
    EndWhile

    If AnyItemRef
    Trace(Self + "CheckFor3D() " + AnyItemRef + " 3D loaded, delay = " + ((delay - 0.016667) as float))
    Return True
    EndIf

    Trace(Self + "CheckFor3D() " + AnyItemRef + " == None, delay = " + ((delay - 0.016667) as float))
    Return False

    EndFunction

    ;/-----------------------------------------
    Checks for this reference still viable.
    End bCalculating.

    Returns true when DisableAndDelete [USKP 2.0.4]

    Credit STEVE40 for initial code.
    /;
Bool Function CheckViability()

If PlayerRef && !bKilled && CheckCellAttached(self) && CheckFor3D(self)
    return False
    EndIf

    ; allow DisableAndDelete [USKP 2.0.3]
    bCalculating = False

    Trace(Self + "CheckViability() DisableAndDelete.")
DisableAndDelete(PlayerRef && !bKilled)
    Return True

    EndFunction

    ;/-----------------------------------------
    Checks for this reference both viable and within distance.
    Begin/Enforce bCalculating.

    Returns false when DisableAndDelete or already calculating.
    /;
Bool Function CheckViableDistance()

    ; prevent DisableAndDelete during calculations [USKP 2.0.3]
    Bool wasCalculating = bCalculating
    bCalculating = True

    ; repeat PlayerRef test as OnCellAttach can occur during rapid cell boundary crossings
    If PlayerRef && !bKilled && CheckCellAttached(self) && CheckFor3D(self) && PlayerRef && PlayerRef.GetDistance(self) <= fMaxPlayerDistance
    ; prevent repeat calculations [USKP 2.0.4]
    If wasCalculating
    return False
    EndIf

UnregisterForUpdateGameTime()
    return True
    EndIf

    ; allow DisableAndDelete [USKP 2.0.3]
    bCalculating = wasCalculating

    Trace(Self + "CheckViable() DisableAndDelete.")
DisableAndDelete(PlayerRef && !bKilled)
    Return False

    EndFunction
