# FuelCategoryModFix

## Description
Used to soft patch mods for Factorio after the 2.1.20 update that changed ItemPrototype::fuel_category with ItemPrototype::fuel_categories. Original credit to /u/cathexis08/ for the idea to use a grep to do a direct replace on the lines in the modfiles. Original thread [here.](https://www.reddit.com/r/factorio/comments/1wn7lvx/comment/pbdmqyz/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)

## Implementation
The script will back up the mod directory, comb through the mod directory, and iterate through every zip file in the directory, looking for the old fuel_category code, and replacing it with the appropriate fuel_categories code. (changing it from a string to an array, and changing the variable name) It will then repackage the affected zips back into linux compatible zips, so this should work both for Windows and Linux.

## Usage
1) Download the script.
2) Run the script from a terminal using the following command: `powershell -ExecutionPolicy Bypass -File "PathToWhereModfixIsStored\ModFix.ps1" -ModDirectory "PathToYourModDirectory"`
2a) Example:  `powershell -ExecutionPolicy Bypass -File "C:\Users\exampleuser\Downloads\ModFix.ps1" -ModDirectory "C:\Users\exampleuser\appdata\Roaming\Factorio\mods\"`
3) The script should create a backup folder with a time and date stamp in your Factorio appdata folder, and then will replace the offending mods with patched mods.
4) Start Factorio and confirm it's working!

Note: The modified folders are Linux compatible, meaning you should be able to upload your newly modified mods server to a Dedicated server without issue!
