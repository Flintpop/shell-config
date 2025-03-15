@{
# Nom du module
    RootModule        = 'ShellConfig.psm1'

    # Version du module (suivant la sémantique SemVer)
    ModuleVersion     = '1.0.0'

    # Identifiant unique du module (GUID)
    GUID              = 'e7c2b8f1-9d32-4d3c-8d3a-123456789abc'

    # Informations sur l'auteur
    Author            = 'Tanguy Le Goff'
    CompanyName       = ''

    # Informations sur les droits
    Copyright         = '© 2025 Tanguy Le Goff. Tous droits réservés.'

    # Description du module
    Description       = 'Module pour la gestion centralisée des fichiers de configuration PowerShell, incluant profiles et alias.'

    # Version minimale requise de PowerShell
    PowerShellVersion = '5.1'

    # Les fonctions à exporter (listez ici vos fonctions publiques)
    FunctionsToExport = @()

    # Cmdlets à exporter (si vous en avez)
    CmdletsToExport   = @()

    # Variables à exporter (si nécessaire)
    VariablesToExport = @('Global:ProjectVersion')

    # Aliases à exporter
    AliasesToExport   = @()

    # Modules requis par ce module (si applicable)
    RequiredModules   = @()

    # Assemblies requis (si applicable)
    RequiredAssemblies= @()

    # Autres dépendances et configurations
    NestedModules     = @()
}
