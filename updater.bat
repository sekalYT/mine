@echo off
setlocal EnableDelayedExpansion

set "REPO_URL=https://github.com/sekalYT/mine.git"
set "SCRIPT_DIR=%~dp0"
set "GIT_DOWNLOAD_URL=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
set "GIT_INSTALLER=%TEMP%\GitInstaller.exe"
set "TEMP_CLONE_DIR=%~dp0temp_repo"

:: Удаляем закрывающий слеш из пути
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TEMP_CLONE_DIR=%TEMP_CLONE_DIR:~0,-1%"

echo Current script directory: %SCRIPT_DIR%
echo Temporary clone directory: %TEMP_CLONE_DIR%

:: Check if Git is installed
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Git is not installed. Starting installation...
    
    :: Download Git
    echo Downloading Git...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%GIT_DOWNLOAD_URL%', '%GIT_INSTALLER%')"
    
    :: Install Git
    echo Installing Git...
    start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART
    
    :: Remove installer
    del "%GIT_INSTALLER%"
    
    :: Add Git to PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
    
    echo Git has been successfully installed!
)

echo Checking repository...

if exist ".git" (
    echo Updating existing repository...
    git fetch --all
    git reset --hard origin/main
    git clean -fd -e .sl_password
    if errorlevel 1 (
        echo Error updating repository
        pause
        exit /b 1
    )
) else (
    echo Repository not found. Performing initial installation...
    
    :: Clean directory if not empty (except current script and .sl_password)
    for %%F in (*) do (
        if not "%%F"=="%~nx0" if not "%%F"==".sl_password" del "%%F"
    )
    for /d %%D in (*) do (
        if not "%%D"=="temp_repo" rmdir /s /q "%%D"
    )
    
    :: Remove temporary directory if it exists
    if exist "%TEMP_CLONE_DIR%" (
        echo Removing existing temporary directory...
        rmdir /s /q "%TEMP_CLONE_DIR%"
    )
    
    :: Create temporary directory
    mkdir "%TEMP_CLONE_DIR%"
    
    :: Clone repository to temporary directory next to script
    echo Cloning repository to: %TEMP_CLONE_DIR%
    git clone "%REPO_URL%" "%TEMP_CLONE_DIR%"
    if errorlevel 1 (
        echo Error cloning repository
        pause
        exit /b 1
    )
    
    :: Move files (except .git) to script directory
    echo Copying files to: %SCRIPT_DIR%
    xcopy /E /Y /I "%TEMP_CLONE_DIR%\*" "%SCRIPT_DIR%" >nul
    if errorlevel 1 (
        echo Error copying files
        pause
        exit /b 1
    )
    
    :: Initialize git in current directory
    git init
    if errorlevel 1 goto :error
    
    git remote add origin "%REPO_URL%"
    if errorlevel 1 goto :error
    
    git fetch
    if errorlevel 1 goto :error
    
    git reset --hard origin/main
    if errorlevel 1 goto :error
    
    :: Clean temporary directory
    echo Cleaning up temporary directory...
    rmdir /s /q "%TEMP_CLONE_DIR%"
)

echo Done! Repository successfully updated.
dir
pause
exit /b 0

:error
echo An error occurred while executing git commands
pause
exit /b 1