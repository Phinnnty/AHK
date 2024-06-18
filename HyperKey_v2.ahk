; --------------------------------------------------------------
; notes
; --------------------------------------------------------------
; ! = alt
; ^ = ctrl
; + = shift
; # = lwin|rwin

#UseHook
InstallKeybdHook()
#SingleInstance force
SendMode("Input")  ; Use the input mode for sending commands, which is faster and more reliable.
SetCapsLockState("AlwaysOff")  ; Disable the Capslock toggle functionality entirely.

~Capslock::  ; The tilde (~) allows the Capslock key to still be used in other hotkeys.
{ 
    Send("{Ctrl Down}{Alt Down}{LWin Down}")  ; Press down Ctrl, Alt, and Win keys and keep them down.
    KeyWait("Capslock")  ; Wait indefinitely until the Capslock key is released.
    Send("{Ctrl Up}{Alt Up}{LWin Up}")  ; Once released, lift up all modifier keys.
    return
} 
