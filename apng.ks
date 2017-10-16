clearscreen.
stage.

// wait so execution continues on the next frame
// when the vessel reference is already updated
wait 0.01.

// hardcoded target :/
set targetVessel to vessel("Aeris 3A").

print "Launching".
sas on.
lock throttle to 1.

set targetDirection to targetVessel:direction.
set newSteering to R(targetDirection:pitch, targetDirection:yaw, 180).

print "Tracking".
sas off.
lock steering to newSteering.
set initialRoll to ship:facing:roll.

set N to 4.
set kp to 0.02.

set oldDirection to targetVessel:direction.
set lastTime to time:seconds - 0.01.
set gForce to 9.81.     // kerbin g
set accGravityXYZ to ship:up:vector * gForce.

// infinite loop
until false
{
    set deltaTime to time:seconds - lastTime.
    set lastTime to time:seconds.
    set targetDir to targetVessel:direction.
    
    // changes in the direction of the target (in radians)
    set deltaPitch to (arcsin(sin(targetDir:pitch - oldDirection:pitch)) * 3.14159265358979) / 180.
    set deltaYaw to (arcsin(sin(targetDir:yaw - oldDirection:yaw)) * 3.14159265358979) / 180.
    set oldDirection to targetDir.

    // rate of change of the direction
    set pitchRate to deltaPitch / deltaTime.
    set yawRate to deltaYaw / deltaTime.
    
    // speed to the target
    set speedVector to ship:velocity:surface - targetVessel:velocity:surface.
    set speedToTarget to speedVector:mag.

    // acceleration of the corrections
    set accPitch to (N * pitchRate * speedToTarget).
    set accYaw to (N * yawRate * speedToTarget).
    
    // pitch acceleration in the XYZ frame
    set pitchNormal to targetDir:pitch + 90.
    set accPitchXYZ to V(0, -sin(pitchNormal), cos(pitchNormal)) * accPitch.
    
    // yaw acceleration in the XYZ frame
    set yawNormal to targetDir:yaw + 90.
    set accYawXYZ to V(sin(yawNormal), 0, cos(yawNormal)) * accYaw.
    
    // total accelerations
    set accCorrectionXYZ to accPitchXYZ + accYawXYZ.
    // compensate the gravity acceleration (the "A" in APN)
    set accCorrectionXYZ to accCorrectionXYZ + accGravityXYZ.
    
    set accErrorXYZ to kp * accCorrectionXYZ.
    
    // calculate the steering direction from the target direction
    // and the correction accelerations
    // TODO: limit maximum acceleration
    set dirTargetXYZ to targetDir:vector:normalized.
    set dirSteeringXYZ to dirTargetXYZ + accErrorXYZ.
    set dirSteeringXYZ to dirSteeringXYZ:normalized.

    // update the steering direction
    set newSteering to R(0,0,initialRoll) + dirSteeringXYZ.
    
    wait 0.01.
}