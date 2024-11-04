/*
    Chase v1.0 by brokenphilip

    v1.0 - Initial release
*/

/*
    *** CONSTANTS ***

    Feel free to modify them if you really need to, but ideally keep them as-is for consistency.
    NOTE: 1 second is 100 ticks
*/

// how many ticks do we need to be out of bounds/underwater for it to respawn us? (default: 50)
const uint MAX_OOB_TICKS = 50;

// how fast are we allowed to go before our respawn request gets cancelled? (default: 10.0f)
const uint MAX_RESPAWN_SPEED = 10;

// how many ticks before blues can start moving and capturing? (default: 500)
const uint PREGAME_TIME = 500;

// how many ticks do we need to wait before our respawn request gets accepted? (default: 1000)
const uint RESPAWN_WAIT_TIME = 1000;

// how long should rounds last, in ticks? (default: 30000)
const uint TIME_LIMIT = 30000;

/*
    *** CODE STARTS HERE - END OF USER MODIFICATIONS ***
    
    Do NOT modify anything below this line!
*/

// maximum unsigned 32bit integer (-1)
const uint UINT_MAX = 4294967295;

// enums suck
const uint BLUE_TEAM = 0;
const uint RED_TEAM = 1;
const uint NO_TEAM = 2;

// console logging prefix - to enable the console, add "/console" to your launch parameters
const string PREFIX = "[Chase 1.0] ";

// what environemnt are we in?
string _collection;

// challenge bounds, after which we're OOB
Vec3 _bounds;

// is chase mode enabled (only for network games, offline/test mode is separate)
bool _enabled = true;

// what team are we in?
uint _team = NO_TEAM;

// did we request a respawn this tick?
bool _respawn_requested = false;

// the tick at which we requested a respawn (-1 = no active respawn request)
uint _respawn_request_time = UINT_MAX;

// remember our special fin/cp
const GameBlock@ _special_fin;
const GameBlock@ _special_cp;

bool _got_cp = false;

// current tick
uint _tick = 0;

// how long have we been out of bounds/underwater?
uint _oob_ticks = 0;

bool isSpecialFinOrCP(const BlockSettings@ settings, bool cp)
{
    bool good = true;

    if (settings !is null)
    {
        if (settings.isInvisible())
        {
            console.info(PREFIX + "isSpecialFinOrCP: ...is invisible...");
        }
        else
        {
            console.warn(PREFIX + "isSpecialFinOrCP: ...is NOT invisible (!)...");
            good = false;
        }

        if (settings.isNonCollidable())
        {
            console.info(PREFIX + "isSpecialFinOrCP: ...is non-collidable...");
        }
        else
        {
            console.warn(PREFIX + "isSpecialFinOrCP: ...is collidable (!)...");
            good = false;
        }

        if (settings.getBlockTriggerActivationMethod() == BlockSettings::BlockTriggerActivationMethod::TriggerManually)
        {
            console.info(PREFIX + "isSpecialFinOrCP: ...is manually triggerable...");
        }
        else
        {
            console.warn(PREFIX + "isSpecialFinOrCP: ...is NOT manually triggerable (!)...");
            good = false;
        }

        if (cp)
        {
            if (settings.getRespawnCapability() == BlockSettings::RespawnCapability::ForceIsNonRespawnable)
            {
                console.info(PREFIX + "isSpecialFinOrCP: ...is non-respawnable...");
            }
            else
            {
                console.warn(PREFIX + "isSpecialFinOrCP: ...is respawnable (!)...");
                good = false;
            }
        }
    }
    else
    {
        console.warn(PREFIX + "isSpecialFinOrCP: ...does NOT have custom settings...");
        good = false;
    }

    return good;
}

