# Upsy Daisy – unofficial SDL2 port of the 7th Level engine

*Hot Shots: Upsy Daisy* (and its second game, *Inside Outwords*) is one of Disney's Hot Shots
games of the *Topsy Turvy* series (7th Level, 1996), a Windows 3.1 game built on the **7th Level
Runtime Player 1.2**. This repository builds a native 64-bit Windows version of it with
**[7thlevel-engine](https://github.com/LuC-iTA-GHorg/7thlevel-engine)**, a from-scratch
reimplementation of that engine in C11 + SDL2 shared by all the 7th Level games, included here as
a git submodule (`engine\`). No emulator, no virtual machine.

> **You need your own copy of the original game.** This repository contains **no game data, no
> original code and no original assets**. See [NOTICE.md](NOTICE.md).

## Status

The engine implements every feature of the original 7th Level Runtime Player.

- Upsy Daisy and Inside Outwords can be played from start to end: intro, menu, options, scores,
  both games, exit sequence and credits.
- Screens are compared automatically with the original game: menus, intro, games and exit
  sequence match within about 1–2 % of the pixels; scene timings of the intro match within 1 s.
- Known differences: text rendering (fonts, antialiasing), music (a SoundFont synthesizer instead
  of the Windows MIDI synth), random scenes (different random sequence).

## Requirements

- Windows 10 or 11, 64-bit, and git.
- The files of the original CD: `TUPSYPC.BIN`, `TOPSY.BIN`, `TOPSMAIN.BIN`, `TOPSOPN1.BIN`,
  `TOPSOPN2.BIN`, `TOPSUPSY.BIN`, `TOPSWORD.BIN`, `TOPSFINA.BIN`, `TOPSCRED.BIN`, `TOPSSING.BIN`
  and, for the icon, the cursors and the settings section, `TOPSY.EXE`. The `.DLL` files of the CD
  are not used.
- About 120 MB of free space for the portable build tools (downloaded on request).

## Building

```bat
git clone --recursive https://github.com/LuC-iTA-GHorg/upsy-daisy-7thlevel-port.git
cd upsy-daisy-7thlevel-port
rem copy the files of your CD here (or set GAME_DATA to their folder), then:
build.bat
```

The first time, the engine's `tools\setup_tools.bat build` shows what it is going to download
(w64devkit GCC, SDL2, the GeneralUser GS SoundFont), asks for confirmation and checks the SHA-256
of every file. The scripts of the game are translated to C from your `.BIN` files into
`build\gamesrc\` and compiled with the engine: do not publish those generated files.

Output: `build\upsy.exe` and `build\upsy_launcher.exe`. `engine\tools\make_dist.bat` (with
`GAME_ROOT` set to this folder) collects what is needed to play in `dist\`.

If you cloned without `--recursive`: `git submodule update --init`.

## Running

Start `build\upsy_launcher.exe` (settings, then "Start"), or `build\upsy.exe`. Options, keys and
the `upsy.ini` settings are described in the engine's README.

## History

Until October 2026 this repository contained the engine itself, written for Upsy Daisy. The
engine now lives in `7thlevel-engine` and supports the other 7th Level games too; the behaviour
for Upsy Daisy is unchanged (all the test scenes give the same screens, pixel for pixel).

## License

No license has been chosen yet for the code of this project: until then, all rights are reserved
by its author. The game, its names and its data belong to their respective owners.
