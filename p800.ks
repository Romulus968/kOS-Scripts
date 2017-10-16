clearscreen.
Print "CRUISE MISSILE v4.10 - Direct Kill Munition" at (0,0).
wait 1.
 
Print "Kill Vehicle: " + target:name at (0,2).
toggle ag4.
if alt:radar < -2 {set launchheight to 0. Print "Deployment Program: Underwater Launch" at (0,4). }.
if alt:radar > -2 {set launchheight to 10. Print "Deployment Program: Surface Launch" at (0,4).}.
set timer to 1.
set name to target.
set x to name:heading.
set limit to 2000.
lock v to (limit-groundspeed)/limit.
set height to 2000.
 
lock opp to abs(ship:altitude-name:altitude).
lock q to (opp/name:distance).
lock theta to arctan(q).
lock diveangle to ((0-theta)+3).
 
//when alt:radar < altitude then {
//set height to 700.
//}.
 
//when alt:radar > altitude then {
//set height to 200.
//}.
 
when alt:radar < height then {
lock pitch to (height / alt:radar)^2.
lock y to 2 + pitch.
Preserve.
}.
 
when alt:radar > height then {
lock pitch to (alt:radar / height)^2.
lock y to -2-pitch.
Preserve.
}.
 
When timer > 0 then {
//Print "Pitch "+ round(pitch,1) at (0,2).
//Print "Y-Value "+ round(y,1) at (0,4).
Print "Distance to Target: "+round(name:distance/1000,1) + " km   " at (0,8).
Print "Radar Altitude: "+ round(alt:radar) + " meters   " at (0,10).
Print "Velocity: "+ round(groundspeed) + " m/s   " + "/ Mach " + round(groundspeed/340,3) at (0,12).
Print "Target Acquired: " + name:name at (0,6).
Preserve.
}.
 
wait 1.
lock steering to heading(x,90).
wait 4.
 
set fire to 0.
Print " MISSILE ARMED... READY FOR LAUNCH" at (0,20).
Print "         PRESS *R* TO FIRE        " at (0,22).
on rcs set fire to 1.
wait until fire > 0.
lock throttle to 1.
wait 1.
 
toggle lights.
wait 0.1.
toggle lights.
sas off.
stage.
lock steering to heading(x,90).
Print "           MISSILE FIRED          " at (0,20).
Print "                                  " at (0,22).
wait until alt:radar > launchheight.
toggle ag9.
lock steering to heading(x,25).
wait 1.
toggle ag7.
stage.
wait 15.
sas off.
lock steering to heading (x,y).
wait 2.
lock throttle to v.
wait until stage:solidfuel < 0.1.
toggle abort.
 
wait until name:distance < 10000.
lock steering to heading (x,y).
if groundspeed > 280 {set limit to 400.}.
set height to 700.
wait until name:distance < 5000.
set height to 300.
lock throttle to v.
 
//if surfacespeed > 280 {set limit to 400.}.
 
wait until name:distance < 1500.
Print "Theta: " + theta at (0,14).
Print "DiveAngle: " + round(diveangle) at (0,16).
lock steering to heading (x,diveangle).
lock throttle to 0.8.
wait until name:distance < 1200.
lock steering to name:direction.
lock throttle to 1.
wait until name:distance < 20.
toggle ag10.
 
wait until alt:radar < 10.