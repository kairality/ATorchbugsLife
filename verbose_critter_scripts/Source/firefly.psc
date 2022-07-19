scriptName Firefly extends Critter
{Main Behavior script for fireflies}

import Utility
import form
import debug

; Properties (set through the editor)
FormList property PlantTypes auto
{ The list of plant types this firefly can be attracted to}

; Constants
float Property fTimeAtPlantMin = 5.0 auto
{The Minimum time a Firefly stays at a plant}
float Property fTimeAtPlantMax = 10.0 auto
{The Maximum time a Firefly stays at a plant}
float Property fActorDetectionDistance = 300.0 auto
{The Distance at which an actor will trigger a flee behavior}
float Property fTranslationSpeedMean = 50.0 auto
{The movement speed when going from plant to plant, mean value}
float Property fTranslationSpeedVariance = 25.0 auto
{The movement speed when going from plant to plant, variance}
float Property fFleeTranslationSpeed = 100.0 auto
{The movement speed when fleeing from the player}
float Property fFlockPlayerXYDist = 100.0 auto
{When flocking the player, the XY random value to add to its location}
float Property fFlockPlayerZDistMin = 50.0 auto
{When flocking the player, the min Z value to add to its location}
float Property fFlockPlayerZDistMax = 200.0 auto
{When flocking the player, the max Z value to add to its location}
float Property fFlockTranslationSpeed = 300.0 auto
{When flocking the player, the speed at which to move}
float Property fMinScale = 0.3 auto
{Minimum initial scale of the Firefly}
float Property fMaxScale = 0.4 auto
{Maximum initial scale of the Firefly}
float property fMinTravel = 64.0 auto
{Minimum distance a wandering Firefly will travel}
float property fMaxTravel = 512.0 auto 
{Maximum distance a wandering Firefly will travel}
float property fMaxRotationSpeed = 90.0 auto
{Max rotation speed while mocing, default = 90 deg/s}

; Variables
Actor closestActor = none

; Constants
float fWaitingToDieTimer = 10.0


    ; Called by the spawner to kick off the processing on this Firefly
Event OnStart()
    ; Vary size a bit
SetScale(RandomFloat(fMinScale, fMaxScale))

    ; Switch state and trigger a callback immediately
    ; ;     Debug.TraceConditional("Firefly " + self + " warping to state AtPlant", bCritterDebug)

    ; test moved to Critter [indent retained] [USKP 2.0.1]
WarpToNewPlant()
    ; ;         Debug.TraceConditional("Firefly " + self + " registering for update", bCritterDebug)

    ; Enable the critter
Enable()

if !CheckFor3D(self)
    Debug.trace("checkFor3DFailed here in firefly")
DisableAndDelete(false)
    return
    endIf

    ; Switch to keyframe state
SetMotionType(Motion_Keyframed, false)

    ; Get ready to start moving
RegisterForSingleUpdate(0.0)
    endEvent

    ; The Current plant object
    ObjectReference currentPlant = none

    ;/ clear TargetObject [USKP 2.0.1]
    /;
Function TargetClear()
    currentPlant = none
    endFunction

    ; Firefly is at the plant
    State AtPlant

Event OnUpdate()
    ; Is the player too far?
    if CheckViableDistance()
if (ShouldFlockAroundPlayer())
    ; Player is close enough and has the ingredient we're attracted to,
    ; If applicable, play takeoff animation
DoPathStartStuff()

    ; Flock to the player
FlockToPlayer()
    else
if (Spawner && Spawner.IsActiveTime())
    ; Check whether we should flee and move faster
if (closestActor != none)
    ;                       ;Debug.Trace(self + " Oh noes! there is an Actor " + closestActor + " nearby, Flee")
    ; Move fast
    GoToNewPlant(fFleeTranslationSpeed)
elseif (RandomInt(0, 100) < 20)
    ; Move at regular speed
float fspeed = RandomFloat(fTranslationSpeedMean - fTranslationSpeedVariance, fTranslationSpeedMean + fTranslationSpeedVariance)

    ; Time to take off for another plant
GoToNewPlant(fspeed)
    else
    ; Hover close by
HoverCloseBy()
    endIf
    else
    ; Time to go to bed,
    SplineTranslateToRefAtSpeedAndGotoState(Spawner, fTranslationSpeedMean, fMaxRotationSpeed, "KillForTheNight")
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
    ; ;                 Debug.TraceConditional("Firefly " + self + " registering for immediate update", bCritterDebug)
RegisterForSingleUpdate(0.0)
    else
    ; Wait at the plant, then take off again
    ; ;                 Debug.TraceConditional("Firefly " + self + " registering for update at plant", bCritterDebug)
RegisterForSingleUpdate(RandomFloat(fTimeAtPlantMin, fTimeAtPlantMax))
    endIf
    endIf
    EndEvent

    endState

    State Hovering

    ;!  Event OnCritterGoalReached()
    Event OnUpdate();  [USKP 2.0.1]
    ;       traceConditional(self + " reached goal", bCritterDebug)
    if CheckViableDistance()
if (Game.FindClosestActorFromRef(self, fActorDetectionDistance) != none)
    ; There is an actor right there, trigger the update right away, so we'll flee
