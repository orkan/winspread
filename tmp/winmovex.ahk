;-- winmovex open move Folder ----------
; https://autohotkey.com/board/topic/121406-moving-new-window-to-specific-dimensionsposition/
SetTitleMatchMode,2
;x=test
x=ahk_class CabinetWClass
run, C:\Windows
WinWait,%x%
WinMove,%x%, , 100, 100, 300, 200
IfWinNotActive,%x%, ,WinActivate,%x%
WinWaitActive,%x%
exitapp
