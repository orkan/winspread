SendMode Input
#Include ..\lib\orkan.lib.inc.ahk
#Include winspread.ver.ahk
#Include winspread.def.inc.ahk

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
    MsgBox, 64, % Format("{:T} {:s} (rev. {:s})", base_name, git_version, git_revision), % "This program is intended to spread out windows across your desktop space. Check out <" name_ini "> [example] section for more information how to define your windows. Syntax is:`n`n" base_name ".exe section1 [section2 section3 ...]`n`n2020 © Orkan <orkans@gmail.com>`n" base_url
}

;###################################################################################################
; START START START START START START START START START START START START START START START START 
;###################################################################################################
SetTitleMatchMode, % ini.settings.SetTitleMatchMode

loop %0%
{
    key := A_Args[A_Index]
    obj := ini[key]
    cmd := obj.cmd
    cmd .= obj.param ? " " obj.param : ""
    err := false

    if (!obj.cmd)
        err := "epmty [cmd]"
    if (!obj.title)
        err := "epmty [title]"
    
    cmd := err ? "Error! " err : cmd
    slp := err ? ini.settings.ErrorTimeout : obj.sleep
	Progress, % A_Index, % str_reduce("[" key "]: " . cmd, 60)
    
    if (!err)
    {
        Run, % cmd
        WinWaitActive, % obj.title
        WinGet, _hWnd, ID, A
        
        ; send keyboard messages to this window?
        if (obj.poskeys) {
            Send % obj.poskeys
            Sleep, % slp
        }

        ; move this window?
        if (obj.posmoveX or obj.posmoveY or obj.posmoveW or obj.posmoveH) {
            WinMove,,, % obj.posmoveX, % obj.posmoveY, % obj.posmoveW, % obj.posmoveH
            Sleep, % slp
        }
        
        ; extra offset this window?
        if (obj.posoffX or obj.posoffY or obj.posoffW or obj.posoffH) {
            WinGetPos tmpX, tmpY, tmpW, tmpH, % "ahk_id" _hWnd
            tmpX := obj.posoffX ? tmpX + obj.posoffX : tmpX
            tmpY := obj.posoffY ? tmpY + obj.posoffY : tmpY
            tmpW := obj.posoffW ? tmpW + obj.posoffW : tmpW
            tmpH := obj.posoffH ? tmpH + obj.posoffH : tmpH
            WinMove, % "ahk_id" _hWnd,, % tmpX, % tmpY, % tmpW, % tmpH
        }
    }
    else 
    {
        Sleep, % slp
    }
}

ExitApp
