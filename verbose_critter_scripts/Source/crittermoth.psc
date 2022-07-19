scriptName CritterMoth extends Critter
{Main Behavior script for moths and butterflies}

import Utility
import form
import debug

; Properties (set through the editor)
FormList property PlantTypes auto
{ The list of plant types this moth can be attracted to}

; Constants
float Property fTimeAtPlantMin = 5.0 auto
{The Minimum time a Moth stays at a plant}
float Property fTimeAtPlantMax = 10.0 auto
{The Maximum time a Moth stays at a plant}
float Property fActorDetectionDistance = 300.0 auto
{The Distance at which an actor will trigger a flee behavior}
float Property fTranslationSpeedMean = 150.0 auto
{The movement speed when going from plant to plant, mean value}
float Property fTranslationSpeedVariance = 50.0 auto
{The movement speed when going from plant to plant, variance}
float Property fFleeTranslationSpeed = 300.0 auto
{The movement speed when fleeing from the player}
float Property fBellShapePathHeight = 150.0 auto
{The height of the bell shaped path}
float Property fFlockPlayerXYDist = 100.0 auto
{When flocking the player, the XY random value to add to its location}
float Property fFlockPlayerZDistMin = 50.0 auto
{When flocking the player, the min Z value to add to its location}
float Property fFlockPlayerZDistMax = 200.0 auto
{When flocking the player, the max Z value to add to its location}
float Property fFlockTranslationSpeed = 300.0 auto
{When flocking the player, the speed at which to move}
float Property fMinScale = 0.5 auto
{Minimum initial scale of the Moth}
float Property fMaxScale = 1.2 auto
{Maximum initial scale of the Moth}
float property fMinTravel = 64.0 auto
{Minimum distance a wandering moth/butterfly will travel}
float property fMaxTravel = 512.0 auto 
{Maximum distance a wandering moth/butterfly will travel}
string property LandingMarkerPrefix = "LandingSmall0" auto
{Prefix of landing markers on plants, default="LandingSmall0"}
float property fMaxRotationSpeed = 90.0 auto
{Max rotation speed while mocing, default = 90 deg/s}

; Variables
int iPlantTypeCount = 0
Actor closestActor = none

; Constants
float fWaitingToDieTimer = 10.0


    ; Called by the spawner to kick off the processing on this Moth
Event OnStart()
    ; Pick a plant type that we're attracted to
iPlantTypeCount = PlantTypes.GetSize()

    ; Vary size a bit
SetScale(RandomFloat(fMinScale, fMaxScale))

    ; Switch state and trigger a callback immediately
    ; ;     Debug.TraceConditional("Moth " + self + " warping to state AtPlant", bCritterDebug)

    ; test moved to Critter [indent retained] [USKP 2.0.1]
WarpToNewPlant()
    ; ;         Debug.TraceConditional("Moth " + self + " registering for update", bCritterDebug)

    ; Enable the critter
Enable()

if CheckFor3D(self)
    ; Switch to keyframe state
SetMotionType(Motion_Keyframed, false)

    ; Get ready to start moving
RegisterForSingleUpdate(0.0)
    else
    debug.trace("disableanddelete from crittermoth")
DisableAndDelete(false)
    endIf
    endEvent

    ; The Current plant object
    ObjectReference currentPlant = none

    ;/ clear TargetObject [USKP 2.0.1]
    /;
Function TargetClear()
    currentPlant = none
    endFunction

    ; Moth is at the plant
    State AtPlant

Event OnUpdate()
    ; Is the player too far?
if CheckViableDistance()
    ;/// [USKP 2.0.1]
    ; Kill this critter
    debug.trace("crittermoth disable here too")
    DisableAndDelete()
elseif (spawner.iCurrentCritterCount > spawner.iMaxCritterCount) || (spawner.iCurrentCritterCount < 0)
    ; something's up with the spawner.  Kill critters until it recovers
    ;           debug.trace(self+" updated, but spawner ("+spawner+") has bad iCurrentCritterCount ("+spawner.iCurrentCritterCount+")")
disableAndDelete()
    else
    ///;
if (ShouldFlockAroundPlayer())
    ; Player is close enough and has the ingredient we're attracted to,
    ; If applicable, play takeoff animation
DoPathStartStuff()

    ; Flock to the player
FlockToPlayer()
    else
if (Spawner && Spawner.IsActiveTime())
    ; Check whether we should flee and move faster
    float fspeed = 0.0
if (closestActor != none)
    ;                       ;Debug.Trace(self + " Oh noes! there is an Actor " + closestActor + " nearby, Flee")
    ; Move fast
    fspeed = fFleeTranslationSpeed
    else
    ; Move at regular speed
fspeed = RandomFloat(fTranslationSpeedMean - fTranslationSpeedVariance, fTranslationSpeedMean + fTranslationSpeedVariance)
    endIf

    ; Time to take off for another plant