void onStart(TrackManiaRace@ race)
{
    auto challenge = race.challenge;
    auto size = challenge.size;
    uint width = 32;
    if (challenge.get_challengeCollection() == "Coast")
    {
        width = 16;
    }
    if (challenge.get_challengeCollection() == "Island")
    {
        width = 64;
    }

    _bounds.x = size.x * width;
    _bounds.y = size.y * width;
    _bounds.z = size.z * width;

    for (uint i = 0; i < challenge.blocks.length; i++)
    {
        auto block = challenge.blocks[i];
        auto pos = block.coord;

        if (block.waypointType == WaypointType::StartFinish)
        {
            console.info(PREFIX + "onStart: -----");
            console.info(PREFIX + "onStart: Found StartFinish at (X, Y, Z) = (" + pos.x + ", " + pos.y + ", " + pos.z + ") - replace with Start!");
            console.info(PREFIX + "onStart: -----");
            _enabled = false;
        }
        
        else if (block.waypointType == WaypointType::Checkpoint)
        {
            console.info(PREFIX + "onStart: -----");
            console.info(PREFIX + "onStart: Found Checkpoint at (X, Y, Z) = (" + pos.x + ", " + pos.y + ", " + pos.z + ")...");

            if (_special_cp !is null)
            {
                console.warn(PREFIX + "onStart: ...a 'special' Checkpoint already exists (there should only be one CP, and it should be 'special') - remove this one!");
                _enabled = false;
            }
            else
            {
                if (!isSpecialFinOrCP(block.get_blockSettings(), true))
                {
                    console.warn(PREFIX + "onStart: ...is NOT 'special' - Make sure it is invisible, non-collidable, manually triggerable and non-respawnable!");
                    _enabled = false;
                }
                else
                {
                    console.info(PREFIX + "onStart: ...is 'special' - everything is good");
                    @_special_cp = @block;
                }
            }

            console.info(PREFIX + "onStart: -----");
        }

        else if (block.waypointType == WaypointType::Finish)
        {
            console.info(PREFIX + "onStart: -----");
            console.info(PREFIX + "onStart: Found Finish at (X, Y, Z) = (" + pos.x + ", " + pos.y + ", " + pos.z + ")...");

            if (!isSpecialFinOrCP(block.get_blockSettings(), true))
            {
                console.warn(PREFIX + "onStart: ...is NOT 'special'");
            }
            else
            {
                console.info(PREFIX + "onStart: ...is 'special'");

                if (_special_fin !is null)
                {
                    console.warn(PREFIX + "onStart: ...a 'special' Finish already exists - remove this one!");
                    _enabled = false;
                }
                else
                {
                    @_special_fin = @block;
                }
            }

            console.info(PREFIX + "onStart: -----");
        }
    }

    if (_special_cp is null)
    {
        console.error(PREFIX + "onStart: No 'special' checkpoints found - make sure you have exactly one Finish that is invisible, non-collidable, manually triggerable and non-respawnable!");
        _enabled = false;
    }

    if (_special_fin is null)
    {
        console.error(PREFIX + "onStart: No 'special' finishes found - make sure you have at least one Finish that is invisible, non-collidable, and manually triggerable!");
        _enabled = false;
    }

    auto is_net_race = race.isNetworkRace();
    if (is_net_race)
    {
        if (!_enabled)
        {
            console.error(PREFIX + "onStart: Chase is DISABLED, fix all of the above issues first!");
        }
        else
        {
            console.info(PREFIX + "onStart: Chase is enabled, make sure vehicle collisions are enabled and GLHF :3");
        }
    }
    else
    {
        console.info(PREFIX + "onStart: Not a network race - Chase is in offline/test mode");

        if (_enabled)
        {
            console.info(PREFIX + "onStart: This map is ready for Chase, just make sure vehicle collisions are enabled :3");
        }
        else
        {
            console.info(PREFIX + "onStart: This map is NOT ready for Chase - fix all of the above issues first!");
        }
    }

    console.info(PREFIX + "onStart: Current settings/constants are as follows:");
    
    console.info(PREFIX + "onStart: MAX_OOB_TICKS = " + MAX_OOB_TICKS);
    console.info(PREFIX + "onStart: MAX_RESPAWN_SPEED = " + MAX_RESPAWN_SPEED);
    console.info(PREFIX + "onStart: PREGAME_TIME = " + PREGAME_TIME);
    console.info(PREFIX + "onStart: RESPAWN_WAIT_TIME = " + RESPAWN_WAIT_TIME);
    console.info(PREFIX + "onStart: TIME_LIMIT = " + TIME_LIMIT);

    auto local = race.getPlayingPlayer();
    if (local.raceState == TrackManiaPlayer::RaceState::BeforeStart)
    {
        if (is_net_race)
        {
            _team = local.team;
        }
        else if (!is_net_race && _team == NO_TEAM)
        {
            // default to red team for offline mode
            _team = RED_TEAM;
        }

        if (_team == RED_TEAM)
        {
            console.info(PREFIX + "onStart: We're on red team");
        }
        else if (_team == BLUE_TEAM)
        {
            console.info(PREFIX + "onStart: We're on blue team");
        }
        else
        {
            console.warn(PREFIX + "onStart: We're not in any team, somehow?");
        }

        if (local.raceTime > 10 * PREGAME_TIME)
        {
            console.info(PREFIX + "onStart: Joined too late");
            local.giveUp();
        }
    }
    else
    {
        console.info(PREFIX + "onStart: We're not racing");
    }
}

