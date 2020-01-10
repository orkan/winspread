;~ Window dimensions inconsistent (winmove question)
;~ https://www.autohotkey.com/boards/viewtopic.php?t=49084

z::ExitApp 0
x::moveAndResizeWindowByHwnd(WinActive("A"), 0, 0, 400, 200)
c::moveAndResizeWindowByHwnd(WinActive("A"), 400, 0, 400, 200)

moveAndResizeWindowByHwnd(hwnd, x, y, w, h) {
	rect := getClientRectFromHwnd(hwnd)
	WinGetPos, , , currW, currH, % "ahk_id" hwnd
	
	WinSetTitle, % "ahk_id" hwnd,, % "currW: " currW ", rect.W: " rect.W ", currH: " currH ", rect.H: " rect.H
	
	
	;WinMove, % "ahk_id" hwnd, , % (x - (currW - rect.W)), % (y - (currH - rect.H)), % w, % h
	WinMove, % "ahk_id" hwnd, , % (x - (currW - rect.W)), % (y - (currH - rect.H)), % w, % h
}

getClientRectFromHwnd(hwnd) {
	VarSetCapacity(RECT, 4 * 4, 0)
	DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", &RECT)
	return {"W": NumGet(RECT, 8, "Int"), "H": NumGet(RECT, 12, "Int")}
}
