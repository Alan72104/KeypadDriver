#include <File.au3>

Global Const $DOTNET_PATHS_INDEX = 0, $DOTNET_REGASM_OK = 0
Global Enum $DOTNET_LOADDLL, $DOTNET_UNLOADDLL, $DOTNET_UNLOADDLLALL ; Enumeration used for the _DotNet_* functions.
Global Enum $DOTNET_PATHS_FILEPATH, $DOTNET_PATHS_GUID, $DOTNET_PATHS_MAX ; Enumeration used for the internal filepath array.

; #FUNCTION# ====================================================================================================================
; Name ..........: _DotNet_Load
; Description ...: Load a .NET compiled dll assembly.
; Syntax ........: _DotNet_Load($sDllPath)
; Parameters ....: $sDllPath            - A .NET compiled dll assembly located in the @ScriptDir directory.
;                  $bAddAsCurrentUser   - [optional] True or false to add to the current user (supresses UAC). Default is False, all users.
; Return values .: Success: True
;                  Failure: False and sets @error to non-zero:
;                  		1 = Incorrect filetype aka not a dll.
;                  		2 = Dll does not exist in the @ScriptDir location.
;                  		3 = .NET RegAsm.exe file not found.
;                  		4 = Dll already registered.
;                  		5 = Unable to retrieve the GUID for registering as a current user.
; Author ........: guinness
; Remarks .......: With ideas by funkey for running under the current user.
; Example .......: Yes
; ===============================================================================================================================
Func _DotNet_Load($sDllPath, $bAddAsCurrentUser = Default)
	If $bAddAsCurrentUser = Default Then $bAddAsCurrentUser = False
	Local $bReturn = __DotNet_Wrapper($sDllPath, $DOTNET_LOADDLL, $bAddAsCurrentUser)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_DotNet_Load

; #FUNCTION# ====================================================================================================================
; Name ..........: _DotNet_Unload
; Description ...: Unload a previously registered .NET compiled dll assembly.
; Syntax ........: _DotNet_Unload($sDllPath)
; Parameters ....: $sDllPath            - A .NET compiled dll assembly located in the @ScriptDir directory.
; Return values .: Success: True
;                  Failure: False and sets @error to non-zero:
;                  		1 = Incorrect filetype aka not a dll.
;                  		2 = Dll does not exist in the @ScriptDir location.
;                  		3 = .NET RegAsm.exe file not found.
; Author ........: guinness
; Remarks .......: With ideas by funkey for running under the current user.
; Example .......: Yes
; ===============================================================================================================================
Func _DotNet_Unload($sDllPath)
	Local $bReturn = __DotNet_Wrapper($sDllPath, $DOTNET_UNLOADDLL, Default)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_DotNet_Unload

