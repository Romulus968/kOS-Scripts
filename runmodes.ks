//RUNMODES

if runmode = 1 { //Pre-Launch
    set TVAL to 0.1.
    lock throttle to TVAL.
    sas off. RCS on. gear off. lights on.
    wait 1.
    //stage.
    wait 1.
    set TVAL to TWRTarget/TWR.
    wait 0.75.
    //stage.
    set runmode to 11.
    }

if runmode = 11 { //Launch
    ORIENTTOVECTOR(UP,steeringData). 
    //set TVAL to TWRTarget/TWR. //Run engines at a target of 90%
    set TVAL to 1. //MOAR POWER!!!!1!

    if verticalspeed > 60 {
        set runmode to 12.
        }
    }
if runmode = 12 { // Initial climb
    //set TVAL to TWRTarget/TWR. //Run engines at a target of 90%
    set TVAL to 1. //MOAR POWER!!!!1!
    if ALTITUDE < atmoHeight {
        set targetPitch to max( 5, 90 * (1 - (ALT:RADAR + 850) / 47000)).
        }
    else {
        set tPITCH to 2.
        }
    lock steering to heading(90, targetPitch).
    print "tPitch: " + targetPITCH + "        " at ( 5,35).
    
    if SHIP:APOAPSIS > atmoHeight{
	    set RUNMODE to 13.
        }
    else if SHIP:APOAPSIS > tAP{
        set RUNMODE to 14.
        }
    if stage:Liquidfuel < 1800 {
        set runmode to 19.
        }
    }

if runmode = 13 { // Burn to raise Ap while in space
    set TVAL to TWRTarget/TWR.
    set tPITCH to 2.
    lock steering to heading(90, tPITCH).

    if SHIP:APOAPSIS > tAP{
        set RUNMODE to 14.
        }
    }

if runmode = 14 { // Coast to AP
    set TVAL to 0.
    set tPITCH to 3.
    lock steering to heading(90, tPITCH).

    if ETA:APOAPSIS < 10 or VERTICALSPEED < 0{
        set RUNMODE to 15.
        }
    }

if runmode = 15 { // Burn to raise Pe
    set TVAL to TWRTarget/TWR.
    set tPITCH to 3.
    lock steering to heading(90, tPITCH).

    if SHIP:PERIAPSIS > tPe * 0.95{
        set RUNMODE to 0.
        panels on.
        set TVAL to 0.
        }
    }
    
if runmode = 18 { //Simple fuel check
    if stage:Liquidfuel < 2000 { //1600 for my all-stock craft
        set runmode to 19.
        unlock steering.
        }
    }
    
if runmode = 19 { //Stage for reusable first stage
    set TVAL to 0. 
    UNLOCK STEERING.
    SET SHIP:CONTROL:NEUTRALIZE to TRUE.
    rcs on.
    wait 1.
    stage.
    toggle ag3.
    SET SHIP:CONTROL:FORE to -1. // Seperate from the upper stage
    wait 3.
    SET SHIP:CONTROL:PITCH to 1.
    wait 3.
    SET SHIP:CONTROL:FORE to 0.
    SET SHIP:CONTROL:PITCH to 0.
    wait 5.
    set runmode to 20.
    }



	
if runmode = 20 { //Boost Back
    rcs on.
    set BoostBackVector to landingtargetLATLNG:ALTITUDEPOSITION(max(landingtargetLATLNG:TERRAINHEIGHT, 0) + ALTITUDE * 1.30).
    ORIENTTOVECTOR(BoostBackVector:VEC, steeringData).
    
    if VANG( BoostBackVector, fore) < 15 {
        set engineSafety to 0. // Arm the engines
        set TVAL to 3 / TWR.
        }
    else if engineSafety = 0 { //If the engine has fired but we've moved off target
        set TVAL to 0.5 / TWR.
        }
    else { //Wait for things to line up.
        set TVAL to 0.
        }
    // if it will take less time to get to the LZ then it will to hit the ground, while also going in the generally correct direction, end burn
    if ((gs_distance(shipLatLng,landingtargetLATLNG) / SURFACESPEED) + 0) * 1.025 < fallTime + 0 and VANG( BoostBackVector, VELOCITY:SURFACE) < 45{ 
        //TODO: Finish the above formula instead of fudging the BBTL
        //The plus 30 is the modifier for atmo drag
        set TVAL to 0. 
        set engineSafety to 1.
            SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        rcs on.
        wait 1.
        SET SHIP:CONTROL:PITCH to -1.
        wait 3.
        SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        wait 3.
        set runmode to 21.
        }
    else if stage:Liquidfuel < 450 {
        //Low fuel alert!!!
        set TVAL to 0.
        set runmode to 26. //Emergency Landing!
        }
        
    }
    
    
