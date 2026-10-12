<#
.SYNOPSIS
Erfasst Windows-Locks/Unlocks und zeigt Pausen ab fuenf Minuten an.

.DESCRIPTION
Ohne -Watch wertet das Skript die Security-Ereignisse 4800 (Lock) und
4801 (Unlock) des aktuellen Benutzers aus. Sind keine passenden Ereignisse
lesbar oder vorhanden, wird stattdessen die lokale CSV-Historie verwendet.
Die beiden Quellen werden nicht zusammengefuehrt.

Die Ausgabe zeigt Lock-Zeit, Unlock-Zeit, Dauer und Minuten je Pause sowie
die Anzahl und Gesamtdauer der beruecksichtigten Pausen. Pausen unter fuenf
Minuten und unvollstaendige Lock-/Unlock-Paare werden ignoriert.
Die Mindestdauer ist fest vorgegeben und kein Parameter.

Die lokale Erfassung funktioniert ohne Admin-Rechte in einer interaktiven
Windows-Benutzersitzung. Historische Security-Ereignisse setzen aktiviertes
Auditing und Leserechte fuer das Security-Log voraus. Ohne diese Voraussetzungen
koennen vergangene Locks/Unlocks nicht nachtraeglich rekonstruiert werden.

.PARAMETER Watch
Startet die laufende Erfassung zukuenftiger Lock-/Unlock-Ereignisse der
aktuellen Windows-Sitzung und haengt sie an die CSV-Datei an. Das Skript und
das PowerShell-Fenster muessen weiterlaufen; Strg+C beendet die Erfassung.
In diesem Modus erfolgt keine Pausenauswertung. Zur Auswertung das Skript
erneut ohne -Watch starten. Getrennte Erfassungslaufzeiten werden nicht zu
einer gemeinsamen Pause verbunden.

.PARAMETER HistoryPath
Pfad der lokalen CSV-Historie. Standard:
%LOCALAPPDATA%\WindowsLockHistory\events.csv
Mit -Watch werden Ereignisse dort gespeichert und fehlende Ordner angelegt.
Ohne -Watch wird die Datei nur verwendet, wenn keine passenden
Security-Ereignisse verfuegbar sind. Der Parameter erzwingt keine CSV-Auswertung.
Fuer Erfassung und spaetere Auswertung denselben Pfad verwenden.

.EXAMPLE
.\main\event-catcher.ps1
Wertet verfuegbare Ereignisse aus und zeigt vollstaendige Pausen ab fuenf Minuten.

.EXAMPLE
.\main\event-catcher.ps1 -Watch
Erfasst zukuenftige Ereignisse in der lokalen Standarddatei bis Strg+C.

.EXAMPLE
.\main\event-catcher.ps1 -Watch -HistoryPath 'C:\Users\Public\lock-events.csv'
Erfasst Ereignisse in einer eigenen CSV-Datei. Der Zielpfad muss beschreibbar sein.

.EXAMPLE
.\main\event-catcher.ps1 -HistoryPath 'C:\Users\Public\lock-events.csv'
Verwendet die eigene CSV-Datei als Ersatzquelle fuer die Auswertung.

.EXAMPLE
Get-Help .\main\event-catcher.ps1 -Full
Zeigt diese Beschreibung, die Parameter und alle Beispiele an.

.NOTES
AUTOSTART OHNE ADMIN-RECHTE
Der Watch-Modus benoetigt eine interaktive Benutzersitzung. Er startet deshalb
bei der Windows-Anmeldung deines Benutzers, nicht schon beim Systemstart vor
der Anmeldung. Ereignisse vor dem Start der Erfassung werden nicht erfasst.

1. Mit Windows+R den Dialog Ausfuehren oeffnen, shell:startup eingeben und
	bestaetigen. Dies oeffnet den persoenlichen Autostart-Ordner.
2. Im Ordner mit Rechtsklick > Neu > Verknuepfung eine Verknuepfung erstellen.
	Als Ziel die folgende Zeile verwenden (Skriptpfad bei Bedarf anpassen):
	powershell.exe -NoProfile -WindowStyle Hidden -File "<path>\event-catcher.ps1" -Watch
   Beispeil: %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -WindowStyle Minimized -File "D:\tools\WindowsEventHistory\event-catcher.ps1" -Watch