GoToNewPlant(fspeed)
    else
    ; Time to go to bed,
    BellShapeTranslateToRefAtSpeedAndGotoState(Spawner, fBellShapePathHeight, fTranslationSpeedMean, fMaxRotationSpeed, "KillForTheNight")
    endIf
    endIf
    bCalculating = False; [USKP 2.0.4]
    endIf
    closestActor = none; [USKP 2.0.4]
    endEvent

Event OnCritterGoalReached()
    ;       traceConditional(self + " reached goal", bCritterDebug)
    if PlayerRef; interlock, but never delete during Translation [USKP 2.0.1]
closestActor = Game.FindClosestActorFromRef(self, fActorDetectionDistance)
    if closestActor
    ; There is an actor right there, trigger the update right away, so we'll flee
    ; ;                 Debug.TraceConditional("Moth " + self + " registering for update", bCritterDebug)
RegisterForSingleUpdate(0.0)
    else
    ; Wait at the plant, then take off again
    ; ;                 Debug.TraceConditional("Moth " + self + " registering for update", bCritterDebug)
RegisterForSingleUpdate(RandomFloat(fTimeAtPlantMin, fTimeAtPlantMax))
    endIf
    endIf
    EndEvent

    endState

    ; When the player has the ingredient we're interested in, follow him
    State FollowingPlayer

    ;!  Event OnCritterGoalReached()
    Event OnUpdate();  [USKP 2.0.1]
    ; prevent repeat calculations [USKP 2.0.4]
    If bCalculating
    return
    EndIf
    bCalculating = True; [USKP 2.0.3]
    ; Are we too far from our spawner?
if (Spawner && Spawner.GetDistance(self) < fLeashLength && ShouldFlockAroundPlayer())
    ; Nope, flock to the player
FlockToPlayer()
    else
    ; Go back to the plants
GoToNewPlant(fFlockTranslationSpeed)
    endIf
    bCalculating = False; [USKP 2.0.4]
    endEvent

Event OnCritterGoalReached()
    ;       traceConditional(self + " about to reach goal", bCritterDebug)
    if PlayerRef; interlock, but never delete during Translation [USKP 2.0.1]
RegisterForSingleUpdate(0.0)
    endIf
    EndEvent

    endState

    ; When the moths go to sleep, they get deleted
    State KillForTheNight

    ;!  Event OnCritterGoalReached()
    Event OnUpdate();  [USKP 2.0.1]
    ; We've reached the nest, die
    ;       debug.trace ("Killing for the night: "+self)
DisableAndDelete()
    endEvent

Event OnCritterGoalReached()
    ;       traceConditional(self + " about to reach goal", bCritterDebug)
    if PlayerRef; interlock, but never delete during Translation [USKP 2.0.1]
RegisterForSingleUpdate(0.0)
    endIf
    EndEvent

    endState

    ; Helper method to indicate whether the player has the ingredient
bool Function ShouldFlockAroundPlayer()
    ;   if (PlayerRef.GetDistance(Spawner) > fRadius)
    ;       return false
    ;   endIf
    ;   return (PlayerRef.GetItemCount(IngredientType) > 0)
    return false
    endFunction

    ; Utility method, makes a moth flock to a random point around the player
Function FlockToPlayer()
    ; Switch state
    ; ;     Debug.TraceConditional("Moth " + self + " going to state FollowingPlayer", bCritterDebug)
    gotoState("FollowingPlayer")

    ; re-check viability [USKP 2.0.3]
    if !(PlayerRef ;/&& CheckCellAttached(self) && Spawner && CheckCellAttached(Spawner)/;)
RegisterForSingleUpdate(fWaitingToDieTimer)
    return
    endif

    ; Pick a random point around the player
    float ftargetX = PlayerRef.X + RandomFloat(-fFlockPlayerXYDist, fFlockPlayerXYDist)
    float ftargetY = PlayerRef.Y + RandomFloat(-fFlockPlayerXYDist, fFlockPlayerXYDist)
    float ftargetZ = PlayerRef.Z + RandomFloat(fFlockPlayerZDistMin, fFlockPlayerZDistMax)
    float ftargetAngleZ = RandomFloat(-180, 180)
    float ftargetAngleX = RandomFloat(-20, 20)
float fpathCurve = RandomFloat(fPathCurveMean - fPathCurveVariance, fPathCurveMean + fPathCurveVariance)

    ; Travel to it
if CheckViability()
    return
    endIf
SplineTranslateTo(ftargetX, ftargetY, ftargetZ, ftargetAngleX, 0.0, ftargetAngleZ, fpathCurve, fFlockTranslationSpeed, fMaxRotationSpeed)
    endFunction

    ; Finds a new plant to fly to