; #FUNCTION# ====================================================================================================================
; Name ..........: _DotNet_UnloadAll
; Description ...: Unload all previously registered .NET compiled dll assemblies.
; Syntax ........: _DotNet_UnloadAll()
; Parameters ....: None
; Return values .: Success: True
;                  Failure: False and sets @error to non-zero:
;                  		1 = Incorrect filetype aka not a dll.
;                  		2 = Dll does not exist in the @ScriptDir location.
;                  		3 = .NET RegAsm.exe file not found.
;                  		4 = Dll already registered.
;                  		5 = Unable to retrieve the GUID for registering as a current user.
; Author ........: guinness
; Remarks .......: With ideas by funkey for running under the current user.
; Example .......: Yes
; ===============================================================================================================================
Func _DotNet_UnloadAll()
	Local $bReturn = __DotNet_Wrapper(Null, $DOTNET_UNLOADDLLALL, Default)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_DotNet_UnloadAll

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __DotNet_Wrapper
; Description ...: A wrapper for the _DotNet_* functions.
; Syntax ........: __DotNet_Wrapper($sDllPath, $iType)
; Parameters ....: $sDllPath            - A .NET compiled dll assembly located in the @ScriptDir directory.
;                  $iType               - A $DOTNET_* constant.
; Return values .: Success: True
;                  Failure: False and sets @error to non-zero:
;                  		1 = Incorrect filetype aka not a dll.
;                  		2 = Dll does not exist in the @ScriptDir location.
;                  		3 = .NET RegAsm.exe file not found.
;                  		4 = Dll already registered.
;                  		5 = Unable to retrieve the GUID for registering as current user.
; Author ........: guinness
; Remarks .......: ### DO NOT INVOKE, AS THIS IS A WRAPPER FOR THE ABOVE FUNCTIONS. ###
; Remarks .......: With ideas by funkey for running under the current user.
; Related .......: Thanks to Bugfix for the initial idea: http://www.autoitscript.com/forum/topic/129164-create-a-net-class-and-run-it-as-object-from-your-autoit-script/?p=938459
; Example .......: Yes
; ===============================================================================================================================
Func __DotNet_Wrapper($sDllPath, $iType, $bAddAsCurrentUser)
	Local Static $aDllPaths[Ceiling($DOTNET_PATHS_MAX * 1.3)][$DOTNET_PATHS_MAX] = [[0, 0]], _
			$sRegAsmPath = Null

	If Not ($iType = $DOTNET_UNLOADDLLALL) Then
		If Not (StringRight($sDllPath, StringLen('dll')) == 'dll') Then ; Check the correct filetype was passed.
			Return SetError(1, 0, False) ; Incorrect filetype.
		EndIf

		If Not FileExists($sDllPath) Then ; Check the filepath exists in @ScriptDir.
			Return SetError(2, 0, False) ; Filepath does not exist.
		EndIf
	EndIf

	If $sRegAsmPath == Null Then
		$sRegAsmPath = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework', 'InstallRoot')
		If @error Then
			$sRegAsmPath = '' ; Set to an empty string to acknowledge that searching for the path happened.
		Else
			Local $aFilePaths = _FileListToArray($sRegAsmPath, '*', $FLTA_FOLDERS), _
					$sNETFolder = ''
			If Not @error Then
				For $i = UBound($aFilePaths) - 1 To 1 Step -1
					If StringRegExp($aFilePaths[$i], '(?:[vV]4\.0\.\d+)') Then
						$sNETFolder = $aFilePaths[$i]
						ExitLoop
					ElseIf StringRegExp($aFilePaths[$i], '(?:[vV]2\.0\.\d+)') Then
						$sNETFolder = $aFilePaths[$i]
						ExitLoop
					EndIf
				Next
			EndIf
			$sRegAsmPath &= $sNETFolder & '\RegAsm.exe'
			If FileExists($sRegAsmPath) Then
				;~ OnAutoItExitRegister(_DotNet_UnloadAll) ; Register when the AutoIt executable is closed.
			Else
				$sRegAsmPath = '' ; Set to an empty string to acknowledge that searching for the path happened.
			EndIf
		EndIf
	EndIf

	If $sRegAsmPath == '' Then
		Return SetError(3, 0, False) ; .NET Framework 2.0 or 4.0 required.
	EndIf

	Switch $iType
		Case $DOTNET_LOADDLL
			Local $iIndex = -1
			For $i = $DOTNET_PATHS_MAX To $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH]
				If $sDllPath = $aDllPaths[$i][$DOTNET_PATHS_FILEPATH] Then
					Return SetError(4, 0, False) ; Dll already registered.
				EndIf
				If $iIndex = -1 And $aDllPaths[$i][$DOTNET_PATHS_FILEPATH] == '' Then
					$iIndex = $i
					ExitLoop
				EndIf
			Next

			If $iIndex = -1 Then
				$aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] += 1
				$iIndex = $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH]
			EndIf

			Local Const $iUBound = UBound($aDllPaths)
			If $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] >= $iUBound Then
				ReDim $aDllPaths[Ceiling($iUBound * 1.3)][$DOTNET_PATHS_MAX]
			EndIf
			$aDllPaths[$iIndex][$DOTNET_PATHS_FILEPATH] = $sDllPath
			$aDllPaths[$iIndex][$DOTNET_PATHS_GUID] = Null

			If $bAddAsCurrentUser Then ; Idea by funkey, with modification by guinness.
				Local $sTempDllPath = @TempDir & '\' & $sDllPath & '.reg'
				If Not (RunWait($sRegAsmPath & ' /s /codebase ' & $sDllPath & ' /regfile:"' & $sTempDllPath & '"', @ScriptDir, @SW_HIDE) = $DOTNET_REGASM_OK) Then
					Return SetError(5, 0, False) ; Unable to retrieve the GUID for registering as current user.
				EndIf

				Local Const $hFileOpen = FileOpen($sTempDllPath, BitOR($FO_READ, $FO_APPEND))
				If $hFileOpen > -1 Then
					FileSetPos($hFileOpen, 0, $FILE_BEGIN)
					Local $sData = FileRead($hFileOpen)
					If @error Then
						$aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] -= 1 ; Decrease the index due to failure.
						Return SetError(5, 0, False) ; Unable to retrieve the GUID for registering as current user.
					EndIf

					$sData = StringReplace($sData, 'HKEY_CLASSES_ROOT', 'HKEY_CURRENT_USER\Software\Classes')
					FileSetPos($hFileOpen, 0, $FILE_BEGIN)
					If Not FileWrite($hFileOpen, $sData) Then
						$aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] -= 1 ; Decrease the index due to failure.
						Return SetError(5, 0, False) ; Unable to retrieve the GUID for registering as current user.
					EndIf
					FileClose($hFileOpen)

					Local $aSRE = StringRegExp($sData, '(?:\R@="{([[:xdigit:]\-]{36})}"\R)', $STR_REGEXPARRAYGLOBALMATCH)
					If @error Then
						$aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] -= 1 ; Decrease the index due to failure.
						Return SetError(5, 0, False) ; Unable to retrieve the GUID for registering as current user.
					EndIf
					$aDllPaths[$iIndex][$DOTNET_PATHS_GUID] = $aSRE[0] ; GUID of the registry key.

					RunWait('reg import "' & $sTempDllPath & '"', @ScriptDir, @SW_HIDE) ; Import to current users' classes
					FileDelete($sTempDllPath)
				EndIf
			Else
				Return RunWait($sRegAsmPath & ' /codebase ' & $sDllPath, @ScriptDir, @SW_HIDE) = $DOTNET_REGASM_OK ; Register the .NET Dll.
			EndIf

		Case $DOTNET_UNLOADDLL
			For $i = $DOTNET_PATHS_MAX To $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH]
				If $sDllPath = $aDllPaths[$i][$DOTNET_PATHS_FILEPATH] And Not ($aDllPaths[$i][$DOTNET_PATHS_FILEPATH] == Null) Then
					Return __DotNet_Unregister($sRegAsmPath, $aDllPaths[$i][$DOTNET_PATHS_FILEPATH], $aDllPaths[$iIndex][$DOTNET_PATHS_GUID])
				EndIf
			Next

		Case $DOTNET_UNLOADDLLALL
			Local $iCount = 0
			If $sDllPath == Null And $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] > 0 Then
				For $i = $DOTNET_PATHS_MAX To $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH]
					If Not ($aDllPaths[$i][$DOTNET_PATHS_FILEPATH] == Null) Then
						$iCount += (__DotNet_Unregister($sRegAsmPath, $aDllPaths[$i][$DOTNET_PATHS_FILEPATH], $aDllPaths[$iIndex][$DOTNET_PATHS_GUID]) ? 1 : 0)
					EndIf
				Next
				$aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH] = 0 ; Reset the count.
				Return $iCount == $aDllPaths[$DOTNET_PATHS_INDEX][$DOTNET_PATHS_FILEPATH]
			EndIf
	EndSwitch

	Return True
EndFunc   ;==>__DotNet_Wrapper

Func __DotNet_Unregister($sRegAsmPath, ByRef $sDllPath, ByRef $sGUID)
	Local $bReturn = RunWait($sRegAsmPath & ' /unregister ' & $sDllPath, @ScriptDir, @SW_HIDE) = $DOTNET_REGASM_OK ; Unregister the .NET Dll.
	If $bReturn Then
		If Not ($sGUID == Null) Then
			RegDelete('HKEY_CURRENT_USER\Software\Classes\CLSID\' & $sGUID) ; 32-bit path.
			RegDelete('HKEY_CLASSES_ROOT\Wow6432Node\CLSID\' & $sGUID) ; 64-bit path.
			$sGUID = Null ; Remove item.
		EndIf
		$sDllPath = Null ; Remove item.
	EndIf
	Return $bReturn
EndFunc   ;==>__DotNet_Unregister