3. Die Verknuepfung beispielsweise Windows-Lock-Erfassung nennen.
4. Zum Testen die Verknuepfung doppelt anklicken. Danach startet sie bei jeder
	erneuten Windows-Anmeldung automatisch. Falls Windows den Autostart
	deaktiviert hat, unter Einstellungen > Apps > Autostart pruefen.

Das minimierte PowerShell-Fenster muss offen bleiben. Schliessen oder Strg+C
beendet die Erfassung. Keine zweite Watch-Instanz parallel starten, damit
Ereignisse nicht doppelt geschrieben werden. Zur Auswertung kann das Skript
zusaetzlich ohne -Watch gestartet werden.

Standardmaessig wird %LOCALAPPDATA%\WindowsLockHistory\events.csv verwendet.
Fuer einen eigenen Speicherort am Ende des Verknuepfungsziels beispielsweise
-HistoryPath "D:\Meine Daten\lock-events.csv" ergaenzen. Der Ordner muss fuer
deinen Benutzer beschreibbar sein. Fuer die Auswertung denselben Pfad angeben.

Zum Deaktivieren die Verknuepfung aus shell:startup entfernen. Eine bereits
laufende Erfassung endet erst beim Schliessen ihres PowerShell-Fensters oder
beim Abmelden. Die CSV-Historie bleibt erhalten.

Falls eine Ausfuehrungsrichtlinie oder Firmenrichtlinie den Skriptstart
blockiert, die Fehlermeldung im PowerShell-Fenster pruefen und die Freigabe
mit der IT klaeren. Diese Anleitung aendert oder umgeht keine Richtlinien.
#>

[CmdletBinding()]
param(
	[switch]$Watch,
	[string]$HistoryPath = (Join-Path $env:LOCALAPPDATA 'WindowsLockHistory\events.csv')
)

function Get-LockPauses {
	param(
		[object[]]$Events
	)

	$pendingLocks = @{}
	foreach ($entry in ($Events | Sort-Object Timestamp)) {
		$sessionKey = [string]$entry.SessionKey
		$timestamp = [datetimeoffset]::Parse(
			[string]$entry.Timestamp,
			[System.Globalization.CultureInfo]::InvariantCulture
		)

		if ($entry.Action -eq 'Lock') {
			if (-not $pendingLocks.ContainsKey($sessionKey)) {
				$pendingLocks[$sessionKey] = $timestamp
			}
			continue
		}

		if ($entry.Action -ne 'Unlock' -or -not $pendingLocks.ContainsKey($sessionKey)) {
			continue
		}

		$lockedAt = $pendingLocks[$sessionKey]
		$pendingLocks.Remove($sessionKey)
		$duration = $timestamp - $lockedAt
		if ($duration.TotalMinutes -ge 5) {
			[pscustomobject]@{
				Lock = $lockedAt.LocalDateTime
				Unlock = $timestamp.LocalDateTime
				Dauer = $duration
				Minuten = [math]::Round($duration.TotalMinutes, 2)
			}
		}
	}
}

function Get-SecurityLockEvents {
	$userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
	$query = "*[System[(EventID=4800 or EventID=4801)] and EventData[Data[@Name='SubjectUserSid']='$userSid']]"
	try {
		$records = @(Get-WinEvent -LogName Security -FilterXPath $query -ErrorAction Stop)
	}
	catch {
		if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') {
			return
		}
		throw
	}

	foreach ($record in $records) {
		[xml]$xml = $record.ToXml()
		$fields = @{}
		foreach ($field in $xml.Event.EventData.Data) {
			$fields[[string]$field.Name] = [string]$field.'#text'
		}

		[pscustomobject]@{
			Timestamp = ([datetimeoffset]$record.TimeCreated).ToString('o')
			Action = if ($record.Id -eq 4800) { 'Lock' } else { 'Unlock' }
			SessionKey = '{0}:{1}:{2}' -f $userSid, $fields.SubjectLogonId, $fields.SessionId
		}
	}
}

