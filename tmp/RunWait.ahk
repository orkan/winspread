SetWinDelay, 100


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
ExitApp