; This file is partial copy of: _ahk\lib\orkan.lib.ahk
; Moved here to simplify code sharing in git repo and reduce codebase of final EXE
; Not perfect idea, though

;###################################################################################################
; ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN ORKAN 
;###################################################################################################

;===========================
; Load user settings from ini file and merge it with given array
merge_from_ini(o, name) {
    if (FileExist(name)) {
        o := object_merge(o, ReadINI(name)) ; overwrites symlink.def.inc.ahk
    }
    return o
}

;===========================
; Merge 2 objects recursively
; same numeric and string keys gets overwriten
object_merge(o1, o2) {
    local key, val
    for, key, val in o2
        o1[key] := IsObject(val) ? object_merge(IsObject(o1[key]) ? o1[key] : [], val) : val
    return o1
}

;===========================
; Shorten git tag version string to only: major.minor(-RC...)
get_version(str) {
    return RegExReplace(str, "(v[0-9]+)(\.[0-9]+)(\.[0-9]+)(-.+)?", "$1$2$4") ; 
}

;===========================
; Shorten string from middle to a given length. Put ellipsis in cut place
str_reduce(str, len, pos:=50, ellipsis:="...") {
	w := StrLen(str)
	e := StrLen(ellipsis)
	r := w - (len - e) ; reduction length
	
	if (r <= e)
		return str
	if (len <= e)
		return ellipsis

	p := pos > 100 ? w : Floor((w / 100) * pos) ; cut position
	r1 := Ceil(r/2) ; left reduction length
	r2 := r - r1 ; right reduction length
	
	x1 := p - r1
	if (x1 < 0) {
		x1 := Abs(x1)
		r1 := p
		r2 += x1
	}
	x2 := (w - p) - r2
	if (x2 < 0) {
		x2 := Abs(x2)
		r2 -= x2
		r1 += x2
	}
	
	s1 := SubStr(str, 1, p - r1)
	s2 := SubStr(str, 1 + p + r2)
	s := s1 . ellipsis . s2
	return s
}

;###################################################################################################
; EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT  EXT
;###################################################################################################

;===========================
; INI-file object maker
; https://www.autohotkey.com/boards/viewtopic.php?t=60756&p=268738
WriteINI(ByRef Array2D, INI_File) { ; write 2D-array to INI-file
    local Key, Value
    for SectionName, Entry in Array2D {
        Pairs := ""
        for Key, Value in Entry
            Pairs .= Key "=" Value "`n"
        IniWrite, %Pairs%, %INI_File%, %SectionName%
    }
}
ReadINI(INI_File) { ; return 2D-array from INI-file
    Result := []
    IniRead, SectionNames, %INI_File%
    for each, Section in StrSplit(SectionNames, "`n") {
        IniRead, OutputVar_Section, %INI_File%, %Section%
        for each, Haystack in StrSplit(OutputVar_Section, "`n")
            RegExMatch(Haystack, "(.*?)=(.*)", $)
            , Result[Section, $1] := $2
    }
    return Result
}
