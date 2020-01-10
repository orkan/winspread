;SetTitleMatchMode, 2 ; partial match
;SetWinDelay, 100

WinActivate, ahk_class Shell_TrayWnd ; loose focus - try progress instead

;RunWait C:\Windows
;RunWait, C:\Windows , , , nPid
;WinActivate, Windows ahk_class CabinetWClass

;~ Run, explorer.exe /n`,C:\Windows
;~ WinWaitActive, ahk_class CabinetWClass

Run, D:\Apps\Eclipse\eclipse-php-201909\eclipse.exe , , , nPid
WinWaitActive, ahk_class SWT_Window0
WinGet, active_id1, ID, A


;WinMove, Windows ahk_class CabinetWClass,, 0, 0, 600, 400
WinMove, ahk_id %active_id1%,, % 0-8, 0, 600, 400


WinActivate, ahk_class Shell_TrayWnd ; loose focus


Run, explorer.exe /n`,D:\Orkan\Sluk\images\JpgA
WinWaitActive, ahk_class CabinetWClass
;WinActivate, JpgA ahk_class CabinetWClass
WinGet, active_id2, ID, A

;WinMove, JpgA ahk_class CabinetWClass,, 600, 0, 800, 400
WinMove, ahk_id %active_id2%,, % 600-24, 0, 800, 400


WinActivate, ahk_class Shell_TrayWnd ; loose focus


Run, explorer.exe /n`,D:\Orkan\Sluk\clips\JpgA
WinWaitActive, ahk_class CabinetWClass
;WinActivate, JpgA ahk_class CabinetWClass
WinGet, active_id3, ID, A

;WinMove, JpgA ahk_class CabinetWClass,, 0, 400, 800, 400
WinMove, ahk_id %active_id3%,, % 0-8, % 400-8, 800, 400


MsgBox % "active_id1: " active_id1 "`nactive_id2: " active_id2 "`nactive_id3: " active_id3 

ExitApp





nHwnd := WinExist("A")

if (nPid)
	MsgBox % "nPid: " . nPid
if (nHwnd)
	MsgBox % "nHwnd: " . nHwnd

ExitApp




;RunWait, %ComSpec% /c dir d:\ >>d:\DirTest.txt, , min
RunWait, c:\
WinWait, A
WinMove, 0, 0


RunWait, d:\
;RunWait, properties d:\DirTest.txt
WinWait, A
WinMove, 600, 600


;WinWait, Dane (D:)
;Sleep 500


WinWaitClose
