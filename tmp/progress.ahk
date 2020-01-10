#Include D:\Orkan\Code\Exe\AutoHotkey\_ahk\lib\orkan.lib.ahk

items := 50

Progress, B R0-%items% w400 fs11, %A_Space%, Winspread v0.3
;WinSet, ExStyle, ^0x1, A
;WinSet, Transparent, 100

;Sleep, 1500
Loop, % "C:\Windows\SysWOW64\*.*"
{
    Random, rnd, 20, 50
	s := str_reduce("D:\Orkan\wator\" . A_LoopFilePath, 50, rnd)
	
	Progress, %A_Index%, % s
	
    Sleep, 100
    if (A_Index > items)
        break
}

ExitApp


GuiClose:
GuiEscape:
ExitApp
