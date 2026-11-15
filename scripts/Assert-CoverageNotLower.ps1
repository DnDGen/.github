param(
    [Parameter(Mandatory)]
    [string]$ReportPath,

    [Parameter(Mandatory)]
    [string]$BaselinePath
)

$ErrorActionPreference = 'Stop'

function Get-Coverage {
    param([string]$Path)

    $root = ([xml](Get-Content -Path $Path -Raw)).coverage

    return @{
        Line   = @{ Covered = [long]$root.'lines-covered'; Valid = [long]$root.'lines-valid' }
        Branch = @{ Covered = [long]$root.'branches-covered'; Valid = [long]$root.'branches-valid' }
    }
}

function Get-FullFraction {
    param([hashtable]$Count)

    if ($Count.Valid -eq 0) {
        return @{ Covered = 1; Valid = 1 }
    }

    return $Count
}

function Test-IsLower {
    param([hashtable]$Change, [hashtable]$Baseline)

    $change = Get-FullFraction $Change
    $baseline = Get-FullFraction $Baseline

    return $change.Covered * $baseline.Valid -lt $baseline.Covered * $change.Valid
}

function Format-Coverage {
    param([hashtable]$Count)

    $fraction = Get-FullFraction $Count
    $percent = (100.0 * $fraction.Covered / $fraction.Valid).ToString('0.00', [cultureinfo]::InvariantCulture)

    return "$($Count.Covered)/$($Count.Valid) ($percent%)"
}

# The release job fails if it can't attach a coverage report, so a missing baseline means there
# is nothing to compare against yet: no release, or one made before releases carried a report.
if (-not (Test-Path -Path $BaselinePath)) {
    Write-Host "::warning title=No coverage baseline::No coverage report for the latest release to compare against: $BaselinePath. Skipping the coverage check."
    return
}

$change = Get-Coverage $ReportPath
$baseline = Get-Coverage $BaselinePath

$drops = foreach ($kind in 'Line', 'Branch') {
    if (Test-IsLower -Change $change[$kind] -Baseline $baseline[$kind]) {
        "$kind coverage dropped from $(Format-Coverage $baseline[$kind]) to $(Format-Coverage $change[$kind])."
    }
}

if ($drops) {
    throw ($drops -join ' ')
}

Write-Host "Line coverage $(Format-Coverage $change.Line) and branch coverage $(Format-Coverage $change.Branch) are no lower than the latest release's $(Format-Coverage $baseline.Line) and $(Format-Coverage $baseline.Branch)."
