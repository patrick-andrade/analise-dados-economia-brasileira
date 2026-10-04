# Sessões limpas e separadas: aulas não dependem de objetos deixados no console.
$ErrorActionPreference = 'Stop'
$raizCurso = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $raizCurso
$rCurso = (Get-Command Rscript -ErrorAction SilentlyContinue).Source
if (!$rCurso) {
  $rCurso = @(Get-ChildItem -Path (Join-Path $env:ProgramFiles 'R/R-*/bin/Rscript.exe') -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1).FullName
}
if (!$rCurso) {
  $rCurso = @(Get-ChildItem -Path (Join-Path $env:ProgramFiles 'R/R-*/bin/x64/Rscript.exe') -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1).FullName
}
if (!$rCurso) { throw 'Rscript não localizado. Execute as conferências no console R ou informe o caminho da instalação.' }
# C.UTF-8 não é um locale Windows. Remover apenas da sessão deste processo.
foreach ($variavelCurso in @('LANG','LC_ALL','LC_CTYPE')) {
  [Environment]::SetEnvironmentVariable($variavelCurso, $null, 'Process')
}
$logsCurso = Join-Path $raizCurso 'internal/validacao'
New-Item -ItemType Directory -Force -Path $logsCurso | Out-Null
$arquivosCurso = @('scripts/verificar.R') + @(Get-ChildItem -LiteralPath (Join-Path $raizCurso 'aulas') -Filter '*-pratica.R' | ForEach-Object { 'aulas/' + $_.Name }) + @(Get-ChildItem -LiteralPath (Join-Path $raizCurso 'docentes') -Filter '*-solucao.R' | ForEach-Object { 'docentes/' + $_.Name })
$resultadosCurso = @()
foreach ($arquivoCurso in $arquivosCurso) {
  $logCurso = Join-Path $logsCurso (($arquivoCurso -replace '/','-') + '.log')
  & $rCurso --vanilla -e ('source("' + $arquivoCurso + '",encoding="UTF-8")') *> $logCurso
  $codigoCurso = $LASTEXITCODE
  $resultadosCurso += [pscustomobject]@{arquivo=$arquivoCurso;exit_code=$codigoCurso;log=$logCurso}
  Write-Output ('{0}: {1}' -f $arquivoCurso,$codigoCurso)
}
$resultadosCurso | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $logsCurso 'sessoes.json') -Encoding utf8
if (@($resultadosCurso | Where-Object exit_code -ne 0).Count) { throw 'Há sessões com falha. Conferir logs em internal/validacao.' }
