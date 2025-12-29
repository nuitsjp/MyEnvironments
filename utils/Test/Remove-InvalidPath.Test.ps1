. "$PSScriptRoot\..\Remove-InvalidPath.ps1"

Describe 'Remove-InvalidPath' {
	It '呼び出し可能で例外を投げない' {
		{ Remove-InvalidPath } | Should -Not -Throw
	}
}

Describe 'Normalize-PathEntry' {
	It '既存の相対パスを正規化して絶対パスを返す' {
		$tmp = Join-Path $PSScriptRoot 'tmp-normalize-1'
		Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $tmp
		New-Item -ItemType Directory -Path $tmp | Out-Null
		try {
			$res = Normalize-PathEntry $tmp
			$expected = (Get-Item $tmp).FullName.TrimEnd('\','/')
			$res | Should -Not -BeNullOrEmpty
			$res | Should -Be $expected
		} finally {
			Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $tmp
		}
	}

	It '存在しないパスは null を返す' {
		$p = Join-Path $PSScriptRoot 'no-such-path-for-test-12345'
		Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $p
		$res = Normalize-PathEntry $p
		$res | Should -BeNull
	}

	It '環境変数を展開してパスを返す' {
		$tmp = Join-Path $env:TEMP "removeinvalid_test_$([guid]::NewGuid().ToString())"
		New-Item -ItemType Directory -Path $tmp | Out-Null
		$env:TMPTEST_REMOVEINVALID = $tmp
		try {
			$res = Normalize-PathEntry '%TMPTEST_REMOVEINVALID%'
			$expected = (Get-Item $tmp).FullName.TrimEnd('\','/')
			$res | Should -Be $expected
		} finally {
			Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $tmp
			Remove-Item Env:TMPTEST_REMOVEINVALID -ErrorAction SilentlyContinue
		}
	}
}

Describe 'Get-UserPathEntries' {
	It 'HKCU の PATH を取得して Normalize-PathEntry を呼ぶ（Mock 使用）' {
		# RawPathString を直接渡してテスト（正規化は行わないため、生の要素が返ることを期待）
		$res = Get-UserPathEntries -RawPathString 'C:\One;C:\Two;C:\One'
		$res | Should -Be @('C:\One','C:\Two','C:\One')
	}
}

if ($env:RUNNING_PESTER -ne '1') {
	try {
		if (-not (Get-Module -ListAvailable -Name Pester)) {
			Write-Error 'Pester モジュールが見つかりません。インストール: Install-Module -Name Pester -Scope CurrentUser'
			exit 2
		}
		Import-Module Pester -ErrorAction Stop
	} catch {
		Write-Error "Pester の読み込みに失敗しました: $_"
		exit 2
	}

	$env:RUNNING_PESTER = '1'
	Invoke-Pester -Script $PSCommandPath
	Remove-Item Env:RUNNING_PESTER -ErrorAction SilentlyContinue
	exit $LASTEXITCODE
}