if runmode = 21 { //Coast to the boost back complete target
    set TVAL to 0.
    ORIENTTOVECTOR(VELOCITY:SURFACE * -1, steeringData).
    if landingtargetLATLNG:DISTANCE < 25000{ //30000 is the most tested value
        set runmode to 50.
        set steeringData[0] to steeringData[0] * 2. //Time to get agressive about
        set steeringData[1] to steeringData[1] * 1. //Changing the heading of the nose
        set steeringData[2] to steeringData[2] * 1.5.
        }
    }  
    
    
if runmode = 26 { // Coast until the ETA of slamming into the ground < 10 seconds
    panels off.
    set SHIP:CONTROL:NEUTRALIZE to TRUE.
    lock STEERING to velocity:surface * -1. //Point retrograde relative to surface velocity
    set TVAL to 0.
    if ALTITUDE > 70000 {
        wait 1. //Wait to make sure the ship is stable
        SET WARP TO 3. //Be really careful about warping
        }
    else if ALTITUDE < 70000 and WARP > 0 {
        SET WARP TO 0. // Make sure we don't time warp through the atmosphere
        }
    if impactTime < 100 and verticalspeed < -1 and betterALTRADAR < 5000{
        set runmode to 27.
        }
    } 

if runmode = 27 { // Land on the ground
    set SHIP:CONTROL:NEUTRALIZE to TRUE.
    lock STEERING to velocity:surface * -1.//Point retrograde relative to surface velocity
    set landingRadar to min(ALTITUDE, betterALTRADAR).
    // Use whichever says our altitude is lower
    //This is useful in case we overshoot the KSC and need to land in the ocean.
    set TVAL to (0.85 / TWR) - min(0,(verticalspeed + max(5, min (350, landingRadar^1.06 / 5)) ) / 3 / TWR).
    if killTime > impactTime*0.95 {set TVAL to 1.} //PANIC BURN!
    
    gear on.
    // Here we set the throttle to hover using a Thrust to weight ratio of one to counter act gravity
    // Then we modify the throttle by the error between the speed we want to be at (based on altitude)
    // and the speed we are currently at, then divide it by three to smooth it out and then divide it again
    // by the TWR to automatically customize it for each ship.
    //
    if betterALTRADAR < 30 and ABS(VERTICALSPEED) < 5 {
        lock throttle to 0.
        set SHIP:CONTROL:NEUTRALIZE to TRUE.
        lock steering to up.
        print "LANDED!".
        wait 2.
        set runmode to 0.
        } 
    }
    
    
    
    
if runmode = 30 { //Cruise

    ORIENTTOVECTOR(V(0,0,0) - VELOCITY:SURFACE:VEC). 
    
    if landingtargetLATLNG:DISTANCE < 60000{ //30000 is the most tested value
        set runmode to 50.
        }
    else if (landingtargetLATLNG:DISTANCE > 2 * betterALTRADAR) and SURFACESPEED < 500 {
        set runmode to 80.
        }
    else {
        run rollcontrol(0).
        }
    }

