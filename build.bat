@echo off
rem Builds the SDL2 port (build\upsy.exe, build\upsy_launcher.exe) and the tools (build\lb7tool.exe)
rem with the portable GCC in tools\w64devkit and SDL2 in tools\SDL2. Nothing is installed.
rem   build.bat           optimized build
rem   build.bat debug     debug build (-O0 -g)
rem   build.bat clean     deletes build\
rem Game logic: the scripts of the original .BIN files are translated to C by scr2c. If
rem port\game\ exists (private development tree) it is used as is; otherwise the C files are
rem generated into build\gamesrc\ from the game files of YOUR copy of the game, found in the
rem folder given by the UPSY_DATA environment variable or, by default, in the project root.
setlocal
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
rem On a new PC the portable tools are missing: setup_tools downloads them (asks for confirmation)
if /i not "%~1"=="clean" if not exist "%ROOT%\tools\w64devkit\bin\gcc.exe" set "NEED_TOOLS=1"
if /i not "%~1"=="clean" if not exist "%ROOT%\tools\SDL2\x86_64-w64-mingw32\bin\SDL2.dll" set "NEED_TOOLS=1"
if defined NEED_TOOLS (
	echo Build tools missing in tools\: running tools\setup_tools.bat build
	call "%ROOT%\tools\setup_tools.bat" build || goto :error
)
call "%ROOT%\tools\env.bat"
set "OUT=%ROOT%\build"

if /i "%~1"=="clean" (
	if exist "%OUT%" rmdir /s /q "%OUT%"
	echo build\ deleted
	exit /b 0
)

set "CFLAGS=-std=c11 -O2 -Wall -Wextra"
if /i "%~1"=="debug" set "CFLAGS=-std=c11 -O0 -g -Wall -Wextra"
if not exist "%OUT%" mkdir "%OUT%"
set "DATA=%UPSY_DATA%"
if "%DATA%"=="" set "DATA=%ROOT%"

echo [1/7] lb7tool
gcc %CFLAGS% -o "%OUT%\lb7tool.exe" "%ROOT%\src\tools\lb7tool.c" "%ROOT%\port\src\lb7.c" || goto :error

echo [2/7] game logic (scripts of the .BIN files translated to C)
set "GAMESRC=%ROOT%\port\game"
if exist "%GAMESRC%\game_libs.c" goto :gamesrc_ok
set "GAMESRC=%OUT%\gamesrc"
if not exist "%DATA%\TOPSY.BIN" (
	echo.
	echo The original game files were not found in "%DATA%".
	echo Copy the files of your Hot Shots: Upsy Daisy CD ^(*.BIN, *.EXE, *.DLL^) into the project
	echo root, or set UPSY_DATA to the folder that contains them, then run build.bat again.
	goto :error
)
if exist "%GAMESRC%\game_libs.c" goto :gamesrc_ok
call "%ROOT%\tools\gen_game.bat" "%DATA%" "%GAMESRC%" >"%OUT%\gen_game.log" 2>&1 || (
	echo scr2c failed: see build\gen_game.log
	goto :error
)
:gamesrc_ok
echo       from %GAMESRC%

rem Windows resources (port\res\upsy.rc): version info, manifest and, if available, the icon of
rem the original TOPSY.EXE (extracted by lb7tool at build time, never stored in the repository)
set "RCDEF="
if exist "%OUT%\upsy.ico" del "%OUT%\upsy.ico"
if exist "%DATA%\TOPSY.EXE" "%OUT%\lb7tool.exe" icon "%DATA%\TOPSY.EXE" "%OUT%\upsy.ico" && set "RCDEF=-DUPSY_ICON"
windres %RCDEF% -I"%ROOT%\port\res" -I"%OUT%" -o "%OUT%\upsy_res.o" "%ROOT%\port\res\upsy.rc" || goto :error
windres %RCDEF% -I"%ROOT%\port\res" -I"%OUT%" -o "%OUT%\launcher_res.o" "%ROOT%\port\res\launcher.rc" || goto :error

echo [3/7] TinySoundFont and stb_truetype (third_party, without project warnings)
gcc -std=c11 -O2 -w -c -o "%OUT%\tsf_impl.o" "%ROOT%\port\src\tsf_impl.c" || goto :error
gcc -std=c11 -O2 -w -c -o "%OUT%\text_impl.o" "%ROOT%\port\src\text_impl.c" || goto :error

echo [4/7] compiling the game logic
if not exist "%OUT%\game" mkdir "%OUT%\game"
set "GAMEOBJ="
setlocal EnableDelayedExpansion
for %%F in ("%GAMESRC%\*.c") do (
	gcc %CFLAGS% -Wno-unused-parameter -I"%ROOT%\port\src" -c -o "%OUT%\game\%%~nF.o" "%%F" || goto :error
	set "GAMEOBJ=!GAMEOBJ! "%OUT%\game\%%~nF.o""
)

echo [5/7] upsy (SDL2 port)
gcc %CFLAGS% -I"%SDL2_DIR%\include\SDL2" -o "%OUT%\upsy.exe" ^
	"%ROOT%\port\src\main.c" "%ROOT%\port\src\video.c" "%ROOT%\port\src\audio.c" ^
	"%ROOT%\port\src\midi.c" "%ROOT%\port\src\lb7.c" "%ROOT%\port\src\rt.c" "%ROOT%\port\src\sprite.c" "%ROOT%\port\src\cov.c" "%ROOT%\port\src\text.c" "%ROOT%\port\src\config.c" "%OUT%\tsf_impl.o" "%OUT%\text_impl.o" "%OUT%\upsy_res.o" ^
	!GAMEOBJ! -L"%SDL2_DIR%\lib" -lmingw32 -lSDL2main -lSDL2 -lm || goto :error
endlocal

echo [6/7] upsy_launcher (Win32 launcher, no SDL)
gcc -std=c11 -O2 -Wall -Wextra -Wno-missing-field-initializers -mwindows -o "%OUT%\upsy_launcher.exe" "%ROOT%\port\launcher\launcher.c" "%OUT%\launcher_res.o" -lcomctl32 -lcomdlg32 -lshell32 -lole32 || goto :error

echo [7/7] SDL2.dll
copy /y "%SDL2_DIR%\bin\SDL2.dll" "%OUT%\" >nul || goto :error

echo.
echo OK: %OUT%\upsy.exe and %OUT%\upsy_launcher.exe
echo Run: build\upsy_launcher.exe (sets upsy.ini and starts the game) or build\upsy.exe (looks for the .BIN files next to upsy.exe, otherwise --data FOLDER)
echo Music: SoundFont in tools\soundfont\GeneralUser-GS.sf2 (otherwise --sf2 FILE)
exit /b 0

:error
echo.
echo BUILD FAILED
exit /b 1
