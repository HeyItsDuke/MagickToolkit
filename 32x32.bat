@echo off
setlocal enabledelayedexpansion

rem Set the target resolution heading
set "target_resolution=32x32"

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

rem Create the output folder if it doesn't exist
mkdir "%output_folder%"
set "non_png_found=0"

rem Recursively scan for PNG files
for /R "%input_folder%" %%f in (*.png) do (
    rem Get the relative path by removing the input folder prefix from the file path
    set "relative_path=%%f"
    set "relative_path=!relative_path:%input_folder%=!"

    rem Extract the directory portion of the relative path
    set "relative_dir=%%~dpf"
    set "relative_dir=!relative_dir:%input_folder%\=!"

    rem Create the corresponding output subdirectory if it doesn't exist
    mkdir "%output_folder%\!relative_dir!" 2>nul

    rem Resize the PNG file and place it in the corresponding subfolder
    %imagemagick_path% "%%f" -resize 32x32 "%output_folder%\!relative_dir!%%~nxf"
)

rem Recursively scan for non-PNG files
for /R "%input_folder%" %%f in (*.*) do (
    if /I not "%%~xf"==".png" (
        rem Set the flag to indicate that a non-PNG file was found
        set "non_png_found=1"

        rem Get the relative path by removing the input folder prefix from the file path
        set "relative_path=%%f"
        set "relative_path=!relative_path:%input_folder%=!"

        rem Extract the directory portion of the relative path
        set "relative_dir=%%~dpf"
        set "relative_dir=!relative_dir:%input_folder%\=converted\!"

        rem Create the corresponding output subdirectory in the converted folder if it doesn't exist
        mkdir "%output_folder%\!relative_dir!" 2>nul

        rem Convert the non-PNG file to PNG and resize it
        %imagemagick_path% "%%f" -resize 32x32 "%output_folder%\!relative_dir!%%~nf.png"
    )
)

rem Create the converted folder only if non-PNG files were found
if !non_png_found! == 1 mkdir "%output_folder%\converted" 2>nul

echo Batch resize for 32x32 completed!
pause



