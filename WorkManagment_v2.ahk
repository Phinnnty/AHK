; AutoHotkey version 2 script

Persistent
#SingleInstance Force

; Define default file name without .csv extension
DefaultFileName := A_ScriptDir "\TaskList"

; Initialize Main GUI
Main := Gui("+Resize +AlwaysOnTop", "Work Management")
Main.MarginX := 20
Main.MarginY := 20

; Define Controls
Main.Add("Text", "xm ym w120", "Task Name:")
TaskNameEdit := Main.Add("Edit", "x+10 yp w200 vTaskName")

Main.Add("Text", "x+20 w120", "Task Description:")
TaskDescriptionEdit := Main.Add("Edit", "x+10 yp w200 vTaskDescription")

Main.Add("Text", "xm y+30 w120", "Priority:")
PriorityDropdown := Main.Add("DropDownList", "x+10 yp w200 vTaskPriority", ["Low", "Medium", "High"])

Main.Add("Text", "x+20 w120", "Difficulty:")
DifficultyDropdown := Main.Add("DropDownList", "x+10 yp w200 vTaskDifficulty", ["Easy", "Moderate", "Hard"])

Main.Add("Text", "xm y+30 w120", "Due Date (DD/MM/YYYY):")
DueDateEdit := Main.Add("Edit", "x+10 yp w200 vTaskDueDate")

Main.Add("Text", "x+20 w120", "Status:")
StatusDropdown := Main.Add("DropDownList", "x+10 yp w200 vTaskStatus", ["Not Started", "In Progress", "Completed"])

AddTaskButton := Main.Add("Button", "xm y+40 w100", "Add Task")
ClearFieldsButton := Main.Add("Button", "x+10 w100", "Clear")

; Keep ListView height but make it more narrow
TaskListView := Main.Add("ListView", "xm y+20 w600 h280", ["Task Name", "Task Description", "Priority", "Difficulty", "Due Date", "Status"])

; Adjust button positions to be higher
EditTaskButton := Main.Add("Button", "xm y+40 w100", "Edit Task")
DeleteTaskButton := Main.Add("Button", "x+40 w100", "Delete Task")
SaveButton := Main.Add("Button", "x+40 w100", "Save Tasks")
LoadButton := Main.Add("Button", "x+40 w100", "Load Tasks")

; Adjust StatusBar position
StatusBar := Main.Add("Text", "xm y+40 w600 h20 vStatusBar", "")

; Set ListView styles
TaskListView.OnEvent("ItemSelect", TaskSelected)
TaskListView.OnEvent("DoubleClick", TaskSelected)

; Event Handlers
AddTaskButton.OnEvent("Click", AddTask)
ClearFieldsButton.OnEvent("Click", ClearFields)
EditTaskButton.OnEvent("Click", EditTask)
DeleteTaskButton.OnEvent("Click", DeleteTask)
SaveButton.OnEvent("Click", SaveTasks)
LoadButton.OnEvent("Click", LoadTasks)

; Hotkey to show the GUI
^!#w::Main.Show()

; Close the GUI with ESC
Main.OnEvent("Escape", GuiClose)

; Show GUI
Main.Show()

; Automatically load tasks from TaskList if it exists
SetTimer(LoadDefaultTasks, -100)

return

; Functions and Handlers
AddTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DifficultyDropdown, DueDateEdit, StatusDropdown, TaskListView, StatusBar

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDifficulty := DifficultyDropdown.Text
    TaskDueDate := DueDateEdit.Value
    TaskStatus := StatusDropdown.Text

    ; Validation
    if (TaskName = "") {
        StatusBar.Text := "Error: Task Name cannot be empty."
        return
    }

    if !IsValidDate(TaskDueDate) {
        StatusBar.Text := "Error: Invalid date format. Use DD/MM/YYYY."
        return
    }

    if (StrLen(TaskDescription) > 255) {
        StatusBar.Text := "Error: Task Description is too long. Maximum 255 characters allowed."
        return
    }

    Row := TaskListView.Add("", TaskName, TaskDescription, TaskPriority, TaskDifficulty, TaskDueDate, TaskStatus)
    StatusBar.Text := "Task added: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDifficulty " - " TaskDueDate " - " TaskStatus
    ClearFields()
}

ClearFields(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DifficultyDropdown, DueDateEdit, StatusDropdown
    TaskNameEdit.Value := ""
    TaskDescriptionEdit.Value := ""
    PriorityDropdown.Text := "Low"
    DifficultyDropdown.Text := "Easy"
    DueDateEdit.Value := ""
    StatusDropdown.Text := "Not Started"
}

EditTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DifficultyDropdown, DueDateEdit, StatusDropdown, TaskListView, StatusBar

    Row := TaskListView.GetNext()
    if (Row = 0) {
        StatusBar.Text := "Error: Please select a task to edit."
        return
    }

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDifficulty := DifficultyDropdown.Text
    TaskDueDate := DueDateEdit.Value
    TaskStatus := StatusDropdown.Text

    ; Validation
    if (TaskName = "") {
        StatusBar.Text := "Error: Task Name cannot be empty."
        return
    }

    if !IsValidDate(TaskDueDate) {
        StatusBar.Text := "Error: Invalid date format. Use DD/MM/YYYY."
        return
    }

    if (StrLen(TaskDescription) > 255) {
        StatusBar.Text := "Error: Task Description is too long. Maximum 255 characters allowed."
        return
    }

    TaskListView.Modify(Row, "", TaskName, TaskDescription, TaskPriority, TaskDifficulty, TaskDueDate, TaskStatus)
    StatusBar.Text := "Task edited: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDifficulty " - " TaskDueDate " - " TaskStatus
    ClearFields()
}

DeleteTask(*) {
    Global TaskListView, StatusBar

    Row := TaskListView.GetNext()
    if (Row = 0) {
        StatusBar.Text := "Error: Please select a task to delete."
        return
    }
    TaskListView.Delete(Row)
    StatusBar.Text := "Task deleted."
    ClearFields()
}

TaskSelected(*) {
    Global TaskListView, TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DifficultyDropdown, DueDateEdit, StatusDropdown

    Row := TaskListView.GetNext()
    if (Row > 0) {
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        TaskPriority := TaskListView.GetText(Row, 3)
        TaskDifficulty := TaskListView.GetText(Row, 4)
        TaskDueDate := TaskListView.GetText(Row, 5)
        TaskStatus := TaskListView.GetText(Row, 6)
        TaskNameEdit.Value := TaskName
        TaskDescriptionEdit.Value := TaskDescription
        PriorityDropdown.Text := TaskPriority
        DifficultyDropdown.Text := TaskDifficulty
        DueDateEdit.Value := TaskDueDate
        StatusDropdown.Text := TaskStatus
    }
}

SaveTasks(*) {
    Global TaskListView, DefaultFileName, StatusBar

    SavePath := DefaultFileName ".csv"

    File := FileOpen(SavePath, "w")
    Loop (TaskListView.GetCount()) {
        Row := A_Index
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        TaskPriority := TaskListView.GetText(Row, 3)
        TaskDifficulty := TaskListView.GetText(Row, 4)
        TaskDueDate := TaskListView.GetText(Row, 5)
        TaskStatus := TaskListView.GetText(Row, 6)
        File.WriteLine(TaskName "," TaskDescription "," TaskPriority "," TaskDifficulty "," TaskDueDate "," TaskStatus)
    }
    File.Close()
    StatusBar.Text := "Tasks saved successfully."
}

LoadTasks(*) {
    Global TaskListView, DefaultFileName, StatusBar

    LoadPath := FileSelect("Open", DefaultFileName, "Load Task List", "*.csv")
    if (!LoadPath) {
        return
    }
    LoadFromFile(LoadPath)
    StatusBar.Text := "Tasks loaded successfully."
}

LoadDefaultTasks(*) {
    Global DefaultFileName
    if FileExist(DefaultFileName ".csv") {
        LoadFromFile(DefaultFileName ".csv")
    }
}

LoadFromFile(FilePath) {
    Global TaskListView, StatusBar
    File := FileOpen(FilePath, "r")
    if (!File) {
        MsgBox("Failed to open file: " FilePath)
        return
    }
    TaskListView.Delete()
    while (!File.AtEOF) {
        Line := File.ReadLine()
        if (Line) {
            Fields := StrSplit(Line, ",")
            if (Fields.Length = 6) {
                Row := TaskListView.Add("", Fields[1], Fields[2], Fields[3], Fields[4], Fields[5], Fields[6])
            }
        }
    }
    File.Close()
    StatusBar.Text := "Tasks loaded from file: " FilePath
}

GuiClose(*) {
    Main.Hide()
}

IsValidDate(date) {
    ; Check if the date is in the format DD/MM/YYYY
    return RegExMatch(date, "^\d{2}/\d{2}/\d{4}$")
}
