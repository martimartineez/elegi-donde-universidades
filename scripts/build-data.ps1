$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $root "data"
$outputPath = Join-Path $sourceRoot "universidades.js"
$areaLabels = @{
    ciencias_aplicadas = "Ciencias aplicadas"
    ciencias_basicas = "Ciencias básicas"
    ciencias_salud = "Ciencias de la salud"
    ciencias_humanas = "Ciencias humanas"
    ciencias_sociales = "Ciencias sociales"
}
$subareaLabels = @{
    arquitectura_disenio = "Arquitectura y diseño"
    astronomia = "Astronomía"
    astronomina = "Astronomía"
    bioquimica_farmacia = "Bioquímica y farmacia"
    ciencias_agropecuarias = "Ciencias agropecuarias"
    ciencias_agrop = "Ciencias agropecuarias"
    suelo = "Ciencias del suelo"
    ciencias_suelo = "Ciencias del suelo"
    estadistica = "Estadística"
    indistrias = "Industrias"
    industrias = "Industrias"
    industria = "Industrias"
    informatica = "Informática"
    ing = "Ingeniería"
    metereologia = "Meteorología"
    otras_ca = "Otras ciencias aplicadas"
    biologia = "Biología"
    fisica = "Física"
    matematica = "Matemática"
    quimica = "Química"
    medicina = "Medicina"
    odontologia = "Odontología"
    paramedicas_auxiliares = "Paramédicas y auxiliares"
    paramedico_auxiliares = "Paramédicas y auxiliares"
    salud_publica = "Salud pública"
    sanidad = "Sanidad"
    veterinaria = "Veterinaria"
    arqueologia = "Arqueología"
    artes = "Artes"
    educacion = "Educación"
    filosofia = "Filosofía"
    historia = "Historia"
    letras_idiomas = "Letras e idiomas"
    psicologia = "Psicología"
    teologia = "Teología"
    ciencias_informacion_comunicacion = "Información y comunicación"
    ci = "Información y comunicación"
    ciencias_politicas_relaciones = "Ciencias políticas y relaciones"
    cp = "Ciencias políticas y relaciones"
    demografia_geografia = "Demografía y geografía"
    dg = "Demografía y geografía"
    derecho = "Derecho"
    economia_administracion = "Economía y administración"
    economia = "Economía y administración"
    otras_cs = "Otras ciencias sociales"
    otras = "Otras ciencias sociales"
    relaciones_institucionales_humanas = "Relaciones institucionales"
    relaciones = "Relaciones institucionales"
    sociologia = "Sociología"
}
$postalLocations = @{
    "1613" = @("Los Polvorines", "Buenos Aires")
    "1642" = @("San Fernando", "Buenos Aires")
    "1650" = @("San Martín", "Buenos Aires")
    "1665" = @("José C. Paz", "Buenos Aires")
    "1678" = @("Caseros", "Buenos Aires")
    "1686" = @("Villa Tesei", "Buenos Aires")
    "1722" = @("Merlo", "Buenos Aires")
    "1744" = @("Moreno", "Buenos Aires")
    "1754" = @("San Justo", "Buenos Aires")
    "1804" = @("Ezeiza", "Buenos Aires")
    "1826" = @("Lanús", "Buenos Aires")
    "1832" = @("Lomas de Zamora", "Buenos Aires")
    "1852" = @("Burzaco", "Buenos Aires")
    "1870" = @("Avellaneda", "Buenos Aires")
    "1876" = @("Bernal", "Buenos Aires")
    "1888" = @("Florencio Varela", "Buenos Aires")
    "1900" = @("La Plata", "Buenos Aires")
    "2000" = @("Rosario", "Santa Fe")
    "2302" = @("Rafaela", "Santa Fe")
    "2760" = @("San Antonio de Areco", "Buenos Aires")
    "3000" = @("Santa Fe", "Santa Fe")
    "3102" = @("Paraná", "Entre Ríos")
    "3103" = @("Libertador San Martín", "Entre Ríos")
    "3260" = @("Concepción del Uruguay", "Entre Ríos")
    "3300" = @("Posadas", "Misiones")
    "3364" = @("San Vicente", "Misiones")
    "3400" = @("Corrientes", "Corrientes")
    "3600" = @("Formosa", "Formosa")
    "3700" = @("Presidencia Roque Sáenz Peña", "Chaco")
    "4000" = @("San Miguel de Tucumán", "Tucumán")
    "4200" = @("Santiago del Estero", "Santiago del Estero")
    "4400" = @("Salta", "Salta")
    "4600" = @("San Salvador de Jujuy", "Jujuy")
    "4700" = @("San Fernando del Valle de Catamarca", "Catamarca")
    "5000" = @("Córdoba", "Córdoba")
    "5147" = @("Córdoba", "Córdoba")
    "5300" = @("La Rioja", "La Rioja")
    "5360" = @("Chilecito", "La Rioja")
    "5400" = @("San Juan", "San Juan")
    "5500" = @("Mendoza", "Mendoza")
    "5501" = @("Godoy Cruz", "Mendoza")
    "5519" = @("Guaymallén", "Mendoza")
    "5700" = @("San Luis", "San Luis")
    "5730" = @("Villa Mercedes", "San Luis")
    "5800" = @("Río Cuarto", "Córdoba")
    "5881" = @("Villa de Merlo", "San Luis")
    "5903" = @("Villa María", "Córdoba")
    "6000" = @("Junín", "Buenos Aires")
    "6300" = @("Santa Rosa", "La Pampa")
    "6700" = @("Luján", "Buenos Aires")
    "7000" = @("Tandil", "Buenos Aires")
    "7109" = @("Mar de Ajó", "Buenos Aires")
    "7600" = @("Mar del Plata", "Buenos Aires")
    "8000" = @("Bahía Blanca", "Buenos Aires")
    "8170" = @("Pigüé", "Buenos Aires")
    "8300" = @("Neuquén", "Neuquén")
    "8332" = @("General Roca", "Río Negro")
    "8500" = @("Viedma", "Río Negro")
    "9000" = @("Comodoro Rivadavia", "Chubut")
    "9103" = @("Rawson", "Chubut")
    "9400" = @("Río Gallegos", "Santa Cruz")
    "9410" = @("Ushuaia", "Tierra del Fuego")
}

