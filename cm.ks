//Missile by Peter Sharpe
//For KSP with the kOS mod

//YOU MUST MANUALLY TARGET YOUR TARGET BEFORE EXECUTING THIS PROGRAM.

//Editable Parameters
set explosionradius to 8.
set DrawVectors to True.

//Don't edit these unless you really understand what you're doing!
set iterations to 5.
set initialguess to 15.
set gravcorrection to 0.5.
set dragcorrection to 1.15.

//Line 26

Clearscreen.

//Do Targeting
print "Enemy heat signature acquired. Launching...".

//Launch Sequence
stage.
lock throttle to 1.
lock steering to up.
wait until alt:radar>100 or velocity:surface:mag>100.
print "Launch sequence completed. Now tracking target.".

//Set up Staging
when ship:maxthrust=0 then {stage. wait 0.01. If ship:maxthrust>0 {preserve.}.}.

//Set up outputs
print "Time to interception:" at (0,10).
print "Distance to Target:" at (0,12).
print "Steering Error:" at (0,14).

//Take steering control, lock it to "steeringangle"
set steeringangle to target:direction.
sas off.
rcs on.
lock steering to steeringangle.

//Arm the warhead to trigger with radius of "explosionradius" + 1 frame to decouple.
when t<explosionradius/50+0.05 or target:distance<50 then {stage.}.
print "Warhead armed. Initiating homing algorithm.".

//Homing Algorithm, infinite loop
set t to 10.
until 0
{
	set rpos to (0-1)*(target:Position).
	set rvel to (ship:velocity:surface-target:velocity:orbit).
	set gravfactor to gravcorrection.
	if target:loaded {set rvel to ship:velocity:surface-target:velocity:surface.}.
	if target:altitude>25000 {set rvel to ship:velocity:orbit-target:velocity:orbit.}.
	set amag to ship:maxthrust/(ship:mass*9.81).
	
	//Solve for t, where 0=at^4+bt^2+ct+d. First get coefficients
	set a to 0-((amag)^2)/4.
	set b to (rvel:sqrmagnitude).
	set c to 2*(rvel*rpos).
	set d to (rpos:sqrmagnitude).

	//Do a few Newton-Raphson iterations:
	set timeguesses to list().
	set timeguesses:add(initialguess).
	set position to 0.
	until position>=iterations
	{
	set timeguesses:add(timeguesses[position]-(a*timeguesses[position]^4+b*timeguesses[position]^2+c*timeguesses[position]+d)/(4*a*timeguesses[position]^3+2*b*timeguesses[position]+c)).
	set position to position+1.
	}.
	set initialguess to abs(timeguesses[iterations]).

	//Then calculate your desired direction. There is a correction for drag.
	set t to abs(timeguesses[iterations])/dragcorrection.
	if altitude>25000 {set t to abs(timeguesses[iterations]). set gravfactor to 0.}.
	print t at (22,10).
	print target:distance at (20,12).
	set steeringvector to v((0-1)*(rpos:x+(rvel:x)*t),(0-1)*(rpos:y+(rvel:y)*t),(0-1)*(rpos:z+(rvel:z)*t)).
	set correctedsteeringvector to (9.81*amag*steeringvector:normalized+9.81*gravfactor*(up:vector)).
	set steeringangle to correctedsteeringvector:direction.
	print vectorangle(steeringvector,ship:facing:vector) at (16,14).
	
	//Draw Vectors
	if DrawVectors=True {
		set Steerdraw TO VECDRAWARGS(v(0,0,0), 9.81*v((0-2)*(rpos:x+(rvel:x)*t)/(t^2),(0-2)*(rpos:y+(rvel:y)*t)/(t^2),(0-2)*(rpos:z+(rvel:z)*t)/(t^2)), rgb(0.5,1,0.5),"Algo. Output", 1, true ).
		set UPdraw TO VECDRAWARGS(9.81*v((0-2)*(rpos:x+(rvel:x)*t)/(t^2),(0-2)*(rpos:y+(rvel:y)*t)/(t^2),(0-2)*(rpos:z+(rvel:z)*t)/(t^2)), 9.81*gravfactor*(up:vector), rgb(0.5,0.5,1),"Grav. Corr.", 1, true ).
		set Vectordraw TO VECDRAWARGS(v(0,0,0), correctedsteeringvector:normalized, rgb(1,0.5,0.5),"Sum", 12.0, true ).
		wait 0.01.
	}.
}.