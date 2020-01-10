
#SingleInstance force
; no  #NoEnv
Menu, Tray, Icon, shell32.dll,  16
;#NoTrayIcon
help=
(
• Toolbar for "Windows Explorer" in Win7 (works also in Win8)
• on click --> go to folders: a, ?, ?, ?, Music, Pics (set paths in .ini file, otherwise - pre-defined as a= folderA, 1=folder1,...)
  (Ctrl+click --> open in new window)
• on right click --> go to another set of folders (paths pre-defined ; a= folderA2, 1=folder1a,...)
• drag and drop to move files to those folders

• ^ icon click --> up one level 
• ^ icon  right click -->  pre-defined "Folder View" options for particular folders 
  Icons View for "C:\a","C:\","D:\","E:\" and for other folders - switch between Details/List View

• click on empty icon after ?  --> switch between: SORT BY name/date modified/type/size (sub. Empty_Sec2:)
  Ctrl+click on empty icon after ? --> launch another window with the same path
	
• last icon --> ListBox :
  • click or double click ListBox items
  • folder size without subfolders (double click - with subfolders); new folder (double click - with name from clipboard)
  • folder size in separate file folder_size.ahk
	
• "Context menu" --> right click not on buttons 
• "showTipOnMouseover:=1" option shows folder paths 

• Search files - option in ListBox or right click on last icon 
• Stop search - Ctrl+D; Close search - Esc
• Search uses Regex - so for regular search use "\." instead of "." and avoid special characters like "\,/,?,*,+,[],(),{}" or simply 'escape' them with "\"
  In the context menu: 
  • found files can be opened by default program. 
  • open containing folder and show the found file (select and scroll into view)

(right click on last icon to start search may not be working if script's path is too long - control's text is clipped)

)
/*  
  • ^ icon click --> up one level (or in another version • first empty icon -> window on top switch, right click ;lines 199-211 )
  • ^ icon  right click -->  switch between: sort by name/date modified (or customize this subroutine "EmptyFirst2") 
  • last icon --> ListBox :
  • click or double click ListBox items
  • folder size without subfolders (double click - with subfolders); new folder (double click - with name from clipboard)
  • folder size in separate file folder_size.ahk
*/


Gosub, ContextMenuMake

SetWinDelay, -1
SetControlDelay, -1
;SetBatchLines, -1

WorkingDir :=A_ScriptDir
;scripts_path:="C:\AutoHotkey Scripts"
icons_folder:= A_ScriptDir "\icons\"

icoOnTop:=RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7") ? 17 : 13 

bar:=""
showTipOnMouseover:=0

global G_color,WinS_ID, selfol,CB_ListID, List_id, win
global del_ico:=0  ; 0= text "X", 1= icon

global settings_ini := WorkingDir "\WinExpToolsDrozd.ini"
global MaxQueries:=10


  global rel_X:=188, rel_Y:=64
  if InStr(A_OSVersion,"WIN_8")
    rel_X:=188, rel_Y:=60
  
/* if RegExMatch(A_OSVersion,"WIN_VISTA"){
  G_color:="286E83"
	bar=%icons_folder%Vista bar.png
 
}
 */
if RegExMatch(A_OSVersion,"WIN_7"){
  G_color:="EAF3FC"
  ;G_color:="DFE8F1"
  bar=%icons_folder%Win7 bar.png

}else{  
  G_color:="EAF3FC"
  G_color:="F5F6F7"
  bar=%icons_folder%Win7 bar.png
}


global folderA, folderA2,folderB,folderB2, folder1, folder2, folder3,folder1a, folder2a, folder3a
global Music, Pictures, Music2, Pictures2

folderA:= "C:\" ;folderA:="C:\a\" 
folderA2:= A_MyDocuments
folder3:=folderB:= A_ProgramFiles 
folder3a:=folderB2:= A_WinDir  
folder1= %HOMEDRIVE%%HOMEPATH%  ;A_MyDocuments
folder1a:= A_AppData ; roaming  %LOCALAPPDATA% ; %APPDATA%
folder2:= APPDATA
folder2a:= LOCALAPPDATA
  

Music2:= Music:= HOMEDRIVE HOMEPATH "\Music"    ;"C:\Users\" A_UserName "\Music"
Pictures2:= Pictures:= HOMEDRIVE HOMEPATH "\Pictures"  ; "C:\Users\" A_UserName "\Pictures"

button3:="Music"
button4:="Pics"


get_folder_size:=A_ScriptDir "\folder_size.ahk"

 getFolders("folderA")
 getFolders("folderB")
 getFolders("Music")
 getFolders("Pictures")
 
 getFolders_2("folder1")
 getFolders_2("folder2")
 
getFolders(folder){	  
  IniRead, read_, %settings_ini%, Folders, %folder%
  if(read_=="ERROR" || read_==""){
    IniWrite,% %folder% , %settings_ini%, Folders, %folder%    
  }else{
    %folder%:= read_
  }    
  IniRead, read_, %settings_ini%, Folders, %folder%2
  if(read_=="ERROR" || read_==""){
    IniWrite,% %folder%2 , %settings_ini%, Folders, %folder%2    
  }else{
    %folder%2:= read_
  }
}

getFolders_2(folder){	  
  IniRead, read_, %settings_ini%, Folders, %folder%
  if(read_=="ERROR" || read_==""){
    IniWrite,% %folder% , %settings_ini%, Folders, %folder%    
  }else{
    %folder%:= read_
  }   
  IniRead, read_, %settings_ini%, Folders, %folder%a  
  if(read_=="ERROR" || read_==""){
    IniWrite,% %folder%a , %settings_ini%, Folders, %folder%a    
  }else{
    %folder%a:= read_
  }
}

folder3:=folderB
folder3a:=folderB2

;==============




  Gosub, Start
  Gosub, add_List
  Gosub, searchList
  
  DllCall("RegisterShellHookWindow", UInt,A_ScriptHwnd )
  MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
  OnMessage(MsgNum,"ShellMessage")
  
  OnMessage(0x204, "WM_RBUTTONDOWN")
  if(showTipOnMouseover)
    OnMessage(0x200, "WM_MOUSEMOVE")  
  OnMessage(0x100, "WM_KEYDOWN")
return


Start:
	WinGet, List_, List , ahk_class CabinetWClass
	Loop, %List_%  {
		id:=List_%A_Index%
		WinGet, pname, ProcessName,ahk_id %id%  
		WinGetClass, class_, ahk_id %id%  
		;WinGet, PID, PID , ahk_id %id%
    win := GetShellFolder(id)
    fold_path:=win.Document.Folder.Self.Path 
      if !InStr(fold_path,"::{")        
          make_Gui(id)
	}
return


