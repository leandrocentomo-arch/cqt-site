@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ============================================================
rem  Atualiza o snapshot do dashboard do cliente (Tetra Pak).
rem  1) Pega o tetrapak-kpi.json mais recente da pasta Downloads
rem     (gerado pelo botao "Export client snapshot" no dashboard
rem      interno da Sodexo).
rem  2) Move pra data/ e publica no GitHub Pages.
rem ============================================================

set "DL=%USERPROFILE%\Downloads"
set "SRC="
for /f "delims=" %%F in ('powershell -NoProfile -Command "Get-ChildItem -Path '%DL%\tetrapak-kpi*.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName"') do set "SRC=%%F"

if not defined SRC goto :nofile

echo Origem : !SRC!
echo Destino: %~dp0data\tetrapak-kpi.json
copy /Y "!SRC!" "%~dp0data\tetrapak-kpi.json" >nul
if errorlevel 1 goto :copyfail

echo.
echo Publicando no GitHub...
git add data/tetrapak-kpi.json
git commit -m "dados: atualiza snapshot Tetra Pak (dashboard do cliente)"
git push

echo.
echo Pronto. Em ~1-2 min o cliente ve os numeros novos em:
echo   https://leandrocentomo-arch.github.io/cqt-site/operational-kpi-tetrapak.html
echo.
pause
exit /b 0

:nofile
echo.
echo Nenhum arquivo tetrapak-kpi*.json encontrado em:
echo   %DL%
echo.
echo Clique "Export client snapshot" no dashboard interno da Sodexo primeiro,
echo depois rode este arquivo de novo.
echo.
pause
exit /b 1

:copyfail
echo.
echo ERRO ao copiar o arquivo. Verifique se data\ existe e tente de novo.
echo.
pause
exit /b 1
