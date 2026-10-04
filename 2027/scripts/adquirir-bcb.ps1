# Aquisição docente pela interface SOAP oficial SGS quando REST não responde.
# Aulas e relatórios não executam este script. Intervalo diário menor que dez anos.
$ErrorActionPreference = 'Stop'
$raizCurso = Split-Path -Parent $PSScriptRoot
$codigosCurso = @(432, 13762, 4513, 5793, 5760, 5727)
foreach ($grupoCurso in @(@(432), @(13762, 4513, 5793, 5760, 5727))) {
$itensCurso = ($grupoCurso | ForEach-Object { '<item xsi:type="xsd:long">' + $_ + '</item>' }) -join ''
$corpoCurso = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sgs="http://publico.ws.casosdeuso.sgs.pec.bcb.gov.br" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><soapenv:Body><sgs:getValoresSeriesXML soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><in0 xsi:type="soapenc:Array" soapenc:arrayType="xsd:long[' + $grupoCurso.Count + ']">' + $itensCurso + '</in0><in1 xsi:type="xsd:string">01/01/2019</in1><in2 xsi:type="xsd:string">31/12/2025</in2></sgs:getValoresSeriesXML></soapenv:Body></soapenv:Envelope>'
$urlCurso = 'https://www3.bcb.gov.br/wssgs/services/FachadaWSSGS'
$respostaCurso = Invoke-WebRequest -Uri $urlCurso -Method Post -Body $corpoCurso -ContentType 'text/xml;charset=UTF-8' -Headers @{SOAPAction='""'} -TimeoutSec 60
[xml]$envelopeCurso = $respostaCurso.Content
$nodoCurso = $envelopeCurso.SelectSingleNode('//*[local-name()="getValoresSeriesXMLReturn"]')
if ($null -eq $nodoCurso) { throw 'SOAP não retornou séries; arquivo anterior preservado.' }
$xmlCurso = $nodoCurso.InnerText
[xml]$seriesCurso = $xmlCurso
if (@($seriesCurso.SERIES.SERIE).Count -ne $grupoCurso.Count) { throw 'Número de séries diferente do esperado.' }
$nomeCurso = if ($grupoCurso.Count -eq 1) { 'bcb-diaria.xml' } else { 'bcb-mensais.xml' }
$destinoCurso = Join-Path $raizCurso ('data/raw/' + $nomeCurso)
[System.IO.File]::WriteAllText($destinoCurso, $xmlCurso, [System.Text.UTF8Encoding]::new($false))
}
$notaCurso = @{fonte=$urlCurso; metodo='getValoresSeriesXML'; codigos=$codigosCurso; inicio='2019-01-01'; fim='2025-12-31'; extraido_utc=[DateTime]::UtcNow.ToString('o')}
$notaCurso | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $raizCurso 'data/bcb-procedencia.json') -Encoding utf8
Write-Output ('SGS: {0} séries salvas pela interface oficial SOAP.' -f $seriesCurso.SERIES.SERIE.Count)
