; Win10Move() - deceptive WinMove - move window based on what is visible ;)
; https://www.autohotkey.com/boards/viewtopic.php?t=18029
#NoEnv

WinSnap(WinTitle, X := "", Y := "", W := "", H := "") {
   If ((X . Y . W . H) = "") ;
      Return False
   WinGet, hWnd, ID, %WinTitle% ; taken from Coco's version
   If !(hWnd)
      Return False
   DL := DT := DR := DB := 0
   VarSetCapacity(RC, 16, 0)
   DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", &RC)
   WL := NumGet(RC, 0, "Int"), WT := NumGet(RC, 4, "Int"), WR := NumGet(RC, 8, "Int"), WB := NumGet(RC, 12, "Int")
   If (DllCall("Dwmapi.dll\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", &RC, "UInt", 16) = 0) { ; S_OK = 0
      FL := NumGet(RC, 0, "Int"), FT := NumGet(RC, 4, "Int"), FR := NumGet(RC, 8, "Int"), FB := NumGet(RC, 12, "Int")
      DL := WL - FL, DT := WT - FT, DR := WR - FR, DB := WB - FB
   }
   X := X <> "" ? X + DL : WL, Y := Y <> "" ? Y + DT : WT
   W := W <> "" ? W - DL + DR : WR - WL - 1, H := H <> "" ? H - DT + DB - 1: WB - WT
   Return DllCall("MoveWindow", "Ptr", hWnd, "Int", X, "Int", Y, "Int", W, "Int", H, "UInt", 1)
}

SysGet, MWA, MonitorWorkArea
MH := MWABottom - MWATop

Gui, +hwndHGUI
Gui, Margin, 200, 100
Gui, Add, Button, gMove, MoveIt
Gui, Add, Button, x+10 yp gSnap, SnapIt
Gui, Add, Button, x+10 yp gResize vBtnResize, +Resize
Gui, Add, StatusBar
Gui, Show, , SnapIt
Return

GuiClose:
ExitApp
Resize:
GuiControlGet, BtnResize
Gui, %BtnResize%
Gui, Show
GuiControl, , BtnResize, % (BtnResize = "+Resize" ? "-Resize" : "+Resize")
Return
Move:
WinMove, ahk_id %HGUI%, , 0, 0, A_ScreenWidth, MH
Return
Snap:
WinSnap("ahk_id" . HGUI, 0, 0, A_ScreenWidth, MH)
Return

/*
; DWMWA_EXTENDED_FRAME_BOUNDS = 9
VarSetCapacity(RC, 16, 0)
DllCall("Dwmapi.dll\DwmGetWindowAttribute", "Ptr", HGUI, "UInt", 9, "Ptr", &RC, "UInt", 16)
FL := NumGet(RC, 0, "Int"), FT := NumGet(RC, 4, "Int"), FR := NumGet(RC, 8, "Int"), FB := NumGet(RC, 12, "Int")
DllCall("GetWindowRect", "Ptr", HGUI, "Ptr", &RC)
WL := NumGet(RC, 0, "Int"), WT := NumGet(RC, 4, "Int"), WR := NumGet(RC, 8, "Int"), WB := NumGet(RC, 12, "Int")
MsgBox, 0, SnapWindow, ExtFrame Bounds:`n%FL% - %FT% - %FR% - %FB%`n`nWindow Bounds:`n%WL% - %WT% - %WR% - %WB%
*/