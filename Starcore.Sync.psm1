Export-ModuleMember -Function Invoke-StarcoreSyncAll

function Invoke-StarcoreSyncAll {
    param([string]$Root = "E:\Git")
    Get-ChildItem $Root -Directory | ForEach-Object {
        $p = $_.FullName
        if (Test-Path (Join-Path $p ".git")) {
            Write-Host "Processing $($_.Name)"
            # ensure HEAD exists
            $hasHead = (git -C $p rev-parse --verify HEAD 2>$null) -ne $null
            if (-not $hasHead) {
                git -C $p add -A
                git -C $p commit -m "Initial commit - auto" 2>$null
            }
            # fetch/pull/push
            try {
                git -C $p fetch origin 2>$null
                git -C $p pull --rebase origin (git -C $p rev-parse --abbrev-ref HEAD) 2>$null
            } catch { }
            try { git -C $p push origin (git -C $p rev-parse --abbrev-ref HEAD) 2>$null } catch { }
        }
    }
}
