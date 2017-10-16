// Cruise missle script, managing pitch and throttle.
// Compatible with KSP 1.0 and kOS 0.18


// Name of target craft
PARAMETER tName.


LOCAL cAltitude 	IS 200.
LOCAL cVelocity 	IS 300.
LOCAL cThrottle 	IS 1.
LOCAL cPitch 		IS 0.

LOCAL sDistance		IS 0.

LOCAL tPID IS PIDLOOP().
LOCAL pPID IS PIDLOOP().

// Launch and ascend straight up for a bit
CLEARSCREEN.
SAS ON.
LOCK THROTTLE TO 1.
STAGE.
UNTIL (SHIP:AIRSPEED > 50)							// Ascend until we reach an airspeed of 50m/s
{
	PRINT "Airspeed: " + ROUND(SHIP:AIRSPEED,0) + "m/s  " AT (0,0).
	
	WAIT 0.01.
}


CLEARSCREEN.


// Set up two PID controllers
// Note that this isn't perfect as throttle will affect altitude which indirectly affects pitch and visa-versa
SET tPID to PIDLOOP( 0.005, 0.01, 0.0, 0, 1 ). 		// Kp, Ki, Kd, Min/Max throttle
SET pPID to PIDLOOP( 0.1, 0.1, 0.2, -15, 15 ). 		// Kp, Ki, Kd, Min/Max pitch change


// Turn towards target
SET TARGET TO tName.
LOCK THROTTLE TO cThrottle.
LOCK STEERING TO HEADING(TARGET:HEADING,cPitch).


// Record the ground distance to target (uses Pythagoras' theorem to find the "adjacent" length)
LOCK sDistance TO SQRT(((TARGET:DISTANCE)^2) - (SHIP:ALTITUDE - TARGET:ALTITUDE)^2).


// Criuse towards the target, until we get to about 2km surface distance away
UNTIL (sDistance < 2000)
{
	// Calculate the throttle to set the cruise speed
	SET tPID:SETPOINT TO cVelocity.
	SET cThrottle 	TO tPID:UPDATE(TIME:SECONDS, SHIP:AIRSPEED).
	
	// Carculate the pitch, which affects altitude
	SET pPID:SETPOINT TO cAltitude.
	IF (ALT:RADAR > 0)
	{
		// If we are above land, use Radar Altitude
		SET cPitch TO pPID:UPDATE(TIME:SECONDS, ALT:RADAR).
	}
	ELSE
	{
		// If we are above water, use Altitude above sea level
		SET cPitch TO pPID:UPDATE(TIME:SECONDS, SHIP:ALTITUDE).
	}
	
	PRINT "Cruise Speed   : " 	+ ROUND(cVelocity,0) 		+ "m/s  " 	AT (0,0).
	PRINT "Airspeed       : " 	+ ROUND(SHIP:AIRSPEED,0) 	+ "m/s  " 	AT (0,1).
	PRINT "Throttle       : " 	+ ROUND(cThrottle,2) 		+ "     " 	AT (0,2).
	
	PRINT "Cruise Altitude: " 	+ ROUND(cAltitude,0) 		+ "m    " 	AT (0,4).
	PRINT "Altitude       : " 	+ ROUND(ALT:RADAR,0) 		+ "m    " 	AT (0,5).
	PRINT "Pitch          : " 	+ ROUND(cPitch,0) 			+ "     " 	AT (0,6).
	
	PRINT "Target Distance: " 	+ ROUND(TARGET:DISTANCE,0) 	+ "m    " 	AT (0,8).
	PRINT "Ground Distance: " 	+ ROUND(sDistance,0) 		+ "m    " 	AT (0,9).
	
	WAIT 0.01.
}


CLEARSCREEN.


// Prepare to dive bomb the target by getting some height, until we are about 1km away
// This avoids hitting a ridge  or otehr obstacle which may be in front of the missile
LOCK cPITCH TO 45.
UNTIL (sDistance < 1000)
{
	PRINT "Altitude       : " 	+ ROUND(ALT:RADAR,0) 		+ "m    " 	AT (0,5).
	
	PRINT "Target Distance: " 	+ ROUND(TARGET:DISTANCE,0) 	+ "m    " 	AT (0,8).
	PRINT "Ground Distance: " 	+ ROUND(sDistance,0) 		+ "m    " 	AT (0,9).
	
	WAIT 0.01.
}


// Dive bomb the target by calculating the pitch towards the target
LOCK STEERING TO TARGET:DIRECTION.
LOCK THROTTLE TO 1.
UNTIL (sDistance < 1)
{
	PRINT "Altitude       : " 	+ ROUND(ALT:RADAR,0) 		+ "m    " 	AT (0,5).
	
	PRINT "Target Distance: " 	+ ROUND(TARGET:DISTANCE,0) 	+ "m    " 	AT (0,8).
	PRINT "Ground Distance: " 	+ ROUND(sDistance,0) 		+ "m    " 	AT (0,9).
	
	WAIT 0.01.
}