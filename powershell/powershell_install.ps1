<#
.SYNOPSIS
    Installe et met à jour automatiquement les fichiers de configuration PowerShell pour Windows (v5.x) et PowerShell 7 (si installé).

.DESCRIPTION
    Ce script copie les fichiers de configuration (Microsoft.PowerShell_profile.ps1 et Microsoft.PowerShell_aliases.ps1) depuis
    le répertoire du dépôt vers les emplacements cibles selon la version de PowerShell et le contexte (current user / all users).
    Il crée les dossiers cibles si nécessaire, sauvegarde les fichiers existants, et s’adapte au mode administrateur.

    Pour Windows PowerShell (v5.x) :
        - Installe pour l’utilisateur courant (CurrentUserCurrentHost et CurrentUserAllHosts)
        - Si en mode administrateur, installe également dans le profil de tous les utilisateurs (AllUsersCurrentHost)

    Pour PowerShell 7 (v7.x) :
        - Vérifie si pwsh.exe est présent dans "C:\Program Files\PowerShell\7\"
        - Installe pour l’utilisateur courant dans le dossier habituel (généralement "$HOME\Documents\PowerShell")
        - L’installation pour tous les utilisateurs est en général déconseillée sur PS7 car le répertoire système n’est pas modifiable.

.NOTES
    Pour mettre à jour vos configurations, il vous suffit de faire un git pull dans le dépôt, puis de réexécuter ce script.
#>

# --- Fonction pour tester si on est en mode administrateur ---
function Test-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
$IsAdmin = Test-Admin
Write-Host "Mode administrateur : $IsAdmin"

# --- Détermination du répertoire du dépôt (supposé être celui du script) ---
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Chemins sources des fichiers de configuration dans le dépôt ---
$profileSource = Join-Path $repoRoot "Microsoft.PowerShell_profile.ps1"
$aliasesSource = Join-Path $repoRoot "Microsoft.PowerShell_aliases.ps1"

# Vérification de l'existence des fichiers sources
if (-not (Test-Path $profileSource)) {
    Write-Error "Fichier de profil non trouvé : $profileSource"
    exit 1
}
if (-not (Test-Path $aliasesSource)) {
    Write-Error "Fichier d'alias non trouvé : $aliasesSource"
    exit 1
}

# --- Fonction pour installer un fichier en créant le dossier et en sauvegardant l'ancien fichier ---
function Install-File {
    param (
        [string]$source,
        [string]$destination
    )
    Write-Host "Installation de $source vers $destination"
    $destDir = Split-Path -Parent $destination
    if (-not (Test-Path $destDir)) {
        Write-Host "Création du répertoire : $destDir"
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    if (Test-Path $destination) {
        $backupPath = "$destination.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Host "Sauvegarde de l'ancien fichier vers : $backupPath"
        Copy-Item -Path $destination -Destination $backupPath -Force
    }
    Copy-Item -Path $source -Destination $destination -Force
}

# --- Installation pour Windows PowerShell (v5.x) ---
Write-Host "`n=== Installation pour Windows PowerShell (v5.x) ==="
# Les chemins de profil sont définis par la variable $PROFILE dans PS5
$currentUserProfile_PS5 = $PROFILE.CurrentUserCurrentHost  # Profil courant de l'utilisateur pour le host courant
$allUsersProfile_PS5  = $PROFILE.AllUsersCurrentHost       # Profil pour tous les utilisateurs (écrivables en mode admin)

# Installation pour l'utilisateur courant
Install-File -source $profileSource -destination $currentUserProfile_PS5
$aliasesDestination_PS5 = Join-Path (Split-Path $currentUserProfile_PS5 -Parent) "Microsoft.PowerShell_aliases.ps1"
Install-File -source $aliasesSource -destination $aliasesDestination_PS5

# Si en mode administrateur, installation pour tous les utilisateurs
if ($IsAdmin) {
    Write-Host "`nInstallation pour tous les utilisateurs (Windows PowerShell) :"
    Install-File -source $profileSource -destination $allUsersProfile_PS5
}

# --- Installation pour PowerShell 7 (v7.x) ---
# Détection de PowerShell 7 même depuis PS5
$pwshExe = Get-Command pwsh.exe -ErrorAction SilentlyContinue
if ($pwshExe) {
    try {
        # On exécute pwsh.exe en ligne de commande pour récupérer le Major version
        $ps7VersionOutput = & $pwshExe.Path -NoProfile -Command { $PSVersionTable.PSVersion.Major }
        $ps7Version = [int]($ps7VersionOutput | Out-String).Trim()
    }
    catch {
        $ps7Version = 0
    }

    if ($ps7Version -ge 7) {
        Write-Host "`n=== PowerShell 7 détecté (version $ps7Version). Installation pour PowerShell 7 (v7.x) ==="
        # Pour PS7, le dossier de profil par défaut pour l'utilisateur est généralement dans Documents\PowerShell
        $myDocuments = [Environment]::GetFolderPath("MyDocuments")
        $ps7Dir = Join-Path $myDocuments "PowerShell"
        $currentUserProfile_PS7 = Join-Path $ps7Dir "Microsoft.PowerShell_profile.ps1"
        $aliasesDestination_PS7 = Join-Path $ps7Dir "Microsoft.PowerShell_aliases.ps1"

        Install-File -source $profileSource -destination $currentUserProfile_PS7
        Install-File -source $aliasesSource -destination $aliasesDestination_PS7

        if ($IsAdmin) {
            Write-Host "`nNote : L'installation pour tous les utilisateurs sous PowerShell 7 est rarement souhaitable, car les répertoires système sont en lecture seule."
        }
    }
    else {
        Write-Host "`nPowerShell 7 non détecté (version détectée: $ps7Version). Installation limitée à Windows PowerShell (v5.x)."
    }
}
else {
    Write-Host "`nPowerShell 7 non détecté. Installation limitée à Windows PowerShell (v5.x)."
}
Write-Host "`nInstallation terminée. Pour mettre à jour vos configurations, effectuez un 'git pull' dans le dépôt et relancez ce script."
