PRINT "Fuck em' up chuck!".
wait 1.
lock throttle to 1.
stage.

if ship:altitude < 65000 then {
lock steering to heading(90,90).
}

when ship:altitude > 70000 then {
	lock steering to target:heading.
}

