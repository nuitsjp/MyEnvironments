$ErrorActionPreference = 'Stop'

function Init-Environments {
	[CmdletBinding()]
	param(
		[string]$TaskName = 'UpdatePackages',
		[string[]]$Time = @('07:10','12:10')
	)

	# 実行するコマンドを .cmd に変更
	$cmdPath = Join-Path $PSScriptRoot 'Update-Packages.cmd'

	if (-not (Test-Path $cmdPath)) {
		Write-Error "スクリプトが見つかりません: $cmdPath"
		return
	}

	$cmdExe = (Get-Command 'cmd.exe' -ErrorAction SilentlyContinue).Path
	if (-not $cmdExe) {
		Write-Error "cmd.exe が見つかりません。タスクは登録されません。"
		return
	}

	$action = New-ScheduledTaskAction -Execute $cmdExe -Argument "/c `"$cmdPath`""
	$triggers = $Time | ForEach-Object { New-ScheduledTaskTrigger -Daily -At $_ }

	$user = "$env:USERDOMAIN\$env:USERNAME"
	$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest

	if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
		# 既存タスクがあれば、実行中なら停止してから削除して再登録する（冪等性確保）
		try {
			$info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
			if ($info -and $info.State -eq 'Running') {
				Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
			}
		} catch {
			# Get-ScheduledTaskInfo が失敗しても先に進む
		}

		Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
	}

	Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $triggers -Principal $principal -Force
	Write-Output "Scheduled task '$TaskName' registered to run $scriptPath daily at $($Time -join ', ')."
}

Init-Environments