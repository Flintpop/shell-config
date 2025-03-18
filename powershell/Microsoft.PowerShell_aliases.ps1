# Définition des alias
Set-Alias -Name goperso -Value GoToPersonalProjetDirectory
Set-Alias -Name enp -Value Edit-Nvim-Profile
Set-Alias -Name eb -Value Edit-Profile
Set-Alias -Name eba -Value Edit-AliasFile
Set-Alias -Name so -Value Reload-Profile
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name v -Value nvim
Set-Alias -Name exportProjectCode -Value Export-ProjectCode

# Fonctions

function GoToPersonalProjetDirectory {
    # Utilise $HOME pour pointer vers le dossier personnel de l'utilisateur
    Set-Location -Path "$HOME\OneDrive\projets_perso"
}

function Edit-Nvim-Profile {
    # $env:LOCALAPPDATA référence le dossier AppData\Local de l'utilisateur
    nvim "$env:LOCALAPPDATA\nvim"
}

function Edit-Profile {
    nvim $PROFILE
}

function Edit-AliasFile {
    nvim "$HOME\Documents\PowerShell\Microsoft.PowerShell_aliases.ps1"
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

    # Définir les extensions valides pour le code source
    $validExtensions = @(
        ".java", ".js", ".ts", ".vue", ".cs", ".cpp", ".c",
        ".py", ".rb", ".sh", ".pl", ".php", ".go", ".swift",
        ".html", ".htm", ".css", ".md", ".mdx"
    )

    # Récupérer tous les fichiers source en excluant certains dossiers
    $codeFiles = Get-ChildItem -Path $SourceFolder -Recurse -File |
        Where-Object {
            $validExtensions -contains $_.Extension.ToLower() -and
            $_.FullName -notmatch '\\(build|target|\.gradle|[Tt]est[s]?|node_modules|\.idea|\.nuxt|\.vscode)\\'
        }

    foreach ($file in $codeFiles) {
        Add-Content -Path $OutputFile -Value "// ---- $($file.FullName) ----" -Encoding UTF8
        $content = Get-Content -Path $file.FullName -Raw
        if (-not $content) { $content = "" }

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

        Add-Content -Path $OutputFile -Value $content -Encoding UTF8
        Add-Content -Path $OutputFile -Value "`n" -Encoding UTF8
    }

    Write-Host "Export terminé: $OutputFile"
}
