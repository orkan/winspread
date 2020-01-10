; default INI values in case there is no ini file yet
ini := []
ini.settings
:= { ErrorTimeout: 4000
   , SetTitleMatchMode: 2}
ini.example
:= { cmd: "explorer.exe      - path to application"
   , param: "/n,""C:\Windows"" - application parameters (optional)"
   , poskeys: "#{left} - send keyboard messages to move this window (optional)"
   , posmoveH: "400    - screen coordinates to move this window after [poskeys] (optional)"
   , posmoveW: "600"
   , posmoveX: "0"
   , posmoveY: "0"
   , posoffH: "-200    - move offset for this window, after [poskeys] and [posmove] (optional)"
   , posoffW: "8"
   , posoffX: "-8"
   , posoffY: "200"
   , sleep: "200       - pause in between window operations (optional)"
   , title: "Windows ahk_class CabinetWClass - identify this window after creation for future processing"}
