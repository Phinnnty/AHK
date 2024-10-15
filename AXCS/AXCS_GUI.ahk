#SingleInstance, Force
#Include JSON.ahk

; Load existing data
FileRead, jsonContent, AXCS_Source.json
existingCommands := JSON.Load(jsonContent)

; GUI creation
Gui, Add, DropDownList, vAction gUpdateFields, Create New Phrase|Edit Existing Phrase
Gui, Add, DropDownList, vCommandType gUpdateFields, Open Webpage|Open Application
Gui, Add, Text, vPhraseText, Trigger Phrase:
Gui, Add, Edit, vPhrase
Gui, Add, Text, vURLText, URL/Application Path:
Gui, Add, Edit, vURL
Gui, Add, Button, gSubmit, Submit

Gui, Show
return

; This script needs a lot of work to be fully functional.
; Currently it is a GUI that allows you to create a new phrase 
; This phrase gets added to the AXCS_Source.json file and to the AXCS_VoiceCommands.ahk file.
; 
; Two bugs to fix
; 
; AXCS_Source.JSON 
; - Currently the JSON file is not being updated correctly. 
; - It takes the Command and adds it to the JSON file.
; - This results in lines like: 
;  - "Open Jira":"https://mxjira.murex.com/secure/Dashboard.jspa"
;- Where as the AXCS_Source.JSON file should be:
;- "Open Facebook":"OpenFacebook", 
;- which then searchs agaisnt the AXCS_VoiceCommands.ahk file and finds the function OpenFacebook() {
;- OpenFacebook() Run, https://facebook.com}
;- With the current method, it cant do the search and find the function.
;- The AXCS_VoiceRecognition.ahk searches for a function called https://mxjira.murex.com/secure/Dashboard.jspa
;- which it will never find. 
;- the AXCS_VoiceRecognition.ahk needs to find the matching funciton name; OpenJira(). 

; AXCS_VoiceCommands.ahk
; - Currently the AXCS_VoiceCommands.ahk file is not being updated correctly when propagating from AXCS_GUI.ahk
; - Currently it adds the newly created phrase to the AXCS_VoiceCommands.ahk file.
; - However it does not handle the function name creation correctly
; - What this results in is Open Jira() instead of OpenJira()
; - So we need to add some sort of hanlder in AXCS_GUI.ahk to handle the function name creation correctly. 
; - It just needs to use regex probably to remvoe the spaces of the Phrase and then add the () to the end.
; - This will allow the AXCS_VoiceRecognition.ahk to find the correct function name.


UpdateFields:
GuiControlGet, Action
GuiControlGet, CommandType
if (Action = "Create New Phrase") {
    GuiControl, Show, CommandType
    GuiControl, Show, PhraseText
    GuiControl, Show, Phrase
    GuiControl, Show, URLText
    GuiControl, Show, URL
} else {
    ; Populate dropdown with existing phrases
    GuiControl,, Phrase, |
    for phrase, _ in existingCommands {
        GuiControl,, Phrase, %phrase%
    }
    GuiControl, Hide, CommandType
    GuiControl, Show, PhraseText
    GuiControl, Show, Phrase
    GuiControl, Hide, URLText
    GuiControl, Hide, URL
}
return

Submit:
GuiControlGet, Action
GuiControlGet, Phrase
GuiControlGet, URL

if (Action = "Create New Phrase") {
    existingCommands[Phrase] := URL
    AppendToAHKFile(Phrase, URL)
} else {
    ; Handle editing existing phrase
}

; Save updated JSON
newJson := JSON.Dump(existingCommands)
FileDelete, AXCS_Source.json
FileAppend, %newJson%, AXCS_Source.json

MsgBox, Command added/updated successfully!
return

AppendToAHKFile(phrase, url) {
    FileAppend, 
    (
    
    %phrase%:
    Run, %url%
    return

    ), AXCS_VoiceCommands.ahk
}

GuiClose:
ExitApp
