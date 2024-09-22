// Car Switch 1.0 by brokenphilip

// in order of the Painter
const array<string> gCars = {"American", "Rally", "SnowCar", "SportCar", "CoastCar", "BayCar", "StadiumCar"};
int gCar = 0;
uint gLastSwitchTime = 0;

void onStart(TrackManiaRace@ race)
{
    // reset switch time
    gLastSwitchTime = 0;

    // reset current car
    for (uint i = 0; i < gCars.length; i++)
    {
        if (race.getPlayingPlayer().getCurrentVehicleId() == gCars[i])
        {
            gCar = i;
            return;
        }
    }
}

bool onBindInputEvent(TrackManiaRace@ race, BindInputEvent@ inputEvent, uint eventTime)
{
    // only switch every 250ms
    if (gLastSwitchTime + 250 > eventTime)
    {
        return false;
    }

    // only switch while racing (not before or after)
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
        // yes there's a space in these lol
		if (inputEvent.getBindName() == "Next score page " || inputEvent.getBindName() == "TMUnlimiter - Action Key 1")
		{
            // switch to next car in list
            gCar++;
			if (gCar > 6)
			{
				gCar = 0;
			}

            gLastSwitchTime = eventTime;
            local.transform(gCars[gCar]);

            // Input event is not cancelable
			//return true;
		}
		else if (inputEvent.getBindName() == "Prev score page " || inputEvent.getBindName() == "TMUnlimiter - Action Key 2")
		{
			// switch to previous car in list
			gCar--;
			if (gCar < 0)
			{
				gCar = 6;
			}

            gLastSwitchTime = eventTime;
            local.transform(gCars[gCar]);

            // Input event is not cancelable
			//return true;
		}
    }

    return false;
}