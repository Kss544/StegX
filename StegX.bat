@echo off
setlocal enabledelayedexpansion

:: Define o diretório de trabalho como o local do script
cd /d "%~dp0"

:check_steghide
where steghide.exe >nul 2>nul
if %errorlevel% neq 0 (
  if not exist ".\steghide.exe" (
    echo [ERRO] steghide.exe nao encontrado.
    echo Certifique-se de que ele esteja na mesma pasta que este script.
    pause
    exit /b
  )
)

:menu
set "photofile="
set "hiddenfile="
set "password="
cls
echo ===========================================
echo       UTILITARIO STEGHIDE (BATCH + PS)
echo ===========================================
echo  1 - Embutir (Esconder arquivo em imagem)
echo  2 - Extrair (Revelar arquivo de imagem)
echo  3 - Sair
echo ===========================================
set /p choice=Escolha uma opcao: 

if "%choice%"=="1" goto embed
if "%choice%"=="2" goto extract
if "%choice%"=="3" exit /b
goto menu

:embed
echo.
set /p password=Defina uma senha para proteger o dado: 

echo [Aguarde] Selecione a imagem de capa (.jpg)...
for /f "delims=" %%i in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd=New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter='Imagens JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg'; $ofd.Title='Selecione a Imagem de Capa'; if($ofd.ShowDialog() -eq 'OK'){ $ofd.FileName }"') do set "photofile=%%i"

if not defined photofile (echo Operacao cancelada pelo usuario. & pause & goto menu)

echo [Aguarde] Selecione o arquivo que deseja esconder...
for /f "delims=" %%i in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd=New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter='Todos os Arquivos (*.*)|*.*'; $ofd.Title='Selecione o arquivo a esconder'; if($ofd.ShowDialog() -eq 'OK'){ $ofd.FileName }"') do set "hiddenfile=%%i"

if not defined hiddenfile (echo Operacao cancelada pelo usuario. & pause & goto menu)

set "output_img=imagem_secreta.jpg"
copy /Y "%photofile%" "%output_img%" >nul

echo Processando...
steghide embed -ef "%hiddenfile%" -cf "%output_img%" -p "%password%" -f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo [SUCESSO] Arquivo embutido com sucesso!
    echo Resultado: %output_img%
) else (
    echo.
    echo [ERRO] Ocorreu um problema. Verifique se o arquivo e muito grande para a imagem.
    if exist "%output_img%" del "%output_img%"
)
pause
goto menu

:extract
echo.
echo [Aguarde] Selecione a imagem que contem o arquivo oculto...
for /f "delims=" %%i in ('powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd=New-Object System.Windows.Forms.OpenFileDialog; $ofd.Filter='Imagens JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg'; if($ofd.ShowDialog() -eq 'OK'){ $ofd.FileName }"') do set "photofile=%%i"

if not defined photofile (echo Operacao cancelada. & pause & goto menu)

set /p password=Digite a senha para extrair: 

echo Extraindo...
steghide extract -sf "%photofile%" -p "%password%" -f

if %errorlevel% equ 0 (
    echo.
    echo [SUCESSO] Arquivo extraido com sucesso para esta pasta!
) else (
    echo.
    echo [ERRO] Falha na extracao. Senha incorreta ou arquivo corrompido.
)
pause
goto menu
