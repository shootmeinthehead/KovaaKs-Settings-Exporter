Set-ExecutionPolicy Bypass -Scope Process -Force
[Console]::CursorVisible = $false

if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $args
    exit
}
Clear-Host
$fixedWidth = 150
$fixedHeight = 100
[console]::WindowWidth = $fixedWidth
[console]::WindowHeight = $fixedHeight
[console]::BufferWidth = $fixedWidth
[console]::BufferHeight = $fixedHeight


$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*KovaaK*" -and $_.Path -like "*steam*" } | Sort-Object CPU -Descending | Select-Object -First 1
$baseaddr = $proc.MainModule.BaseAddress
#$addrmap = @(
#	@{ name = "proccesPath"; value = $proc.Path }
#	@{ name = "PID"; value = $proc.Id }
#	@{ name = "RAM"; value = "{0:N2} MB " -f ($proc.WorkingSet64 / 1MB) }
#)
$LogP = "$env:USERPROFILE\Appdata\Local\tmplog\log.tmp"

$procPID = $proc.Id
$procP   = $proc.Path

if (-not (Test-Path "$env:USERPROFILE\Appdata\Local\tmplog")) {
"`nCreating log dir..`n"
New-Item -Path "$env:USERPROFILE\Appdata\Local\tmplog" -ItemType Directory -Force | Out-Null
$LogDir = "$env:USERPROFILE\Appdata\Local\tmplog"
}

$LogAVB = Get-Item -Path "$env:USERPROFILE\Appdata\Local\tmplog\log.tmp" -ErrorAction SilentlyContinue
if ($LogAVB) {
	"Previous Log avaible`n"
	Start-Sleep -Seconds 1
} else {
	"No log avaible -> Making a log...`n"
	Start-Sleep -Seconds 1
	New-Item  -Path "$env:USERPROFILE\Appdata\Local\tmplog\log.tmp" -Force | Out-Null
}
function addrdebug {	
	
	
	while ($true) {
		$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*KovaaK*" -and $_.Path -like "*steam*" } | Sort-Object CPU -Descending | Select-Object -First 1
		#proc can be any proc but in this script its just kovaaks, this is usefull tho :3
		
		$baseaddr = $proc.MainModule.BaseAddress
		$maxWidth = $fixedWidth - 1
	
		$addrmap = @(
			@{ name = "processPath"; value = $proc.Path }
			@{ name = "PID"; value = $proc.Id }
			@{ name = "RAM"; value = "{0:N2} MB" -f ($proc.WorkingSet64 / 1MB) }
			)
				
		$lw = 0
	foreach ($entry in $addrmap) {
		if ($entry.name -eq "processPath" -and $entry.value) {
				$prefixL = ("0x{0:X} - [{1}]::[" -f $baseaddr, $entry.name).Length
				$leftL = $maxWidth - $prefixL - 2 # ]]
			if ($entry.value.Length -gt $leftL) {
				$value = $entry.value.Substring(0, $leftL) + "..."
			} else {
				$value = $entry.value
			}
		} else {
			$value = $entry.value
		}

			$debugOUT = "0x{0:X} - [{1}]::[{2}] " -f $baseaddr, $entry.name, $value
			
			if ($debugOUT.Length -gt $maxWidth) {
				$debugOUT = $debugOUT.Substring(0, $maxWidth)
			} else {
				$debugOUT = $debugOUT.PadRight($maxWidth)
			}
				
				[Console]::SetCursorPosition(0, $startTop + $lw)
				Write-Host $debugOUT -NoNewline
				
				$lw++
		}
		if (-not $proc) {
			break
		}
		Start-Sleep -Milliseconds 1000
	}
	
}
function procPG {
	New-Item -Path "$LogDir\procl.tmp" -Force | Out-Null
	Set-Content -Path "$LogDir\procl.tmp" -Value $procP
}

function yn {
	param (
		[Parameter(Mandatory=$true)]
		[string]$p
	)
            
	Write-Host "$p (Y/N): " -NoNewLine 
			
	while ($true) {
	$key = [console]::ReadKey($true)
				
	switch ($key.Key){
		'Y' {
			Write-Host "Y"
			return $true
		} 'N' {
			Write-Host "N"
			return $false
			}	
		}
		    
			
	}		
}