ObjectReference Function PickNextPlant()
    ; re-check viability [USKP 2.0.1]
    if !(PlayerRef ;/&& CheckCellAttached(self) && Spawner && CheckCellAttached(Spawner)/;)
    return none
    endif

    ; Look for a random plant within the radius of the Spawner
    int isafetyCheck = 10; was 5, match FireFly [USKP 2.0.1]
    ObjectReference newPlant = CurrentPlant

    while PlayerRef && isafetyCheck > 0; [USKP 2.0.1b]

    ; Grab a random plant from the list of valid plant types
newPlant = Game.FindRandomReferenceOfAnyTypeInList(PlantTypes, fSpawnerX, fSpawnerY, fSpawnerZ, fLeashLength)

    ; Check whether the new plant is valid (different from current)
    ; and 3D check because critters can attempt to pick disabled Nirnroots [USKP 2.0.1]
    ; and not too close to an actor
    if (newPlant != none && newPlant != currentPlant && !newPlant.IsDisabled() \
            && Game.FindClosestActorFromRef(newPlant, fActorDetectionDistance) == none \
            && CheckCellAttached(newPlant) && CheckFor3D(newPlant))
    return newPlant; [USKP 2.0.1b]
    endIf

    ; Safety counter
    isafetyCheck -= 1
    endWhile
    ; [USKP 2.0.1]
    ;       Debug.Trace("Moth " + self + " couldn't find a valid plant to go to", 1)
    return none
    endFunction

    ; Picks a new plant and fly to it if possible
Function GoToNewPlant(float afSpeed)
    ; Find a plant reference, trying to pick a different one than the current one
ObjectReference newPlant = PickNextPlant()

if (newPlant != none)
    ; Update the current plant to the new one
    currentPlant = newPlant

    ; Pick random landing node
    ; And start moving towards it
    string landingMarkerName = LandingMarkerPrefix + RandomInt(1, 3)
if (newPlant.HasNode(landingMarkerName))
    BellShapeTranslateToRefNodeAtSpeedAndGotoState(CurrentPlant, landingMarkerName, fBellShapePathHeight, afSpeed, fMaxRotationSpeed, "AtPlant")
    else
    ;           traceConditional(self + " could not find landing marker " + landingMarkerName + " on plant " + newPlant, bCritterDebug)
    string firstMarkerName = LandingMarkerPrefix + 1
if (newPlant.HasNode(firstMarkerName))
    BellShapeTranslateToRefNodeAtSpeedAndGotoState(CurrentPlant, firstMarkerName, fBellShapePathHeight, afSpeed, fMaxRotationSpeed, "AtPlant")
    else
    ;               traceConditional(self + " could not find landing marker " + firstMarkerName + " on plant " + newPlant, bCritterDebug)
    BellShapeTranslateToRefAtSpeedAndGotoState(CurrentPlant, fBellShapePathHeight, afSpeed, fMaxRotationSpeed, "AtPlant")
    endIf       
    endIf
    else
    ; This moth is stuck, wait until the player is far enough away that it can delete itself
    ;       Debug.Trace("Moth " + self + " is stuck and will wait to kill itself", 1)
    gotoState("KillForTheNight"); [USKP 2.0.1]
RegisterForSingleUpdate(fWaitingToDieTimer)
    endIf
    endFunction

Function WarpToNewPlant()
    ; Find a plant reference, trying to pick a different one than the current one
ObjectReference newPlant = PickNextPlant()

if (newPlant != none)
    ; Update the current plant to the new one
    currentPlant = newPlant

    ; Pick random landing node
    ; And start moving towards it
    string landingMarkerName = LandingMarkerPrefix + RandomInt(1, 3)
if (newPlant.HasNode(landingMarkerName))
    WarpToRefNodeAndGotoState(CurrentPlant, landingMarkerName, "AtPlant")
    else
    ;           traceConditional(self + " could not find landing marker " + landingMarkerName + " on plant " + newPlant, bCritterDebug)
    string firstMarkerName = LandingMarkerPrefix + 1
if (newPlant.HasNode(firstMarkerName))
    WarpToRefNodeAndGotoState(CurrentPlant, firstMarkerName, "AtPlant")
    else
    ;               traceConditional(self + " could not find landing marker " + firstMarkerName + " on plant " + newPlant, bCritterDebug)
    WarpToRefAndGotoState(CurrentPlant, "AtPlant")
    endIf
    endIf
    else
    ; This moth is stuck, wait until the player is far enough away that it can delete itself
    ;       Debug.Trace("Moth " + self + " is stuck and will wait to kill itself", 1)
    gotoState("KillForTheNight"); [USKP 2.0.1]
RegisterForSingleUpdate(fWaitingToDieTimer)
    endIf
    endFunction

Function DoPathStartStuff()
    ; Transition to the flight state
    SetAnimationVariableFloat("fTakeOff", 1.0); [USKP 2.0.1]
    endFunction

Function DoPathEndStuff()
    ; Transition to the hover/landed state
    SetAnimationVariableFloat("fTakeOff", 0.0); [USKP 2.0.1]
    endFunction
