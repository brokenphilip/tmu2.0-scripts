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
*todo*

## Flying Respawn v1.0
Aims to replicate flying checkpoint respawns from Trackmania (2020). Needs more testing.

## ScaredyPoint v1.0
Makes the first checkpoint it finds "flee" from the player, as seen on my TMNF track: [[2.0] scaredypoint](https://tmnf.exchange/trackshow/11836842). Probably needs more work, as it doesn't properly calculate the forward vector from the quaternion (pitch and yaw seem to be fine, but roll might not be?).