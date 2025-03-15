Set-Alias -Name goperso -Value GoToPersonalProjetDirectory
Set-Alias -Name enp -Value Edit-Nvim-Profile
Set-Alias -Name eb -Value Edit-Profile
Set-Alias -Name eba -Value Edit-AliasFile
Set-Alias -Name so -Value Reload-Profile
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name v -Value nvim
Set-Alias -Name exportProjectCode -Value Export-ProjectCode

function GoToPersonalProjetDirectory {
    Set-Location -Path '~\OneDrive\projets_perso'
}

function Edit-Nvim-Profile {
    nvim 'C:\Users\darwh\AppData\Local\nvim'
}

function Edit-Profile {
    nvim $PROFILE
}

function Edit-AliasFile {
    nvim 'C:\users\darwh\Documents\PowerShell\Microsoft.PowerShell_aliases.ps1'
}

function Reload-Profile {
    . $PROFILE
}

function Export-ProjectCode {
    param(
        [string]$SourceFolder = (Get-Location).Path,
        [string]$OutputFile = (Join-Path (Get-Location).Path "allProjectCode.txt")
    )

    # Supprimer le fichier de sortie s'il existe
    if (Test-Path $OutputFile) {
        Remove-Item $OutputFile -Force
    }

    # Définir les extensions valides pour le code source (les .txt sont exclus)
    $validExtensions = @(
        ".java", ".js", ".ts", ".vue", ".cs", ".cpp", ".c",
        ".py", ".rb", ".sh", ".pl", ".php", ".go", ".swift",
        ".html", ".htm", ".css"
    )

    # Récupérer tous les fichiers source en excluant certains dossiers :
    # build, target, .gradle, tests, node_modules, .idea, .nuxt, .vscode
    $codeFiles = Get-ChildItem -Path $SourceFolder -Recurse -File |
            Where-Object {
                $validExtensions -contains $_.Extension.ToLower() -and
                        $_.FullName -notmatch '\\(build|target|\.gradle|[Tt]est[s]?|node_modules|\.idea|\.nuxt|\.vscode)\\'
            }

    foreach ($file in $codeFiles) {
        # Écrire l'en-tête du fichier dans le fichier de sortie
        Add-Content -Path $OutputFile -Value "// ---- $($file.FullName) ----" -Encoding UTF8

        # Lire le contenu du fichier et s'assurer qu'il n'est pas null
        $content = Get-Content -Path $file.FullName -Raw
        if (-not $content) { $content = "" }

        # Supprimer les commentaires en fonction de l'extension du fichier
        switch ($file.Extension.ToLower()) {
            { $_ -in @(".java", ".js", ".ts", ".vue", ".cs", ".cpp", ".c", ".go", ".swift", ".php") } {
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, '/\*[\s\S]*?\*/', '')
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, '//.*', '')
            }
            { $_ -in @(".py", ".rb", ".sh", ".pl") } {
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, '#.*', '')
            }
            { $_ -in @(".html", ".htm") } {
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, '<!--[\s\S]*?-->', '')
            }
            default { }
        }

        # Écrire le contenu filtré dans le fichier de sortie
        Add-Content -Path $OutputFile -Value $content -Encoding UTF8

        # Ajouter une ligne vide pour améliorer la lisibilité
        Add-Content -Path $OutputFile -Value "`n" -Encoding UTF8
    }

    Write-Host "Export terminé: $OutputFile"
}
