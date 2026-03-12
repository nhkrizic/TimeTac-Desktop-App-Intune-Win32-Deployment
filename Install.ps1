# install-timetac.ps1

$installer     = ".\timetac-desktop-app.exe"
$installerArgs = "/S /allusers"

# 1) Silent-Install hidden
$proc = Start-Process -FilePath $installer -ArgumentList $installerArgs -PassThru -WindowStyle Hidden
$proc.WaitForExit()

# 2) Auf das vom Installer erstellte Public-Desktop-Shortcut warten (max. 120s)
$publicLink = "C:\Users\Public\Desktop\TimeTac Desktop App.lnk"
$timeoutSec = 120
while (!(Test-Path $publicLink) -and $timeoutSec -gt 0) {
    Start-Sleep -Seconds 1
    $timeoutSec--
}

# 3) Falls vorhanden -> in öffentlichen Autostart kopieren
$startupDir = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
$startupLink = Join-Path $startupDir "TimeTac Desktop App.lnk"

if (Test-Path $publicLink) {
    try {
        # sicherstellen, dass der Startup-Ordner existiert
        if (!(Test-Path $startupDir)) { New-Item -ItemType Directory -Path $startupDir -Force | Out-Null }
        Copy-Item -Path $publicLink -Destination $startupLink -Force
    } catch {
        # Optional: Fallback – Scheduled Task anlegen, falls Kopie scheitert (z.B. AV/Lockdown)
        # $action  = New-ScheduledTaskAction -Execute (Resolve-Path $publicLink)
        # $trigger = New-ScheduledTaskTrigger -AtLogOn
        # $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\INTERACTIVE" -LogonType InteractiveToken -RunLevel LeastPrivilege
        # try { Unregister-ScheduledTask -TaskName "Start TimeTac at Logon (All Users)" -Confirm:$false -ErrorAction SilentlyContinue } catch {}
        # Register-ScheduledTask -TaskName "Start TimeTac at Logon (All Users)" -Action $action -Trigger $trigger -Principal $principal | Out-Null
    }
}
else {
    # Optional: Fallback – wenn das Shortcut nie erscheint, alternativ direkt .lnk erzeugen:
    $exeCandidates = @(
        "C:\Program Files\TimeTac Desktop App\timetac-desktop-app.exe",
        "C:\Program Files (x86)\TimeTac Desktop App\timetac-desktop-app.exe"
    )
    $exePath = $exeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($exePath) {
        $ws = New-Object -ComObject WScript.Shell
        $sc = $ws.CreateShortcut($startupLink)
        $sc.TargetPath = $exePath
        $sc.WorkingDirectory = Split-Path $exePath
        $sc.Save()
    }
}

exit 0