ShellMessage(wParam,lParam){
	Critical
  global lastExpId
	lParam:=Format("0x{1:x}", lParam) ; decimal to hexadecimal
	
	if(wParam=1 || wParam=2 || wParam=4 || wParam=32772){		
		id:=lParam
		if(wParam=1){   ;  HSHELL_WINDOWCREATED = 1  ; new program started
			WinGet, PID, PID , ahk_id %lParam%
			WinGet, pname, ProcessName,ahk_id %lParam%  
			WinGetClass, class_, ahk_id %lParam%  
			id:=lParam
			if(RegExMatch(class_,"i)CabinetWClass")){ 
        fn:=Func("make_Gui").Bind(id)
        SetTimer, %fn% , -500
        
        if(selfol==1){
          fn2:=Func("selectInWindow").Bind(id)
          SetTimer, %fn2% , -500
          ;selectInWindow(id)
        }
			}
		}
/* 
  if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
			;MsgBox,,, %  "HSHELL_WINDOWDESTROYED  " "wParam=" wParam  " | lParam=" lParam ", "  "`n" class_ , 2
  } 
		
  if(wParam=4 || wParam=32772){ 	;HSHELL_WINDOWACTIVATED=4, 
    
  }					
		 */
	}	
}



checkWin(id,GuiHwnd){  
  win := GetShellFolder(id)
  fold_path:=win.Document.Folder.Self.Path 
  static exclude:=["{21EC2020-3AEA-1069-A2DD-08002B30309D}","{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}","{645FF040-5081-101B-9F08-00AA002F954E","{20D04FE0-3AEA-1069-A2D8-08002B30309D","{9343812E-1C37-4A49-A12E-4B2D810D956B","{26EE0668-A00A-44D7-9371-BEB064C98683}"]
  Loop, % exclude.Length(){
    if(InStr(fold_path,exclude[A_Index])){
      Gui, %GuiHwnd%: Destroy
      break
    }
  }
  ; ::{645FF040-5081-101B-9F08-00AA002F954E} Recycle Bin 
  ; ::{20D04FE0-3AEA-1069-A2D8-08002B30309D} Computer
  ; ::{9343812E-1C37-4A49-A12E-4B2D810D956B} search 
  ; ::{21EC2020-3AEA-1069-A2DD-08002B30309D} Control Panel
  ; ::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C} Network
  ; ::{26EE0668-A00A-44D7-9371-BEB064C98683} Control Panel
}

;===========================

 make_Gui(parentID){
  global icons_folder, bar, button3, button4, icoOnTop
  Gui, New, +ToolWindow -caption +AlwaysOnTop	+HwndGuiHwnd ;-border
  ;G_color:="286E83" ; blue
	;G_color:="8BAFBE"
  Gui, %GuiHwnd%:Color, %G_color% 
  font_1:="000000" , font_2:="333333" , font_3:="0C6881" ,font_4:="004254" ; Win7 
  font_2a:="0C3E4C"
  if(FileExist(bar)){
    Gui, %GuiHwnd%: Add, Picture, x0 y0 w332 h28   BackgroundTrans, %bar% 
  }else{    
    Gui, %GuiHwnd%: Add, Text , x-100 y-100  BackgroundTrans Center, ;dummy static 
  }
  
;========== up
  if RegExMatch(A_OSVersion,"WIN_7"){
    Gui, %GuiHwnd%: Font, S9 W700 c%font_3% , Verdana   
    Gui, %GuiHwnd%: Add, Text ,  x1 y8 w16 h16 gEmptyFirst BackgroundTrans Center , % Chr(8593) ;^
  }else{
    Gui, %GuiHwnd%: Font, S12 W700 c%font_3% , Verdana   
    Gui, %GuiHwnd%: Add, Text ,  x1 y6 w18 h22 gEmptyFirst BackgroundTrans Center , % Chr(8593) ;^    
  }
;========== 

;==========  onTop: 
  ;Gui, %GuiHwnd%: Add, Picture,  x0 y6 w16 h16 +HwndonTopHwnd gonTop BackgroundTrans Icon30 AltSubmit, shell32.dll       
;========== 
 
  switch=%icons_folder%switch1.png
  if(FileExist(switch)){
    Gui, %GuiHwnd%: Add, Picture, x246 y5 w18 h18   gshowList  BackgroundTrans , %switch%
  }else{ 
    Gui, %GuiHwnd%: Add, Picture, x246 y4 w18 h18   gshowList  BackgroundTrans Icon249 AltSubmit, shell32.dll
  } 
  

    font_1:="000000" , font_2:="333333" , font_3:="085B72" ,font_4:="004254", font_5:="800000" ; Win7 
    
    Gui, %GuiHwnd%: Font, S11 W700 c%font_3% , Segoe UI 
    Gui, %GuiHwnd%: Add, Text , x21 y3 w26 h18  ggo_a BackgroundTrans Center,  a
    Gui, %GuiHwnd%: Add, Text , x+4  y3 w26 h18 ggo_b BackgroundTrans Center, b
    Gui, %GuiHwnd%: Font, S8 W700 c%font_3% , Segoe UI  ;Verdana     
    Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h18  ggo_to_folder_1 BackgroundTrans Center, % Chr(10102) ; ?
    Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h18  ggo_to_folder_2 BackgroundTrans Center, % Chr(10103) ; ?
    ;Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h16  ggo_to_folder_3 BackgroundTrans Center, % Chr(10104) ; ?
    
    ;Gui, %GuiHwnd%: Font, S9 W700 c%font_1% , Verdana
    ;Gui, %GuiHwnd%: Add, Text , x138  y4 w20 h18  gEmpty_Sec BackgroundTrans Center , ;^ ;% Chr(11014) ;?? Chr(10506) 
    Gui, %GuiHwnd%: Add, Text , x140  y4 w20 h18 cDCE6F4 gEmpty_Sec BackgroundTrans Center , % Chr(3894) ;? ; % Chr(9642) ;?
    
    Gui, %GuiHwnd%: Font, S8 W700 c%font_4% , Verdana
    Gui, %GuiHwnd%: Add, Text , x163 y7 w34 h16  gbutton3 BackgroundTrans  Center, %button3% 
    Gui, %GuiHwnd%: Add, Text , x205 y7 w32 h16  gbutton4 BackgroundTrans Center, %button4%     
      
    Gui, %GuiHwnd%: Add, Picture , x19 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
    Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
    Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
    Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll  
    
    Gui, %GuiHwnd%: Add, Picture , x155 y4 w48 h20 BackgroundTrans Icon181 AltSubmit, imageres.dll    
    Gui, %GuiHwnd%: Add, Picture , x201 y4 w42 h20 BackgroundTrans Icon181 AltSubmit, imageres.dll    

    Gui, %GuiHwnd%: +Parent%parentID%

  if InStr(A_OSVersion,"WIN_7"){
    ;x:= 396 , y:= 36
    x:= 416 , y:= 36
    Gui, %GuiHwnd%:Show, x%x%  y%y% w322 h26 NA, DrozdTools_Expl ;Win7   
  }else{
    x:= 486 , y:= 28
    Gui, %GuiHwnd%:Show, x%x%  y%y% w322 h26 NA, DrozdTools_Expl ;Win8   
  }

  WinSet, Region, 0-0 270-0 270-29 0-29, ahk_id %GuiHwnd% 
 ; WinActivate, ahk_id %parentID% 
/*   if(FileExist(bar))
    WinSet, Region, 0-0  w268 h28  R10-10 , ahk_id %GuiHwnd%  ; rounded corners
   */
  ;if(Gui_transp)
   ; WinSet, TransColor, %G_color%, ahk_id %GuiHwnd% ; transparent Gui

  checkWin(parentID,GuiHwnd)
  ;WinSet, Redraw,, ahk_id %id%
}

