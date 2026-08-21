Export-ModuleMember -Function Get-StarcoreProjectProfile, Ensure-ProjectDefinition

function Get-StarcoreProjectProfile {
    param([string]$Root = "E:\Git")
    Get-ChildItem $Root -Directory | ForEach-Object {
        $name = $_.Name
        $path = $_.FullName
        $hasGit = Test-Path (Join-Path $path ".git")
        $platform = "MIXED"
        if ($name -match "(?i)android|termux") { $platform = "ANDROID" }
        elseif ($name -match "(?i)rpi|raspberry|ubuntu|ultraos|linux") { $platform = "LINUX" }
        elseif ($name -match "(?i)winpe|powershell|vscode|workspace|run_os") { $platform = "WINDOWS" }
        $category = "OTHER"
        if ($name -match "(?i)starcore-platform|starcore") { $category = "CORE_PLATFORM" }
        elseif ($name -match "(?i)starcore-android|android") { $category = "CORE_ANDROID" }
        elseif ($name -match "(?i)workspace|vscode|codespace") { $category = "WORKSPACE" }
        elseif ($name -match "(?i)supernastroj|starko") { $category = "TOOLS" }
        [PSCustomObject]@{
            Name = $name; Path = $path; Git = $hasGit; Platform = $platform; Category = $category
        }
    }
}

function Ensure-ProjectDefinition {
    param([string]$ProjectPath)
    $pd = Join-Path $ProjectPath "PROJECT_DEFINITION.md"
    if (-not (Test-Path $pd)) {
        $name = Split-Path $ProjectPath -Leaf
        $content = Get-Content (Join-Path $PSScriptRoot "..\project_definition_template.md") -Raw
        $content = $content -replace "{{NAME}}",$name
        $content | Set-Content $pd -Encoding UTF8
        return $true
    }
    return $false
}
