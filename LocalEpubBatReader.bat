@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 📚 LocalEpubBatReader - EPUB转HTML / TXT直接挂载 - 浏览器原生离线阅读终端
color 0A
cd /d "%~dp0"


:: ===================== 基础配置 =====================
set "PORT=8922"
set "INDEX=reading.html"
set "LAN_IP=127.0.0.1"

:: ===================== 清理旧导航文件 =====================
if exist "%INDEX%" del /f /q "%INDEX%"

:: ===================== 获取局域网IP =====================
for /f "tokens=4 delims=: " %%a in ('netsh interface ip show addresses WLAN 2^>nul ^| findstr /i "IP.*:"') do set "LAN_IP=%%a"
for /f "tokens=4 delims=: " %%a in ('netsh interface ip show addresses "以太网" 2^>nul ^| findstr /i "IP.*:"') do set "LAN_IP=%%a"

cls
echo ================================================================================
echo                LocalEpubBatReader - 本地EPUB转HTML浏览器阅读工具
echo.
echo                          匠心凝点滴  屏间阅自由
echo.
echo           版本 1.61 · ITU 161th：Standardizing Telegraph, Uniting the Globe
echo ================================================================================
echo.

:: ===================== 批量解包 EPUB =====================
echo [1/2] 正在批量解包 EPUB 文件...
for %%f in (*.epub) do (
    echo 处理：%%~nf
    rd /s /q "%%~nf" 2>nul
    md "%%~nf"
    tar -xf "%%f" -C "%%~nf" >nul 2>&1
)

:: ===================== 生成导航页 =====================
echo.
echo [2/2] 正在生成阅读导航页面...
(
echo ^<!DOCTYPE html^>
echo ^<html lang="zh-CN"^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<title^>Readering 导航^</title^>
echo ^<style^>
echo body{font-family:"Microsoft YaHei",sans-serif;max-width:960px;margin:2rem auto;background:#f5f6f8;padding:0 20px;}
echo h1{text-align:center;color:#222;margin-bottom:30px;}
echo .book-item{background:#fff;border-radius:8px;padding:16px;margin:12px 0;box-shadow:0 2px 6px #0000001a;}
echo a{color:#0066cc;text-decoration:none;font-size:16px;}
echo ^</style^>
echo ^</head^>
echo ^<body^>
:: 页面主标题
echo ^<h1^>📚 LocalEpubBatReader - 本地电子书库^</h1^>
) > "%INDEX%"

:: ===================== 遍历目录（极简 + 特殊字符兼容） =====================
for /d %%d in (*) do (
    set "name=%%~nd"
    set "link=%%~nxd"

    set "link=!link: =%%20!"
    set "link=!link:#=%%23!"
    set "link=!link:&=%%26!"
    set "link=!link:(=%%28!"
    set "link=!link:)=%%29!"
    set "link=!link:,=%%2C!"

    echo ^<div class="book-item"^> >> "%INDEX%"
    echo ^<h3^>!name!^</h3^> >> "%INDEX%"
    echo ^<a href="!link!/"^>📖 进入阅读^</a^> >> "%INDEX%"
    echo ^</div^> >> "%INDEX%"
)

:: ===================== 闭合HTML =====================
echo ^</body^> >> "%INDEX%"
echo ^</html^> >> "%INDEX%"

:: ===================== 输出格式 =====================
echo.
echo ======================================================================
echo ✅ 全部成功
echo 🔗 本机访问：http://localhost:%PORT%/%INDEX%
echo 🌐 局域网访问：http://%LAN_IP%:%PORT%/%INDEX%
echo ⛔ 停止服务：Ctrl + C
echo ======================================================================
echo.

timeout /t 1 /nobreak >nul 2>&1
start http://localhost:%PORT%/%INDEX%

python --version >nul 2>&1
if %errorlevel% equ 0 (
    python -m http.server %PORT%
) else (
    echo.
    echo ⚠  未检测到Python，已为你生成 reading.html
    echo    直接双击 reading.html 即可看书！
    echo.
    pause
)

exit /b