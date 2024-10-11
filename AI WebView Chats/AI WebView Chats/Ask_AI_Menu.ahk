#Requires AutoHotkey v2.0+
#SingleInstance Force

Persistent()
SetWorkingDir(A_ScriptDir)    

;; GLOBAL VARIABLES ;;

    global clipboardMenuItemName := "ClipboardContentItem"
    global clipboardContent := ""
    
;; HOTKEY CTRL + ALT + A ;;    
    ^!A::ShowMenu()

;; MENU GENERATION & DYNAMIC CLIPBOARD ITEM ;;    
    ShowMenu() {
        global Ask_AI
        clipboardContent := CopyToClipboard()
        global Search_text := clipboardContent
    
        
        if (StrLen(clipboardContent) == 0) {
            RenameClipboardMenuItem("`t Clipboard is empty")
        } else {
            truncatedText := StrLen(clipboardContent) > 50 ? SubStr(clipboardContent, 1, 50) . "..." : clipboardContent
            RenameClipboardMenuItem("Clipboard: `t" . truncatedText)
        }
    
        Ask_AI.Show()
    }
    
; Create the main menu
    Ask_AI := Menu()

; Add GPT and Claude submenus to the main menu
    Ask_AI.Add("ClipboardContentItem", (*) => {}), Ask_AI.SetIcon("ClipboardContentItem", "Icons\Clipboard.png", 1)
    Ask_AI.Add("Ask ChatGPT", CreateGPTMenu()), Ask_AI.SetIcon("Ask ChatGPT", "Icons\GPT.png", 1)
    Ask_AI.Add("Ask Claude 3.5", CreateCluadeMenu()), Ask_AI.SetIcon("Ask Claude 3.5", "Icons\Claude-3.5.png", 1)

;; ---------- ASK GPT MENU  ---------- 

CreateGPTMenu() {
    GptSubmenu := Menu()
    GptSubmenu.Add("Fix Spelling and Grammar", (*) => OpenChatGPTWithQuery("Correct any spelling and grammatical errors in the following text. Ensure proper punctuation and sentence structure."))
    GptSubmenu.Add("Improve Clarity", (*) => OpenChatGPTWithQuery("Rewrite the following text to improve clarity and readability. Maintain the original meaning and highlight changes made."))
    GptSubmenu.Add("Explain Topic", (*) => OpenChatGPTWithQuery("Provide a detailed explanation of the following text, breaking it down for easier understanding."))
    GptSubmenu.Add()
    GptSubmenu.Add("Generate Image", (*) => OpenChatGPTWithQuery("Generate an image based on this prompt:"))
    GptSubmenu.Add("Debug Code", (*) => OpenChatGPTWithQuery("Debug the following code. Identify errors or issues and suggest corrections or improvements."))
    GptSubmenu.Add("Explain Code", (*) => OpenChatGPTWithQuery("Explain the following code. Identify its purpose, usage, and suggest improvements."))
    GptSubmenu.Add()
    GptSubmenu.Add("Condense Text", (*) => OpenChatGPTWithQuery("Condense the following text, preserving key points while reducing length."))
    GptSubmenu.Add("Expand Text", (*) => OpenChatGPTWithQuery("Expand on the following text, adding more details, examples, or explanations."))
    GptSubmenu.Add()
    GptSubmenu.Add("Identify Action Items", (*) => OpenChatGPTWithQuery("Identify and list any specific actions, tasks, or next steps mentioned or implied in the following text."))
    GptSubmenu.Add("Summarize Text", (*) => OpenChatGPTWithQuery("Provide a concise summary of the main points and key ideas from the following text."))
    GptSubmenu.Add()
    GptSubmenu.Add("Strengthen Argument", (*) => OpenChatGPTWithQuery("Strengthen the given argument with additional evidence or reasoning. Present opposing views for a comprehensive analysis."))
    GptSubmenu.Add("Polish Language", (*) => OpenChatGPTWithQuery("Review the following text for spelling, punctuation, and grammatical errors. Improve overall coherence and enhance sentence structure."))
    GptSubmenu.Add("Enhance Content", (*) => OpenChatGPTWithQuery("Enhance the following content by emphasizing crucial information. Verify accuracy using reliable sources and include supporting references."))
    GptSubmenu.Add("Optimize Length", (*) => OpenChatGPTWithQuery("Optimize the length of the following text. Adjust for brevity or expand with relevant details as needed."))
    GptSubmenu.Add("Refine Structure", (*) => OpenChatGPTWithQuery("Improve the structure of the following content. Enhance design elements and ensure logical flow with smooth transitions."))
    GptSubmenu.Add("Adjust Tone", (*) => OpenChatGPTWithQuery("Adjust the tone of the following text to be formal, casual, business-appropriate, etc. Modify to reflect specific company personality or values."))
    GptSubmenu.Add("Enhance Style", (*) => OpenChatGPTWithQuery("Enhance the style of the following text. Use active voice, improve clarity, and vary sentence length to improve rhythm and flow."))
    return GptSubmenu
}
;; ---------- ASK CLAUDE MENU  ----------
CreateCluadeMenu() {
    ClaudeSubmenu := Menu()
    ClaudeSubmenu.Add("Explain Code", (*) => OpenChatClaudeWithQuery("Explain the following code, breaking it down for easier understanding."))
    ClaudeSubmenu.Add("Generate Code", (*) => OpenChatClaudeWithQuery("Generate code based on this prompt. Add comments to explain functionality and provide suggestions at the end."))
    ClaudeSubmenu.Add("Debug Code", (*) => OpenChatClaudeWithQuery("Debug the following code. Identify errors or issues and suggest corrections or improvements."))
    return ClaudeSubmenu
}


