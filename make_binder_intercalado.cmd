@echo on
setlocal EnableExtensions EnableDelayedExpansion

REM ===== CONFIG =====
set "MASTER=EB2_NIW_Petition_Package_MASTER.pdf"
set "OUT=EB2_NIW_FULL-BINDER.pdf"
set "TMP=TMP_SPLIT"

REM A — Policy/Strategy
set "A01=Biden-Harris-Administrations-National-Security-Strategy-10.2022.pdf"
set "A02=CMR-PREX23-00185928.pdf"
set "A03=Treasury-Cloud-Report.pdf"

REM B — Industry/Workforce (inclui WEF e Skillsoft)
set "B01=comptia-it-industry-outlook-2025.pdf"
set "B02=comptia-state-of-the-tech-workforce-2024.pdf"
set "B03=05-2025-CompTIA Tech Jobs Report.pdf"
set "B04_1=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-1.pdf"
set "B04_2=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-2.pdf"
set "B04_3=Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-3.pdf"
set "B05=WEF_Future_of_Jobs_Report_2025.pdf"
set "B06=Skillsoft-IT-Skills-and-Salary-Report-2023.pdf"

REM C — Standards/Compliance (se tiver)
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

REM ===== FUNÇÕES =====
goto :afterfunc
:addfile
  if not "%~1"=="" if exist "%~1" (set "MERGE=!MERGE! "%~1"") else (echo [WARN] Falta: %~1)
  exit /b 0
:afterfunc

REM ===== SPLIT =====
if exist "%TMP%" rd /s /q "%TMP%"
mkdir "%TMP%"
pdfseparate "%MASTER%" "%TMP%\MASTER_%%03d.pdf"

for /f "delims=" %%# in ('dir /b /a:-d "%TMP%\MASTER_*.pdf" ^| find /c /v ""') do set "PAGECOUNT=%%#"
echo [INFO] MASTER paginas=!PAGECOUNT!

REM ===== se < 13 pgs, faz modo simples =====
if "!PAGECOUNT!" LSS "13" goto SIMPLE

REM ===== MONTAR LISTA INTERCALADA =====
set "MERGE="

for /l %%P in (1,1,10) do (
  set "P=00%%P"
  set "P=!P:~-3!"
  call :addfile "%TMP%\MASTER_!P!.pdf"
)

call :addfile "%TMP%\MASTER_011.pdf"
call :addfile "%A01%"
call :addfile "%A02%"
call :addfile "%A03%"
call :addfile "%B01%"
call :addfile "%B02%"

call :addfile "%TMP%\MASTER_012.pdf"
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

call :addfile "%TMP%\MASTER_013.pdf"
call :addfile "%G01%"
call :addfile "%G02%"
call :addfile "%G03%"

if "!PAGECOUNT!" GTR "13" (
  for /l %%P in (14,1,!PAGECOUNT!) do (
    set "P=00%%P"
    set "P=!P:~-3!"
    call :addfile "%TMP%\MASTER_!P!.pdf"
  )
)

pdfunite %MERGE% "%OUT%"
if errorlevel 1 goto SIMPLE

rd /s /q "%TMP%" 2>nul
echo [OK] "%OUT%" criado (intercalado).
exit /b 0

:SIMPLE
echo [MODO SIMPLES] Concatenando sem intercalar...
set "MERGE="
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

pdfunite %MERGE% "%OUT%"
rd /s /q "%TMP%" 2>nul
echo [OK] "%OUT%" criado (simples).
exit /b 0
