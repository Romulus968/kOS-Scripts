clearscreen.
print "Cruise Missile v 1.0 by check".
Print "Targeting...".
//set targlat to 3.
//set targlong to -78.


set targheight to 400. //Sets desired height of missile.
set targetelev to 1350. //Sets elevation of target.

set pitchcoeff to 90/targheight. //Agressiveness of pitch change.
set target to "target1". //Target name.
set targ to target.


//lock targ to latlng(targlat,targlong).
lock targdist to targ:distance. //Below, locates target, spins launcher to point to target, launches missile.
lock targheading to targ:heading.

lock wheelsteering to targ.
lock wheelthrottle to 0.2.
wait until abs(targ:bearing) < 1.
lock wheelthrottle to 0.
wait 2.
brakes on.
ag1 on.
Print "Launching...".
stage.
lock throttle to 0.25.
lock steering to heading targheading by 25.
wait 6.
lock throttle to 1.
stage.
set pitch to 20.
wait 5.

//flies until target is <5000 m away.
until ((targ:distance)^2-(altitude-targetelev)^2)^0.5 < 5000 {
	print "CRUISE MODE   " at (5,5).
	print "DISTANCE TO TARGET: "+ targ:distance +" m   " at (5,6).
	print "ETA: "+ targ:distance/surfacespeed + " s   " at (5,7).
	lock targheading to targ:heading.

	//These lines determine if the missile is flying over water. If it is, the missile determins its height based on altitude, not radalt.
	set height to alt:radar.
	if alt:radar <0 {set height to altitude.}.
	if alt:radar > altitude {set height to altitude.}.

	set pitch to (pitchcoeff*height*(-1)) +110. //some more aggressiveness of pitch change. 
	if pitch <-25 {set pitch to -25.}. //Sets limits on max/min pitch.
	if pitch >89 {set pitch to 89.}.

	lock steering to heading targheading by pitch.
}.
//When missile is 5000m from target, it pitches up to divebomb the target.
lock throttle to 0.6.
until ((targ:distance)^2-(altitude-targetelev)^2)^0.5 < 2200 {
	print "*FINAL TARGETING*   " at (5,5).
	print "DISTANCE TO TARGET: "+ targ:distance +" m   " at (5,6).
	print "ETA: "+ targ:distance/surfacespeed + " s   " at (5,7).


	set pitch to 45.
	lock targheading to targ:heading.
	lock steering to heading targheading by pitch.
	if altitude > targetelev + 800 {set pitch to 0.
		lock targheading to targ:heading.
		lock steering to heading targheading by pitch.
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
		lock steering to heading targheading by pitch.
	}.
	if sin(pitch) > (targetelev-altitude)/targ:distance {
		set pitch to pitch - 1.5.
		lock targheading to targ:heading.
		lock steering to heading targheading by pitch.
	}.
	lock targheading to targ:heading.
	lock steering to heading targheading by pitch.
}.