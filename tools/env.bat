@echo off
rem Portable environment of the project: JDK, Ghidra, GCC (w64devkit) and SDL2.
rem Nothing is written to the registry or to the user profile.
set "UPSY_TOOLS=%~dp0"
set "UPSY_TOOLS=%UPSY_TOOLS:~0,-1%"
set "JAVA_HOME=%UPSY_TOOLS%\jdk"
set "GHIDRA_HOME=%UPSY_TOOLS%\ghidra"
set "SDL2_DIR=%UPSY_TOOLS%\SDL2\x86_64-w64-mingw32"
set "PATH=%JAVA_HOME%\bin;%UPSY_TOOLS%\w64devkit\bin;%SDL2_DIR%\bin;%PATH%"
set "GHIDRA_JAVA_OPTIONS=-Dapplication.settingsdir=%UPSY_TOOLS%\ghidra_user\settings -Dapplication.cachedir=%UPSY_TOOLS%\ghidra_user\cache -Dapplication.tempdir=%UPSY_TOOLS%\ghidra_user\temp"
if exist "%UPSY_TOOLS%\ghidra" if not exist "%UPSY_TOOLS%\ghidra_user" mkdir "%UPSY_TOOLS%\ghidra_user\settings" "%UPSY_TOOLS%\ghidra_user\cache" "%UPSY_TOOLS%\ghidra_user\temp"
if exist "%UPSY_TOOLS%\ghidra" if not exist "%UPSY_TOOLS%\ghidra_projects" mkdir "%UPSY_TOOLS%\ghidra_projects"
