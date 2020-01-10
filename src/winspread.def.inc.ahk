; default INI values in case there is no ini file yet
ini := []
ini.settings
:= { ErrorTimeout: 4000
   , SetTitleMatchMode: 2}
ini.example
:= { cmd: "explorer.exe - path to application"
   , param: "/n,""C:\Windows"" - application parameters (optional)"
   , keys: "#{left} - send keyboard messages to move this window (optional)"
   , moveH: "400 - screen coordinates to move this window after [poskeys] (optional)"
   , moveW: "600"
   , moveX: "0"
   , moveY: "0"
   , offsetH: "-200 - move offset for this window, after [poskeys] and [posmove] (optional)"
   , offsetW: "8"
   , offsetX: "-8"
   , offsetY: "200"
   , sleep: "200 - pause in between window operations (optional)"
   , title: "Windows ahk_class CabinetWClass - identify this window after creation for future processing"}