~LButton::
  MouseGetPos,x,y,Win_id,	control
  if (Win_id != GuiDropDownHwnd)    
   Gui,3:Hide   
return

showList:
  MouseGetPos,x1,y1, Win_id, control
  last_Win_id:=Win_id
  WinGetPos, x2,y2,w2,h2, A
  ControlGet, CtrlHwnd, Hwnd,, %control%, ahk_id %Win_id%
  WinGetPos, x2,y2,w2,h2, ahk_id %CtrlHwnd%	
  Gui, 3: Show, % "x" x2-56 " y" y2-3
return

add_List:
  Gui, New, 
  Gui,3: +ToolWindow +AlwaysOnTop -caption   +HwndGuiDropDownHwnd  
  Gui,3: Margin, 0,0
  Gui,3: Font, S8 W700  , Segoe UI
  ;lista:="folder size|folder size*|-------|Documents|Windows|Pictures|Music|-------|new folder|new folder*"
  lista:="search files|folder size|new folder|-------|Documents|Pictures|Music|-------|" A_ComputerName "|-------|Roaming|ProgramFiles|Windows"
  ;Gui,3: Add, ListBox, x0 y0 w80 r12 vListBox_1 gDropDown, %lista%
  arr1:=StrSplit(lista,"|"), len:=arr1.Length() 
  Gui,3: Add, ListBox, x0 y0 w80 r%len%  vListBox_1  +HWNDListBox_id , %lista%
  fn := Func("ListBox_Func_1").Bind(ListBox_id)
	GuiControl, +g, % ListBox_id, % fn
  Gui,3:Show, , win_Exp_List - Drozd  
  Gui,3:Hide
return


onTop:
	MouseGetPos,,, Gui_ID, control
	Win_id:=DllCall("GetParent", "UInt",Gui_ID), Win_id := !Win_id ? Gui_ID : Win_id 

  WinGet, ExStyle, ExStyle, ahk_id %Win_id%	
  WS_EX_TOPMOST := 0x00000008 ; Ex-style AlwaysOnTop
  
  if(ExStyle & WS_EX_TOPMOST){ 
		Winset, AlwaysOnTop, off, ahk_id %Win_id%
    GuiControl,%A_Gui%:, %control%  ,*Icon30 *w16 *h16 shell32.dll 
  }else{
    WinSet, AlwaysOnTop, on, ahk_id %Win_id%
    GuiControl,%A_Gui%:, %control%  ,*Icon%icoOnTop% *w16 *h16 wmploc.dll  ;  ontop
  }   
return
 
 

;==============


WM_RBUTTONDOWN(){
  global last_Gui
	if(A_Gui){
    last_Gui:=A_Gui
		Gosub, Menu_    
  }
}


Menu_:
MouseGetPos,,, Win_id, control

;Asc("?")=10102 ; Asc("?")=10103; Asc("?")=10104 ; Asc("?")=10105
if(A_GuiControl="a"){
  goToFolder(folderA2,Win_id) 
}else if(A_GuiControl="?" || Asc(A_GuiControl)=10102){
  goToFolder(folder1a,Win_id) 
}else if(A_GuiControl="?" || Asc(A_GuiControl)=10103){
  goToFolder(folder2a,Win_id) 
  
}else if(A_GuiControl="b" || A_GuiControl="?" || Asc(A_GuiControl)=10104){
  goToFolder(folder3a,Win_id)  
  
  
}else if(A_GuiControl=button3){
  goToFolder(Music2,Win_id)  
}else if(A_GuiControl=button4){
  goToFolder(Pictures2,Win_id) 
  
}else if(A_GuiControl="shell32.dll" || RegExMatch(A_GuiControl,"i)switch")){ 
  WinS_ID:=Win_id
  showSearchDialog(Win_id)
  
}else if(Asc(A_GuiControl)=8593 || control="Static2"){ ; ^ upFolder ; Duplicate
  ;Gosub,  upFolder
  Gosub, EmptyFirst2
  
/* 
}else if(Asc(A_GuiControl)=3894 || control="Static8"){ ; ? 
  Gosub, Empty_Sec2 
   */
}
return
;====================


go_a:
  goToFolder(folderA,Win_id) 
return

go_b:
  goToFolder(folder3,Win_id)  
return

button3:
  goToFolder(Music,Win_id) 
return


button4:
  goToFolder(Pictures,Win_id) 
return




go_to_folder_1:
  goToFolder(folder1,Win_id)
return

go_to_folder_2:
  goToFolder(folder2,Win_id) 
return

go_to_folder_3:
  goToFolder(folder3,Win_id) 
return


;==========================================


go_to_folder:
  goToFolder(folder_path,Win_id) 
return

;=======================



ListBox_Func_1(hwnd){ 
  global lastEvent, lastListBox, last_Win_id
	GuiControlGet, list_folder_expl,3: , % hwnd
  lastEvent:=A_GuiEvent
	lastListBox:=list_folder_expl

  SetTimer, ListBox_Clicks, % DllCall("GetDoubleClickTime")
}

ListBox_Clicks:
  SetTimer, ListBox_Clicks, Off

	if(lastEvent="DoubleClick"){    
    if(lastListBox=="folder big"){
      win := GetShellFolder(last_Win_id)
      fold_path:=win.Document.Folder.Self.Path
      Run, %get_folder_size% "%fold_path%" "1" "big" "700000" "give size"
    }else if(lastListBox=="folder size"){ 
      win := GetShellFolder(last_Win_id)
      fold_path:=win.Document.Folder.Self.Path      
      Run, %get_folder_size% "%fold_path%"      
      
    }else if(lastListBox=="new folder"){
      ;Gosub, newFolderClipName 
      new_name:=SubStr(Clipboard,1,150)
      win := GetShellFolder(last_Win_id)
      win.Document.Folder.NewFolder(new_name)  
      Sleep, 1500  
      win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3) ; 1, 3
 

    }else if(lastListBox=="Roaming"){ 
      goToFolder(LOCALAPPDATA,last_Win_id)
    }else if(lastListBox=="ProgramFiles"){ 
      goToFolder(A_ProgramFiles " (x86)",last_Win_id) 
    }else if(lastListBox=="Windows"){ 
      goToFolder(A_WinDir "\System32",last_Win_id)

    }else if(lastListBox==A_ComputerName){ 
      win:=GetShellFolder(last_Win_id)
      win.Navigate("\\" A_ComputerName) 
      
      
    }
    Gui,3: Hide
  }else if(lastEvent="Normal"){    
      Gosub, ListBox_go    
  }
