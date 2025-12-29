$ErrorActionPreference = "Stop"

function Remove-InvalidPath {
}

Remove-InvalidPath

function Normalize-PathEntry {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string]$Path
	)

	if ([string]::IsNullOrWhiteSpace($Path)) { return $null }

	# 展開（%VAR% や $env:..）して絶対パス化を試みる。
	$expanded = [Environment]::ExpandEnvironmentVariables($Path)
	try {
		$resolved = Resolve-Path -Path $expanded -ErrorAction Stop
		$norm = $resolved.Path
		# ルート以外は末尾の区切りを取り除いて正規化
		$root = [IO.Path]::GetPathRoot($norm)
		if ($norm -ne $root) { $norm = $norm.TrimEnd('\','/') }
		return $norm
	} catch {
		# 存在しないパスは null を返す（呼び出し側で判定するため）
		return $null
	}
}
# ユーザー環境変数 PATH を取得し、各要素を Normalize-PathEntry に渡して配列で返す
function Get-UserPathEntries {
	[CmdletBinding()]
	param(
		[string]$RawPathString
	)

	if ($PSBoundParameters.ContainsKey('RawPathString')) {
		$raw = $RawPathString
	} else {
		try {
			$user = Get-UserPathRaw
		} catch {
			$user = $null
		}
		if ($null -eq $user -or [string]::IsNullOrEmpty($user.PATH)) { return @() }
		$raw = $user.PATH
	}

	# ここでは正規化せず、生のパス要素（trim されたもの）を返す
	$parts = $raw -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
	return ,$parts
}

# 内部ヘルパー: 実際の実装はここにあり、テスト時に Mock される想定
function Get-UserPathRaw {
	try {
		return Get-ItemProperty -Path 'HKCU:\Environment' -Name PATH -ErrorAction SilentlyContinue
	} catch {
		return $null
	}
}
# スクリプトとして読み込む用途のため、Export-ModuleMember は使用しない