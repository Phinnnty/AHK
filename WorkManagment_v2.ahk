; would be nice to add a Completed Task button which moves the task to a histroically completed worksheet.
; would be fun to add a temporary celebratory gif or png when task is completed. 
; would be nice to add functionallity so that it has multiple .csv files, or works off of a .xls file format
; this would mean more worksheets = tabs on the GUI. 
; would be nice to have tabs for (1) active tasks / backlog tasks (2) historic tasks (3) archived historic tasks (hidden). 

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
TaskNameEdit := Main.Add("Edit", "xm+140 yp w200 vTaskName")

Main.Add("Text", "xm y+30 w120", "Task Description:")
TaskDescriptionEdit := Main.Add("Edit", "xm+140 yp w200 vTaskDescription")

Main.Add("Text", "xm y+30 w120", "Priority:")
PriorityDropdown := Main.Add("DropDownList", "xm+140 yp w200 vTaskPriority", ["Low", "Medium", "High"])

Main.Add("Text", "xm y+30 w120", "Due Date:")
DueDateEdit := Main.Add("Edit", "xm+140 yp w200 vTaskDueDate")

AddTaskButton := Main.Add("Button", "xm y+40 w100", "Add Task")
ClearFieldsButton := Main.Add("Button", "x+10 w100", "Clear")

TaskListView := Main.Add("ListView", "xm y+20 w450 h200", ["Task Name", "Task Description", "Priority", "Due Date"])
EditTaskButton := Main.Add("Button", "xm y+210 w100", "Edit Task")
DeleteTaskButton := Main.Add("Button", "x+10 w100", "Delete Task")

SaveButton := Main.Add("Button", "x+10 w100", "Save Tasks")
LoadButton := Main.Add("Button", "x+10 w100", "Load Tasks")

; Status bar
StatusBar := Main.Add("Text", "xm y+40 w450 h20", "")

; Set ListView styles
TaskListView.OnEvent("ItemSelect", TaskSelected)
TaskListView.ModifyCol(1, "AutoHdr")
TaskListView.ModifyCol(2, "AutoHdr")
TaskListView.ModifyCol(3, "AutoHdr")
TaskListView.ModifyCol(4, "AutoHdr")

; Event Handlers
AddTaskButton.OnEvent("Click", AddTask)
ClearFieldsButton.OnEvent("Click", ClearFields)
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
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit, TaskListView, StatusBar

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDueDate := DueDateEdit.Value

    if (TaskName = "") {
        StatusBar.Text := "Error: Task Name cannot be empty."
        return
    }

    Row := TaskListView.Add("", TaskName, TaskDescription, TaskPriority, TaskDueDate)
    StatusBar.Text := "Task added: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDueDate
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
    Global TaskNameEdit, TaskDescriptionEdit, PriorityDropdown, DueDateEdit, TaskListView, StatusBar

    Row := TaskListView.GetNext()
    if (Row = 0) {
        StatusBar.Text := "Error: Please select a task to edit."
        return
    }

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    TaskPriority := PriorityDropdown.Text
    TaskDueDate := DueDateEdit.Value

    if (TaskName = "") {
        StatusBar.Text := "Error: Task Name cannot be empty."
        return
    }

    TaskListView.Modify(Row, "", TaskName, TaskDescription, TaskPriority, TaskDueDate)
    StatusBar.Text := "Task edited: " TaskName " - " TaskDescription " - " TaskPriority " - " TaskDueDate
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
    Global TaskListView, DefaultFileName, StatusBar

    SavePath := DefaultFileName ".csv"

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
            if (Fields.Length = 4) {
                Row := TaskListView.Add("", Fields[1], Fields[2], Fields[3], Fields[4])
            }
        }
    }
    File.Close()
    StatusBar.Text := "Tasks loaded from file: " FilePath
}

GuiClose(*) {
    ExitApp()
}
