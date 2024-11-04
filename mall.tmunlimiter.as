/*
	Ada Mall v1.0 by brokenphilip
	
	v1.0 - Initial release
*/

const string VERSION = "1.0";

enum Going
{
	Shopping,
	ToEat,
	ShoppingAgain,
	ToTheRestroom,
	ToLeave,
}

namespace Global
{
	Going state = Going::Shopping;
	uint cps_reached = 0;

	Vec3 respawn_loc;
	Quat respawn_rot;
}

namespace Retailers
{
	array<GameBlock@ const> checkpoints;

	namespace Floor0
	{
		bool left_first = false;

		namespace Left
		{
			int index = -1;
			const array<string> names = {"$f00NewYorker", "$08fLC Waikiki", "$fffTommy $f03Hilfiger"};
			const array<Vec3> positions = {Vec3(896, 40, 480), Vec3(896, 40, 640), Vec3(896, 40, 800)};
			const GameBlock@ checkpoint;
		}

		namespace Right
		{
			int index = -1;
			const array<string> names = {"Springfield", "$f04sOliver", "Lacoste"};
			const array<Vec3> positions = {Vec3(544, 40, 448), Vec3(544, 40, 608), Vec3(544, 40, 768)};
			const GameBlock@ checkpoint;
		}
	}

	namespace Floor1
	{
		bool left_first = false;

		namespace Left
		{
			int index = -1;
			const array<string> names = {"$fffgame$fc0S", "$fd3Dexy Co", "$f00BebaKids", "$f00Ciciban"};
			const array<Vec3> positions = {Vec3(1056, 72, 448), Vec3(1056, 72, 608), Vec3(1056, 72, 768), Vec3(1056, 72, 928)};
			const GameBlock@ checkpoint;
		}

		namespace Right
		{
			int index = -1;
			const array<string> names = {"Nike", "Adidas", "Converse", "$0d9Deichmann"};
			const array<Vec3> positions = {Vec3(384, 72, 416), Vec3(384, 72, 576), Vec3(384, 72, 736), Vec3(384, 72, 896)};
			const GameBlock@ checkpoint;
		}
	}

	namespace Floor2
	{
		bool left_first = false;

		namespace Left
		{
			int index = -1;
			const array<string> names = {"SBB", "$e11A$3331", "$bf0Yettel", "$f24mts", "$de3in$444mobile", "$e12Laguna", "Vulkan"};
			const array<Vec3> positions = {Vec3(1216, 104, 416), Vec3(1216, 104, 576), Vec3(1216, 104, 736), Vec3(1216, 104, 896), Vec3(1216, 104, 1056), Vec3(1216, 104, 1216), Vec3(992, 104, 1216)};
			const GameBlock@ checkpoint;
		}

		namespace Right
		{
			int index = -1;
			const array<string> names = {"$f72mi", "iStyle", "$08fSamsung", "Tehnomanija", "$fc0Gigatron", "Swarovski", "Stefanovic"};
			const array<Vec3> positions = {Vec3(224, 104, 384), Vec3(224, 104, 544), Vec3(224, 104, 704), Vec3(224, 104, 864), Vec3(224, 104, 1024), Vec3(224, 104, 1184), Vec3(416, 104, 1216)};
			const GameBlock@ checkpoint;
		}

		namespace Center
		{
			int index = -1;
			const array<string> names = {"$fc0McDonalds", "$c13KFC", "$096Burrito Madre", "Walter", "$668Richard Gyros"};
			const array<Vec3> positions = {Vec3(832, 104, 1216), Vec3(768, 104, 1216), Vec3(704, 104, 1216), Vec3(640, 104, 1216), Vec3(576, 104, 1216)};
			const GameBlock@ checkpoint;
		}
	}
}

namespace Restrooms
{
	const array<Vec3> positions = {
		Vec3(832, 40, 384),
		Vec3(608, 40, 352),
		Vec3(640, 40, 960),
		Vec3(800, 40, 992),
		Vec3(992, 72, 352),
		Vec3(448, 72, 320),
		Vec3(576, 72, 1056),
		Vec3(864, 72, 1088),
		Vec3(1152, 104, 320),
		Vec3(288, 104, 288),
		Vec3(512, 104, 1184),
		Vec3(896, 104, 1184),
	};

	const array<CardinalDir> directions = {
		West,
		East,
		East,
		West,
		West,
		East,
		East,
		West,
		West,
		East,
		North,
		North,
	};

	const GameBlock@ checkpoint;
}

class LCG
{
	private uint seed = 0;
	private uint multiplier = 1103515245;
	private uint increment = 12345;
	
	LCG(uint default_seed)
	{
		seed = default_seed;
	}
	
	void reSeed()
	{
		seed = seed * multiplier + increment;
	}
	
	uint8 nextUInt8(uint8 max)
	{
		reSeed();
		return (seed >> 24) % max;
	}

