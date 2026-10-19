@echo off
rem Prepares dist\ with everything needed to play, except the files of the original game:
rem   upsy.exe, upsy_launcher.exe, SDL2.dll, GeneralUser-GS.sf2 (if present), sample upsy.ini.
rem Then copy the .BIN files of the game (TUPSYPC.BIN, TOPSY.BIN, ...) into the same folder and
rem start upsy_launcher.exe. Requires build\ (build.bat).
setlocal
set "ROOT=%~dp0.."
set "OUT=%ROOT%\dist"
if not exist "%ROOT%\build\upsy.exe" (
	echo build\upsy.exe not found: run build.bat first
	exit /b 1
)
if not exist "%OUT%" mkdir "%OUT%"
copy /y "%ROOT%\build\upsy.exe" "%OUT%\" >nul
copy /y "%ROOT%\build\upsy_launcher.exe" "%OUT%\" >nul
copy /y "%ROOT%\build\SDL2.dll" "%OUT%\" >nul
if exist "%ROOT%\tools\soundfont\GeneralUser-GS.sf2" (
	copy /y "%ROOT%\tools\soundfont\GeneralUser-GS.sf2" "%OUT%\" >nul
) else (
	echo WARNING: no SoundFont in tools\soundfont\: the music will be silent
)
copy /y "%ROOT%\port\upsy.ini.example" "%OUT%\upsy.ini" >nul
if exist "%OUT%\LEGGIMI.txt" del "%OUT%\LEGGIMI.txt"
(
	echo Unofficial SDL2 port of the 7th Level engine for Hot Shots: Upsy Daisy ^(1996^).
	echo Not affiliated with or endorsed by Disney or 7th Level. No game data is included.
	echo.
	echo Copy into this folder the files of your original game CD: *.BIN ^(TUPSYPC.BIN, TOPSY.BIN,
	echo TOPSUPSY.BIN, ...^). Then start upsy_launcher.exe, choose the settings and start the game
	echo ^(or run upsy.exe directly: it reads upsy.ini^).
	echo.
	echo Required files: upsy.exe, SDL2.dll, the .BIN files, GeneralUser-GS.sf2 ^(music^).
	echo SDL2: zlib license. SoundFont: GeneralUser GS by S. Christian Collins, own license.
) > "%OUT%\README.txt"
echo Ready: %OUT%   ^(add the .BIN files of the original game^)
exit /b 0
