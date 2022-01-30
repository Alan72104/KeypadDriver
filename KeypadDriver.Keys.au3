; ================================================================================
;
; KeypadDriver.Keys.au3
; Manages key mapping
;
; ================================================================================

; Todo: Better name for this module

#include-once
#include "KeypadDriver.Vars.au3"
#include "KeypadDriver.Gui.au3"

; [[keyStrokeUp, keyStrokeDown], ...]
Global $keys_keyMap[$WIDTH * $HEIGHT][$keyStrokeAmount]

Func SendKey($num, $state)
    ; Only send the key stroke when the gui isn't opened
    If $num <= $WIDTH * $HEIGHT And Not IsGuiOpened() And $keys_keyMap[$num - 1][$state] <> "" Then
        Send($keys_keyMap[$num - 1][$state])
    EndIf
EndFunc

Func KeyHasBinding($num, $state)
    Return GetKeybindingForKey($num, $state) <> "" ? True : False
Endfunc

Func GetKeybindingForKey($num, $state)
    If $num <= $WIDTH * $HEIGHT Then
        Return $keys_keyMap[$num - 1][$state]
    EndIf
EndFunc

; Removes both up and down strokes from a key
Func BindRemove($num)
    $keys_keyMap[$num - 1][$KEYSTROKEUP] = ""
    $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = ""
EndFunc

; Takes 2 arguments and binds a character to both keystrokes of a key,
; or takes 3 arguments and binds special keystrokes to a key
Func BindKey($num, $key, $extra = 0x0)
    If $num > $WIDTH * $HEIGHT Then Return
    Switch @NumParams
        Case 2
            $keys_keyMap[$num - 1][$KEYSTROKEUP] = "{" & $key & " up}"
            $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = "{" & $key & " down}"
        Case 3
            $keys_keyMap[$num - 1][$KEYSTROKEUP] = $key
            $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = $extra
    EndSwitch
EndFunc

Func ConfigLoad($path)
    For $i = 1 To $WIDTH * $HEIGHT
        BindKey($i, IniRead($path, "ButtonBindings", "Button" & $i & "Up", ""), IniRead($path, "ButtonBindings", "Button" & $i & "Down", ""))
    Next
EndFunc

Func ConfigSave($path)
    For $i = 1 To $WIDTH * $HEIGHT
        IniWrite($path, "ButtonBindings", "Button" & $i & "Up", GetKeybindingForKey($i, $KEYSTROKEUP))
        IniWrite($path, "ButtonBindings", "Button" & $i & "Down", GetKeybindingForKey($i, $KEYSTROKEDOWN))
    Next
EndFunc