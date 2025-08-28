@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =========================
REM CONFIGURACAO BASICA
REM =========================
set "MASTER=EB2_NIW_Petition_Package_MASTER.pdf"
set "OUT=EB2_NIW_FULL-BINDER.pdf"
set "TMP=TMP_SPLIT"

REM ---- ANNEX FILES (ajuste os nomes se necessário) ----
REM A — Policy/Strategy
set "A01=Biden-Harris-Administrations-National-Security-Strategy-10.2022.pdf"
set "A02=CMR-PREX23-00185928.pdf"
set "A03=Treasury-Cloud-Report.pdf"

REM B — Industry/Workforce
set "B01=comptia-it-industry-outlook-2025.pdf"
set "B02=comptia-state-of-the-tech-workforce-2024.pdf"
set "B03=05-2025-CompTIA Tech Jobs Report.pdf"
set "B04_1=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-1.pdf"
set "B04_2=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-2.pdf"
set "B04_3=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-3.pdf"
set "B05=WEF_Future_of_Jobs_Report_2025.pdf"
set "B06=Skillsoft-IT-Skills-and-Salary-Report-2023.pdf"

REM C — Standards/Compliance (opcional; deixe vazio se ainda não tiver)
set "C01="
set "C02="
set "C03="
set "C04="

REM D — Credentials/Education
set "D07=Gustavo Ferreira AEE evaluation.pdf"
set "D08=ENG_Gustavo_Ferreira_2025.docx.pdf"

REM E — Letters
set "E01=Letter_of_Recommendation_JoséRicardoFerrazza_latest (1).pdf"
set "E02=Recommendation_Letter_Gustavo_Ferreira____Carlos_Feitosa (1).pdf"

REM G — Career Path / Employment
set "G01=carrear pathway 2025.drawio.pdf"
set "G02=CTPSDigital_101.954.376-08_04-06-2025.pdf"
set "G03=Demonstrativo de Pagamento-latest-month.pdf"

REM =========================
REM CHECAGENS INICIAIS
REM =========================
where pdfunite >nul 2>&1 || (echo [ERRO] pdfunite nao encontrado no PATH. Instale Poppler (ex.: choco install poppler) & exit /b 1)
where pdfseparate >nul 2>&1 || (echo [ERRO] pdfseparate nao encontrado no PATH. Instale Poppler (ex.: choco install poppler) & exit /b 1)

if not exist "%MASTER%" (
  echo [ERRO] Nao encontrei o MASTER: "%MASTER%"
  exit /b 1
)

REM =========================
REM PASSO 1 — SPLIT DO MASTER
REM =========================
echo.
echo [1/4] Separando "%MASTER%" em paginas...
if exist "%TMP%" rd /s /q "%TMP%"
mkdir "%TMP%" || (echo [ERRO] Nao foi possivel criar pasta temporaria & exit /b 1)

pdfseparate "%MASTER%" "%TMP%\MASTER_%%03d.pdf"
if errorlevel 1 (
  echo [AVISO] Falha ao separar. Vou usar o modo simples (sem intercalar).
  goto SIMPLE_MODE
)

REM Conta quantas paginas o MASTER tem
for /f "delims=" %%# in ('dir /b /a:-d "%TMP%\MASTER_*.pdf" ^| find /c /v ""') do set "PAGECOUNT=%%#"
echo [INFO] MASTER possui !PAGECOUNT! paginas.

REM =========================
REM PASSO 2 — CONSTRUIR LISTA DE MERGE (INTERCALADO)
REM Coberturas mapeadas (seu pacote):
REM  - A/B (primeiros itens) apos pagina 11
REM  - B (restante) + C/D/E/F apos pagina 12
REM  - G apos pagina 13
REM Se alguma pagina nao existir (ex.: PAGECOUNT < 13), o script cai para modo simples.
REM =========================

if "!PAGECOUNT!" LSS "13" (
  echo [AVISO] MASTER com menos de 13 paginas (!PAGECOUNT!). Vou usar o modo simples (sem intercalar).
  goto SIMPLE_MODE
)

set "MERGE="

