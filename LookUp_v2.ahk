; --------------------------------------------------------------
; notes
; --------------------------------------------------------------
; ! = alt
; ^ = ctrl
; + = shift
; # = lwin|rwin


SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
#SingleInstance Force
SetTitleMatchMode(2)

^!#g::  ; Ctrl+Alt+Win+G
{ 
MyClip := ClipboardAll()
A_Clipboard := "" ; empty the clipboard
Send("^c") ; copy the contents of highlighted text
Errorlevel := !ClipWait(2)
if ErrorLevel  ; ClipWait timed out.
{
    ToolTip("Clipboard capture failed. Please try again.")
    Sleep(1500) ; Display the tooltip for 1.5 seconds
    ToolTip() ; Removes the tooltip
    A_Clipboard := MyClip
    return
}
if RegExMatch(A_Clipboard, "^[^ ]*\.[^ ]*$")
{
    Run("`"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`" " A_Clipboard)
}
else 
{
    ; Modify some characters that screw up the URL
    ; RFC 3986 section 2.2 Reserved Characters (January 2005):  !*'();:@&=+$,/?#[]
    ; StrReplace() is not case sensitive
    ; check for StringCaseSense in v1 source script
    ; and change the CaseSense param in StrReplace() if necessary
    A_Clipboard := StrReplace(A_Clipboard, "`r`n", A_Space)
    ; StrReplace() is not case sensitive
    ; check for StringCaseSense in v1 source script
    ; and change the CaseSense param in StrReplace() if necessary
    A_Clipboard := StrReplace(A_Clipboard, "#", "`%23")
    ; StrReplace() is not case sensitive
    ; check for StringCaseSense in v1 source script
    ; and change the CaseSense param in StrReplace() if necessary
    A_Clipboard := StrReplace(A_Clipboard, "&", "`%26")
    ; StrReplace() is not case sensitive
    ; check for StringCaseSense in v1 source script
    ; and change the CaseSense param in StrReplace() if necessary
    A_Clipboard := StrReplace(A_Clipboard, "+", "`%2b")
    ; StrReplace() is not case sensitive
    ; check for StringCaseSense in v1 source script
    ; and change the CaseSense param in StrReplace() if necessary
    A_Clipboard := StrReplace(A_Clipboard, "`"", "`%22")
    Run("https://www.google.com/search?hl=en&q=" . A_Clipboard) ; uriEncode(clipboard) ; note that the run command will open this URL in the deafult browser you have selected.
}
A_Clipboard := MyClip
return
} 