return




;=======================

ListBox_go:
  Gui,3:Submit, Nohide

    Gui,3:Hide 
    Sleep, 100
    WinGet, Win_id, ID , A
    list_folder_expl:=ListBox_1  
if(list_folder_expl=="Documents"){
    goToFolder(A_MyDocuments,Win_id)
  }else if(list_folder_expl=="Windows"){ 
    goToFolder(A_WinDir,Win_id)
  }else if(list_folder_expl=="Pictures"){
    goToFolder(Pictures,Win_id)  
  }else if(list_folder_expl=="Music"){
    goToFolder(Music,Win_id)

  }else if(lastListBox=="Roaming"){ 
      goToFolder(A_AppData,last_Win_id)
  }else if(lastListBox=="ProgramFiles"){ 
      goToFolder(A_ProgramFiles,last_Win_id) 
      
  }else if(lastListBox==A_ComputerName){ 
      win:=GetShellFolder(last_Win_id)
      win.Navigate("\\" A_ComputerName) 

  }else if(list_folder_expl=="folder size*"){ 
    Gosub, getFolder
    Run, %get_folder_size% "%fold_path%"
  }else if(list_folder_expl=="folder size"){ 
   	win := GetShellFolder(Win_id)
    fold_path:=win.Document.Folder.Self.Path  
    Run, %get_folder_size% "%fold_path%" "0" "" "" ""

  }else if(list_folder_expl=="search files"){
    WinS_ID:=last_Win_id
    showSearchDialog(last_Win_id)
    
  }else if(list_folder_expl=="new folder*"){
    Gosub, newFolderClipName    
  }else if(list_folder_expl=="new folder"){
    Gosub, newFolder
  }  
return



;==========================

goToFolder(folder_path,Win_id){
  if (!FileExist(folder_path) && !InStr(folder_path,"::{")){    
    MsgBox,4096,, %  "No folder:" "`n" folder_path , 3
    return
  }
  if(GetKeyState("Ctrl", "P")==1){
    Run, Explorer.exe %folder_path%
  }else{
    win := GetShellFolder(Win_id)
    win.Navigate(folder_path)
  }
}
;==========================

newFolder:
  win := GetShellFolder(Win_id)
  win.Document.Folder.NewFolder("_New Folder") 
  Sleep, 1500  
  win.Document.SelectItem(win.Document.Folder.ParseName("_New Folder"), 3) ; 1, 3
return

newFolderClipName:
  new_name:=SubStr(Clipboard,1,150)
  win := GetShellFolder(Win_id)
  win.Document.Folder.NewFolder(new_name)  
  Sleep, 1500  
  win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3) ; 1, 3
 ; win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3|4|8|16) 
return

upFolder:  
  win := GetShellFolder(Win_id)
  if FileExist(win.Document.Folder.ParentFolder.Self.Path)
    win.Navigate(win.Document.Folder.ParentFolder.Self.Path) 
return
;==========================

getFolder:
	win := GetShellFolder(Win_id)
  fold_path:=win.Document.Folder.Self.Path
;MsgBox,,, % Win_id "`n" win.Document.CurrentViewMode "`n" win.Document.Folder.Self.Path "`n" win.Document.Folder.Self.Parent.Self.Path
return

Duplicate:  
	win := GetShellFolder(Win_id)
  path:=win.Document.Folder.Self.Path
  Run,  explorer %path% 
return


EmptyFirst:
	;Gosub, Duplicate
  ;Gosub, onTop
  Gosub, upFolder
return


Empty_Sec:
  if(GetKeyState("Ctrl","P")==1){
    Gosub, Duplicate 
  }else{
    Gosub, Empty_Sec2
  }
;Gosub, upFolder
return

EmptyFirst2:
  folderList:=["C:\a","C:\","D:\","E:\"]

  win := GetShellFolder(Win_id)  
  fold_path:=win.Document.Folder.Self.Path

  if array_contains(folderList,fold_path){
    win.Document.CurrentViewMode := 5
    win.Document.IconSize := 34
  }else if InStr(fold_path,"\Pictures\"){
    win.Document.CurrentViewMode := 5
    win.Document.IconSize := 48
  }else{    
    if(win.Document.CurrentViewMode=3){ ; switch Details/List
      ToolTip_("Details view", 1)
      win.Document.CurrentViewMode := 4 ; Details
    }else{
      ToolTip_("List view", 1)
      win.Document.CurrentViewMode := 3 ; List
    }
  }
  ;View modes: Icon= 1 ; List=3 ; Details=4 ; Icons=5 ; Tile=6 ;SmallIcon=2 Tile=6, ThumbStrip=7
  ;MsgBox,,, % fold_path "`n" win.Document.CurrentViewMode "`n" win.Document.IconSize 
return


Empty_Sec2:
  win := GetShellFolder(Win_id)  
  ;fold_path:=win.Document.Folder.Self.Path
  ;MsgBox,,, % win.Document.CurrentViewMode "`n" win.Document.IconSize "`n" win.Document.SortColumns "`n"

  if(InStr(win.Document.SortColumns,"System.ItemNameDisplay")){
    ToolTip_("sort - newest", 1) ;sort by date    
    win.Document.SortColumns:="prop:-System.DateModified;"   ; sort - from newest
  }else if(InStr(win.Document.SortColumns,"System.DateModified")){
    ToolTip_("sort by type", 1) ;sort by type       
    win.Document.SortColumns:="prop:System.ItemTypeText;"   ; sort - type 
    
  }else if(InStr(win.Document.SortColumns,"prop:System.ItemTypeText")){
    ToolTip_("sort by size", 1) ;     
    win.Document.SortColumns:="prop:-System.Size;"   ; sort - size     
    
  }else{
    ToolTip_("sort by name", 1)  
    win.Document.SortColumns:="prop:+System.ItemNameDisplay;"  ; sort ascending A-Z
  }
    
  ;win.Document.SortColumns:="prop:-System.DateModified;"   ; sort - from newest
  ;win.Document.SortColumns:="prop:+System.DateModified;"   ; sort - from oldest

  ;win.Document.SortColumns:="prop:-System.ItemNameDisplay;"  ; sort descending Z-A
  ;win.Document.SortColumns:="prop:+System.ItemNameDisplay;"  ; sort ascending A-Z

  ;win.Document.SortColumns:="prop:-System.Size;"   ; sort - from largest
  ;win.Document.SortColumns:="prop:+System.Size;"   ; sort - from smallest

  ;win.Document.SortColumns:="prop:-System.DateCreated;"   ; sort - from newest
  ;win.Document.SortColumns:="prop:+System.DateCreated;"   ; sort - from oldest
  
  ;win.Document.SortColumns:="prop:System.ItemTypeText;" ; sort - Type
  ;https://docs.microsoft.com/en-us/windows/desktop/api/shobjidl_core/ns-shobjidl_core-sortcolumn
return

array_contains(haystack, needle){	
 if(!isObject(haystack))
  return false
 if(haystack.Length()==0)
  return false
 for k,v in haystack	{
	StringLower,v,v
	StringLower,needle,needle
		v:=Trim(v), needle:=Trim(needle)		
  if(v==needle)
   return k
	}
 return false
}


GetShellFolder(Win_id){
  for win in ComObjCreate("Shell.Application").Windows  {
			if(win.HWND && win.HWND == Win_id){
				return win
			}
  }			
}
  
  
destroyGui: 
  Gui, %last_Gui%: Destroy
return


;======================================

GuiDropFiles:
	MouseGetPos,,,Win_id,control
	arr := StrSplit(A_GuiEvent,"`n") 
	file_path:=A_GuiEvent
	objShell:=ComObjCreate("Shell.Application")	


  if(control=="Static4"){ ; folder a
    folder:=folderA
		objFolder:=objShell.NameSpace(folder)
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
      ;objFolder.MoveHere(A_LoopField, 8|64) ;8-new name if exists ; 64-undo
		}
	}else	if(control=="Static5"){  ; folder  1
     folder:=folder1
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}
  }else	if(control=="Static6"){  ; folder 2
     folder:=folder2
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}
  }else	if(control=="Static7"){  ; folder 3
     folder:=folder3
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}    


  }else	if(control=="Static9"){
    folder:=Music
		objFolder:=objShell.NameSpace(folder)
    
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes    
    {
      Loop, parse, A_GuiEvent, `n 
      {
        objFolder.MoveHere(A_LoopField, 64) 
      }  
    }    
  }else	if(control=="Static10"){
    folder:=Pictures
		objFolder:=objShell.NameSpace(folder)
    
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes    
    {
      Loop, parse, A_GuiEvent, `n 
      {
        objFolder.MoveHere(A_LoopField, 64)         
      }  
    }    
    
	}

