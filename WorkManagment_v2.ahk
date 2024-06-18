Persistent
#SingleInstance Force

; Initialize Main GUI
Main := Gui("+Resize", "Work Management")

; Define Controls
Main.Add("Text", "x10 y10 w120", "Task Name:")
TaskNameEdit := Main.Add("Edit", "x140 y10 w200 vTaskName")

Main.Add("Text", "x10 y40 w120", "Task Description:")
TaskDescriptionEdit := Main.Add("Edit", "x140 y40 w200 vTaskDescription")

AddTaskButton := Main.Add("Button", "x10 y70 w100", "Add Task")
ClearFieldsButton := Main.Add("Button", "x120 y70 w100", "Clear")

TaskListView := Main.Add("ListView", "r10 w350", ["Task Name", "Task Description"])
EditTaskButton := Main.Add("Button", "x10 y250 w100", "Edit Task")
DeleteTaskButton := Main.Add("Button", "x120 y250 w100", "Delete Task")

SaveButton := Main.Add("Button", "x230 y250 w100", "Save Tasks")
LoadButton := Main.Add("Button", "x340 y250 w100", "Load Tasks")

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

return

; Functions and Handlers
AddTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, TaskListView

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value
    
    ; Debug information
    MsgBox("Debug: TaskName = " TaskName "`nTaskDescription = " TaskDescription)
    
    if (TaskName = "") {
        MsgBox("Task Name cannot be empty.", "Error", 48)
        return
    }
    
    TaskListView.Add("", TaskName, TaskDescription)
    MsgBox("Task added: " TaskName " - " TaskDescription)
    ClearFields()
}

ClearFields(*) {
    Global TaskNameEdit, TaskDescriptionEdit
    TaskNameEdit.Value := ""
    TaskDescriptionEdit.Value := ""
}

EditTask(*) {
    Global TaskNameEdit, TaskDescriptionEdit, TaskListView

    Row := TaskListView.GetNext()
    if (Row = 0) {
        MsgBox("Please select a task to edit.", "Error", 48)
        return
    }

    TaskName := TaskNameEdit.Value
    TaskDescription := TaskDescriptionEdit.Value

    TaskListView.Modify(Row, "", TaskName, TaskDescription)
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
    Global TaskListView, TaskNameEdit, TaskDescriptionEdit

    Row := TaskListView.GetNext()
    if (Row > 0) {
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        TaskNameEdit.Value := TaskName
        TaskDescriptionEdit.Value := TaskDescription
    }
}

SaveTasks(*) {
    Global TaskListView

    SavePath := FileSelect("Save", "CSV Files (*.csv)", "", "Save Tasks As")
    if (!SavePath) {
        return
    }
    File := FileOpen(SavePath, "w")
    Loop (TaskListView.GetCount()) {
        Row := A_Index
        TaskName := TaskListView.GetText(Row, 1)
        TaskDescription := TaskListView.GetText(Row, 2)
        File.WriteLine(TaskName "," TaskDescription)
    }
    File.Close()
    MsgBox("Tasks saved successfully.", "Info", 64)
}

LoadTasks(*) {
    Global TaskListView

    LoadPath := FileSelect("Open", "CSV Files (*.csv)", "", "Load Tasks")
    if (!LoadPath) {
        return
    }
    File := FileOpen(LoadPath, "r")
    TaskListView.Delete()
    while (!File.AtEOF) {
        Line := File.ReadLine()
        if (Line) {
            Fields := StrSplit(Line, ",")
            TaskListView.Add("", Fields[1], Fields[2])
        }
    }
    File.Close()
    MsgBox("Tasks loaded successfully.", "Info", 64)
}

GuiClose(*) {
    ExitApp()
}
