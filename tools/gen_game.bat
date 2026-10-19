@echo off
rem Translates to C the game logic (type 16 scripts and type 11 lists) of all the .BIN files of a game.
rem   gen_game.bat [game_folder] [output_folder]
rem Default output: port\game\  (one .c file per archive + game_libs.c)
rem build.bat calls it automatically (output in build\gamesrc\) when port\game\ does not exist.
rem To translate a single archive: build\scr2c.exe lib FILE.BIN out.c
setlocal EnableDelayedExpansion
call "%~dp0env.bat"
set "ROOT=%~dp0.."
set "GAME=%~1"
if "%GAME%"=="" set "GAME=%ROOT%"
set "OUT=%~2"
if "%OUT%"=="" set "OUT=%ROOT%\port\game"
if not exist "%ROOT%\build" mkdir "%ROOT%\build"
if not exist "%OUT%" mkdir "%OUT%"
gcc -std=c11 -O2 -Wall -Wextra -o "%ROOT%\build\scr2c.exe" "%ROOT%\port\tools\scr2c.c" "%ROOT%\port\src\lb7.c" || exit /b 1
set "BINS="
for %%F in ("%GAME%\*.bin") do (
	set "N=%%~nF"
	"%ROOT%\build\scr2c.exe" lib "%%F" "%OUT%\!N!.c" || exit /b 1
	set "BINS=!BINS! "%%F""
)
"%ROOT%\build\scr2c.exe" registry "%OUT%\game_libs.c" %BINS% || exit /b 1
endlocal