GenerateChatGPTURL(prompt) {
    global Search_text
    url := "https://chat.openai.com/chat?q=" . Prompt . '>' . Search_text
    return url
}

; Creates a new tab on ChatGPT and sends your query
OpenChatGPTWithQuery(prompt) {
    global Search_text
    url := GenerateChatGPTURL(prompt)
    A_Clipboard := prompt . ' > ' . Search_text
    

    Run(A_ScriptDir . "\WV_OpenChatGPT.ahk `"" . url . "`"")
    Sleep(3000)
    Send("{Tab}" . '^v' . "{Enter}")
}

OpenChatClaudeWithQuery(prompt) {
    global Search_text
    url := "https://claude.ai/new"
    A_Clipboard := prompt . ' > ' . Search_text
    
    Run(A_ScriptDir . "\WV_OpenClaude.ahk `"" . url . "`"")
    Sleep(3000)
    Send("^v{Enter}")
}

;; ---- Functions to get dynamic updates to menu ----- ;; 

GetWindowTitle() {
    return WinGetTitle("A")
}

GetWindowPID() {
    return WinGetPID("A")
}

; Standardized function to copy text to clipboard
CopyToClipboard() {
    savedClipboard := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if (!ClipWait(2)) {
        A_Clipboard := savedClipboard
        return ""
    }
    clipText := A_Clipboard
    A_Clipboard := savedClipboard
    return clipText
}


; Function to rename the clipboard content menu item
RenameClipboardMenuItem(newTitle) {
    global clipboardMenuItemName
    Ask_AI.Rename(clipboardMenuItemName, newTitle)
    clipboardMenuItemName := newTitle
}

;; ---------- SET DARK MODE ----------

SetPreferredAppMode()
; Build the menu, then call FlushMenuThemes
FlushMenuThemes()

AppsUseLightTheme() {
    keyName := "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    valueName := "AppsUseLightTheme"
    return RegRead(keyName, valueName)
}

SetPreferredAppMode(option := "") {
    static options := Map()
    if (!options.Count) {
        options.CaseSense := false
        options.Set(
            "Default", 0,
            "AllowDark", 1,
            "ForceDark", 2,
            "ForceLight", 3,
            "Max", 4
        )
        options.Default := !AppsUseLightTheme()
    }
    hModule := DllCall("kernel32.dll\GetModuleHandle", "str", "uxtheme.dll", "ptr")
    ; These are undocumented functions. They must be called via ordinal.
    localSetPreferredAppMode := DllCall("kernel32.dll\GetProcAddress", "ptr", hModule, "ptr", 135, "ptr")
    DllCall(localSetPreferredAppMode, "int", options.Get(option))
    DllCall("kernel32.dll\FreeLibrary", "ptr", hModule)
}       

FlushMenuThemes() {
    hModule := DllCall("kernel32.dll\GetModuleHandle", "str", "uxtheme.dll", "ptr")
    ; Undocumented functions must be called via ordinal.
    localFlushMenuThemes := DllCall("kernel32.dll\GetProcAddress", "ptr", hModule, "ptr", 136, "ptr")
    DllCall(localFlushMenuThemes)
    DllCall("kernel32.dll\FreeLibrary", "ptr", hModule)
}

ShowMenu()