GoToNewPlant(fFleeTranslationSpeed)
    else
if (RandomInt(0, 100) < 20)
    ; Time to take off for another plant
    ; ;                     Debug.TraceConditional("Firefly " + self + " stopping hover and going to a new plant", bCritterDebug)
GoToNewPlant(RandomFloat(fTranslationSpeedMean - fTranslationSpeedVariance, fTranslationSpeedMean + fTranslationSpeedVariance))
    else
    ; Hover close by
    ; ;                     Debug.TraceConditional("Firefly " + self + " is hovering", bCritterDebug)
HoverCloseBy()
    endIf
    endIf
    bCalculating = False; [USKP 2.0.4]
    endIf
    EndEvent

Event OnCritterGoalReached()
    ;       traceConditional(self + " about to reach goal", bCritterDebug)
    if PlayerRef; interlock, but never delete during Translation [USKP 2.0.1]
RegisterForSingleUpdate(0.0)
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

    ; When the Fireflys go to sleep, they get deleted
    State KillForTheNight

    ;!  Event OnCritterGoalReached()
    Event OnUpdate();  [USKP 2.0.1]
    ; We've reached the nest, die
    debug.trace ("Here42 Killing for the night: "+self)
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

    ; Utility method, makes a Firefly flock to a random point around the player
Function FlockToPlayer()
    ; Switch state
    ; ;     Debug.TraceConditional("Firefly " + self + " going to state FollowingPlayer", bCritterDebug)
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
TranslateTo(ftargetX, ftargetY, ftargetZ, ftargetAngleX, 0.0, ftargetAngleZ, fFlockTranslationSpeed, fMaxRotationSpeed)
    endFunction

Function HoverCloseBy()
    ; Pick a random point around the the current location
    float ftargetX = X + RandomFloat(-20, 20)
    float ftargetY = Y + RandomFloat(-20, 20)
float ftargetZ = Z + RandomFloat(-20, 20)

    float ftargetAngleZ = GetAngleZ() + RandomFloat(-20, 20)
float ftargetAngleX = RandomFloat(-5, 5)

    ; check against currentPlant after using local 3D references [USKP 2.0.1]
    if currentPlant && CheckFor3D(currentPlant) && fTargetZ < currentPlant.z
    fTargetz = currentPlant.z
    endif

    ; Travel to it
    GotoState("Hovering")
    ; ;     Debug.TraceConditional("Firefly " + self + " going to state Hovering", bCritterDebug)
if CheckViability()
    return
    endIf
TranslateTo(ftargetX, ftargetY, ftargetZ, ftargetAngleX, 0.0, ftargetAngleZ, RandomFloat(10, 30), fMaxRotationSpeed)
    endFunction

    ; Finds a new plant to fly to
ObjectReference Function PickNextPlant()
    ; re-check viability [USKP 2.0.1]
    if !(PlayerRef ;/&& CheckCellAttached(self) && Spawner && CheckCellAttached(Spawner)/;)
    debug.trace("PickNextPlant viability fail Here42")
    return none
    endif

    ; Look for a random plant within the radius of the Spawner
    int isafetyCheck = 10
    ObjectReference newPlant = CurrentPlant

    while PlayerRef && isafetyCheck > 0; [USKP 2.0.1b]

    ; Grab a random plant from the list of valid plant types
    newPlant = Game.FindRandomReferenceOfAnyTypeInList(PlantTypes, fSpawnerX, fSpawnerY, fSpawnerZ, fLeashLength); speed, match Moth [USKP 2.0.1]
    Debug.Trace("Firefly could pick " + newPlant, 1)
    Debug.Trace("bits:" + newPlant + " " + (newPlant != currentPlant) + " " + !newPlant.IsDisabled() + " " + (Game.FindClosestActorFromRef(newPlant, fActorDetectionDistance) == none) + " " +  CheckCellAttached(newPlant) + " " + CheckFor3D(newPlant) , 1)

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
    Debug.Trace("Firefly " + self + " couldn't find a valid plant to go to", 1)
    return none
    endFunction

    ; Picks a new plant and fly to it if possible
Function GoToNewPlant(float afSpeed)
    ; Find a plant reference, trying to pick a different one than the current one
ObjectReference newPlant = PickNextPlant()

if (newPlant != none)
    ; Update the current plant to the new one
    currentPlant = newPlant
    SplineTranslateToRefAtSpeedAndGotoState(currentPlant, afSpeed, fMaxRotationSpeed, "AtPlant")

    else
    ; This Firefly is stuck, wait until the player is far enough away that it can delete itself
    Debug.Trace("Firefly " + self + " is stuck and will wait to kill itself", 1)
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

    WarpToRefAndGotoState(CurrentPlant, "AtPlant")

    else
    ; This Firefly is stuck, wait until the player is far enough away that it can delete itself
    Debug.Trace("Here32 Firefly " + self + " is stuck and will wait to kill itself", 1)
    gotoState("KillForTheNight"); [USKP 2.0.1]
RegisterForSingleUpdate(fWaitingToDieTimer)
    endIf
    endFunction
