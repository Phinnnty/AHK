#Requires AutoHotkey v2+
#SingleInstance Force

Application := { 
    Name: "Python Venv Manager", 
    Version: "0.2",
    Icon: "AHK\Icons\Py.png"
}

; Set both tray and window icon
TraySetIcon(Application.Icon)


ShowGUI() {
    mainGui := Gui(, "Python Venv Manager")
    mainGui.Add("Picture", "w32 h-1", Application.Icon)
    mainGui.MarginX := 10
    mainGui.MarginY := 10
    
    ; First row of buttons - wider and centered
    createBtn := mainGui.Add("Button", "x10 y10 w110 h30", "Create Venv")
    createBtn.OnEvent("Click", CreateVenv)

    runBtn := mainGui.Add("Button", "x+5 yp w110 h30", "Run Program")
    runBtn.OnEvent("Click", RunProgram)
    
    ; Second row of buttons - matching first row
    createReqsBtn := mainGui.Add("Button", "x10 y+10 w110 h30", "Create Reqs")
    createReqsBtn.OnEvent("Click", CreateReqs)

    installBtn := mainGui.Add("Button", "x+5 yp w110 h30", "Install Reqs")
    installBtn.OnEvent("Click", InstallReqs)
   
    ; Python Files List - adjusted width to match buttons
    mainGui.Add("GroupBox", "x10 y+20 w225 h150", "Python Files")
    pyList := mainGui.Add("ListView", "xp+10 yp+20 w205 h120 -Hdr", ["Filename"])
    
    
    ; Add list events
    pyList.OnEvent("DoubleClick", RunProgram)
    
    ; Find .py files
    Loop Files, A_WorkingDir "\*.py" {
        pyList.Add(, A_LoopFileName)
    }
    
    ; Store ListView reference globally
    global gPyList := pyList
    
    mainGui.Show()  ; Set fixed window size
}

CreateVenv(*) {
    if !FileExist("venv") {
        Run("cmd.exe /k python -m venv venv && .venv\Scripts\activate.bat")
        TrayTip("Virtual environment created", , "Mute")
        return
    }else{
        TrayTip("Virtual environment already exists", , "Mute")
    }
}

CreateReqs(*){
    if !FileExist("requirements.txt"){
        Run("cmd.exe /c pip freeze > requirements.txt")
        TrayTip("Requirements file created", , "Mute")
        return
    }else{
        TrayTip("Requirements file already exists", , "Mute")
    }
}

InstallReqs(*) {
    if FileExist("requirements.txt") {
        ; Get installed packages
        RunWait("cmd.exe /c pip list > installed_packages.txt")
        installed := FileRead("installed_packages.txt")
        FileDelete("installed_packages.txt")
        
        ; Read requirements
        required := FileRead("requirements.txt")
        needsInstall := false
        
        ; Check each requirement
        Loop Parse, required, "`n", "`r" {
            if (A_LoopField = "")
                continue
            if !InStr(installed, StrSplit(A_LoopField, "==")[1]) {
                needsInstall := true
                break
            }
        }
        
        if (needsInstall) {
            TrayTip("Installing missing packages...", , "Mute")
            RunWait("cmd.exe /k pip install -r requirements.txt")
        } else {
            TrayTip("All packages already installed", , "Mute")
        }
        return
    }

    ; Check for .py files
    pyFileExists := false
    Loop Files, A_WorkingDir "\*.py" {
        pyFileExists := true
        break
    }

    if (pyFileExists) {
        RunWait("cmd.exe /k pip freeze > requirements.txt && pip install -r requirements.txt")
        TrayTip("Created and installed requirements", , "Mute")
    } else {
        MsgBox("No requirements.txt found and no Python files to generate requirements from!")
    }
}


RunProgram(*) {
    ; Get selected file from ListView
    if (row := gPyList.GetNext()) {
        selectedFile := gPyList.GetText(row, 1)
        if selectedFile {
            if FileExist("venv\Scripts\") {
                Run("cmd.exe /k .venv\Scripts\activate.bat && python " selectedFile)
            } else {
                Run("python " selectedFile)
            }
            TrayTip("Running " selectedFile, , "Mute")
        }
    } else {
        MsgBox("Please select a Python file to run")
    }
}

ShowGUI()