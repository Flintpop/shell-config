Invoke-Expression (&starship init powershell)

function trash {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Path
    )

    $shell = New-Object -ComObject Shell.Application
    $item = Get-Item -Path $Path
    $folder = Split-Path -Path $item.FullName -Parent
    $shellItem = $shell.NameSpace($folder).ParseName($item.Name)
    $shellItem.InvokeVerb("delete")
}

. ~\Documents\PowerShell\Microsoft.PowerShell_aliases.ps1