if runmode = 50 { ///Let the fun begin. Get back to the pad.
    set LZDistCUTOFF to 2000.
    //set LZTargetAltitude to MIN(40000, MIN(betterALTRADAR - 35 , 200 + landingtargetLATLNG:DISTANCE / 4)).
    //set LZTargetAltitude to MIN(40000, (landingtargetLATLNG:DISTANCE / 4) - 35). //This is what we've been using
    set LZTargetAltitude to MIN(40000, MAX(0, betterALTRADAR / 4) - 35).
    sas off.
    //set LZVECMODED to landingtargetLATLNG:POSITION:VEC. // no longer :NORMALIZED

    // Set landing target
   set LandingSiteVM to landingtargetLATLNG:ALTITUDEPOSITION(MAX(0, landingtargetLATLNG:TERRAINHEIGHT) + LZTargetAltitude).
        set LandingSiteVM:MAG to 2.

    //Surface Velocity
    set SurfaceVelocityVM to VELOCITY:SURFACE.
        set SurfaceVelocityVM:MAG to -2 - MIN(3, ( MAX(0.0, 3 - betterALTRADAR / 500 ))).
        if SURFACESPEED > 300 { 
            //set SurfaceVelocityVM:MAG to SurfaceVelocityVM:MAG - SURFACESPEED / 50.
            }

    //UP Vector
    set UpVectorM to ship:up:vector:normalized.
        if landingtargetLATLNG:DISTANCE > LZDistCUTOFF {
            set UpVectorM:MAG to 0.4.
            }
        else {
            set UpVectorM:MAG to MIN(5, ( MAX(0.4, 3 - (-VerticalSpeed / 120) - landingtargetLATLNG:DISTANCE / 500 ))).
            }
    //Put it all together
    set vcProd to (UpVectorM + SurfaceVelocityVM + LandingSiteVM):VEC.
    //set vcProd:MAG to 1.


    //Steering
    if betterALTRADAR < 2 and SURFACESPEED < 0.25 {
        ORIENTTOVECTOR(UP:VEC).
        }
    else if betterALTRADAR < 50 and SURFACESPEED > 0.25 {
        ORIENTTOVECTOR((SurfaceVelocityVM:normalized + ship:up:vector:normalized):VEC, steeringData).
        }
    else if VANG (VCPROD, UP:VEC) > 180{
        //Safety to make sure the ship stays pointing away from the ground
        ORIENTTOVECTOR(UP:VEC, steeringData).
        }
    else {
        ORIENTTOVECTOR(VCPROD:VEC, steeringData).
        }

    //Throttle
    //set TVAL to 0.1/TWR.
    if sin(pitchangle) > 0{
        set tFALLSPEED to max(2, min(500, (max(2.5, betterALTRADAR-10)^0.7))).

        set TVAL to max( 0.1/TWR, (MIN(3/TWR, (1 / TWR)/ sin(pitchangle))) - ((verticalspeed + tFALLSPEED)/10  )).
        //print "Base Fall Spd: " + round(tFALLSPEED, 2) + "       " at (5,33).
        }
    if VANG( VCPROD, fore) < 20 {
        if VANG(UP:VEC, LandingSiteVM) > VANG(UP:VEC, VELOCITY:SURFACE) AND landingtargetLATLNG:DISTANCE > LZDistCUTOFF*2 {
            set TVAL to TVAL + MAX(-1, (-VANG(LandingSiteVM, VELOCITY:SURFACE)))/10 / TWR.
            }
        else if VANG(UP:VEC, LandingSiteVM) < VANG(UP:VEC, VELOCITY:SURFACE)  AND landingtargetLATLNG:DISTANCE > LZDistCUTOFF*2{
            set TVAL to TVAL + MIN( TWRTarget, VANG(LandingSiteVM, VELOCITY:SURFACE)/10) / TWR.
            }
       }
    else if VANG( VCPROD, fore) < 20 and vcProd:MAG > 0.5 AND landingtargetLATLNG:DISTANCE > 5000{
        set TVAL to MIN(TWRTarget, (vcProd:MAG -0.5 ) * 5)/ TWR.
        }
    else if sin(pitchangle) < 0.01 {
        set TVAL to 0.
        }
    else if landingtargetLATLNG:DISTANCE < LZDistCUTOFF*5{
        set TVAL to MAX( TVAL, 0.3/TWR).
        }
    //Engine keep alive
    if betterALTRADAR < 15000{
        set TVAL to MAX(TVAL, 0.1).
        }
        
    //print "RCVec Mag: " + round(vcProd:MAG, 2) + "       " at (5,34).
    //print "UP Angle Mag: " + round(UpVectorM:MAG, 2) + "       " at (5,35).
    SET vVCPROD TO VECDRAWARGS(
                  V(0,0,0),
                  vcProd,
                  green, 
                  "VC PRODUCT", 20, true).
    SET vLandingSiteVM  TO VECDRAWARGS(
                  V(0,0,0),
                  LandingSiteVM,
                  RED, 
                  "LZ Alt Target", 10, true).
    if betterALTRADAR < 30 AND TOTALSPEED < 1.5{
        set runmode to 99.
        SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        SET vVCPROD:SHOW TO FALSE.
        SET vLandingSiteVM:SHOW TO FALSE.
        }
    else if impactTime < 8{
        gear on.
        }

    SET SHIP:CONTROL:ROLL TO 0.
    }    

