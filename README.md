# TMU2.0 Scripts
This repository contains various track scripts that I've made for [Unlimiter 2.0](https://unlimiter.net/), a mod for TrackMania (Nations/United) Forever.

Script changelogs are shown in their respective files as comments on top.

## Car Switch v1.0
Lets the player change their vehicle every 0.25 seconds (in order of the in-game vehicle skin painter) when they press a key:
- Next vehicle: `TMU Action Key 1` or `Next score page` (default: <kbd>End</kbd>)
- Previous vehicle: `TMU Action Key 2` or `Prev score page` (default: <kbd>Home</kbd>)

## Car Switch Lap v1.0
Changes the player's driven vehicle (in order of the in-game vehicle skin painter) each time a lap is completed.

## Chase v1.0
Adds a custom gamemode intended to be played online by 2 or more players:
- Red team's goal is to make it to the end of the track
- Blue team's goal is to "catch" all red players by crashing into them
- If at least one red player crosses the finish, red team wins
- If there are no more red players, red team loses:
  - If there is at least one blue player left, blue team wins
  - If there are no blue players left, the round is drawn

A round of Chase goes like this:
- Once the round starts, there is a 5 second grace period (dictated by the `PREGAME_TIME` global constant) - during this time:
  - Anyone can respawn as many times as they want
  - Blue players cannot move nor capture players
- After the grace period ends, blue players can move and start capturing players, and red players lose their ability to instantly respawn
- While blue players can respawn whenever, red players have to "request" a respawn by hitting their respawn key (default: <kbd>Enter</kbd>), and they also:
  - Must wait 10 seconds (dictated by the `RESPAWN_WAIT_TIME` global constant) for their respawn to kick in
  - Must NOT move faster than 10km/h (dictated by the `MAX_RESPAWN_SPEED` global constant), otherwise their respawn request gets canceled
  - May cancel their respawn by hitting their respawn key again
- 5 minute time limit (dictated by the `TIME_LIMIT` global constant) - once it runs out, red team loses
- Going underwater (does not apply to TMO vehicles) or going out-of-bounds (apart from the upper height limit) for longer than 0.5 seconds (dictated by the `MAX_OOB_TICKS` global constant) will force the player to retire for that round, regardless of their team

In order for your track to be compatible with Chase, it must have:
- No `StartFinish` blocks (ie. must not be multi-lap)
- A `Start` and a `Finish` block (you can add as many as you'd like)
- A single "special" `Checkpoint` block - one that is:
  - invisible
  - non-collidable
  - manually triggerable
  - non-respawnable
- A single "special" `Finish` block - one that is:
  - invisible
  - non-collidable
  - manually triggerable
- Collisions enabled

Additionally, your server also must have:
- `game_mode` set to `2` (ie. Team mode)
- `team_maxpoints` set to `1`

This gamemode is yet to be fully playtested, and a lot of design decision (mostly related to balancing) are not final - be sure to keep track of this readme and/or the changelogs to stay up-to-date.

## Flying Respawn v1.0
Aims to replicate flying checkpoint respawns from Trackmania (2020). Needs more testing.

## ScaredyPoint v1.0
Makes the first checkpoint it finds "flee" from the player, as seen on my TMNF track: [[2.0] scaredypoint](https://tmnf.exchange/trackshow/11836842). Probably needs more work, as it doesn't properly calculate the forward vector from the quaternion (pitch and yaw seem to be fine, but roll might not be?).