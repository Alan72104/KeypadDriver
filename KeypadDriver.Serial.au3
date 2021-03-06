; ================================================================================
;
; KeypadDriver.Serial.au3
; Functions required to communicate with the keypad
;
; ================================================================================

#include-once
#include <MsgBoxConstants.au3>
#include "Include\CommMG.au3"
#include "Include\LibDebug.au3"
#include "KeypadDriver.Vars.au3"

Global $serial_keyDataNum, $serial_keyDataState, $serial_keyDataReceived = False

Global $serial_byteString = "", $serial_byte, $serial_byteReceived = False

Global $serial_comPort

; Tries to connect to the keypad serial port
Func Connect()
    Local $ports[0]
    $ports = _ComGetPortNames()
    For $i = 0 To UBound($ports) - 1
        If $ports[$i][1] == "USB-SERIAL CH340" Then
            Local $errorStr = ""
            $serial_comPort = $ports[$i][0]
            _CommSetPort(Int(StringReplace($serial_comPort, "COM", "")), $errorStr, 19200, 8, "none", 1, 2)
            
            If Not @error Then
                ; Connection completed
                $connectionStatus = $CONNECTED
                _CommSetRTS(0)
                _CommSetDTR(0)
            Else
                ; Connection failed
                $connectionStatus = $CONNECTIONFAILED
                c("Connection failed, error: $", 1, $errorStr)
            EndIf
            
            Return
        EndIf
    Next
    
    ; If it reaches this line that means no port was detected
    $connectionStatus = $PORTDETECTIONFAILED
EndFunc

; Checks for connection drop and try to reconnect
Func EnsureConnection()
    Local Static $retryTimer = 0

    ; Because retrieving the port list takes a while???, so don't reconnect too often
    If $connectionStatus <> $CONNECTED And TimerDiff($retryTimer) > 4000 Then
        $retryTimer = TimerInit()
        Connect()
    EndIf
EndFunc

; Polls the serial for new key datas
Func PollKeys()
    If $connectionStatus <> $CONNECTED Then Return
    
    ; Don't continue if there's still unprocessed key data in the buffer
    If $serial_keyDataReceived Then Return
    
    $serial_byteString = _CommReadByte()
    If @error = 3 Then
        $connectionStatus = $CONNECTIONFAILED
        Return
    EndIf
    If $serial_byteString <> "" Then
        $serial_byte = Int($serial_byteString)
        
        ; Key status byte - |first 4 bits for key number, 3 zero padding bits, last one bit for pressed state|
        $serial_keyDataNum = BitShift($serial_byte, 4)
        $serial_keyDataState = BitAND($serial_byte, 0x01)

        $serial_keyDataReceived = True
    EndIf
EndFunc

; Polls the serial for a byte
Func PollData()
    If $connectionStatus <> $CONNECTED Then Return
    
    ; Don't continue if there's still unprocessed byte in the buffer
    If $serial_byteReceived Then Return
    
    $serial_byteString = _CommReadByte()
    If @error = 3 Then
        $connectionStatus = $CONNECTIONFAILED
        Return
    EndIf
    If $serial_byteString <> "" Then
        $serial_byte = Int($serial_byteString)
        ; c("Received data $", 1, $serial_byteString)
        $serial_byteReceived = True
        Return
    EndIf
EndFunc

; Sends a message to the keypad
Func SendMsgToKeypad($type, $data)
    If $connectionStatus <> $CONNECTED Then Return
    
    ; Message - |1 byte for msg type, 1 byte for msg data|
    If $type > 0xFF Then
        Throw("SendMsgToKeypad", "Message type cannot be larger than 1 byte! Type: " & $type, "Message not sent!")
        Return
    EndIf
    If $data > 0xFF Then
        Throw("SendMsgToKeypad", "Data to send cannot be larger than 1 byte! Data: " & $data, "Message not sent!")
        Return
    EndIf

    _CommSendByte($type)
    _CommSendByte($data)
EndFunc

Func GetComPort()
    Return $serial_comPort
EndFunc

Func GetKeyDataNum()
    Return $serial_keyDataNum
EndFunc

Func GetKeyDataState()
    Return $serial_keyDataState
EndFunc

Func IsKeyDataReceived()
    Return $serial_keyDataReceived
EndFunc

Func KeyDataProcessed()
    $serial_keyDataReceived = False
EndFunc

Func GetByte()
    Return $serial_byte
EndFunc

Func IsByteReceived()
    Return $serial_byteReceived
EndFunc

Func ByteProcessed()
    $serial_byteReceived = False
EndFunc