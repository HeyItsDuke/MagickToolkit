@echo off
setlocal enabledelayedexpansion

rem Check for dry run argument
set "dry_run=0"
if /I "%~1"=="/dry-run" (
    set "dry_run=1"
    echo Dry run mode activated. No changes will be made.
)

rem Set the target resolution heading
set "target_resolution=320x256"

rem Read the paths from the paths.txt file
set "path_file=%~dp0paths.txt"

rem Initialize variables
set "input_folder="
set "output_folder="

rem Read the paths from the file
set "reading_paths=0"
for /f "delims=" %%A in ('type "%path_file%"') do (
    rem Check if we found the target resolution heading
    if "%%A"=="# !target_resolution!" (
        set "reading_paths=1"
        set "input_folder="
        set "output_folder="
        set "line_count=0"
    ) else if !reading_paths! == 1 (
        if !line_count! lss 2 (
            set /a line_count+=1
            if !line_count! equ 1 (
                set "input_folder=%%A"
            ) else (
                set "output_folder=%%A"
            )
        ) else (
            set "reading_paths=0"
        )
    )
)

rem Check if both paths were read successfully
if not defined input_folder (
    echo Input folder not specified for resolution !target_resolution! in paths.txt.
    pause
    exit /b
)

if not defined output_folder (
    echo Output folder not specified for resolution !target_resolution! in paths.txt.
    pause
    exit /b
)

rem Define the ImageMagick path
set "imagemagick_path=%~dp0bin\magick.exe"

rem Create the output folder if it doesn't exist (but skip if dry run)
if !dry_run! == 0 (
    mkdir "%output_folder%"
) else (
    echo [Dry Run] Would create output folder: "%output_folder%"
)

set "non_png_found=0"
set "paused=0"

rem Function to handle pause/resume/cancel
:check_controls
choice /c PRC /n /t 0 /d Y >nul
if errorlevel 3 (
    echo Cancelling operations...
    exit /b
) else if errorlevel 2 (
    if !paused! == 0 (
        echo Pausing operations... Press 'R' to resume.
        set "paused=1"
    )
) else if errorlevel 1 (
    if !paused! == 1 (
        echo Resuming operations...
        set "paused=0"
    )
)
exit /b

rem Recursively scan for PNG files
for /R "%input_folder%" %%f in (*.png) do (
    call :check_controls
    if !paused! == 1 (
        choice /c R /n /m "Paused. Press 'R' to resume." >nul
        set "paused=0"
    )

    rem Get the relative path by removing the input folder prefix from the file path
    set "relative_path=%%f"
    set "relative_path=!relative_path:%input_folder%=!"

    rem Extract the directory portion of the relative path
    set "relative_dir=%%~dpf"
    set "relative_dir=!relative_dir:%input_folder%\=!"

    rem Create the corresponding output subdirectory if it doesn't exist (but skip if dry run)
    if !dry_run! == 0 (
        mkdir "%output_folder%\!relative_dir!" 2>nul
    ) else (
        echo [Dry Run] Would create directory: "%output_folder%\!relative_dir!"
    )

    rem Resize the PNG file and place it in the corresponding subfolder (but skip if dry run)
    if !dry_run! == 0 (
        %imagemagick_path% "%%f" -resize 320x256 "%output_folder%\!relative_dir!%%~nxf"
    ) else (
        echo [Dry Run] Would resize PNG: "%%f" to 320x256 and save to "%output_folder%\!relative_dir!%%~nxf"
    )
)

rem Recursively scan for non-PNG files
for /R "%input_folder%" %%f in (*.*) do (
    call :check_controls
    if !paused! == 1 (
        choice /c R /n /m "Paused. Press 'R' to resume." >nul
        set "paused=0"
    )

    if /I not "%%~xf"==".png" (
        rem Set the flag to indicate that a non-PNG file was found
        set "non_png_found=1"

        rem Get the relative path by removing the input folder prefix from the file path
        set "relative_path=%%f"
        set "relative_path=!relative_path:%input_folder%=!"

        rem Extract the directory portion of the relative path
        set "relative_dir=%%~dpf"
        set "relative_dir=!relative_dir:%input_folder%\=converted\!"

        rem Create the corresponding output subdirectory in the converted folder if it doesn't exist (but skip if dry run)
        if !dry_run! == 0 (
            mkdir "%output_folder%\!relative_dir!" 2>nul
        ) else (
            echo [Dry Run] Would create directory: "%output_folder%\!relative_dir!"
        )

        rem Convert the non-PNG file to PNG and resize it (but skip if dry run)
        if !dry_run! == 0 (
            %imagemagick_path% "%%f" -resize 320x256 "%output_folder%\!relative_dir!%%~nf.png"
        ) else (
            echo [Dry Run] Would convert and resize file: "%%f" to PNG and resize to 320x256, saving to "%output_folder%\!relative_dir!%%~nf.png"
        )
    )
)

rem Create the converted folder only if non-PNG files were found (but skip if dry run)
if !non_png_found! == 1 if !dry_run! == 0 (
    mkdir "%output_folder%\converted" 2>nul
) else if !non_png_found! == 1 (
    echo [Dry Run] Would create folder: "%output_folder%\converted"
)

echo Batch resize for !target_resolution! completed!

if !dry_run! == 1 (
    echo This was a dry run. No changes were made.
)

pause
