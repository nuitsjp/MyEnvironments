function Start-ClaudeYolo {
    & claude --dangerously-skip-permissions @args
}

$env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"
$env:ENABLE_TOOL_SEARCH = 1

Set-Alias -Name claude-yolo -Value Start-ClaudeYolo