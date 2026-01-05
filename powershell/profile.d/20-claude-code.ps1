function Start-ClaudeYolo {
    & claude --dangerously-skip-permissions @args
}

Set-Alias -Name claude-yolo -Value Start-ClaudeYolo