function Get-NormalizedVariants {
    param([string]$Value)

    $clean = $Value.ToLowerInvariant()
    $clean = $clean.Replace("©", "o").Replace("½", "o").Replace("ÿ", "a")
    $clean = $clean.Replace("ñ", "i").Replace([string][char]0x00AD, "i")
    $clean = $clean.Normalize([Text.NormalizationForm]::FormD) -replace "\p{Mn}", ""
    $clean = $clean -replace "[^a-z0-9?]", ""
    $variants = [System.Collections.Generic.List[string]]::new()
    $variants.Add($clean.Replace("?", "a"))
    foreach ($vowel in @("e", "i", "o", "u")) {
        $variants.Add($clean.Replace("?", $vowel))
    }
    return $variants | Select-Object -Unique
}

function Import-DelimitedRows {
    param([string]$Path, [string]$Delimiter)
    return @(Get-Content -LiteralPath $Path -Encoding UTF8 | ConvertFrom-Csv -Delimiter $Delimiter)
}

function Get-Number {
    param($Value)
    $parsed = 0.0
    if ([double]::TryParse([string]$Value, [Globalization.NumberStyles]::Any,
            [Globalization.CultureInfo]::InvariantCulture, [ref]$parsed)) {
        return $parsed
    }
    return 0.0
}

function Repair-ImportedText {
    param([string]$Value)

    $clean = $Value.Replace("©", "ó").Replace("½", "ó").Replace("ÿ", "á")
    $clean = $clean.Replace("Ñ", "í").Replace([string][char]0x00AD, "í")
    foreach ($pair in @{
        "Biom?dicas" = "Biomédicas"
        "C?rdoba" = "Córdoba"
        "Tucum?n" = "Tucumán"
        "Jos? C. Paz" = "José C. Paz"
        "Ra?l" = "Raúl"
        "Ant?rtida" = "Antártida"
        "Atl?ntico" = "Atlántico"
        "Andr?s" = "Andrés"
        "Lan?s" = "Lanús"
        "Luj?n" = "Luján"
        "Mar?n" = "Marín"
        "Tom?s" = "Tomás"
        "Teologia" = "Teología"
        "Economia" = "Economía"
        "Administracion" = "Administración"
        "Psicoanalitica" = "Psicoanalítica"
        "Santa Maria" = "Santa María"
        "Plácido Marin" = "Plácido Marín"
    }.GetEnumerator()) {
        $clean = $clean.Replace($pair.Key, $pair.Value)
    }
    return $clean.Trim().Trim('"')
}

