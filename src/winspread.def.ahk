; default INI values in case there is no ini file yet
ini := []
ini.settings
:= { ErrorTimeout: 4000
   , SetTitleMatchMode: 2}
ini.example
:= { cmd: "explorer.exe `; path to application @see: https://www.autohotkey.com/docs/commands/Run.htm"
   , param: "/n,""C:\Windows"" `; application parameters (optional)"
   , keys: "#{left} `; send keyboard messages directly to this window (optional) @see: https://www.autohotkey.com/docs/commands/Send.htm"
   , moveH: "400 `; screen coordinates to move this window after processing [keys] (optional) @see: https://www.autohotkey.com/docs/commands/WinMove.htm"
   , moveW: "600"
   , moveX: "0"
   , moveY: "0"
   , offsetH: "-200 `; offset this window, after processing [keys] and [move] (optional)"
   , offsetW: "8"
   , offsetX: "-8"
   , offsetY: "200"
   , sleep: "200 `; pause (ms) in between current window operations [keys|move|offset] (optional)"
   , title: "Windows ahk_class CabinetWClass `; identify this window after creation - for future processing. @see: https://www.autohotkey.com/docs/misc/WinTitle.htm"}
