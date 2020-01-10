#SingleInstance Force
#Include D:\Orkan\Code\Exe\AutoHotkey\_ahk\lib\orkan.lib.ahk

Gui +HwndhWndGui
Gui Add, Text,, Path / string reduce examples
Gui, Add, Edit, w800 vmyEDIT, D:\Orkan\Aaa\Windows\BB\Explorator\CCCCC\explorer.txt
Gui Add, Radio,    gonClick_RADIO, path_reduce
Gui Add, Radio, x+ gonClick_RADIO, str_reduce
Gui Font,, Consolas
Gui Add, Edit, xm w800 r30 HwndhLog ReadOnly -Wrap -WantReturn
Gui, Submit, NoHide
Gui Show

GuiControl,, str_reduce, 1
;str_reduce(myEDIT,  5, 96)
;str_reduce(myEDIT, 13, 11)
str_reduce_test()
return

GuiClose:
ExitApp

; Radio button handler
onClick_RADIO:
%A_GuiControl%_test()
return

path_reduce_test() {
	Gui, Submit, NoHide
	global myEDIT
	Println("----------------------------------------------------------------------")
	Println("path_reduce(str, len[->real])")
	
	Loop, parse, % "36,34,32,30,27,25,24,22,20,18,15,13,11,8,5", `,
	{
		s := path_reduce(myEDIT, A_LoopField)
		Println("path_reduce(str, " . Format("{: 2}", A_LoopField) . "->" . Format("{: 2}", StrLen(s)) . "): " . s)
	}
}

str_reduce_test() {
	Gui, Submit, NoHide
	global myEDIT
	Println("----------------------------------------------------------------------")
	Println("str_reduce(str, len[->real], pos:=50, ellipsis:=""..."")")

	Loop, parse, % "56,53,52,50,37,25,20,13,5,3", `,
	{
		Random, rnd, 1, 100
		s := str_reduce(myEDIT, A_LoopField, rnd)
		Println("str_reduce(str, " . Format("{: 2}", A_LoopField) . "->" . Format("{: 2}", StrLen(s)) . ", " . Format("{: 3}", rnd) . "): " . s)
	}
}