return
;======================================


showFolderPaths:
  showPaths:= "a`n" "folderA= " folderA "`n" "folderA2= " folderA2   "    (RClick)"
  . "`n`n" "?`n" "folder1= " folder1 "`n" "folder1a= " folder1a "    (RClick)"
  . "`n`n" "?`n" "folder2= " folder2 "`n" "folder2a= " folder2a "    (RClick)"
  . "`n`n" "?`n" "folder3= " folder3 "`n" "folder3a= " folder3a "    (RClick)"
  . "`n`n" "`n" "Music= " Music "`n" "Music2= " Music2 "    (RClick)" 
  . "`n`n" "`n" "Pictures= " Pictures "`n" "Pictures2= " Pictures2 "    (RClick)" 
  . "`n`n"
  ;MsgBox,4096,, %  showPaths "`n" 
  Progress, zh0 w350  M2 C0y ZX30 ZY10 CWFFFFFF FS8 FM12 WM700 WS700 , %showPaths%, Folder paths, Drozd Tools Win Explorer, Segoe UI Semibold
return

WM_MOUSEMOVE(){  
  global 
  Sleep, 200
	MouseGetPos,,,Win_id,control	
		;if (control="Static3")	{	
  if(A_Gui){	
      ;ToolTip_(A_Gui "`n" control ,t:=2)
    if(control=="Static4"){
      ToolTip_(folderA "`n" folderA2, 0.5)
    }else if(control=="Static5"){
      ToolTip_(folder1 "`n" folder1a, 0.5)        
    }else if(control=="Static6"){
      ToolTip_(folder2 "`n" folder2a, 0.5) 
    }else if(control=="Static7"){
      ToolTip_(folder3 "`n" folder3a, 0.5)
    
    }else if(control=="Static9"){
      ToolTip_(Music "`n" Music2 , 0.5)    
    }else if(control=="Static10"){
      ToolTip_(Pictures "`n" Pictures2 , 0.5)    
    }
  }
}
;======================================
;======================================
;====================================
;=========== Search


showSearchDialog(Win_ID){
  global GuiInpID, EventHook, stop_loop, EventHook, EventHook_2
  stop_loop:=0
	win := GetShellFolder(Win_ID)
	fold_path:=win.Document.Folder.Self.Path

	inputDrozd_(Win_ID,win)	
  
  EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B
  WINEVENT_SKIPOWNTHREAD:= 0x0001,WINEVENT_SKIPOWNPROCESS:= 0x0002, WINEVENT_OUTOFCONTEXT:= 0x0000
 
 
 ;EventHook := DllCall( "SetWinEventHook", "UInt",0x8000, "UInt",0x800B, "Ptr",0,"Ptr",RegisterCallback("WinProcCallback"), "UInt", 0, "UInt",0, "UInt",0 )  ; from all 
 
idThread := DllCall("GetWindowThreadProcessId", "Int", Win_ID, "UInt*", PID)	 ; LPDWORD  
EventHook:=DllCall("SetWinEventHook","UInt",0x8000,"UInt",0x800B,"Ptr",0,"Ptr",RegisterCallback("WinProcCallback")
                  ,"UInt", PID,"UInt",idThread,"UInt", WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD) ; from this 

  OnExit(Func("UnhookWinEvent").Bind(EventHook))
  
;===========

  static EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006

  global CB_EditID , CB_ListID, List_id, CB_ListID
    CtrlHwnd:=List_id
    VarSetCapacity(CB_info, 40 + (3 * A_PtrSize), 0)
    NumPut(40 + (3 * A_PtrSize), CB_info, 0, "UInt")
    DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CB_info)
    CB_EditID := NumGet(CB_info, 40 + A_PtrSize, "Ptr") ;48/44
    CB_ListID := NumGet(CB_info, 40 + (2 * A_PtrSize), "Ptr") ; 56/48
    
    CB_EditID:=Format("0x{1:x}",CB_EditID) , CB_ListID:=Format("0x{1:x}",CB_ListID) 
    
    GuiHwnd_:=CB_ListID
    ThreadId := DllCall("GetWindowThreadProcessId", "Int", GuiHwnd_, "UInt*", PID)	

    
  EventHook_2:=DllCall("SetWinEventHook","UInt",0x8006,"UInt",0x8006,"Ptr",0,"Ptr"
            ,RegisterCallback("WinProcCallback_2")	,"UInt", PID,"UInt", ThreadId,"UInt", 0)  

	OnExit(Func("UnhookWinEvent").Bind(EventHook_2))	
  
}



