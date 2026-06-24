@echo off
title Diagnostico de Conexao - Partiu Destino
echo ==================================================
echo   DIAGNOSTICO DE CONEXAO - PARTIU DESTINO
echo ==================================================
echo.

echo 1. Verificando se o Node.js esta instalado...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Node.js nao encontrado! Instale em: https://nodejs.org/
) else (
    echo [OK] Node.js detectado.
)

echo.
echo 2. Verificando se o MySQL esta na porta padrao (3306)...
netstat -an | findstr 3306 >nul
if %errorlevel% neq 0 (
    echo [AVISO] Nao detectamos nada na porta 3306. O MySQL esta ligado?
) else (
    echo [OK] MySQL parece estar ativo.
)

echo.
echo 3. Verificando se a API Node esta rodando (Porta 3000)...
netstat -an | findstr 3000 >nul
if %errorlevel% neq 0 (
    echo [ERRO] API Node.js NAO esta rodando! 
    echo       -> Va na pasta 'backend' e rode 'npm start'
) else (
    echo [OK] API Node.js detectada e rodando.
)

echo.
echo 4. Seu IP Local (Para Celular Fisico):
ipconfig | findstr "IPv4"

echo.
echo ==================================================
echo Se tudo estiver [OK] e o erro persistir:
echo 1. Verifique se criou o banco 'partiu_destino' no MySQL.
echo 2. Verifique se o Firewall do Windows nao esta bloqueando o Node.
echo ==================================================
pause