function Get-InstitutionMatch {
    param([string]$Alias, [object[]]$Candidates)

    $institutionAliases = @{
        "Centro de la PBA" = "35"
        "Gral. Sarmiento" = "87"
        "Noroeste de la PBA" = "2158"
        "Oeste" = "2632"
        "Patagonia S. J. Bosco" = "42"
        "San Juan" = "53"
        "Sur" = "56"
        "Artes" = "3101"
        "Entre Ríos" = "39"
        "DD. HH. Madres de Plaza de Mayo" = "3098"
        "FASTA" = "101"
        "Cs de la Salud de la Fundación Barceló" = "103"
        "ESEADE" = "924"
        "ITBA" = "64"
        "Este" = "2523"
    }
    $institutionId = $institutionAliases[$Alias]
    if ($institutionId) {
        $explicitMatch = $Candidates | Where-Object { $_.id -eq $institutionId } | Select-Object -First 1
        if ($explicitMatch) { return $explicitMatch }
    }

    $aliasForms = @(Get-NormalizedVariants $Alias)
    $best = $null
    $bestScore = 0
    foreach ($candidate in $Candidates) {
        $candidateForms = @(Get-NormalizedVariants $candidate.name)
        foreach ($candidateForm in $candidateForms) {
            foreach ($aliasForm in $aliasForms) {
                if ($aliasForm.Length -lt 4) { continue }
                if ($candidateForm.Contains($aliasForm)) {
                    if ($aliasForm.Length -gt $bestScore) {
                        $best = $candidate
                        $bestScore = $aliasForm.Length
                    }
                }
            }
        }
    }
    return $best
}

