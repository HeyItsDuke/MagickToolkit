# MagickToolkit
Simple batch-based toolkit using ImageMagick to automate resizing and conversion of images.

This was developed as a lightweight toolkit to ease my indie game development and modding workflow. I decided to share it. Will it be useful to other people? No idea. But it's here if you want it.

# Usage

To use the scripts, place the paths of your input folder and your output folder into "paths.txt" so the scripts can read them. Then click them to run.

"convert_png" will simply convert any non-PNG files to PNG format without resizing them. Same with the two WebP conversion scripts.

Is this the most optimal way to go about this? I don't know. But it was fun to make and is useful for my needs.

These scripts are licensed under CC0 1.0 Universal. However, ImageMagick has its own license which is included in this toolkit's "bin" directory for compliance purposes.
This toolkit is NOT licensed under the ImageMagick license.

# Dependencies

This toolkit relies on ImageMagick to function. A portable copy of ImageMagick 7.1.1 is included in the "bin" directory for easy usage. No further dependencies required.
The bundled portable copy of ImageMagick will be updated on a as-needed basis if applicable. However, you can update it yourself by downloading the latest portable stable Windows binaries from the official ImageMagick website at: https://imagemagick.org/script/download.php#windows

# Alternate Branches

This is the Red Faction version of MagickToolkit intended for Red Faction modding usage and focuses on TGA files. It will work for any project that requires TGA files. You can use the branch selector to view the primary branch for more general purpose use.