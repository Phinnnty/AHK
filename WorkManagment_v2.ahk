Persistent
#SingleInstance Force

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

; Automatically load tasks from TaskList.csv if it exists
LoadDefaultTasks()

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
    Global TaskListView

    ; Set a default file name
    DefaultFileName := "TaskList"
    
    ; Open file selection dialog with default file name
    SavePath := FileSelect("Save", DefaultFileName, "csv)")
    
    if (!SavePath) {
        return
    }
    
    ; Ensure the selected file has a .csv extension
    if (SubStr(SavePath, -3) != ".csv") {
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
    Global TaskListView

    LoadPath := FileSelect("Open", "TaskList", "csv)")
    if (!LoadPath) {
        return
    }
    LoadFromFile(LoadPath)
    MsgBox("Tasks loaded successfully.", "Info", 64)
}

LoadDefaultTasks() {
    DefaultFileName := "TaskList.csv"
    MsgBox("Checking for file: " DefaultFileName)
    if FileExist(DefaultFileName) {
        MsgBox("File exists: " DefaultFileName)
        LoadFromFile(DefaultFileName)
    } else {
        MsgBox("File does not exist: " DefaultFileName)
    }
}

LoadFromFile(FilePath) {
    Global TaskListView
    File := FileOpen(FilePath, "r")
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
}

GuiClose(*) {
    ExitApp()
}
