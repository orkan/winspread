# Winspread
AutoHotkey script to spread out windows across desktop space. Driven with cmd line params through defined INI configuration

## Basic features:

This script will let you launch a group of different windows after clicking one shortcut only. You can define the order and position of each individual window.

Syntax is:
`winspread.exe section1 [section2 section3 ...]`

Each parameter is a separate INI section, with the following settings:
* **cmd** - path to application
* **param** - application parameters
* **title** - identify this window after creation for future processing (can use **ahk_class**, **ahk_pid**, etc...)
* **keys** - send keyboard inputs directly to the window after creation
* **move[X,Y,W,H]** - move window to exact position within screen coordinates
* **offset[X,Y,W,H]** - offset window by specified pixels after creation (+/-)
* **sleep** - pause in between operations (ms)

Example INI section:
```
[Windows]
cmd=explorer.exe
param=/n,"C:\Windows"
title=Windows ahk_class CabinetWClass
keys=#{left}
sleep=200
```
Create a shortcut with location: `winspread.exe Windows`
This will open a Windows Explorer window, occupying the left half of the desktop, with selected C:\Windows directory in the side panel

## Requirements

The [AutoHotkey](https://www.autohotkey.com/) compiler is required to run any *.ahk script. Note that this isn't the case if you run the compiled EXE file

## Author

* [Orkan](https://github.com/orkan) - *Initial work*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
