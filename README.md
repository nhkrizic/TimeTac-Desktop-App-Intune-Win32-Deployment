
# TimeTac Desktop App – Intune Win32 Deployment (System-wide + Autostart)

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Microsoft Intune](https://img.shields.io/badge/Microsoft%20Intune-Win32-blue?logo=microsoft)](https://learn.microsoft.com/intune/)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D6?logo=windows)](https://learn.microsoft.com/en-us/windows/)


## Überblick

Dieses Repository dokumentiert ein erprobtes Deployment‑Szenario für die **TimeTac Desktop App** mittels **Microsoft Intune (Win32 App)**.

Der Fokus liegt auf:

*   **Silent Installation** der TimeTac Desktop App
*   **Systemweiter Installation (All Users / per‑Machine)**
*   **Automatischem Autostart für alle Benutzer**
*   **Sauberer Deinstallation**
*   **Stabiler Erkennung (Detection Rule)**
  
***

## Zielsetzung

Ziel dieses Setups ist es, TimeTac:

*   ohne Benutzerinteraktion zu installieren
*   im **System‑Kontext** auszurollen
*   für **alle Benutzer automatisch beim Login zu starten**
*   vollständig über Intune verwaltbar zu machen (Install / Uninstall / Detection)

Dieses Vorgehen ist besonders geeignet für:

*   standardisierte Clients
*   Shared Devices
*   produktive Unternehmensumgebungen

***

## Technisches Konzept

### Installation

*   Die Installation erfolgt **silent** über den originalen Hersteller‑Installer (`timetac-desktop-app.exe`).
*   Die Installation wird **systemweit** ausgeführt (`All Users`).
*   Die Ausführung erfolgt **im System‑Kontext**, nicht im Benutzerkontext.

### Autostart‑Mechanismus

TimeTac erstellt während der Installation **immer** ein öffentliches Desktop‑Shortcut:

    C:\Users\Public\Desktop\TimeTac Desktop App.lnk

Dieses Verhalten wird bewusst genutzt:

1.  Nach der Installation wird auf dieses Shortcut gewartet.
2.  Das vorhandene `.lnk` wird anschließend nach folgendem Pfad kopiert:

<!---->

    C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup

➡️ Dadurch startet TimeTac **automatisch für alle Benutzer** beim Login.

**Vorteile dieses Ansatzes:**

*   Keine Registry‑Manipulation
*   Keine Abhängigkeit vom exakten EXE‑Pfad
*   Hersteller‑Shortcut wird wiederverwendet
*   Sehr robust gegenüber Updates

***

## Deinstallation

*   Die Deinstallation erfolgt **silent** über den vom Installer bereitgestellten Uninstaller.
*   Das Autostart‑Shortcut im **All Users Startup** wird entfernt.
*   Die Deinstallation läuft ebenfalls im **System‑Kontext**.

***

## Intune Win32 App – Konfiguration

### App‑Typ

*   **Windows app (Win32)**

***

### Programm

#### Installationsbefehl

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
```

#### Deinstallationsbefehl

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1
```

#### Installationsverhalten

*   **System**

#### Verhalten beim Geräteneustart

*   *App‑Installation kann einen Geräteneustart erzwingen*

#### Rückgabecodes (empfohlen)

| Code | Bedeutung                 |
| ---: | ------------------------- |
|    0 | Erfolgreich               |
| 1707 | Erfolgreich               |
| 3010 | Warmneustart erforderlich |
| 1641 | Harter Neustart           |
| 1618 | Wiederholen               |

***

### Anforderungen

*   **Betriebssystem:** Windows 10 1607 oder höher
*   **Architekturprüfung:** Keine
*   **Skript auf 64‑Bit‑Clients als 32‑Bit ausführen:** **Nein**

***

### Erkennungsregel (Detection)

Die Erkennung erfolgt **ausschließlich über den Installationspfad**.

#### Detection‑Typ

#### Logik

*   Wenn der Installationsordner existiert → App ist installiert
*   Andernfalls → nicht installiert

#### Erwarteter Pfad

    C:\Program Files\TimeTac Desktop App

Diese Methode hat sich als **zuverlässiger** erwiesen als Detection Script

***

## Paketstruktur (`.intunewin`)

Empfohlene Ordnerstruktur vor dem Erstellen des Intune‑Pakets:

    TimeTac.Win32\
    │
    ├─ Install.ps1
    ├─ Uninstall.ps1
    └─ timetac-desktop-app.exe

Das Paket wird anschließend mit dem **Microsoft Win32 Content Prep Tool** (`IntuneWinAppUtil.exe`) erstellt.

***

## Hinweise

*   Das Setup basiert auf dem aktuellen Verhalten des TimeTac‑Installers.  
    Änderungen seitens des Herstellers (Installer‑Parameter, Pfade, Shortcut‑Verhalten) können Anpassungen erforderlich machen.
*   Das Deployment sollte **vor Produktivrollout** in einer Testgruppe validiert werden.

***

## Lizenz / Haftungsausschluss

Die bereitgestellten Informationen und Skripte dienen als Beispiel.  
Keine Gewährleistung für Vollständigkeit oder Eignung in jeder Umgebung.

***
