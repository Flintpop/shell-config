# Test-ConfigValidity.ps1
Write-Host "=== Test de sourçabilité des fichiers de configuration ==="

function Test-Sourceable {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    Write-Host "Test du fichier : $FilePath"
    try {
        . $FilePath
        Write-Host "OK : Le fichier '$FilePath' est sourçable."
        return $true
    }
    catch {
        Write-Error "Erreur lors du sourcing de '$FilePath' : $_"
        return $false
    }
}

# Chemins des fichiers à tester (supposés être dans le même répertoire que ce script)
$profileFile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile.ps1"
$aliasesFile = Join-Path $PSScriptRoot "Microsoft.PowerShell_aliases.ps1"

$testProfile = Test-Sourceable -FilePath $profileFile
$testAliases = Test-Sourceable -FilePath $aliasesFile

if ($testProfile -and $testAliases) {
    Write-Host "Tous les fichiers sont sourçables. Test réussi."
    exit 0
}
else {
    Write-Error "Un ou plusieurs fichiers ne sont pas sourçables. Test échoué."
    exit 1
}
