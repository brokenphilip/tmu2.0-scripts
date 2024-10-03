/*
	Flying Respawn v1.0 by brokenphilip

	v1.0 - Initial release
*/

/*
    *** CONSTANTS ***

    Feel free to modify them if you really need to, but ideally keep them as-is for consistency.
    NOTE: 1 second is 100 ticks
*/

// Flying respawn duration (default = 1.5s / 150 ticks)
const uint DURATION = 150;

/*
    *** CODE STARTS HERE - END OF USER MODIFICATIONS ***
    
    Do NOT modify anything below this line!
*/

// are we currently in a flying respawn?
bool _is_respawning = false;

uint _tick = 0;
uint _respawn_tick = 0;

//array<HmsStateDyna> current;
array<Quat> cur_rotation = array<Quat>();
array<Vec3> cur_location = array<Vec3>();
array<Vec3> cur_linearSpeed = array<Vec3>();
array<Vec3> cur_addLinearSpeed = array<Vec3>();
array<Vec3> cur_angularSpeed = array<Vec3>();
array<Vec3> cur_force = array<Vec3>();
array<Vec3> cur_torque = array<Vec3>();
array<Vec3> cur_inverseInertiaTensor = array<Vec3>();
array<Vec3> cur_notTweakedLinearSpeed = array<Vec3>();

//array<HmsStateDyna> saved;
array<Quat> sav_rotation = array<Quat>();
array<Vec3> sav_location = array<Vec3>();
array<Vec3> sav_linearSpeed = array<Vec3>();
array<Vec3> sav_addLinearSpeed = array<Vec3>();
array<Vec3> sav_angularSpeed = array<Vec3>();
array<Vec3> sav_force = array<Vec3>();
array<Vec3> sav_torque = array<Vec3>();
array<Vec3> sav_inverseInertiaTensor = array<Vec3>();
array<Vec3> sav_notTweakedLinearSpeed = array<Vec3>();

void onTick(TrackManiaRace@ race)
{
	_tick++;

    auto local = race.getPlayingPlayer();
    if (local.raceState != TrackManiaPlayer::RaceState::Running)
    {
        return;
    }

	auto car = local.get_vehicleCar();
	auto dyna = car.get_hmsDyna();
	
	if (_is_respawning)
	{
		if (_respawn_tick + DURATION < _tick)
		{
			_respawn_tick = _tick;
		}

		if (_tick - _respawn_tick < 150)
		{
			dyna.currentState.rotation = sav_rotation[_tick - _respawn_tick];
			dyna.currentState.location = sav_location[_tick - _respawn_tick];
			dyna.currentState.linearSpeed = sav_linearSpeed[_tick - _respawn_tick];
			dyna.currentState.addLinearSpeed = sav_addLinearSpeed[_tick - _respawn_tick];
			dyna.currentState.angularSpeed = sav_angularSpeed[_tick - _respawn_tick];
			dyna.currentState.force = sav_force[_tick - _respawn_tick];
			dyna.currentState.torque = sav_torque[_tick - _respawn_tick];
			dyna.currentState.inverseInertiaTensor = sav_inverseInertiaTensor[_tick - _respawn_tick];
			dyna.currentState.notTweakedLinearSpeed = sav_notTweakedLinearSpeed[_tick - _respawn_tick];
		}
		else
		{
			_is_respawning = false;
		}
	}

	auto state = dyna.currentState;

/*
	auto length = cur_rotation.length;
	if (length == 0)
	{
		cur_rotation.add(state.rotation);
		cur_location.add(state.location);
		cur_linearSpeed.add(state.linearSpeed);
		cur_addLinearSpeed.add(state.addLinearSpeed);
		cur_angularSpeed.add(state.angularSpeed);
		cur_force.add(state.force);
		cur_torque.add(state.torque);
		cur_inverseInertiaTensor.add(state.inverseInertiaTensor);
		cur_notTweakedLinearSpeed.add(state.notTweakedLinearSpeed);
	}
	else
	{
		cur_rotation.insertAt(0, state.rotation);
		cur_location.insertAt(0, state.location);
		cur_linearSpeed.insertAt(0, state.linearSpeed);
		cur_addLinearSpeed.insertAt(0, state.addLinearSpeed);
		cur_angularSpeed.insertAt(0, state.angularSpeed);
		cur_force.insertAt(0, state.force);
		cur_torque.insertAt(0, state.torque);
		cur_inverseInertiaTensor.insertAt(0, state.inverseInertiaTensor);
		cur_notTweakedLinearSpeed.insertAt(0, state.notTweakedLinearSpeed);
	}
	*/
		cur_rotation.add(state.rotation);
		cur_location.add(state.location);
		cur_linearSpeed.add(state.linearSpeed);
		cur_addLinearSpeed.add(state.addLinearSpeed);
		cur_angularSpeed.add(state.angularSpeed);
		cur_force.add(state.force);
		cur_torque.add(state.torque);
		cur_inverseInertiaTensor.add(state.inverseInertiaTensor);
		cur_notTweakedLinearSpeed.add(state.notTweakedLinearSpeed);


	auto length = cur_rotation.length;
	if (length > DURATION)
	{
		cur_rotation.removeAt(0, length - DURATION);
		cur_location.removeAt(0, length - DURATION);
		cur_linearSpeed.removeAt(0, length - DURATION);
		cur_addLinearSpeed.removeAt(0, length - DURATION);
		cur_angularSpeed.removeAt(0, length - DURATION);
		cur_force.removeAt(0, length - DURATION);
		cur_torque.removeAt(0, length - DURATION);
		cur_inverseInertiaTensor.removeAt(0, length - DURATION);
		cur_notTweakedLinearSpeed.removeAt(0, length - DURATION);
	}
}

void onCheckPoint(TrackManiaRace@ race, GameBlock@ checkPointBlock)
{
	sav_rotation = cur_rotation;
	sav_location = cur_location;
	sav_linearSpeed = cur_linearSpeed;
	sav_addLinearSpeed = cur_addLinearSpeed;
	sav_angularSpeed = cur_angularSpeed;
	sav_force = cur_force;
	sav_torque = cur_torque;
	sav_inverseInertiaTensor = cur_inverseInertiaTensor;
	sav_notTweakedLinearSpeed = cur_notTweakedLinearSpeed;
}

bool onBindInputEvent(TrackManiaRace@ race, BindInputEvent@ inputEvent, uint eventTime)
{
	// only check inputs if the race has begun
    auto local = race.getPlayingPlayer();
    if (local.raceState != TrackManiaPlayer::RaceState::Running)
    {
        return false;
    }

	// [OnBindInputEvent] Exception catched - "Input event is not a button type"
    if (inputEvent.isAnalogType())
    {
        return false;
    }

    if (inputEvent.getEnabled())
    {
		if (inputEvent.getBindName() == "Respawn")
		{
			if (!_is_respawning)
			{
				_is_respawning = true;
				return true;
			}
			else
			{
				_is_respawning = false;
			}
		}
	}

	return false;
}

void onVehicleInputEvent(TrackManiaRace@ race, VehicleInputEvent@ inputEvent, uint eventTime)
{
	if (_is_respawning)
	{
		if (inputEvent.isAnalogType())
		{
			inputEvent.setAnalog(0.0f);
		}
		else
		{
			inputEvent.setEnabled(false);
		}
	}
}