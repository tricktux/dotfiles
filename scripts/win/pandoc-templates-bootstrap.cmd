
@echo off
REM Define the destination directory
set "DEST=C:\Users\%USERNAME%\AppData\Roaming\pandoc\templates"

REM Create the destination directory if it does not exist
if not exist "%DEST%" (
  mkdir "%DEST%"
)

REM Download the templates by cloning the repositories (shallow clone)
git clone --depth 1 https://github.com/Wandmalfarbe/pandoc-latex-template %TEMP%\eisvogel
git clone --depth 1 https://github.com/ryangrose/easy-pandoc-templates %TEMP%\easy-pandoc-templates

REM Copy HTML files to the destination directory (avoid overwriting)
for %%F in ("%TEMP%\easy-pandoc-templates\html\*.html") do (
  if not exist "%DEST%\%%~nxF" (
    copy "%%F" "%DEST%"
  )
)

REM Copy specific .tex file and rename it in the destination directory
copy "%TEMP%\eisvogel\eisvogel.tex" "%DEST%\eisvogel.latex"

REM Cleanup temporary clone directories
rmdir /S /Q "%TEMP%\eisvogel"
rmdir /S /Q "%TEMP%\easy-pandoc-templates"

echo Templates downloaded and placed in %DEST%.
