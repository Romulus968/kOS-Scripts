CLEARSCREEN.
PRINT "NEPTUNE MK3 BOOTING...".
WAIT 5.0.
PRINT "...".
PRINT "...".
PRINT "...".
WAIT 2.0.
PRINT "TARGET LOCATION IN PROCESS.".
WAIT 3.0.
PRINT "TARGET IDENTIFIED.".
WAIT 1.0.

RCS ON.

SET targ TO TARGET.
set targheight to 1000.//ets desired height of missile.
set targetelev to target:BEARING.

set pitchcoeff to 90/targheight. //Agressiveness of pitch change.

PRINT "SYSTEM READY.".

LOCK THROTTLE TO 1.0.

WHEN SHIP:MAXTHRUST = 0 THEN {
	PRINT "STAGING".
	WAIT 1.0.
	STAGE.
	PRESERVE.
}.

until ((targ:distance)^2-(altitude-targetelev)^2)^0.5 < 5000 {
	print "CRUISE MODE   " at (5,5).
	print "DISTANCE TO TARGET: "+ targ:distance +" m   " at (5,6).
	print "ETA: "+ targ:distance/groundspeed + " s   " at (5,7).
	lock targheading to targ:heading.

	//These lines determine if the missile is flying over water. If it is, the missile determins its height based on altitude, not radalt.
	set height to alt:radar.
	if altitude:radar <0 {set height to altitude.}.
	if altitude:radar > altitude {set height to altitude.}.

	set pitch to (pitchcoeff*height*(-1)) +110. //some more aggressiveness of pitch change. 
	if pitch <-25 {set pitch to -25.}. //Sets limits on max/min pitch.
	if pitch >89 {set pitch to 89.}.

	lock steering to TARGET:HEADING.
}.


lock throttle to 0.6.
until ((targ:distance)^2-(altitude-targetelev)^2)^0.5 < 2200 {
	print "*FINAL TARGETING*   " at (5,5).
	print "DISTANCE TO TARGET: "+ targ:distance +" m   " at (5,6).
	print "ETA: "+ targ:distance/surfacespeed + " s   " at (5,7).


	set pitch to 45.
	lock targheading to targ:heading.
	lock steering to TARGET:HEADING.
	if altitude > targetelev + 800 {set pitch to 0.
		lock targheading to targ:heading.
		lock steering to TARGET:HEADING.
	}.


}.
lock throttle to 0.
set pitch to -30.
until targ:distance < 10 {
	print "***TARGET IN SIGHT***   " at (5,5).
	print "DISTANCE TO TARGET: "+ targ:distance +" m   " at (5,6).
	print "ETA: "+ targ:distance/surfacespeed + " s   " at (5,7).


	//When missile is 2200m away, engines are cut and missile coasts to target, adjusting pitch to try and reach it.
	if sin(pitch) < (targetelev-altitude)/targ:distance {
		set pitch to pitch + 1.5.
		lock targheading to targ:heading.
		lock steering to TARGET:HEADING.
	}.
	if sin(pitch) > (targetelev-altitude)/targ:distance {
		set pitch to pitch - 1.5.
		lock targheading to targ:heading.
		lock steering to TARGET:HEADING.
	}.
	lock targheading to targ:heading.
	lock steering to TARGET:HEADING.
}.


WAIT UNTIL SHIP:ALTITUDE = 0.