function chM {
	param (
		[Parameter(Mandatory=$true)]
		[string]$ch1,
		
		[Parameter(Mandatory=$true)]
		[string]$ch2
 )

$options = @("$ch1", "$ch2")
$index = 0

Write-Host "$($options[0]) | $($options[1])" -NoNewLine

while ($true) {	
	
	$key = [console]::ReadKey($true)
		
		if ($key.Key -eq [ConsoleKey]::Tab) {
			$index = 1 - $index
		} elseif ($key.Key -eq [ConsoleKey]::Enter) {
			Write-Host "`n|| $($options[$index]) || Has been chosen`n"
			Start-Sleep -Second 1
			return $index
		}	
	
	if ($index -eq 1) {
		Write-Host "`r$($options[0]) | " -NoNewLine
		Write-Host "$($options[1])" -ForegroundColor Red -NoNewLine	
	} else {
		Write-Host "`r$($options[0])" -ForegroundColor Red -NoNewLine
		Write-Host " | $($options[1])" -NoNewLine			
	}

	} 
}

function exptkv {
	Write-Host "|    εΞπτKvK made by 0x696e73616e6974797877   |"
	
	$kvDir = Split-Path $proc.Path
	$masterDir = Split-Path (Split-Path $kvDir)
	$appdir = "$env:USERPROFILE\AppData\Local\FPSAimTrainer\Saved\Config\WindowsNoEditor\"
	$SGf = (Join-Path $masterDir 'Saved\SaveGames\')
	Remove-Item -Path "$LogDir\procl.tmp" -Force -ErrorAction SilentlyContinue
	[Console]::CursorVisible = $true
	
	$DesiredPath = Read-Host "Backup Folder ('cc' to select current script folder)"
	
	while (-not (Test-Path $DesiredPath)) {
		if ($DesiredPath -eq "cc") {
		$procKVKEXPT = Get-Process | Where-Object { $_.MainWindowTitle -like "*settings export*"} | Sort-Object CPU -Descending | Select-Object -First 1
		$exeprocpath = Split-Path $procKVKEXPT.Path
		$DesiredPath = $exeprocpath
		} else {
		$DesiredPath = Read-Host "`nThe folder doesn't exist... Try again" }
	}	
	
	
	Write-Host "`nFolder Found... `n`nMaking folder for .ini files pressent in $appdir"
	
	New-Item (Join-Path $DesiredPath 'iniFiles') -ItemType Directory -Force | Out-Null
	
	Write-Host "`nMaking folder for Palette.ini`n"
	
	New-Item (Join-Path $DesiredPath 'Palette.ini') -ItemType Directory -Force | Out-Null
	
	
	[Console]::CursorVisible = $false
	
	#Write-Host "Copy Mode: "
	
	#$Custom = chM -ch1 "Pre-set" -ch2 "Custom (not finished :3)"
	
	#if ($Custom -ne 0) {
	#	[Console]::CursorVisible = $true
		#Write-Host "`nDesire: "
		#$choice = chM -ch1 "master" -ch2 "appd"
	
		#	if ($choice -ne 1) {
		#	Start-Sleep -Seconds 1
	
		#	$dRfile = Read-Host "$masterDir\" 
		#	$ActualPath = "$masterDir\$dRfile"
	
		#	Copy-Item "$ActualPath" "$DesiredPath" -Recurse -Force
	
		#	} else {
		#		Start-Sleep -Seconds 1
			
		#		$dRfile = Read-Host "$appdir\"
		#		$ActualPath = "$appdir\$dRfile"
		#		Copy-Item "$ActualPath" "$DesiredPath" -Recurse -Force
		#	}
	
#	} else {
		"|| Select Y on the things you want to copy ||"
		
		if (yn -p "Palette.ini") {
			 
			 Copy-Item (Join-Path $appdir 'Palette.ini') (Join-Path $DesiredPath 'Palette.ini') -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		} 
        
		if (yn -p "Themes")	{
		 
			 Copy-Item (Join-Path $SGf 'Themes') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		}
		
		if (yn -p "GameUserSettings.ini & Engine.ini") {
		 
			Copy-Item (Join-Path $appdir 'GameUserSettings.ini') (Join-Path $DesiredPath 'iniFiles') -Recurse -Force -ErrorAction Stop` | Write-Host "Error: GameUserSettings.ini copy failure"	 

			
			Copy-Item (Join-Path $appdir 'Engine.ini') (Join-Path $DesiredPath 'iniFiles') -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Engine.ini copy failure"

		}
		
		if (yn -p "UI.json") {
			
			Copy-Item (Join-Path $SGf 'UI.json') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"
			
		}
		
		if (yn -p "weaponsettings.ini")	{
		 
			Copy-Item (Join-Path $SGf 'weaponsettings.ini') "$DesiredPath" -Recurse -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		}
		
		if (yn -p "Input.ini")	{
		 
			Copy-Item (Join-Path $appdir 'Input.ini') (Join-Path $DesiredPath 'iniFiles') -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		} 
		
		if (yn -p "PrimaryUserSettings.json")	{
		 
			Copy-Item (Join-Path $SGf 'PrimaryUserSettings.json') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		}
		
		if (yn -p "Crosshairs")	{
		 
			Copy-Item (Join-Path $masterDir 'crosshairs') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		}
		
		if (yn -p "Playlists")	{
		 
			Copy-Item (Join-Path $SGf 'Playlists') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"

		}
		
		if (yn -p "Sounds")	{
			
			Copy-Item (Join-Path $masterDir 'sounds') "$DesiredPath" -Recurse -Force -ErrorAction Stop` | Write-Host "Error: Item copy failure"
			
		}	
	#}
}

if (-not $proc){
	"No KvK process running!"
	$host.UI.RawUI.WindowTitle = (
        "εΞπτKvK detecting.."
    )
	while ($true) {
		if (-not $proc) {
		$proc = Get-Process | Where-Object { $_.MainWindowTitle -like "*KovaaK*" -and $_.Path -like "*steam*" } | Sort-Object CPU -Descending | Select-Object -First 1
		Start-Sleep -Milliseconds 500
	} else {
		break
	}
	}
	$host.UI.RawUI.WindowTitle = (
        "εΞπτKvK running"
    )
	$ST = Get-Date 
	clear-host
	addrdebug
	
	$ET = Get-Date
	
	"eax0x1 ebx0 int 0x80 (syscall exit)`n`n|| -------------------------------------------- ||"
	
	$DT  = $ET - $ST
	$FMDT = $ST.ToString("hh:mmtt 'on' dd/MM/yy")
	$FMD = "{0:hh\:mm\:ss}" -f $DT
	
	$LogE = "Logged in at $FMDT for $FMD hours`n"
	Add-Content -Path $LogP -Value $LogE
	Clear-Host
	[Console]::SetCursorPosition(0, $startTop)
	$host.UI.RawUI.WindowTitle = (
        "εΞπτKvK settings export"
    )
	exptkv
	Write-Host "Press Enter to Close" -NoNewline
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	
} else {
	$ST = $proc.StartTime
	$host.UI.RawUI.WindowTitle = (
        "εΞπτKvK running"
    )
	clear-host
	addrdebug
	
	$ET = Get-Date
	
	"KovaaKs has exited`n`n|| --------------------------------------------||"
	
	$DT  = $ET - $ST
	$FMDT = $ST.ToString("hh:mmtt 'on' dd/MM/yy")
	$FMD = "{0:hh\:mm\:ss}" -f $DT
	
	$LogE = "Logged in at $FMDT for $FMD hours`n"
	Add-Content -Path $LogP -Value $LogE
	Clear-Host
	[Console]::SetCursorPosition(0, $startTop)
	$host.UI.RawUI.WindowTitle = (
        "εΞπτKvK settings export"
    )
	exptkv
	Write-Host "Press Enter to Close" -NoNewline
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

