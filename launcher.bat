@echo off
setlocal enabledelayedexpansion

rem Title for the launcher
title MagickToolkit Launcher

rem List of available resolution scripts (you can add more here)
set "script1=resize_512x512.bat"
set "script2=resize_320x256.bat"
set "script3=resize_256x256.bat"
set "script4=resize_256x128.bat"
set "script5=resize_128x128.bat"
set "script6=resize_128x64.bat"
set "script7=resize_64x128.bat"
set "script8=resize_64x64.bat"
set "script9=resize_64x32.bat"
set "script10=resize_32x32.bat"
set "script11=convert_png.bat"
set "script12=convert_webp_lossless.bat"
set "script13=convert_webp_lossy.bat"
rem Add more scripts as needed

:main_menu
echo =======================================
echo  MagickToolkit Launcher
echo =======================================
echo  Select an option:
echo   1. Run script for 512x512 textures
echo   2. Run script for 320x256 textures
echo   3. Run script for 256x256 textures
echo   4. Run script for 256x128 textures
echo   5. Run script for 128x128 textures
echo   6. Run script for 128x64 textures
echo   7. Run script for 64x128 textures
echo   8. Run script for 64x64 textures
echo   9. Run script for 64x32 textures
echo   10. Run script for 32x32 textures
echo   11. Run script to convert textures to PNG (No Resize)
echo   12. Run script to convert textures to Lossless WebP (No Resize)
echo   13. Run script to convert textures to Lossy WebP (No Resize)
echo   14. Run all resize scripts at once (Mass texture resizing)
echo   15. Exit
echo =======================================
set /p "user_choice=Enter your choice (1-15): "

rem Validate the input to ensure it's a number
if "%user_choice%" geq "1" if "%user_choice%" leq "15" (
    if "%user_choice%" == "15" goto end
    if "%user_choice%" == "14" set "selected_option=ALL"
    if "%user_choice%" == "13" set "selected_option=script13"
    if "%user_choice%" == "12" set "selected_option=script12"
    if "%user_choice%" == "11" set "selected_option=script11"
    if "%user_choice%" == "10" set "selected_option=script10"
    if "%user_choice%" == "9" set "selected_option=script9"
    if "%user_choice%" == "8" set "selected_option=script8"
    if "%user_choice%" == "7" set "selected_option=script7"
    if "%user_choice%" == "6" set "selected_option=script6"
    if "%user_choice%" == "5" set "selected_option=script5"
    if "%user_choice%" == "4" set "selected_option=script4"
    if "%user_choice%" == "3" set "selected_option=script3"
    if "%user_choice%" == "2" set "selected_option=script2"
    if "%user_choice%" == "1" set "selected_option=script1"
) else (
    echo Invalid choice. Please select a valid option.
    pause
    cls
    goto main_menu
)

goto dryrun_prompt

:dryrun_prompt
echo =======================================
echo  Do you want to perform a dry run?
echo  (This will show what changes will be made without applying them)
echo =======================================
set /p "dryrun_choice=Press Y for dry run, N for real run: "

if /I "%dryrun_choice%" == "Y" set "dry_run=/dry-run"
if /I "%dryrun_choice%" == "N" set "dry_run="

goto execute_scripts

:execute_scripts
if "%selected_option%" == "ALL" (
    rem Run all scripts
    call "%script1%" %dry_run%
    call "%script2%" %dry_run%
    call "%script3%" %dry_run%
    call "%script4%" %dry_run%
    call "%script5%" %dry_run%
    call "%script6%" %dry_run%
    call "%script7%" %dry_run%
    call "%script8%" %dry_run%
    call "%script9%" %dry_run%
    call "%script10%" %dry_run%
) else (
    rem Run only the selected script
    call "!%selected_option%!" %dry_run%
)

goto end

:end
echo =======================================
echo  Exiting the launcher.
echo =======================================
pause
exit /b