if runmode = 79 { //Wait for landing
    if impacttime < 40 { set RUNMODE to 80.} // 75 seconds works \\60 works w/ thrust modulation
    ORIENTTOVECTOR(SHIP:SRFRETROGRADE:VECTOR, steeringData). 
        run rollcontrol(0).
    }

if runmode = 80 { ///Emergency Landing
    
    if ((killTime * 1.15) - impactTime) < 1 {
        set correctionVector to UP:VEC:NORMALIZED.
        set correctionVector:MAG to MAX(0.15, 0.6 - (SURFACESPEED / 200)).
         ORIENTTOVECTOR(SHIP:SRFRETROGRADE:VECTOR:normalized + correctionVector, steeringData).
         if VANG(SHIP:SRFRETROGRADE:VECTOR, UP:VEC) < 10 {
           SET SHIP:CONTROL:ROLL TO 0.
            }
         else {
            run rollcontrol(0).
            }
        }
    else if ((killTime * 1.15) - impactTime) > 1 {
        set correctionVector to UP:VEC:NORMALIZED.
         set correctionVector:MAG to MAX(0, ((killTime * 1.15) - impactTime) / 30). //40 worked historically
        ORIENTTOVECTOR(SHIP:SRFRETROGRADE:VECTOR + correctionVector, steeringData). 
        run rollcontrol(0).
        }
    else {
        ORIENTTOVECTOR(SHIP:SRFRETROGRADE:VECTOR, steeringData). 
        run rollcontrol(0).
        }

   if VERTICALSPEED < 0 and impactTime < killTime * 1.15 { // Wait until the ship is falling.
        set ENGINESAFETY to 0. 
        }

    

    if ENGINESAFETY = 0 and VERTICALSPEED < 0 and impactTime < killTime * 1.40 {
        set TVAL to (TWRTarget + (killTime * 1.15) - impactTime) / TWR.
        }
    else if ENGINESAFETY = 0 and VERTICALSPEED < 0 {
        set TVAL to 0.1 / TWR. 
        }
    else { 
        set TVAL to 0. 
        }

    if totalSpeed < 75 {
        set runmode to 81.
        }
    }

if runmode = 81 { //Final Touchdown
    gear on. set ENGINESAFETY to 0.
    SET SHIP:CONTROL:ROLL TO 0.
    if VERTICALSPEED < 0 {
        set correctionVector to UP:VEC:NORMALIZED.
         set correctionVector:MAG to MIN(5, ( MAX(1, 5 - ABS(VERTICALSPEED/3)))).
        ORIENTTOVECTOR(SHIP:SRFRETROGRADE:VECTOR:NORMALIZED + correctionVector, steeringData). 
        //run rollcontrol(0).
        }
    else {
        ORIENTTOVECTOR(UP:VEC, steeringData).
        }

    set TVAL to (1 / TWR) - (verticalspeed + max(2, min (75, (betterALTRADAR^1.08 / 10))))/3 / TWR.

    if alt:radar < shipHeight + 2 { //If really close to landing
        set runmode to 99.
        set TVAL to 0.
           SET SHIP:CONTROL:PITCH TO 0.
           SET SHIP:CONTROL:YAW TO 0.
           SET SHIP:CONTROL:ROLL TO 0.
        print "TOUCHDOWN SPEED: " + round(TOTALSPEED,2) + " M/s" at (8, 30).
        SAS ON.
        Wait 2.
        SAS OFF.
        }
    }

if runmode = 99 {
        set TVAL to 0.
        SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        print "TOUCHDOWN SPEED: " + round(TOTALSPEED,2) + " M/s" at (8, 30).
        SAS ON.
        Wait 2.
        SAS OFF.
        SET runmode to 0.
        }

set t0 to TIME:SECONDS.