WinProcCallback(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical
  global WinS_ID, GuiInpID, Gui1_Id, ParID
  if !hwnd
    return
  event:=Format("0x{1:x}",event)

  if event not in 0x8000,0x8001,0x800B   ; 
     return
 
  ;EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B
  
  hwnd:=Format("0x{1:x}",hwnd) 
	;WinGetClass, class_, ahk_id %hwnd% 
  ;WinGet, pname, ProcessName,ahk_id %hwnd%  	
  ;WinGetTitle, Title, ahk_id %hwnd%      
    

  if(event=0x800B){ ; move, re-size	
    WinGetPos, x1,y1,w1,h1, ahk_id %WinS_ID%
      if(x1 && y1){
        x:=x1+w1-rel_X, y:=y1+rel_Y
      }
      WinMove, ahk_id %GuiInpID%,, %x%, %y%  

      x2:=x1+8, y2:=y1+95,  w2:=w1-17, h2:=h1-110
      WinMove, ahk_id %Gui1_Id%,, %x2%, %y2%,%w2%, ;%h2% ;Drozd_searchList
      GuiControl,1: Move, List__, % "W"  w2 . " H" h2
  
  }else if(event=0x8000 ){ ; new created
/*     if(class_=="CabinetWClass")
      selectInWindow(hwnd)
 */
  }else if(event=0x8001 ){ ;  closed     
      if(hwnd==WinS_ID)
         Gosub, close_search_list
  }
}

;==========================

WinProcCallback_2(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical  
  if !hwnd
    return
  event:=Format("0x{1:x}",event) ; decimal to hexadecimal
	hwnd:=Format("0x{1:x}",hwnd) 
	;EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006
	if(event=0x8006){ ;EVENT_OBJECT_SELECTION
		del_icons(List_id,hwnd,del_ico)
		return 0
	}
}



UnhookWinEvent(hWinEventHook){
  DllCall("UnhookWinEvent", "Ptr",hWinEventHook)
  DllCall("CoUninitialize")
}




;====================================================



del_icons(List_id,CB_ListID,del_ico:=0){
	SendMessage,0x0146,0,0, ,% "ahk_id " List_id ;CB_GETCOUNT:= 0x0146
	len:=ErrorLevel
	WinGetPos, ,,, CB_height, ahk_id %CB_ListID% 
	row_height2:=CB_height/len
	SendMessage,0x0154,1,0, ,% "ahk_id " List_id ;CB_GETITEMHEIGHT:= 0x0154
	row_height:= ErrorLevel
	if(del_ico)
		iconOnWin(CB_ListID,len,row_height)
	else
		textOnWin(CB_ListID,len,row_height,"X")
}

textOnWin(hwnd, len,row_h,text_:="X"){
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)

	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=W-12,y:=0
	heightF:=12 , weight:=400,fontName:="Arial"  ;"Segoe Print"
	widthF:=6
	hFont:=DllCall("CreateFont", "Int", heightF,"Int",widthF, "Int",  0, "Int", 0,"Int",  weight, "Uint", 0,"Uint", 0,"uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontName)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
	colorR:=0x0000BB
	colorG:=0xAFAFAF

 

	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"),		PosY:=NumGet(POINT,4,"Int") 
		
	colorR:=0x0000EE
	m:=2
	y:=m
	Loop, % len {

		if(PosY>=y-m && PosY<y+row_h-m){
			DllCall("SetTextColor", "UPtr", hDC, "UInt",colorR )
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 		
		}else{	
	/* 		DllCall("SetTextColor", "UPtr", hDC, "UInt",colorG )
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 
			 */
		}
		y+=row_h
	}
  DllCall("DeleteObject", "UPtr", hFont)
  DllCall("ReleaseDC", "Uint", hwnd, "Uint", hDC)
}


;==============================================
iconOnWin(hwnd,len,row_h){
	hIcon:=LoadPicture("C:\AutoHotkey Scripts\icons\test\Close_16x16.ico","",ImageType)
	;hIcon:=LoadPicture("shell32.dll","Icon132 w16 h-1" ,ImageType) ; Win8
	hIcon:=LoadPicture("imageres.dll","Icon162 w16 h-1" ,ImageType) ; Win7
	
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)
	
	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=W-18,y:=0
	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"),		PosY:=NumGet(POINT,4,"Int")

	cxWidth:=cyWidth:=0
	m:=0
	y:=m
Loop, % len {
 	if(PosY>=y-m && PosY<y+row_h-m){
		RC:=DllCall("DrawIconEx","Ptr",hDC,"Int",x ,"Int",y ,"Ptr",hIcon ,"Int",cxWidth ,"Int",cyWidth ,"UInt",0 ,"Ptr",0,"UInt",0x3)
	}
	y+=row_h
}

	DllCall("ReleaseDC", "Uint", CtrlHwnd, "Uint", hDC)	
}

;====================================================


searchList:
if WinExist("Drozd_searchList")
	return
GuiWidth:=700, GuiHeight:=400
Gui,1: -MaximizeBox -MinimizeBox ; +Resize 
Gui,1: +HWNDGui1_Id
Gui,1: +ToolWindow -border ;-Caption 
Gui,1:Color,  DCE8ED 
Gui,1: Font, S9 w400, Tahoma
Gui,1: ListView , List__
Gui,1: Add, ListView, x0 y0 w%GuiWidth% h%GuiHeight% vList__ gClickListView , File Name|Date modified|Folder|Size
Gui,1:Default
Gui,1:ListView , List__
    LV_ModifyCol(1,580)
		LV_ModifyCol(2,70,"Size")
    LV_ModifyCol(3,120,"Date modified")
		LV_ModifyCol(4,500,"Folder") 

Gui,1: Show, Hide  w%GuiWidth% h%GuiHeight% , Drozd_searchList

;WinSet, Style, -0xC00000, Drozd_searchList 
return

WM_KEYDOWN(wParam, lParam){	
	ControlGetFocus , control, inputDrozd_Search
	if(control!="Edit1")
		return
	if(wParam = 13){ ; VK_ENTER := 13		
		List_Func_B(List_id, win)
	}else	if(wParam = 27){ ; Esc  ; del 46
	}
}