	bool nextBool()
	{
		reSeed();
		return ((seed >> 24) % 2) == 0;
	}
}

uint xorshift32(uint x)
{
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return x;
}

void onStart(TrackManiaRace@ race)
{
	console.info("Ada Mall Script v" + VERSION + " by brokenphilip");

	if (race.isNetworkRace())
	{
		auto net_race = race.getNetworkRace();
		auto first_player = net_race.players[0];
		auto round_num = first_player.tmRoundNum;
		auto seed = xorshift32(round_num);
		auto lcg = LCG(seed);
		console.info("Seed: " + seed);

		Retailers::Floor0::Left::index = lcg.nextUInt8(3);
		Retailers::Floor0::Right::index = lcg.nextUInt8(3);
		Retailers::Floor1::Left::index = lcg.nextUInt8(4);
		Retailers::Floor1::Right::index = lcg.nextUInt8(4);
		Retailers::Floor2::Left::index = lcg.nextUInt8(7);
		Retailers::Floor2::Right::index = lcg.nextUInt8(7);
		Retailers::Floor2::Center::index = lcg.nextUInt8(5);
		Retailers::Floor0::left_first = lcg.nextBool();
		Retailers::Floor1::left_first = lcg.nextBool();
		Retailers::Floor2::left_first = lcg.nextBool();
	}
	else
	{
		Retailers::Floor0::Left::index = Math::rand(0, 2);
		Retailers::Floor0::Right::index = Math::rand(0, 2);
		Retailers::Floor1::Left::index = Math::rand(0, 3);
		Retailers::Floor1::Right::index = Math::rand(0, 3);
		Retailers::Floor2::Left::index = Math::rand(0, 6);
		Retailers::Floor2::Right::index = Math::rand(0, 6);
		Retailers::Floor2::Center::index = Math::rand(0, 4);
		Retailers::Floor0::left_first = Math::rand(0, 1) == 0;
		Retailers::Floor1::left_first = Math::rand(0, 1) == 0;
		Retailers::Floor2::left_first = Math::rand(0, 1) == 0;
	}

	int picker = 0;
	auto blocks = race.challenge.blocks;
	for (uint i = 0; i < blocks.length; i++)
	{
		auto block = blocks[i];

		if (block.waypointType == WaypointType::Checkpoint)
		{
			auto dir = block.direction;
			if (dir == South)
			{
				@Restrooms::checkpoint = block;
			}
			else
			{
				switch (picker)
				{
					case 0: @Retailers::Floor0::Left::checkpoint = block; break;
					case 1: @Retailers::Floor0::Right::checkpoint = block; break;
					case 2: @Retailers::Floor1::Left::checkpoint = block; break;
					case 3: @Retailers::Floor1::Right::checkpoint = block; break;
					case 4: @Retailers::Floor2::Left::checkpoint = block; break;
					case 5: @Retailers::Floor2::Right::checkpoint = block; break;
					case 6: @Retailers::Floor2::Center::checkpoint = block; break;
				}
				picker++;
			}
		}
	}
}

bool isNear(const Vec3&in car_loc, const Vec3&in target_pos, CardinalDir dir)
{
	auto loc = Vec3(car_loc);
	auto pos = Vec3(target_pos);
	pos.y += 4;

	if (dir == North)
	{
		pos.x += 16;
		pos.z += 16;
	}
	else if (dir == East)
	{
		pos.x -= 16;
		pos.z += 16;
	}
	else if (dir == South)
	{
		pos.x -= 16;
		pos.z -= 16;
	}
	else if (dir == West)
	{
		pos.x += 16;
		pos.z -= 16;
	}
	
	if (loc.distance(pos) <= 14)
	{
		return true;
	}
	return false;
}

