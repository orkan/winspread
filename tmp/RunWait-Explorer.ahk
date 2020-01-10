SetTitleMatchMode, 2

;RunWait, C:\Windows , , , nPid ; otwiera nowe okno tylko jesli nie istnieje
RunWait, explorer.exe /n`,C:\Windows , , , nPid ; otwiera nowe okno
hwnd1 := WinActive("A")

;WinWait ahk_pid %nPid%.
WinWait, Windows ahk_class CabinetWClass
;WinActivate, Windows ahk_class CabinetWClass
WinMove, % "ahk_id" hwnd1,, -8, 0, 600, 400


ExitApp


getClientRectFromHwnd(hwnd) {
	VarSetCapacity(RECT, 4 * 4, 0)
	DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", &RECT)
	return {"W": NumGet(RECT, 8, "Int"), "H": NumGet(RECT, 12, "Int")}
}