inputDrozd_(WinS_ID, win){
	global List_id, GuiInpID , queryList
	Gui,77: Destroy

	IniRead, read_, %settings_ini%, Search, query
  if(read_!="ERROR" && read_!=""){
		queries:= RegExReplace(read_,"im),","`n")
	}

  Gui,77: +Delimiter`n ; not | in ComboBox (for Regex)
	Gui,77: Margin, 0,0
	Gui,77: Color, EAF3FC ;3C557C ;2C3D59 
	Gui,77:+ToolWindow -Caption -MinimizeBox -MaximizeBox 
	Gui,77: +HwndGuiInpID 
	Gui,77:Font, S9 Q5  , Segoe UI 
	;Gui,77:Font, cDefault
	Gui,77:Add, ComboBox, x8 y3  +HWNDList_id vqueryList , %queries%
	Gui,77:Font, S8
	Gui,77:Add, Button, x+6 y+-23 h20   +HWNDBut_id, % Chr(9654) ;? ;Go
		fn := Func("List_Func_B").Bind(List_id, win)
		GuiControl, +g, % But_id, % fn	
    fn2 := Func("List_Func").Bind(List_id, win)    
    GuiControl, +g, % List_id, % fn2	

	WinGetPos, x1,y1,w1,h1, ahk_id %WinS_ID%
	Gui,77: +Owner%WinS_ID% 
  
  x:=x1+w1-rel_X, y:=y1+rel_Y
	Gui,77:Show,   x%x% y%y% w180 h28  NA , inputDrozd_Search
	ControlFocus, ComboBox1, inputDrozd_Search
	return	
	
	Cancel:
	Gui,77: Destroy
	return	
}


List_Func_B(hwnd, win){
	global WinS_ID, GuiInpID
	WinGetPos, x1,y1,w1,h1, ahk_id %WinS_ID%
	Gui,1: +Owner%WinS_ID% 
	x:=x1+55, y:=y1+95
	x2:=x1+8, y2:=y1+95,  w2:=w1-17, h2:=h1-110	
	Gui,1:Show,   x%x2% y%y2% w%w2% h%h2% NA , Drozd_searchList
	GuiControl,1: Move, List__, % "W"  w2 . " H" h2
	
	GuiControlGet, query, , % hwnd
	fold_path:=win.Document.Folder.Self.Path

  Gosub, ContextMenuSearch
	search_folder(fold_path, query)	  
}



List_Func(hwnd, win){
	global Win_ID, Gui1_Id, List__
	
		del:=ComboDel(hwnd)		
			if(del==1)
				return
}

ComboDel(hwnd){
  global List_id, GuiInpID , queryList
		VarSetCapacity(POINT,8,0)
		DllCall("GetCursorPos","Ptr",&POINT)
		DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
		x:=NumGet(POINT,0,"Int")
		y:=NumGet(POINT,4,"Int") 

		GuiControlGet, Pos, Pos, %hwnd%
		GuiControlGet, item_,,	%hwnd%
    
    if(PosW-x<16){
        ;MsgBox,4096,, % FocusedItem "`n"  x " , " y " |  "  PosW " , " PosH "`n"  PosX " , " PosY "`n"  PosX+PosW " , " PosY+PosH 
        ToolTip_("Deleted item:" "`n" item_ , 1)
        GuiControl, +AltSubmit, queryList
        GuiControlGet, line_,, %hwnd%
        Control, Delete, %line_%,, ahk_id %hwnd%
        GuiControl, -AltSubmit, queryList     
         
    }else{
      CbAutoComplete()
    }
  ;return 0 
}




