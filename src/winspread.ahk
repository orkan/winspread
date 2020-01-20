SendMode Input
#Include ..\lib\orkan.lib.inc.ahk
#Include winspread.def.ahk
#Include winspread.ver.ahk

base_name := "winspread"
base_url := "https://github.com/orkan/winspread"

; user settings - overwrites winspread.def.inc.ahk
example := ini.example.Clone() ; save original [example] section
name_ini := base_name ".ini"
ini := merge_from_ini(ini, name_ini)
ini.example := example ; restore [example] section
WriteINI(ini, name_ini)

;###################################################################################################
; Check startup arguments
if (%0%) {
    Progress, B R0-%0% w400 fs11, %A_Space%, % Format("{:T} {:s}", base_name, get_version(git_version))
}
else {
    MsgBox, 64, % Format("{:T} {:s} (rev. {:s})", base_name, git_version, git_revision), % "This program is intended to spread out windows across your desktop. `n`nSyntax:`n        " base_name " section1 [section2 section3 ...]`n`nCheck out <" name_ini "> [example] section for more information on how to define your own windows.`n`nCopyright 2020 Orkan <orkans@gmail.com>`n" base_url
}

;###################################################################################################
; START START START START START START START START START START START START START START START START 
;###################################################################################################
SetTitleMatchMode, % ini.settings.SetTitleMatchMode

loop %0%
{
    key := A_Args[A_Index]
    obj := ini[key]
    err := false
    
    if (!obj)
        err := "Missing: [section...]"
    else if (!obj.cmd)
        err := "Epmty: cmd=..."
    else if (!obj.title)
        err := "Epmty: title=..."
    
    if (!err) {
        cmd := obj.cmd
        cmd .= obj.param ? " " obj.param : ""
    }
    else
        cmd := "Error! " err
    
	Progress, % A_Index, % str_reduce("[" key "] " . cmd, 60)
    
    if (!err)
    {
        Run, % cmd
        WinWaitActive, % obj.title
        WinGet, _hWnd, ID, A
        
        ; send keyboard messages to this window?
        if (obj.keys) {
            Send % obj.keys
            Sleep, % obj.sleep
        }

        ; move this window?
        if (obj.moveX or obj.moveY or obj.moveW or obj.moveH) {
            WinMove, % "ahk_id" _hWnd,, % obj.moveX, % obj.moveY, % obj.moveW, % obj.moveH
            Sleep, % obj.sleep
        }
        
        ; extra offset this window?
        if (obj.offsetX or obj.offsetY or obj.offsetW or obj.offsetH) {
            WinGetPos tmpX, tmpY, tmpW, tmpH, % "ahk_id" _hWnd
            tmpX := obj.offsetX ? tmpX + obj.offsetX : tmpX
            tmpY := obj.offsetY ? tmpY + obj.offsetY : tmpY
            tmpW := obj.offsetW ? tmpW + obj.offsetW : tmpW
            tmpH := obj.offsetH ? tmpH + obj.offsetH : tmpH
            WinMove, % "ahk_id" _hWnd,, % tmpX, % tmpY, % tmpW, % tmpH
        }
    }
    else 
    {
        Sleep, % ini.settings.ErrorTimeout ; keep the error msg for a while
    }
}

ExitApp