void onTick(TrackManiaRace@ race)
{
	auto local = race.getPlayingPlayer();
	auto car = local.get_vehicleCar();
	auto dyna = car.get_hmsDyna();
	auto cur_state = dyna.currentState;
	auto loc = cur_state.location;
	auto rot = cur_state.rotation;
	string status = "";

	if (Global::state == Going::Shopping || Global::state == Going::ShoppingAgain)
	{
		Vec3 position;
		if (Retailers::Floor0::left_first)
		{
			position = Retailers::Floor0::Left::positions[Retailers::Floor0::Left::index];

			if (isNear(loc, position, West))
			{
				local.triggerWaypointBlock(Retailers::Floor0::Left::checkpoint);
			}
		}
		else
		{
			position = Retailers::Floor0::Right::positions[Retailers::Floor0::Right::index];

			if (isNear(loc, position, East))
			{
				local.triggerWaypointBlock(Retailers::Floor0::Right::checkpoint);
			}
		}

		if (Retailers::Floor1::left_first)
		{
			position = Retailers::Floor1::Left::positions[Retailers::Floor1::Left::index];

			if (isNear(loc, position, West))
			{
				local.triggerWaypointBlock(Retailers::Floor1::Left::checkpoint);
			}
		}
		else
		{
			position = Retailers::Floor1::Right::positions[Retailers::Floor1::Right::index];

			if (isNear(loc, position, East))
			{
				local.triggerWaypointBlock(Retailers::Floor1::Right::checkpoint);
			}
		}

		if (Retailers::Floor2::left_first)
		{
			auto index = Retailers::Floor2::Left::index;
			position = Retailers::Floor2::Left::positions[index];

			CardinalDir dir = West;
			if (index == 6)
			{
				dir = North;
			}
			if (isNear(loc, position, dir))
			{
				local.triggerWaypointBlock(Retailers::Floor2::Left::checkpoint);
			}
		}
		else
		{
			auto index = Retailers::Floor2::Right::index;
			position = Retailers::Floor2::Right::positions[index];

			CardinalDir dir = East;
			if (index == 6)
			{
				dir = North;
			}
			if (isNear(loc, position, dir))
			{
				local.triggerWaypointBlock(Retailers::Floor2::Right::checkpoint);
			}
		}

		string floor0_retailer = Retailers::Floor0::left_first? Retailers::Floor0::Left::names[Retailers::Floor0::Left::index] : Retailers::Floor0::Right::names[Retailers::Floor0::Right::index];
		string floor1_retailer = Retailers::Floor1::left_first? Retailers::Floor1::Left::names[Retailers::Floor1::Left::index] : Retailers::Floor1::Right::names[Retailers::Floor1::Right::index];
		string floor2_retailer = Retailers::Floor2::left_first? Retailers::Floor2::Left::names[Retailers::Floor2::Left::index] : Retailers::Floor2::Right::names[Retailers::Floor2::Right::index];
		status = "$sShop at $aaa" + floor0_retailer + "$g, $aaa" + floor1_retailer + "$g and $aaa" + floor2_retailer + "$g.";
	}
	else if (Global::state == Going::ToEat)
	{
		auto position = Retailers::Floor2::Center::positions[Retailers::Floor2::Center::index];

		if (isNear(loc, position, North))
		{
			Retailers::Floor0::left_first = !Retailers::Floor0::left_first;
			Retailers::Floor1::left_first = !Retailers::Floor1::left_first;
			Retailers::Floor2::left_first = !Retailers::Floor2::left_first;
			local.triggerWaypointBlock(Retailers::Floor2::Center::checkpoint);
		}

		status = "$sGetting hungry for some $aaa" + Retailers::Floor2::Center::names[Retailers::Floor2::Center::index] + "$g...";
	}
	else if (Global::state == Going::ToTheRestroom)
	{
		for (uint i = 0; i < Restrooms::positions.length; i++)
		{
			auto position = Restrooms::positions[i];

			if (isNear(loc, position, Restrooms::directions[i]))
			{
				local.triggerWaypointBlock(Restrooms::checkpoint);
				Global::respawn_loc = loc;
				Global::respawn_rot = rot;
				break;
			}
		}

		status = "$sUghhh... Find a $0afrestroom$g immediately!";
	}
	else if (Global::state == Going::ToLeave)
	{
		status = "$sShopping complete! Leave the mall.";
	}

	race.challenge.inGameClipGroup.clips[0].tracks[0].blocks[0].text_setText(status);
}

void onCheckPoint(TrackManiaRace@ race, GameBlock@ checkPointBlock)
{
	Global::cps_reached++;
	if (Global::cps_reached == 3)
	{
		Global::state = Going::ToEat;
	}
	else if (Global::cps_reached == 4)
	{
		Global::state = Going::ShoppingAgain;
	}
	else if (Global::cps_reached == 7)
	{
		Global::state = Going::ToTheRestroom;
	}
	else if (Global::cps_reached == 8)
	{
		Global::state = Going::ToLeave;
	}
}

bool onBindInputEvent(TrackManiaRace@ race, BindInputEvent@ inputEvent, uint eventTime)
{
    auto local = race.getPlayingPlayer();
    if (local.raceState == TrackManiaPlayer::RaceState::Running && inputEvent.getBindName() == "Respawn" && inputEvent.getEnabled() && Global::state == Going::ToLeave)
    {
		auto car = local.get_vehicleCar();
		auto dyna = car.get_hmsDyna();
		auto cur_state = dyna.currentState;
		cur_state.location = Global::respawn_loc;
		cur_state.rotation = Global::respawn_rot;
		cur_state.linearSpeed = Vec3(0, 0, 0);
		cur_state.addLinearSpeed = Vec3(0, 0, 0);
		cur_state.angularSpeed = Vec3(0, 0, 0);
		cur_state.force = Vec3(0, 0, 0);
		cur_state.torque = Vec3(0, 0, 0);
		cur_state.inverseInertiaTensor = Vec3(0, 0, 0);
		cur_state.notTweakedLinearSpeed = Vec3(0, 0, 0);
        return true;
    }

	return false;
}