void onTick(TrackManiaRace@ race)
{
    _tick++;

    bool is_net_race = race.isNetworkRace();
    if (is_net_race && !_enabled)
    {
        return;
    }

    auto local = race.getPlayingPlayer();
    if (local.raceState != TrackManiaPlayer::RaceState::Running)
    {
        return;
    }

    // if we activate cps too early (or in onStart), finishing will not work
    if (!_got_cp && _team == RED_TEAM && _tick > PREGAME_TIME)
    {
        local.triggerWaypointBlock(_special_cp);
        _got_cp = true;
    }

    auto car = local.get_vehicleCar();
    auto dyna = car.get_hmsDyna();
    auto state = dyna.currentState;
    auto loc = state.location;

    // we can go as high as we want
    if (car.isUnderWater || loc.x < 0 || loc.y < 0 || loc.z < 0 || loc.x > _bounds.x /*|| loc.y > _bounds.y*/ || loc.z > _bounds.z)
    {
        _oob_ticks--;
        if (_oob_ticks <= 0)
        {
            // we want cops to die too, to make things more interesting
            console.info(PREFIX + "onTick: We went out of bounds");
            local.giveUp();
        }
    }
    else
    {
        // we got back into bounds, reset our timer
        _oob_ticks = MAX_OOB_TICKS;
    }

    if (is_net_race && local.team != _team)
    {
        console.info(PREFIX + "onTick: Team switch detected when racing, this is not allowed");
        local.giveUp();
        return;
    }

    if (_respawn_requested)
    {
        _respawn_requested = false;
        _respawn_request_time = _tick;
        console.info(PREFIX + "onTick: Respawn request received at " + _tick);
    }
    
    if (_respawn_request_time != UINT_MAX)
    {
        // too fast! no respawn for you
        if (local.displaySpeed >= MAX_RESPAWN_SPEED)
        {
            _respawn_request_time = UINT_MAX;
            console.info(PREFIX + "onTick: Respawn cancelled, went too fast");
        }
        
        // enough time have passed, we can respawn
        else if (_tick >= _respawn_request_time + RESPAWN_WAIT_TIME)
        {
            _respawn_request_time = UINT_MAX;
            local.respawn();
            console.info(PREFIX + "onTick: Respawn request serviced at " + _tick);
        }
    }

    // time ran out, blue wins
    if (_tick >= TIME_LIMIT)
    {
        console.info(PREFIX + "onTick: Game over - timelimit ran out at " + _tick);
        if (_team == RED_TEAM)
        {
            local.giveUp();
        }
        else if (_team == BLUE_TEAM)
        {
            if (_special_cp !is null && _special_fin !is null)
            {
                // can't do both of these at once
                if (_got_cp)
                {
                    local.triggerWaypointBlock(_special_fin);
                }
                else
                {
                    local.triggerWaypointBlock(_special_cp);
                    _got_cp = true;
                }
            }
        }
        return;
    }
    
    // need to wait pregame, so we don't finish too early if server is empty
    if (is_net_race && _tick > PREGAME_TIME)
    {
        auto net_race = race.getNetworkRace();
        
        bool at_least_one_red_player = false;
        for (uint i = 0; i < net_race.players.length; i++)
        {
            auto player = net_race.players[i];
            if (player.raceState == TrackManiaPlayer::RaceState::Running || local.raceState == TrackManiaPlayer::RaceState::BeforeStart)
            {
                if (player.team == RED_TEAM)
                {
                    at_least_one_red_player = true;
                    break;
                }
            }
        }
        
        // we are racing, and there are no more red players, thus we are on blue team and should win instantly
        // if there were no blue players instead, red still has to finish before time runs out, otherwise it's a tie
        if (!at_least_one_red_player)
        {
            console.info(PREFIX + "onTick: Game over - no more red players");
            if (_special_cp !is null && _special_fin !is null)
            {
                // can't do both of these at once
                if (_got_cp)
                {
                    local.triggerWaypointBlock(_special_fin);
                }
                else
                {
                    local.triggerWaypointBlock(_special_cp);
                    _got_cp = true;
                }
            }
        }
    }
}

