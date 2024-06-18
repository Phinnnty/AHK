; --------------------------------------------------------------
; notes
; --------------------------------------------------------------
; This script is an attempt to emulate work management software for personal use. 
; When the script is run a GUI should pop up with a list of tasks the user has created. 
; This script should help users keep track of their tasks for work. 


Persistent

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

; Event Handlers
AddTaskButton.OnEvent("Click", AddTask)
ClearFieldsButton.OnEvent("Click", ClearFields)
TaskListView.OnEvent("ItemSelect", TaskSelected)
EditTaskButton.OnEvent("Click", EditTask)
DeleteTaskButton.OnEvent("Click", DeleteTask)

; Show GUI
Main.Show()

return

; Functions and Handlers
AddTask(*) {
    Global Main, TaskListView
    Main.Submit()
    TaskName := Main["TaskName"]
    TaskDescription := Main["TaskDescription"]
    if (TaskName = "") {
        MsgBox("Task Name cannot be empty.", "Error", 48)
        return
    }
    TaskListView.Add("", TaskName, TaskDescription)
    ClearFields()
}

ClearFields(*) {
    Global TaskNameEdit, TaskDescriptionEdit
    TaskNameEdit.Value := ""
    TaskDescriptionEdit.Value := ""
}

EditTask(*) {
    Global Main, TaskListView
    Row := TaskListView.GetNext()
    if (Row = 0) {
        MsgBox("Please select a task to edit.", "Error", 48)
        return
    }
    Main.Submit()
    TaskName := Main["TaskName"]
    TaskDescription := Main["TaskDescription"]
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

GuiClose(*) {
    ExitApp()
}
