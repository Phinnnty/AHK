Persistent
#SingleInstance Force

; Define default file name without .csv extension
DefaultFileName := A_ScriptDir "\TaskList"

; Initialize Main GUI
Main := Gui("+Resize", "Work Management")

; Define Controls
Main.Add("Text", "x10 y10 w120", "Task Name:")
TaskNameEdit := Main.Add("Edit", "x140 y10 w200 vTaskName")

Main.Add("Text", "x10 y40 w120", "Task Description:")
TaskDescriptionEdit := Main.Add("Edit", "x140 y40 w200 vTaskDescription")

Main.Add("Text", "x10 y70 w120", "Priority:")
PriorityDropdown := Main.Add("DropDownList", "x140 y70 w200 vTaskPriority", ["Low", "Medium", "High"])

Main.Add("Text", "x10 y100 w120", "Due Date:")
DueDateEdit := Main.Add("Edit", "x140 y100 w200 vTaskDueDate")

AddTaskButton := Main.Add("Button", "x10 y130 w100", "Add Task")
ClearFieldsButton := Main.Add("Button", "x120 y130 w100", "Clear")

TaskListView := Main.Add("ListView", "x10 y160 w450 h200", ["Task Name", "Task Description", "Priority", "Due Date"])
EditTaskButton := Main.Add("Button", "x10 y370 w100", "Edit Task")
DeleteTaskButton := Main.Add("Button", "x120 y370 w100", "Delete Task")

SaveButton := Main.Add("Button", "x230 y370 w100", "Save Tasks")
LoadButton := Main.Add("Button", "x340 y370 w100", "Load Tasks")

; Event Handlers
AddTaskButton.OnEvent("Click", AddTask)
ClearFieldsButton.OnEvent("Click", ClearFields)
TaskListView.OnEvent("ItemSelect", TaskSelected)
EditTaskButton.OnEvent("Click", EditTask)
DeleteTaskButton.OnEvent("Click", DeleteTask)
SaveButton.OnEvent("Click", SaveTasks)
LoadButton.OnEvent("Click", LoadTasks)

; Show GUI
Main.Show()

; Automatically load tasks from TaskList if it exists
SetTimer(LoadDefaultTasks, -100)

return

; Functions and Handlers
AddTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit, TaskListView

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDueDate := DueDateEdit.Value

    if (TaskName = "") {
        MsgBox("Task Name cannot be empty.", "Error", 48)
        return
    }

    TaskListView.Add("", TaskName, TaskDescription, TaskPriority, TaskDueDate)
    MsgBox("Task added: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDueDate)
    ClearFields()
}

ClearFields(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit
    TaskNameEdit.Value := ""
    TaskDescriptionEdit.Value := ""
    PriorityDropdown.Text := "Low"
    DueDateEdit.Value := ""
}

EditTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit, TaskListView

    Row := TaskListView.GetNext()
    if (Row = 0) {
        MsgBox("Please select a task to edit.", "Error", 48)
        return
    }

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDueDate := DueDateEdit.Value

    if (TaskName = "") {
        MsgBox("Task Name cannot be empty.", "Error", 48)
        return
    }

    TaskListView.Modify(Row, "", TaskName, TaskDescription, TaskPriority, TaskDueDate)
    MsgBox("Task edited: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDueDate)
    ClearFields()
}

DeleteTask(*) {
    Global TaskListView

    Row := TaskListView.GetNext()
    if (Row = 0) {
        MsgBox("Please select a task to delete.", "Error", 48)
        return
    }
    TaskListView.Delete(Row)
    ClearFields()
}

TaskSelected(*) {
    Global TaskListView, TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit

    Row := TaskListView.GetNext()
    if (Row > 0) {
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        TaskPriority := TaskListView.GetText(Row, 3)
        TaskDueDate := TaskListView.GetText(Row, 4)
        TaskNameEdit.Value := TaskName
        TaskDescriptionEdit.Value := TaskDescription
        PriorityDropdown.Text := TaskPriority
        DueDateEdit.Value := TaskDueDate
    }
}

SaveTasks(*) {
    Global TaskListView, DefaultFileName

    ; Set a default file name
    SavePath := FileSelect("Save", DefaultFileName , "Save Task List As", "*.csv")

    if (!SavePath) {
        return
    }

    ; Ensure the selected file has a .csv extension only once
    if (SubStr(SavePath, -4) != ".csv") {
        SavePath := SavePath ".csv"
    }

    File := FileOpen(SavePath, "w")
    Loop (TaskListView.GetCount()) {
        Row := A_Index
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        TaskPriority := TaskListView.GetText(Row, 3)
        TaskDueDate := TaskListView.GetText(Row, 4)
        File.WriteLine(TaskName "," TaskDescription "," TaskPriority "," TaskDueDate)
    }
    File.Close()
    MsgBox("Tasks saved successfully.", "Info", 64)
}

LoadTasks(*) {
    Global TaskListView, DefaultFileName

    LoadPath := FileSelect("Open", DefaultFileName, "Load Task List", "*.csv")
    if (!LoadPath) {
        return
    }
    LoadFromFile(LoadPath)
    MsgBox("Tasks loaded successfully.", "Info", 64)
}

LoadDefaultTasks(*) {
    Global DefaultFileName
    MsgBox("Checking for file: " DefaultFileName ".csv") ; Debugging message
    if FileExist(DefaultFileName ".csv") {
        MsgBox("File exists: " DefaultFileName ".csv") ; Debugging message
        LoadFromFile(DefaultFileName ".csv")
    } else {
        MsgBox("File does not exist: " DefaultFileName ".csv") ; Debugging message
    }
}

LoadFromFile(FilePath) {
    Global TaskListView
    MsgBox("Loading from file: " FilePath) ; Debugging message
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
            if (Fields.Length = 4) {
                TaskListView.Add("", Fields[1], Fields[2], Fields[3], Fields[4])
            }
        }
    }
    File.Close()
    MsgBox("Finished loading from file: " FilePath) ; Debugging message
}

GuiClose(*) {
    ExitApp()
}