REM ---- Funcao para adicionar arquivo se existir ----
REM Uso: call :addfile "caminho\arquivo.pdf"
REM Acrescenta ao MERGE entre aspas
goto :after_functions
:addfile
  set "F=%~1"
  if not "%~1"=="" (
    if exist "%~1" (
      set "MERGE=!MERGE! "%~1""
      echo   [OK] + %~1
    ) else (
      echo   [WARN] Arquivo ausente: %~1  ^(sera ignorado^)
    )
  )
  exit /b 0
:after_functions

echo.
echo [2/4] Montando sequencia intercalada...

REM Pgs 1..10 (frente do binder/inicio do memo)
for /l %%P in (1,1,10) do (
  set "P=00%%P"
  set "P=!P:~-3!"
  call :addfile "%TMP%\MASTER_!P!.pdf"
)

REM Pagina 11 (cover sheets A e B-inicio)
call :addfile "%TMP%\MASTER_011.pdf"

REM === Inserir A-01..A-03 ===
call :addfile "%A01%"
call :addfile "%A02%"
call :addfile "%A03%"

REM === Inserir B-01..B-02 ===
call :addfile "%B01%"
call :addfile "%B02%"

REM Pagina 12 (cover sheets B-restante / C / D / E / F)
call :addfile "%TMP%\MASTER_012.pdf"

REM === Inserir B-03..B-04..B-05..B-06 ===
call :addfile "%B03%"
call :addfile "%B04_1%"
call :addfile "%B04_2%"
call :addfile "%B04_3%"
call :addfile "%B05%"
call :addfile "%B06%"

REM === Inserir C-01..C-04 (se tiver) ===
call :addfile "%C01%"
call :addfile "%C02%"
call :addfile "%C03%"
call :addfile "%C04%"

REM === Inserir D-07..D-08 ===
call :addfile "%D07%"
call :addfile "%D08%"

REM === Inserir E-01..E-02 ===
call :addfile "%E01%"
call :addfile "%E02%"

REM Pagina 13 (cover sheet G)
call :addfile "%TMP%\MASTER_013.pdf"

REM === Inserir G-01..G-03 ===
call :addfile "%G01%"
call :addfile "%G02%"
call :addfile "%G03%"

REM Se o MASTER tiver mais paginas (>13), adiciona o restante no final
if "!PAGECOUNT!" GTR "13" (
  for /l %%P in (14,1,!PAGECOUNT!) do (
    set "P=00%%P"
    set "P=!P:~-3!"
    call :addfile "%TMP%\MASTER_!P!.pdf"
  )
)

echo.
echo [3/4] Unindo em "%OUT%"...
pdfunite %MERGE% "%OUT%"
if errorlevel 1 (
  echo [ERRO] Falha no pdfunite (modo intercalado). Vou tentar modo simples.
  goto SIMPLE_MODE
)

echo [4/4] Limpeza de temporarios...
rd /s /q "%TMP%" 2>nul

echo.
echo [SUCESSO] Binder gerado: "%OUT%"
exit /b 0

REM =========================
REM MODO SIMPLES (sem intercalar)
REM =========================
:SIMPLE_MODE
echo.
echo [MODO SIMPLES] Vou concatenar MASTER + anexos em ordem, sem intercalar nas cover sheets.

set "MERGE_SIMPLE="
call :addfile "%MASTER%"
call :addfile "%A01%"
call :addfile "%A02%"
call :addfile "%A03%"
call :addfile "%B01%"
call :addfile "%B02%"
call :addfile "%B03%"
call :addfile "%B04_1%"
call :addfile "%B04_2%"
call :addfile "%B04_3%"
call :addfile "%B05%"
call :addfile "%B06%"
call :addfile "%C01%"
call :addfile "%C02%"
call :addfile "%C03%"
call :addfile "%C04%"
call :addfile "%D07%"
call :addfile "%D08%"
call :addfile "%E01%"
call :addfile "%E02%"
call :addfile "%G01%"
call :addfile "%G02%"
call :addfile "%G03%"

echo.
echo [Merge] Gerando "%OUT%"...
pdfunite %MERGE% %MERGE_SIMPLE% "%OUT%"
if errorlevel 1 (
  echo [ERRO] Falha no pdfunite (modo simples).
  exit /b 1
)

if exist "%TMP%" rd /s /q "%TMP%" 2>nul

echo [SUCESSO] Binder gerado: "%OUT%"
exit /b 0
