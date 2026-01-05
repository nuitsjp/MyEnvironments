function Start-Codex {
    param(
        [switch]$Yolo, 
        [switch]$Azure
    )

    if ($Azure) {
        codex logout > $null 2>&1
    }

    $codexArgs = @(
        '--enable', 'experimental_windows_sandbox', 
        '--sandbox', 'danger-full-access',
        '--ask-for-approval', 'never',
        '--config', 'windows_wsl_setup_acknowledged=true'
    )

    if ($Yolo) {
        $codexArgs = @('--dangerously-bypass-approvals-and-sandbox') + $codexArgs
    }

    if ($Azure) {
        $codexArgs = @('--profile', 'azure') + $codexArgs
    }

    & codex $codexArgs @args
}

function Start-CodexAzure { Start-Codex -Azure }
function Start-CodexAzureYolo { Start-Codex -Azure -Yolo }
function Start-CodexYolo { Start-Codex -Yolo }

Set-Alias -Name codex-azure -Value Start-CodexAzure
Set-Alias -Name codex-azure-yolo -Value Start-CodexAzureYolo
Set-Alias -Name codex-yolo -Value Start-CodexYolo