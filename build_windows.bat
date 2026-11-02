@echo off
chcp 65001 >nul
REM Сборка EXE выполняется только на Windows и требует PyInstaller.
python -m pip install pyinstaller
python -m PyInstaller --noconfirm --clean --windowed --onedir --name StroyMaterialy --add-data "UI\resources;UI\resources" main.py
pause
