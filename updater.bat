@echo off
setlocal EnableDelayedExpansion

set "REPO_URL=https://github.com/sekalYT/mine.git"
set "SCRIPT_DIR=%~dp0"

echo Script directory: %SCRIPT_DIR%

if exist ".git" (
    echo Resetting and updating repository...
    git fetch --all
    git reset --hard origin/main
    git clean -fd
    if errorlevel 1 (
        echo Error during reset operation
        pause
        exit /b 1
    )
) else (
    echo Initializing new repository...
    git init
    git remote add origin %REPO_URL%
    git fetch
    git reset --hard origin/main
    if errorlevel 1 (
        echo Error during initialization
        pause
        exit /b 1
    )
)

echo Done! Repository forcefully updated.
dir
pause