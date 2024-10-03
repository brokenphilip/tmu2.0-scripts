/*
    Car Switch Lap v1.0 by brokenphilip

    v1.0 - Initial release
*/

const array<string> gCars = {"American", "Rally", "SnowCar", "SportCar", "CoastCar", "BayCar", "StadiumCar"};
int gCar = 0;
uint gLap = 0;

// normally i'd use onLap here instead of checking the current lap in onTick
// unfortunately, switching cars in onLap tends to frequently crash the game
// whereas doing it this way works perfectly fine lol /shrug
void onTick(TrackManiaRace@ race)
{
    auto local = race.getPlayingPlayer();

    // did we finish a lap?
    auto curlap = local.curLap;
    if (gLap != curlap)
    {
        gLap = curlap;

        // change to next car
        gCar++;
        if (gCar > 6)
        {
            gCar = 0;
        }
        local.transform(gCars[gCar]);
    }
}

void onStart(TrackManiaRace@ race)
{
    auto local = race.getPlayingPlayer();
    gLap = local.curLap;

    // find our initial car index
    for (uint i = 0; i < gCars.length; i++)
    {
        if (local.getCurrentVehicleId() == gCars[i])
        {
            gCar = i;
            return;
        }
    }
}