bool onBindInputEvent(TrackManiaRace@ race, BindInputEvent@ inputEvent, uint eventTime)
{
    bool is_net_race = race.isNetworkRace();
    if (is_net_race && !_enabled)
    {
        return false;
    }

    auto local = race.getPlayingPlayer();
    if (local.raceState != TrackManiaPlayer::RaceState::Running)
    {
        return false;
    }

    if (inputEvent.getBindName() == "Respawn")
    {
        if (inputEvent.getEnabled())
        {
            if (_tick <= PREGAME_TIME)
            {
                console.info(PREFIX + "onBindInputEvent: Respawning instantly at pregame");
                return false;
            }
            
            if (_team == RED_TEAM)
            {
                // if we already have a pending respawn request, undo it
                if (_respawn_request_time != UINT_MAX)
                {
                    _respawn_request_time = UINT_MAX;
                    console.info(PREFIX + "onBindInputEvent: Respawn request cancelled");
                }
                
                // if we're slow enough, request a respawn
                else if (local.displaySpeed < MAX_RESPAWN_SPEED)
                {
                    _respawn_requested = true;
                    console.info(PREFIX + "onBindInputEvent: Respawn request accepted");
                }
                
                // too fast!
                else
                {
                    console.info(PREFIX + "onBindInputEvent: Respawn request failed, we're going too fast");
                }
                
                // block respawn, we'll handle it ourselves
                return true;
            }
            else if (_team == BLUE_TEAM)
            {
                console.info(PREFIX + "onBindInputEvent: Respawning instantly as blue");
                return false;
            }
            else
            {
                console.warn(PREFIX + "onBindInputEvent: We're not in any team, somehow?");
            }
        }
    }

    else if (inputEvent.getBindName() == "Next score page " || inputEvent.getBindName() == "TMUnlimiter - Action Key 1")
    {
        if (!is_net_race && inputEvent.getEnabled())
        {
            console.info(PREFIX + "onBindInputEvent: Set offline/test team to blue");
            _team = BLUE_TEAM;
        }
    }
    else if (inputEvent.getBindName() == "Prev score page " || inputEvent.getBindName() == "TMUnlimiter - Action Key 2")
    {
        if (!is_net_race && inputEvent.getEnabled())
        {
            console.info(PREFIX + "onBindInputEvent: Set offline/test team to red");
            _team = RED_TEAM;
        }
    }

    return false;
}

void onVehicleInputEvent(TrackManiaRace@ race, VehicleInputEvent@ inputEvent, uint eventTime)
{
    if (_tick <= PREGAME_TIME && _team == BLUE_TEAM)
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

bool onVehicleCollision(TrackManiaRace@ race, PhysicalContact@ physicalContact)
{
    if (_tick <= PREGAME_TIME)
    {
        return false;
    }

    if (physicalContact.getContactObjectType() == PhysicalContact::ContactObjectType::Player)
    {
        auto player = physicalContact.getPlayer();
        auto local = race.getPlayingPlayer();
        
        // we're red and a blue caught us! game over
        if (_team == RED_TEAM && player.team == BLUE_TEAM)
        {
            console.info(PREFIX + "onVehicleCollision: We were caught by " + player.get_login());
            local.giveUp();
        }
        else if (_team == BLUE_TEAM && player.team == RED_TEAM)
        {
            console.info(PREFIX + "onVehicleCollision: We caught " + player.get_login());
        }
    }

    return false;
}