@echo off
setlocal enabledelayedexpansion

rem Check for dry run argument
set "dry_run=0"
if /I "%~1"=="/dry-run" (
    set "dry_run=1"
    echo Dry run mode activated. No changes will be made.
)

rem Set the target resolution heading
set "target_resolution=convert_webp_lossless"

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

set "non_webp_found=0"
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

rem Recursively scan for non-WebP files
for /R "%input_folder%" %%f in (*.*) do (
    call :check_controls
    if !paused! == 1 (
        choice /c R /n /m "Paused. Press 'R' to resume." >nul
        set "paused=0"
    )

    if /I not "%%~xf"==".webp" (
        rem Set the flag to indicate that a non-WebP file was found
        set "non_webp_found=1"

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

        rem Convert the non-WebP file to WebP (but skip if dry run)
        if !dry_run! == 0 (
            %imagemagick_path% "%%f" "%output_folder%\!relative_dir!%%~nf.webp" -quality 75
        ) else (
            echo [Dry Run] Would convert file: "%%f" to Lossy WebP, saving to "%output_folder%\!relative_dir!%%~nf.webp" -quality 75
        )
    )
)

rem Create the converted folder only if non-WebP files were found (but skip if dry run)
if !non_png_found! == 1 if !dry_run! == 0 (
    mkdir "%output_folder%\converted" 2>nul
) else if !non_webp_found! == 1 (
    echo [Dry Run] Would create folder: "%output_folder%\converted"
)

echo Batch resize for !target_resolution! completed!

if !dry_run! == 1 (
    echo This was a dry run. No changes were made.
)

pause
