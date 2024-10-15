;********************Voice command labels***********************************

OpenFacebook() {
    Run, https://facebook.com
}

OpenInstaCart() {
    Run, https://instacart.ca
}

OpenAirCanada() {
    Run, https://aircanada.ca
}

TurnVolumeUp() {
    Send {Volume_Up} 
}

TurnVolumeDown() {
    Send {Volume_Down} 
}

TurnScreenOff() {
    SendMessage, 0x112, 0xF170, 2,, Program Manager ; Use 2 to turn the monitors off.
}

TurnScreenOn() {
    SendMessage, 0x112, 0xF170, -1,, Program Manager ; Use -1 to turn the monitor on.
}
