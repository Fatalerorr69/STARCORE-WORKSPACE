Export-ModuleMember -Function Invoke-ProjectAudit

function Invoke-ProjectAudit {
    param([string]$ProjectPath)
    $report = [ordered]@{
        Name = Split-Path $ProjectPath -Leaf
        Path = $ProjectPath
        HasGit = Test-Path (Join-Path $ProjectPath ".git")
        HasReadme = Test-Path (Join-Path $ProjectPath "README.md")
        HasProjectDefinition = Test-Path (Join-Path $ProjectPath "PROJECT_DEFINITION.md")
        HasGitIgnore = Test-Path (Join-Path $ProjectPath ".gitignore")
        HasCI = Test-Path (Join-Path $ProjectPath ".github\workflows")
        Uncommitted = $false
        Branch = $null
    }
    if ($report.HasGit) {
        try {
            $status = git -C $ProjectPath status --porcelain 2>$null
            if ($status) { $report.Uncommitted = $true }
            $report.Branch = git -C $ProjectPath rev-parse --abbrev-ref HEAD 2>$null
        } catch { }
    }
    return $report
}
