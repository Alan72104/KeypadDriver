#include-once

Global $__Discord_hDll = 0
Global $__Discord_atEventInterfaces[$__DISCORD_CLASSCOUNT]  ; Event tables (Callback function ptr tables)
Global $__Discord_atMethodInterfaces[$__DISCORD_CLASSCOUNT] ; Method tables
Global $__Discord_apMethodPtrs[$__DISCORD_CLASSCOUNT]       ; Method table pointers
Global $__Discord_hLogHookCallback = 0
Global $__Discord_fnLogHookCallbackHandler = 0

Global $__Discord_ActivityManager_ahCallbacks[4]
Global $__Discord_ActivityManager_afnCallbackHandlers[4]
Global $__Discord_ActivityManager_hUpdateActivityCallback = 0
Global $__Discord_ActivityManager_fnUpdateActivityCallbackHandler = 0
Global $__Discord_ActivityManager_hClearActivityCallback = 0
Global $__Discord_ActivityManager_fnClearActivityCallbackHandler = 0
Global $__Discord_ActivityManager_hSendRequestReplyCallback = 0
Global $__Discord_ActivityManager_fnSendRequestReplyCallbackHandler = 0
Global $__Discord_ActivityManager_hSendInviteCallback = 0
Global $__Discord_ActivityManager_fnSendInviteCallbackHandler = 0
Global $__Discord_ActivityManager_hAcceptInviteCallback = 0
Global $__Discord_ActivityManager_fnAcceptInviteCallbackHandler = 0

Global $__Discord_ApplicationManager_hValidateOrExitCallback = 0
Global $__Discord_ApplicationManager_fnValidateOrExitCallbackHandler = 0
Global $__Discord_ApplicationManager_hGetOAuth2TokenCallback = 0
Global $__Discord_ApplicationManager_fnGetOAuth2TokenCallbackHandler = 0
Global $__Discord_ApplicationManager_hGetTicketCallback = 0
Global $__Discord_ApplicationManager_fnGetTicketCallbackHandler = 0

Global $__Discord_UserManager_ahCallbacks[1]
Global $__Discord_UserManager_afnCallbackHandlers[1]
Global $__Discord_UserManager_hGetUserCallback = 0
Global $__Discord_UserManager_fnGetUserCallbackHandler = 0