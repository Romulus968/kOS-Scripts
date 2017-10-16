clearscreen.
print "starting take off sequence.".


FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} 
	DO {
		PRINT "..." + countdown.
		WAIT 1. 
}

ag3 on.
ag4 on.
ag6 off.
sas on.
rcs on.
wait 1.
gear off.
lights on.


lock throttle to 1.
stage.

print "Engine spooling up".

FROM {local countdown is 15.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} 
	DO {
		PRINT "..." + countdown.
		WAIT 1. 
}

print "Activating rocket engines".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} 
	DO {
		PRINT "..." + countdown.
		WAIT 1.
}
lock throttle to 1.
ag1 on.

print "Prepare for separation".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} 
	DO {
		PRINT "..." + countdown.
		WAIT 1.
}
stage.
wait 1.
stage.

print "Flap and Elevator retract in:".
FROM {local countdown is 15.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} 
	DO {
		PRINT "..." + countdown.
		WAIT 1.
}
ag3 off.
ag4 off.