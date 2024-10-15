; You may also need to train voice recognition in Windows so that it will understand your voice.
#Persistent
#Include JSON.ahk
#Include temp_command.ahk
#SingleInstance, Force

; Load and parse the JSON file
FileRead, jsonContent, AXCS_Source.json
global responses := JSON.Load(jsonContent)

; Print the list of commands
; MsgBox, % "Available Voice Commands:`n`n" . ListCommands(responses)

; Function to create a formatted list of commands
ListCommands(commands) {
    commandList := ""
    for command, action in commands {
        commandList .= command . "`n"
    }
    return commandList
}


global pspeaker := ComObjCreate("SAPI.SpVoice") ;plistener := ComObjCreate("SAPI.SpSharedRecognizer") 
plistener:= ComObjCreate("SAPI.SpInprocRecognizer") ; For not showing Windows Voice Recognition widget.
paudioinputs := plistener.GetAudioInputs() ; For not showing Windows Voice Recognition widget.
plistener.AudioInput := paudioinputs.Item(0)   ; For not showing Windows Voice Recognition widget.
ObjRelease(paudioinputs) ; Release object from memory, it is not needed anymore.
pcontext := plistener.CreateRecoContext()
pgrammar := pcontext.CreateGrammar()
pgrammar.DictationSetState(0)
prules := pgrammar.Rules()
prulec := prules.Add("wordsRule", 0x1|0x20)
prulec.Clear()
pstate := prulec.InitialState()

; Update the loop to use the parsed JSON data
for Text, v in responses
    pstate.AddWordTransition(ComObjParameter(13,0), Text)

for Text, v in Responses ;Need to add each text to the pstate object and watch for them
	pstate.AddWordTransition( ComObjParameter(13,0),Text) ; ComObjParemeter(13,0) is value Null for AHK_L

prules.Commit()
pgrammar.CmdSetRuleState("wordsRule",1)
prules.Commit()
ComObjConnect(pcontext, "On")
If (pspeaker && plistener && pcontext && pgrammar && prules && prulec && pstate){	
	SplashTextOn,300,50,,Voice recognition initialisation succeeded
    
}Else { 
	MsgBox, Sorry, voice recognition initialisation FAILED  ;	pspeaker.speak("Starting voice recognition initialisation failed")
}
sleep, 2000
SplashTextOff


FileRead, voiceCommandsContent, AXCS_VoiceCommands.ahk
if (voiceCommandsContent) {
    ; MsgBox, % "Contents of AXCS_VoiceCommands.ahk:`n`n" . voiceCommandsContent
} else {
    MsgBox, Unable to read AXCS_VoiceCommands.ahk file.
}
return

;; RECOGNITION EVENT HANDLER ;; 
#Include AXCS_VoiceCommands.ahk

OnRecognition(StreamNum,StreamPos,RecogType,Result) {
    sText := Result.PhraseInfo().GetText()
    if (responses[sText]) {
        functionName := responses[sText]
        if (IsFunc(functionName)) {
            %functionName%()
        } else {
            MsgBox, Function %functionName% not found.
        }
    }
    ObjRelease(sText)
}


^Escape::ExitApp ; Control Escape exits the programRun Notepad
Return