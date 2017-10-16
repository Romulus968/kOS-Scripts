Clearscreen.

PRINT "Guidance routine activated.".
PRINT "Seeking Target".
PRINT "...".
PRINT "...".
PRINT "Target Found.".

When Target:Distance > 0 THEN {
	print "Target Distance: " + Target:distance at (0,15).
	Lock steering to Target:heading.
	Lock Throttle to 1.
	

}.

Wait until ship:altitude = 0.
