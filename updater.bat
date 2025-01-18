@echo off
setlocal EnableDelayedExpansion

set "REPO_URL=https://github.com/sekalYT/mine.git"
set "SCRIPT_DIR=%~dp0"
set "GIT_DOWNLOAD_URL=https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
set "GIT_INSTALLER=%TEMP%\GitInstaller.exe"

:: Проверка наличия Git
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Git не установлен. Начинаем установку...
    
    :: Скачивание Git
    echo Скачивание Git...
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%GIT_DOWNLOAD_URL%', '%GIT_INSTALLER%')"
    
    :: Установка Git
    echo Установка Git...
    start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART
    
    :: Удаление установщика
    del "%GIT_INSTALLER%"
    
    :: Добавление Git в PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
    
    echo Git успешно установлен!
)

echo Проверка репозитория...

if exist ".git" (
    echo Обновление существующего репозитория...
    git fetch --all
    git reset --hard origin/main
    git clean -fd
    if errorlevel 1 (
        echo Ошибка при обновлении репозитория
        pause
        exit /b 1
    )
) else (
    echo Репозиторий не найден. Выполняется первичная установка...
    
    :: Очистка директории, если она не пуста (кроме текущего скрипта)
    for %%F in (*) do (
        if not "%%F"=="%~nx0" del "%%F"
    )
    for /d %%D in (*) do rmdir /s /q "%%D"
    
    :: Клонирование репозитория
    git clone %REPO_URL% "%TEMP%\temp_clone"
    if errorlevel 1 (
        echo Ошибка при клонировании репозитория
        pause
        exit /b 1
    )
    
    :: Перемещение файлов (кроме .git) в текущую директорию
    xcopy /E /Y /I "%TEMP%\temp_clone\*" "%SCRIPT_DIR%" >nul
    
    :: Инициализация git в текущей директории
    git init
    git remote add origin %REPO_URL%
    git fetch
    git reset --hard origin/main
    
    :: Очистка временной директории
    rmdir /s /q "%TEMP%\temp_clone"
)

echo Готово! Репозиторий успешно обновлен.
dir
pause