function Show-LockPauses {
	param(
		[object[]]$Events
	)

	$pauses = @(Get-LockPauses -Events $Events)
	if ($pauses.Count -eq 0) {
		Write-Host 'Keine vollstaendigen Lock-/Unlock-Pausen ab 5 Minuten gefunden.'
		return
	}

	$pauses | Format-Table Lock, Unlock, Dauer, Minuten -AutoSize
	$totalTicks = ($pauses | ForEach-Object { $_.Dauer.Ticks } | Measure-Object -Sum).Sum
	Write-Host ('Pausen: {0} | Gesamtdauer: {1}' -f $pauses.Count, [timespan]::FromTicks([long]$totalTicks))
}

function Watch-LockEvents {
	param(
		[string]$Path
	)

	if (-not ('Microsoft.Win32.SystemEvents' -as [type])) {
		Add-Type -AssemblyName Microsoft.Win32.SystemEvents -ErrorAction Stop
	}
	$parentDirectory = Split-Path -Parent $Path
	if ($parentDirectory -and -not (Test-Path -LiteralPath $parentDirectory)) {
		New-Item -ItemType Directory -Path $parentDirectory -Force -ErrorAction Stop | Out-Null
	}

	$sourceIdentifier = 'WindowsLockHistory.{0}' -f [guid]::NewGuid()
	$subscription = Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) `
		-EventName SessionSwitch -SourceIdentifier $sourceIdentifier -ErrorAction Stop
	$sessionKey = '{0}:{1}:{2}' -f [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value,
		[System.Diagnostics.Process]::GetCurrentProcess().SessionId, $sourceIdentifier

	Write-Host ('Erfassung aktiv. Lokale Historie: {0}' -f $Path)
	Write-Host 'Dieses Skript laufen lassen; mit Strg+C beenden. Auswertung durch erneuten Start ohne -Watch.'
	Write-Host 'Fruehere Ereignisse werden nicht nachtraeglich erfasst.'
	try {
		while ($true) {
			$notification = Wait-Event -SourceIdentifier $sourceIdentifier
			try {
				$reason = [string]$notification.SourceEventArgs.Reason
				if ($reason -notin @('SessionLock', 'SessionUnlock')) {
					continue
				}

				$entry = [pscustomobject]@{
					Timestamp = ([datetimeoffset]$notification.TimeGenerated).ToString('o')
					Action = if ($reason -eq 'SessionLock') { 'Lock' } else { 'Unlock' }
					SessionKey = $sessionKey
				}
				$entry | Export-Csv -LiteralPath $Path -Append -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
				Write-Host ('{0}: {1}' -f $notification.TimeGenerated, $entry.Action)
			}
			finally {
				Remove-Event -EventIdentifier $notification.EventIdentifier -ErrorAction SilentlyContinue
			}
		}
	}
	finally {
		Unregister-Event -SourceIdentifier $sourceIdentifier -ErrorAction SilentlyContinue
		Get-Event -SourceIdentifier $sourceIdentifier -ErrorAction SilentlyContinue | Remove-Event
		if ($subscription -is [System.Management.Automation.Job]) {
			Remove-Job -Job $subscription -Force -ErrorAction SilentlyContinue
		}
	}
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
	throw 'Dieses Skript benoetigt Windows und eine interaktive Benutzersitzung.'
}

if ($Watch) {
	Watch-LockEvents -Path $HistoryPath
	return
}

$securityEvents = @()
try {
	$securityEvents = @(Get-SecurityLockEvents)
}
catch {
	Write-Warning ('Security-Log nicht lesbar: {0}' -f $_.Exception.Message)
}

if ($securityEvents.Count -gt 0) {
	Write-Host 'Quelle: Security-Log, Ereignisse 4800/4801 des aktuellen Benutzers.'
	Show-LockPauses -Events $securityEvents
}
elseif (Test-Path -LiteralPath $HistoryPath -PathType Leaf) {
	Write-Host ('Quelle: lokal erfasste Ereignisse aus {0}' -f $HistoryPath)
	Show-LockPauses -Events @(Import-Csv -LiteralPath $HistoryPath -ErrorAction Stop)
}
else {
	Write-Warning 'Keine lesbare Historie vorhanden. Security-Ereignisse benoetigen aktiviertes Auditing und Leserechte.'
	Write-Host 'Ohne diese Voraussetzungen lassen sich vergangene Locks/Unlocks nicht verlaesslich rekonstruieren.'
	Write-Host 'Fuer die Erfassung ab jetzt das Skript mit -Watch in einer normalen PowerShell starten.'
}