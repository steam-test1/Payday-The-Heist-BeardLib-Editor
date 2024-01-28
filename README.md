# PDTH BeardLib-Editor Alpha

This is a very work in progress port of BeardLib Editor to PDTH

Most stuff doesn't work

# !!!!!!!!!!!!!!!!!NOTICE ABOUT MATCHMAKING!!!!!!!!!!!!!!
Matchmaking is **disabled** by default due to having to edit the physics settings of the game.
Playing with people with said edit can cause issues if not everyone has the said fix. 

In order to enable matchmaking, you must disable the physics fix through the editor's options menu. Do note that without that fix, the editor will not work properly.

## Installation
1. (Required for the massunits tool) https://dotnet.microsoft.com/download/dotnet/5.0/runtime Download the x64 version runtime.
2. Install [Diesel SuperBLT](https://gitlab.com/cpone/diesel-superblt-lua-temp-pdth/-/raw/master/Install.zip)
3. Install [PDTH BeardLib](https://github.com/steam-test1/Payday-The-Heist-BeardLib)
4. After downloading the editor by clicking `Code` -> `Download ZIP`, unzip the contents of the ZIP file in the mods folder of the game.

## Generating the Data Files
If the hashlist/game gets updated you can update the data files yourself by doing the following:

1. Get DieselBundleViewer (1.1.1 and up)
2. Install the PackageOutputter script from https://github.com/Luffyyy/DieselBundleViewer-Scripts
3. Open DieselBundleViewer and open the BLB file from PAYDAY 2's assets directory.
4. Once the load is complete, run the script from File > Scripts > Package Hashlist Outputter
5. This should create a file named packages.txt.
6. Drop the file to BeardLib Editor's root directory and run the game. The editor will do the rest.

## Plugin Source
https://github.com/Luffyyy/LuaFileSystem-SBLT