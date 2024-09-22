// ScaredyFin 1.0 by brokenphilip

int _tick;
uint _fin;

bool _dist_set = false;
float _dist;

void onStart(TrackManiaRace@ race)
{
    _tick = 0;
    _dist_set = false;

    for (uint i = 0; i < race.challenge.blocks.length; i++)
    {
        auto block = race.challenge.blocks[i];

        if (block.waypointType == WaypointType::Checkpoint)
        {
            _fin = i;
            break;
        }
    }
}

void onTick(TrackManiaRace@ race)
{
    _tick++;

    if (_tick > 200)
    {
        if (_dist_set && _dist < 10)
        {
            return;
        }

        auto state = race.challenge.blocks[_fin].getBlockState();

        auto local = race.getPlayingPlayer();
        auto car = local.get_vehicleCar();
        auto dyna = car.get_hmsDyna();
        auto pos = dyna.currentState.location;

        if (!_dist_set)
        {
            auto b_pos = state.getPosition();
            _dist = pos.distance(b_pos);
            _dist_set = true;
        }

        auto rot = dyna.currentState.rotation;
        
        Vec3 fwd_vec;
        fwd_vec.x = 2 * (rot.x * rot.z - rot.w * rot.y);
        fwd_vec.y = 2 * (rot.y * rot.z + rot.w * rot.x);
        fwd_vec.z = 1 - 2 * (rot.x * rot.x + rot.y * rot.y);

        fwd_vec.x *= -1;
        fwd_vec.y *= -1;

        fwd_vec *= _dist;
        pos += fwd_vec;

        pos.y -= 2;
        
        state.setRotation(rot);
        state.setPosition(pos);

        float step = local.displaySpeed * 0.000025;

        _dist -= step;
    }
}