search_folder(path,query){
	global List_, stop_loop
  add_to_ComboBox(query,"ComboBox1",MaxQueries)
  SetBatchLines, 5ms
  ;SetBatchLines, -1
	i:=0
	Gui,1:Show
	Gui,1:Default
	Gui,1:ListView , List__
	LV_Delete()
  LV_ModifyCol(1,,"Files found # " i "/" num_ " - """ query """")
  ;Loop, %path%\*.*, 0 , 1 
  Loop, Files, %path%\*.* , FDR ; Files, Dir, Recurse
    {
/*       if !RegExMatch(A_LoopFileExt,"i)htm|mp3|mp4|wav|aac|jpg|jpeg|png|gif|webp|3gp")
        continue
    */
    if RegExMatch(A_LoopFileExt,"i)lnk")
        continue
    
      if(stop_loop=1){
       MsgBox,,, Search stopped , 2
       stop_loop:=0
       break
      }
        if(Mod(A_Index, 100)==0) ; co 100
          ToolTip, % "#" i " / " A_Index , 480 , 6
        
      if(search_query(A_LoopFileName, query)){  
				i+= 1    
				FormatTime, FileTime, %A_LoopFileTimeModified% , yyyy/MM/dd HH:mm
				;FileTime:=A_LoopFileTimeModified	
				LV_Add("", A_LoopFileName, Size_format_file(A_LoopFileSize),FileTime,A_LoopFileDir) ; LoopFileSizeKB
      }  
      num_:=A_Index      
    }
    ToolTip
		LV_ModifyCol(1, "SortAsc")
		LV_ModifyCol(1,,"Files found # " i "/" num_ " - """ query """")
    GuiControl, +Redraw, List__  ; Re-enable redrawing
    SetBatchLines, 10ms
}


~^d::
stop_loop:=1
return

search_query(line, query){ 
  if(RegExMatch(query,"i)^""(.*)""$", q)){
    query:=q1
    if(RegExMatch(line,"i)" query))
      return true
  }else{
    array:=StrSplit(query," ")
    if(array.Length()>1){
      Loop, % array.Length(){
        if(array[A_Index]==""){
          continue
        }else if(!RegExMatch(line,"i)" array[A_Index])){
          return false
        }           
      }
        return true
    }else{   
      if(RegExMatch(line,"i)" query))        
        return true
    }
  }
  return false
}


add_to_ComboBox(new_val,box, max){ ;
	ControlGet, list_,List, ,%box%, inputDrozd_Search 
	list_array:=StrSplit(list_,"`n")
	if(list_array.Length()>=max){
		Control, Delete, % list_array.Length() , %box% ,  inputDrozd_Search
    ControlGet, list_,List, ,%box%, inputDrozd_Search 
    list_array:=StrSplit(list_,"`n")
  }
  index1:=array_contains(list_array, new_val)
	if(index1==0){
		new_box:= "`n" Trim(new_val) "`n" list_
		GuiControl,77:, %box%, %new_box% 
		;GuiControl,77:ChooseString, %box%, %new_val% ; select	
		GuiControl,77: Choose, %box%, 1
	}else{
		;GuiControl,77:ChooseString, %box%, %new_val% ; select	
		GuiControl,77: Choose, %box%, %index1%
	}
}


Size_format_file(bytes){
    size:=0
    if(bytes >= 1073741824){
        size :=Round(bytes/1073741824,2) " GB"
    }else if (bytes >= 1048576){
				size :=Round(bytes/1048576,1) " MB"				
    }else if (bytes >= 1024){
				size :=Round(bytes/1024) " kB"
		}else if (bytes == 0){
				size :=0				
    }else {
				size := bytes " B"               
    } 
			return size
 }


;===================================================

ClickListView:
if A_GuiEvent = DoubleClick
{
    LV_GetText(FileName, A_EventInfo)  
    LV_GetText(FolderPath, A_EventInfo, 4) 
    ;LV_GetText(date_mod, A_EventInfo, 3)
    FilePath:= FolderPath "\" FileName
    Run, %FilePath%
    
}
return

;===================================================

Open_folder:
  LV_GetText(FolderPath,row_now , 4)
	LV_GetText(FileName,row_now , 1)
  win := GetShellFolder(WinS_ID)
  fold_path:=win.Document.Folder.Self.Path
  if(FolderPath==fold_path){
    MsgBox, 0x00040103,, Found file is in the same folder.  Cancel search and select the file?
		IfMsgBox, No
			return
		IfMsgBox Cancel
			return    
		IfMsgBox, Yes
      Gosub,close_search_list
      win.Document.SelectItem(win.Document.Folder.ParseName(FileName), 1|4|8)
    return  
  }
	selfol:=1
  Run, %FolderPath%
	;Run, C:\windows\explorer.exe %FolderPath% ,,, PID_
return 

Open_file:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  Run, % FilePath
return


selectInWindow(hwnd){
  global selfol, WinS_ID, FileName, win
  if(hwnd==WinS_ID)
    return
  selfol:=0
  win_2 := GetShellFolder(hwnd)
  win_2.Document.SelectItem(win_2.Document.Folder.ParseName(FileName), 1|4|8) 
}

getWinInfo(hwnd){
  WinGet, PID, PID , ahk_id %hwnd%
  WinGet, pname, ProcessName,ahk_id %hwnd%  
  WinGetClass, class_, ahk_id %hwnd%  
  WinGetTitle, Title, ahk_id %hwnd%  
  return "hwnd=" hwnd " | class_= " class_ " | Title= " Title " | PID= " PID
}


copy_name:
  LV_GetText(name, row_now, 1)
  clipboard:=name
return

fileProperties:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  Run Properties %FilePath%
return

copy_path:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  clipboard:=FilePath
return

Edit_in_Scite:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  Process, Exist, SciTE.exe
  PID := Errorlevel
  if !PID{
    Run , "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
    WinWaitActive, ahk_class SciTEWindow
  }
  Run , "C:\Program Files\AutoHotkey\SciTE\SciTE.exe" "%FilePath%"
return

;===================================================
Open_ini:
Run, %settings_ini%
return

show_help:
Progress, zh0 w600 M2 C0y ZX20 ZY10 CWFFFFFF FS8 FM10 WM700 WS700 ,%help%,  , Windows Explorer Toolbar, Segoe UI Semibold
return
;============

~Esc::
GuiClose:
close_search_list:
  UnhookWinEvent(EventHook)
  UnhookWinEvent(EventHook_2)
  stop_loop:=1
  Gosub, saveQueries
	Gui,1: -Owner%WinS_ID% 
	Gui,77: -Owner%WinS_ID%
  ;DllCall("AnimateWindow", "Int", Gui1_Id, "Int", 200, "Int", 0x00050008) ;0x00050008
	Gui,1: Hide
  DllCall("AnimateWindow", "Int", GuiInpID, "Int", 200, "Int", 0x00050001)  
	Gui,77: Destroy
  Gosub, ContextMenuMake
return

saveQueries:
  ControlGet, query_,List, ,ComboBox1, inputDrozd_Search
  query_:= RegExReplace(query_,"im)`n",",")	
	
	if(query_!="")
  IniWrite, %query_%, %settings_ini%, Search, query
return


;====================================
 
ToolTip_(tekst,t:=2){
	CoordMode,ToolTip,Screen
	ToolTip, %tekst% ,%tipX%, %tipY%
	t:=t*1000
	Settimer, ToolTip_close , -%t%
}

ToolTip_close:
Settimer, ToolTip_close , Off
ToolTip
;ToolTip,,,,3
return

;=================


;=================

ContextMenuMake:
Menu, ContextMenu, Add
Menu, ContextMenu, DeleteAll
Menu, ContextMenu, Add, Remove this, destroyGui
Menu, ContextMenu, Add, Show Folder Paths, showFolderPaths
Menu, ContextMenu, Add , Open settings file , Open_ini
Menu, ContextMenu, Icon , Open settings file , Shell32.dll, 70
Menu, ContextMenu, Add, Help , show_help
Menu, ContextMenu, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit DrozdTools, Exit 
Menu, ContextMenu, Icon, Exit DrozdTools, Shell32.dll, 132
return

ContextMenuSearch:
Menu, ContextMenu, Add
Menu, ContextMenu, DeleteAll
Menu, ContextMenu, Add , Open , Open_file
Menu, ContextMenu, Add , Open in folder and select , Open_folder
Menu, ContextMenu, Add , Edit in Scite , Edit_in_Scite
if FileExist("C:\Program Files\AutoHotkey\SciTE\SciTE.exe")
Menu, ContextMenu, Icon , Edit in Scite , C:\Program Files\AutoHotkey\SciTE\SciTE.exe

Menu, ContextMenu, Icon, Open, shell32.dll,  3 
Menu, ContextMenu, Icon,  Open in folder and select, Shell32.dll, 111
Menu, ContextMenu, Add   
Menu, ContextMenu, Add , Copy name, copy_name 
Menu, ContextMenu, Add , Copy path, copy_path
Menu, ContextMenu, Add , Properties, fileProperties
Menu, ContextMenu, Add 
Menu, ContextMenu, Add,  Close search `t(Escape) , close_search_list
Menu, ContextMenu, Icon, Close search `t(Escape)  , shell32.dll,153
return

;====================================
;Menu_:

GuiContextMenu:
  if (A_GuiControl = "List__"){  ; ListView    
    menu_control_now:=A_GuiControl
    row_now:=A_EventInfo 
  }else if(A_GuiControl=="a"  || A_GuiControl="b" || A_GuiControl=button3  || A_GuiControl=button4 || Asc(A_GuiControl)==10102 || Asc(A_GuiControl)==8593 || Asc(A_GuiControl)==10103 || Asc(A_GuiControl)==10104 || RegExMatch(A_GuiControl,"i)switch|Shell32")){ 
    return
  }
  ;|| Asc(A_GuiControl)==3894 ;empty2
  ;  Asc("?")=10102 ; Asc("?")=10103; Asc("?")=10104 ; Asc("?")=10105 ; Asc("^")=8593 ; Asc("?")=3894
  MouseGetPos,x1,y1 
  Menu, ContextMenu, Show, %x1%, %y1%
Return


Reload:
Reload
return

Exit:
ExitApp



;=======================================================================================
CbAutoComplete(){	;autohotkey.com/boards/viewtopic.php?f=6&t=15002 Pulover
; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
	If ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
		return
	GuiControlGet, lHwnd, Hwnd, %A_GuiControl%
	SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%
	MakeShort(ErrorLevel, Start, End)
	GuiControlGet, CurContent,, %lHwnd%
	GuiControl, ChooseString, %A_GuiControl%, %CurContent%
	If (ErrorLevel)	{
		ControlSetText,, %CurContent%, ahk_id %lHwnd%
		PostMessage, 0x0142, 0, MakeLong(Start, End),, ahk_id %lHwnd%
		return
	}
	GuiControlGet, CurContent,, %lHwnd%
	PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
}

MakeLong(LoWord, HiWord){
	return (HiWord << 16) | (LoWord & 0xffff)
}

MakeShort(Long, ByRef LoWord, ByRef HiWord){
	LoWord := Long & 0xffff,   HiWord := Long >> 16
} 