$institutions = [System.Collections.Generic.List[object]]::new()
foreach ($sector in @(
    @{ name = "Pública"; file = "estatal.utf8.csv"; directory = "Capitulo 2 Pregrado Grado Estatal"; prefix = "Cuadro_2_1_" },
    @{ name = "Privada"; file = "privada.utf8.csv"; directory = "Capitulo 2 Pregrado Grado Privado"; prefix = "Cuadro_2_2_" }
)) {
    $sourcePath = Join-Path $sourceRoot $sector.file
    $rows = Import-DelimitedRows $sourcePath ";"
    foreach ($row in $rows) {
        $name = Repair-ImportedText ([string]$row.Universidad)
        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        $postalCode = ([string]$row.'Codigo Postal').Trim()
        $location = $postalLocations[$postalCode]
        if (-not $location -and $postalCode -match "^\d{4}$") {
            $number = [int]$postalCode
            if ($number -ge 1000 -and $number -lt 1500) { $location = @("Ciudad de Buenos Aires", "Ciudad Autónoma de Buenos Aires") }
            elseif ($number -ge 1600 -and $number -lt 2000) { $location = @("Localidad no informada", "Buenos Aires") }
            elseif (($number -ge 2000 -and $number -lt 3000) -or ($number -ge 3000 -and $number -lt 3100)) { $location = @("Localidad no informada", "Santa Fe") }
            elseif ($number -ge 3100 -and $number -lt 3300) { $location = @("Localidad no informada", "Entre Ríos") }
            elseif ($number -ge 3300 -and $number -lt 3400) { $location = @("Localidad no informada", "Misiones") }
            elseif ($number -ge 3400 -and $number -lt 3500) { $location = @("Localidad no informada", "Corrientes") }
            elseif ($number -ge 3500 -and $number -lt 3600) { $location = @("Localidad no informada", "Chaco") }
            elseif ($number -ge 3600 -and $number -lt 3700) { $location = @("Localidad no informada", "Formosa") }
            elseif ($number -ge 3700 -and $number -lt 4000) { $location = @("Localidad no informada", "Chaco") }
            elseif ($number -ge 4000 -and $number -lt 4200) { $location = @("Localidad no informada", "Tucumán") }
            elseif ($number -ge 4200 -and $number -lt 4400) { $location = @("Localidad no informada", "Santiago del Estero") }
            elseif ($number -ge 4400 -and $number -lt 4600) { $location = @("Localidad no informada", "Salta") }
            elseif ($number -ge 4600 -and $number -lt 4700) { $location = @("Localidad no informada", "Jujuy") }
            elseif ($number -ge 4700 -and $number -lt 5000) { $location = @("Localidad no informada", "Catamarca") }
            elseif ($number -ge 5000 -and $number -lt 5300) { $location = @("Localidad no informada", "Córdoba") }
            elseif ($number -ge 5300 -and $number -lt 5400) { $location = @("Localidad no informada", "La Rioja") }
            elseif ($number -ge 5400 -and $number -lt 5500) { $location = @("Localidad no informada", "San Juan") }
            elseif ($number -ge 5500 -and $number -lt 5700) { $location = @("Localidad no informada", "Mendoza") }
            elseif ($number -ge 5700 -and $number -lt 5800) { $location = @("Localidad no informada", "San Luis") }
            elseif ($number -ge 5800 -and $number -lt 6000) { $location = @("Localidad no informada", "Córdoba") }
            elseif ($number -ge 6000 -and $number -lt 6300) { $location = @("Localidad no informada", "Buenos Aires") }
            elseif ($number -ge 6300 -and $number -lt 6700) { $location = @("Localidad no informada", "La Pampa") }
            elseif ($number -ge 6700 -and $number -lt 7600) { $location = @("Localidad no informada", "Buenos Aires") }
            elseif ($number -ge 7600 -and $number -lt 8200) { $location = @("Localidad no informada", "Buenos Aires") }
            elseif ($number -ge 8300 -and $number -lt 8400) { $location = @("Localidad no informada", "Neuquén") }
            elseif ($number -ge 8400 -and $number -lt 9000) { $location = @("Localidad no informada", "Río Negro") }
            elseif ($number -ge 9000 -and $number -lt 9400) { $location = @("Localidad no informada", "Chubut") }
            elseif ($number -ge 9400 -and $number -lt 9410) { $location = @("Localidad no informada", "Santa Cruz") }
            elseif ($number -ge 9410 -and $number -lt 9500) { $location = @("Localidad no informada", "Tierra del Fuego") }
        }

        $institutions.Add([pscustomobject]@{
            id = [string]$row.'Id Universidad'
            name = $name
            sector = $sector.name
            province = if ($location) { $location[1] } else { "" }
            areas = [System.Collections.Generic.List[string]]::new()
            subareas = [System.Collections.Generic.List[string]]::new()
            students2022 = 0
        })
    }

    $candidates = @($institutions | Where-Object { $_.sector -eq $sector.name })
    $annualDirectory = Join-Path (Join-Path $sourceRoot "anuario2022\Anuario 2022") $sector.directory

    $totalTable = Join-Path $annualDirectory "$($sector.prefix)1.csv"
    foreach ($row in (Import-DelimitedRows $totalTable "|")) {
        $match = Get-InstitutionMatch ([string]$row.nombre_corto) $candidates
        if ($match) { $match.students2022 = [int](Get-Number $row._2022) }
    }

    $areaTable = Join-Path $annualDirectory "$($sector.prefix)9.csv"
    foreach ($row in (Import-DelimitedRows $areaTable "|")) {
        $match = Get-InstitutionMatch ([string]$row.nombre_corto) $candidates
        if (-not $match) { continue }
        foreach ($column in $row.PSObject.Properties) {
            if ($column.Name -match "^(est|ma)_(.+)$" -and $areaLabels.ContainsKey($Matches[2]) -and (Get-Number $column.Value) -gt 0) {
                $label = $areaLabels[$Matches[2]]
                if (-not $match.areas.Contains($label)) { $match.areas.Add($label) }
            }
        }
    }

    $tableAreaMap = @{
        "10" = "Ciencias aplicadas"
        "11" = "Ciencias básicas"
        "12" = "Ciencias de la salud"
        "13" = "Ciencias humanas"
        "14" = "Ciencias sociales"
    }
    foreach ($tableNumber in $tableAreaMap.Keys) {
        $path = Join-Path $annualDirectory "$($sector.prefix)$tableNumber.csv"
        if (-not (Test-Path -LiteralPath $path)) { continue }
        foreach ($row in (Import-DelimitedRows $path "|")) {
            $match = Get-InstitutionMatch ([string]$row.nombre_corto) $candidates
            if (-not $match) { continue }
            foreach ($column in $row.PSObject.Properties) {
                if ($column.Name -match "^(est|ma)_(.+)$" -and (Get-Number $column.Value) -gt 0) {
                    $subarea = $subareaLabels[$Matches[2]]
                    if ($subarea -and -not $match.subareas.Contains($subarea)) {
                        $match.subareas.Add($subarea)
                    }
                }
            }
        }
    }
}

$ordered = @($institutions | Sort-Object name)
$data = $ordered | ForEach-Object {
    [pscustomobject]@{
        id = $_.id
        name = $_.name
        sector = $_.sector
        province = $_.province
        areas = @($_.areas | Sort-Object)
        subareas = @($_.subareas | Sort-Object)
        students2022 = $_.students2022
    }
}

$json = ConvertTo-Json -InputObject @($data) -Depth 6
$contents = "window.UNIVERSIDADES = $json;`n"
Set-Content -LiteralPath $outputPath -Value $contents -Encoding UTF8
Write-Output "Generated $($ordered.Count) institutions: $outputPath"
