# TimeTac Desktop App – Intune Win32 Deployment (System-wide + Autostart)

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Microsoft Intune](https://img.shields.io/badge/Microsoft%20Intune-Win32-blue?logo=microsoft)](https://learn.microsoft.com/intune/)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D6?logo=windows)](https://learn.microsoft.com/en-us/windows/)

## Why this approach?

- **System-wide / All Users**: Installation läuft im **System-Kontext**, die App steht allen Benutzern zur Verfügung.
- **Autostart für alle Benutzer**: Der Hersteller legt ein **Public-Desktop**-Shortcut an; dieses wird in den **All Users Startup** kopiert – stabiler als Registry-Run-Einträge und unabhängig von exakten EXE-Pfaden.
- **Intune‑Best Practices**: Skripte werden mit `powershell.exe -File` ausgeführt; Verpackung als Win32‑App via Win32 Content Prep Tool. Siehe offizielle Doku: [Prepare a Win32 app for Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare). -service/apps/apps-win32-prepare)

## How to use

1. **Paket vorbereiten**  
   Lege `Install.ps1`, `Uninstall.ps1` und `timetac-desktop-app.exe` in einen Ordner.  
   Verpacke alles mit dem **Microsoft Win32 Content Prep Tool** zu einer `.intunewin`.  
   → Anleitung: [Prepare Win32 app content](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare). [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare)

2. **Intune-App anlegen**  
   - **Install command**  
     `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1`  
   - **Uninstall command**  
     `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1`  
   - **Install behavior**: `System`  
   - **Detection (Custom Script)**: Pfadprüfung `C:\Program Files\TimeTac Desktop App` (bzw. `(x86)` wenn zutreffend).  
     Für allgemeine Win32‑Deployments und Detection‑Basics siehe:  
     * [How to deploy Win32 Apps with Intune (Guide)](https://www.prajwaldesai.com/deploy-win32-apps-with-intune/) [2](https://www.prajwaldesai.com/deploy-win32-apps-with-intune/)  
     * [Intune Win32 App Deployment – Step by Step](https://www.anoopcnair.com/intune-win32-app-deployment/) [3](https://www.anoopcnair.com/intune-win32-app-deployment/)

3. **Zuweisen & Monitoren**  
   Weise die App deinen Geräten zu und überwache das Deployment unter **Apps → Monitor**.  
   (Grundlagen und typische Stolpersteine werden in den oben verlinkten Artikeln behandelt.) [2](https://www.prajwaldesai.com/deploy-win32-apps-with-intune/)[3](https://www.anoopcnair.com/intune-win32-app-deployment/)

## Troubleshooting

- **Install klappt lokal, schlägt aber in Intune fehl**  
  Stelle sicher, dass die Ausführung **explizit** über PowerShell erfolgt (`powershell.exe -File …`) und die App im **System‑Kontext** installiert wird.  
  → Offizielle Hinweise zur Paketvorbereitung und Ausführung: [Win32 app prep tool](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare). [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-win32-prepare)

- **Detection rot, obwohl Desktop-Icon sichtbar**  
  Nutze eine **Pfad‑Detection** (`C:\Program Files\TimeTac Desktop App` oder `C:\Program Files (x86)\…`). EXE‑Installer setzen ARP‑Einträge (HKLM\Uninstall) nicht immer konsistent – Pfad‑Checks sind oft robuster.  
  → Praxisguides: [Prajwal Desai](https://www.prajwaldesai.com/deploy-win32-apps-with-intune/), [HTMD](https://www.anoopcnair.com/intune-win32-app-deployment/). [2](https://www.prajwaldesai.com/deploy-win32-apps-with-intune/)[3](https://www.anoopcnair.com/intune-win32-app-deployment/)

- **Logs (Client)**  
  - `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`  
  - `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log`

## Repository structure

Dieses Repo enthält:
- `Install.ps1` – Silent‑Install + Kopie des Public‑Desktop‑Shortcuts in den All‑Users‑Autostart  
- `Uninstall.ps1` – Entfernt Autostart‑Link und deinstalliert silent  
- **(Optional)** Screenshots und eine Beispiel‑Detection (Pfad)

> Hinweis: Den Hersteller‑Installer (**timetac-desktop-app.exe**) bitte **nicht** im Repo hosten; direkt vom Hersteller beziehen.

## License

Released under the **MIT License**. See [LICENSE](./LICENSE).

---
