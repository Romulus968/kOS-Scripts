// Tuning parameters
SET pGain TO 1/1000.			// proportional gain
SET dGain TO 1/100.				// differential gain
SET maxPitch TO 67.5.			// Hard limit for maximum pitch angle (degrees)
SET asInfl TO 900.				// Determines how much airspeed influences maximum pitch angle.

// Cruising altitude calculation
IF TARGET:DISTANCE < 190000 {
	SET alt TO 1000 + TARGET:DISTANCE / 10.
} ELSE {
	// Cruising altitude is capped at 20 km
	SET alt TO 20000.
}

CLEARSCREEN.
print "Initial distance to target : " + ROUND(TARGET:DISTANCE).
print "Cruising altitude: " + ROUND(alt).

WAIT 2.0.
LOCK THROTTLE TO 1.0.
RCS ON.
TOGGLE AG1.

// Launch
STAGE.
LOCK STEERING TO HEADING(TARGET:HEADING, 20).

WAIT UNTIL STAGE:SOLIDFUEL < 0.001.
STAGE.

SET anArrow TO VECDRAW().
SET anArrow:SHOW TO true.
SET anArrow:START TO V(0,0,0).
SET anArrow:COLOR TO RGB(1,0,0).
SET anArrow:SCALE TO 5.0.

WHEN true THEN {
	SET anArrow:VEC TO target:position.
	SET anArrow:LABEL TO TARGET:DISTANCE.
	PRINT "Distance to target: " + ROUND(TARGET:DISTANCE) AT(0,3).
	
	PRESERVE.
}

UNTIL ((TARGET:DISTANCE)^2-(ALTITUDE^2))^0.5 < ALTITUDE*3 {
	SET pError TO (alt - ALTITUDE).									// error in height (positive means too low)
	SET dError TO -1*VERTICALSPEED.									// error in vertical speed
	SET angleCor TO 1/(AIRSPEED/asInfl + 1).				// Correction on maximum pitch angle influenced by airspeed
	SET pitch TO ARCTAN(pError*pGain + dError*dGain) / 90 * maxPitch * angleCor.
	LOCK STEERING TO HEADING(TARGET:HEADING, pitch).
	
	PRINT "pError: " + ROUND(pError, 3) AT(0,5).
	PRINT "dError: " + ROUND(dError, 3) AT(0,6).
	PRINT "pTerm: " + ROUND(pError*pGain, 3) AT(20,5).
	PRINT "dTerm: " + ROUND(dError*dGain, 3) AT(20,6).
	PRINT "Pitch: " + ROUND(pitch, 3) AT(0,7).
	PRINT "Max pitch: " + ROUND(angleCor*90, 3) AT(20,7).
}

PRINT "Target in range. Diving..." AT(0,10).

LOCK STEERING TO TARGET:POSITION.

WAIT UNTIL false.