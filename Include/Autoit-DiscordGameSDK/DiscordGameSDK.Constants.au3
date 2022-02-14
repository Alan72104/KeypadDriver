#include-once

; #CONSTANTS# ===================================================================================================================
Global Enum $DISCORD_RESULT_OK = 0, _
            $DISCORD_OK = $DISCORD_RESULT_OK, _
            $DISCORD_RESULT_SERVICEUNAVAILABLE = 1, _
            $DISCORD_RESULT_INVALIDVERSION = 2, _
            $DISCORD_RESULT_LOCKFAILED = 3, _
            $DISCORD_RESULT_INTERNALERROR = 4, _
            $DISCORD_RESULT_INVALIDPAYLOAD = 5, _
            $DISCORD_RESULT_INVALIDCOMMAND = 6, _
            $DISCORD_RESULT_INVALIDPERMISSIONS = 7, _
            $DISCORD_RESULT_NOTFETCHED = 8, _
            $DISCORD_RESULT_NOTFOUND = 9, _
            $DISCORD_RESULT_CONFLICT = 10, _
            $DISCORD_RESULT_INVALIDSECRET = 11, _
            $DISCORD_RESULT_INVALIDJOINSECRET = 12, _
            $DISCORD_RESULT_NOELIGIBLEACTIVITY = 13, _
            $DISCORD_RESULT_INVALIDINVITE = 14, _
            $DISCORD_RESULT_NOTAUTHENTICATED = 15, _
            $DISCORD_RESULT_INVALIDACCESSTOKEN = 16, _
            $DISCORD_RESULT_APPLICATIONMISMATCH = 17, _
            $DISCORD_RESULT_INVALIDDATAURL = 18, _
            $DISCORD_RESULT_INVALIDBASE64 = 19, _
            $DISCORD_RESULT_NOTFILTERED = 20, _
            $DISCORD_RESULT_LOBBYFULL = 21, _
            $DISCORD_RESULT_INVALIDLOBBYSECRET = 22, _
            $DISCORD_RESULT_INVALIDFILENAME = 23, _
            $DISCORD_RESULT_INVALIDFILESIZE = 24, _
            $DISCORD_RESULT_INVALIDENTITLEMENT = 25, _
            $DISCORD_RESULT_NOTINSTALLED = 26, _
            $DISCORD_RESULT_NOTRUNNING = 27, _
            $DISCORD_RESULT_INSUFFICIENTBUFFER = 28, _
            $DISCORD_RESULT_PURCHASECANCELED = 29, _
            $DISCORD_RESULT_INVALIDGUILD = 30, _
            $DISCORD_RESULT_INVALIDEVENT = 31, _
            $DISCORD_RESULT_INVALIDCHANNEL = 32, _
            $DISCORD_RESULT_INVALIDORIGIN = 33, _
            $DISCORD_RESULT_RATELIMITED = 34, _
            $DISCORD_RESULT_OAUTH2ERROR = 35, _
            $DISCORD_RESULT_SELECTCHANNELTIMEOUT = 36, _
            $DISCORD_RESULT_GETGUILDTIMEOUT = 37, _
            $DISCORD_RESULT_SELECTVOICEFORCEREQUIRED = 38, _
            $DISCORD_RESULT_CAPTURESHORTCUTALREADYLISTENING = 39, _
            $DISCORD_RESULT_UNAUTHORIZEDFORACHIEVEMENT = 40, _
            $DISCORD_RESULT_INVALIDGIFTCODE = 41, _
            $DISCORD_RESULT_PURCHASEERROR = 42, _
            $DISCORD_RESULT_TRANSACTIONABORTED = 43
Global Enum $DISCORD_LOGLEVEL_ERROR = 1, _
            $DISCORD_LOGLEVEL_WARN, _
            $DISCORD_LOGLEVEL_INFO, _
            $DISCORD_LOGLEVEL_DEBUG
Global Enum $DISCORD_CREATEFLAGS_DEFAULT = 0, _
            $DISCORD_CREATEFLAGS_NOREQUIREDISCORD
Global Enum $DISCORD_PREMIUMTYPE_NONE = 0, _
            $DISCORD_PREMIUMTYPE_TIER1, _
            $DISCORD_PREMIUMTYPE_TIER2
Global Enum $DISCORD_IMAGETYPE_USER = 0
Global Enum $DISCORD_ACTIVITYTYPE_PLAYING = 0, _
            $DISCORD_ACTIVITYTYPE_STREAMING, _
            $DISCORD_ACTIVITYTYPE_LISTENING, _
            $DISCORD_ACTIVITYTYPE_WATCHING
Global Enum $DISCORD_ACTIVITYACTIONTYPE_JOIN = 1, _
            $DISCORD_ACTIVITYACTIONTYPE_SPECTATE
Global Enum $DISCORD_ACTIVITYJOINREQUESTREPLY_NO = 0, _
            $DISCORD_ACTIVITYJOINREQUESTREPLY_YES, _
            $DISCORD_ACTIVITYJOINREQUESTREPLY_IGNORE
Global Enum $DISCORD_USERFLAG_PARTNER = 2, _
            $DISCORD_USERFLAG_HYPESQUADEVENTS = 4, _
            $DISCORD_USERFLAG_HYPESQUADHOUSE1 = 64, _
            $DISCORD_USERFLAG_HYPESQUADHOUSE2 = 128, _
            $DISCORD_USERFLAG_HYPESQUADHOUSE3 = 256
; ===============================================================================================================================
; #INTERNAL CONSTANTS# ==========================================================================================================
Global Const $__DISCORD_tagFFICREATEPARAMS = "struct;" & _
                                             "int64 ClientId;" & _
                                             "uint64 Flags;" & _
                                             "ptr Events;" & _
                                             "ptr EventData;" & _
                                             "ptr ApplicationEvents;" & _
                                             "uint ApplicationVersion;" & _
                                             "ptr UserEvents;" & _
                                             "uint UserVersion;" & _
                                             "ptr ImageEvents;" & _
                                             "uint ImageVersion;" & _
                                             "ptr ActivityEvents;" & _
                                             "uint ActivityVersion;" & _
                                             "ptr RelationshipEvents;" & _
                                             "uint RelationshipVersion;" & _
                                             "ptr LobbyEvents;" & _
                                             "uint LobbyVersion;" & _
                                             "ptr NetworkEvents;" & _
                                             "uint NetworkVersion;" & _
                                             "ptr OverlayEvents;" & _
                                             "uint OverlayVersion;" & _
                                             "ptr StorageEvents;" & _
                                             "uint StorageVersion;" & _
                                             "ptr StoreEvents;" & _
                                             "uint StoreVersion;" & _
                                             "ptr VoiceEvents;" & _
                                             "uint VoiceVersion;" & _
                                             "ptr AchievementEvents;" & _
                                             "uint AchievementVersion;" & _
                                             "endstruct;"
Global Const $__DISCORD_tagUSER = "struct;" & _
                                  "int64 Id;" & _
                                  "char Username[256];" & _
                                  "char Discriminator[8];" & _
                                  "char Avatar[128];" & _
                                  "boolean Bot;" & _
                                  "endstruct;"
Global Const $__DISCORD_tagOAUTH2TOKEN = "struct;" & _
                                         "char AccessToken[128];" & _
                                         "char Scopes[1024];" & _
                                         "int64 Expires;" & _
                                         "endstruct;"
Global Const $__DISCORD_tagIMAGEHANDLE = "struct;" & _
                                         "int Type;" & _
                                         "int64 Id;" & _
                                         "uint Size;" & _
                                         "endstruct;"
Global Const $__DISCORD_tagIMAGEDIMENSIONS = "struct;" & _
                                             "uint Width;" & _
                                             "uint Height;" & _
                                             "endstruct;"
Global Const $__DISCORD_tagACTIVITY = "struct;" & _
                                      "int Type;" & _
                                      "int64 ApplicationId;" & _
                                      "char Name[128];" & _
                                      "char State[128];" & _
                                      "char Details[128];" & _
                                      "int64 Timestamps_Start;" & _
                                      "int64 Timestamps_End;" & _
                                      "char Assets_LargeImage[128];" & _
                                      "char Assets_LargeText[128];" & _
                                      "char Assets_SmallImage[128];" & _
                                      "char Assets_SmallText[128];" & _
                                      "char Party_Id[128];" & _
                                      "int Party_Size_CurrentSize;" & _
                                      "int Party_Size_MaxSize;" & _
                                      "char Secrets_Match[128];" & _
                                      "char Secrets_Join[128];" & _
                                      "char Secrets_Spectate[128];" & _
                                      "boolean Instance;" & _
                                      "endstruct;"
Global Const $__DISCORD_tagUSERACHIEVEMENT = "struct;" & _
                                             "int64 UserId;" & _
                                             "int64 AchievementId;" & _
                                             "byte PercentComplete;" & _
                                             "char UnlockedAt[64];" & _
                                             "endstruct;"
; Discord classes
Global Enum $__DISCORD_LOBBYTRANSACTION, _
            $__DISCORD_LOBBYMEMBERTRANSACTION, _
            $__DISCORD_LOBBYSEARCHQUERY, _
            $__DISCORD_CORE, _
            $__DISCORD_APPLICATIONMANAGER, _
            $__DISCORD_USERMANAGER, _
            $__DISCORD_IMAGEMANAGER, _
            $__DISCORD_ACTIVITYMANAGER, _
            $__DISCORD_RELATIONSHIPMANAGER, _
            $__DISCORD_LOBBYMANAGER, _
            $__DISCORD_NETWORKMANAGER, _
            $__DISCORD_OVERLAYMANAGER, _
            $__DISCORD_STORAGEMANAGER, _
            $__DISCORD_STOREMANAGER, _
            $__DISCORD_VOICEMANAGER, _
            $__DISCORD_ACHIEVEMENTMANAGER, _
            $__DISCORD_CLASSCOUNT
; Core events
Global Const $__DISCORD_tagCOREEVENTS = "struct;" & _
                                        "endstruct;"
; Core methods
; void DestroyHandler(IntPtr MethodsPtr)
; Result RunCallbacksMethod(IntPtr methodsPtr)
; void SetLogHookCallback(IntPtr ptr, LogLevel level, [MarshalAs(UnmanagedType_LPStr)]string message)
; void SetLogHookMethod(IntPtr methodsPtr, LogLevel minLevel, IntPtr callbackData, SetLogHookCallback callback)
; IntPtr GetApplicationManagerMethod(IntPtr discordPtr)
; IntPtr GetUserManagerMethod(IntPtr discordPtr)
; IntPtr GetImageManagerMethod(IntPtr discordPtr)
; IntPtr GetActivityManagerMethod(IntPtr discordPtr)
; IntPtr GetRelationshipManagerMethod(IntPtr discordPtr)
; IntPtr GetLobbyManagerMethod(IntPtr discordPtr)
; IntPtr GetNetworkManagerMethod(IntPtr discordPtr)
; IntPtr GetOverlayManagerMethod(IntPtr discordPtr)
; IntPtr GetStorageManagerMethod(IntPtr discordPtr)
; IntPtr GetStoreManagerMethod(IntPtr discordPtr)
; IntPtr GetVoiceManagerMethod(IntPtr discordPtr)
; IntPtr GetAchievementManagerMethod(IntPtr discordPtr)
Global Const $__DISCORD_tagCOREMETHODS = "struct;" & _
                                         "ptr Destroy;" & _
                                         "ptr RunCallbacks;" & _
                                         "ptr SetLogHook;" & _
                                         "ptr GetApplicationManager;" & _
                                         "ptr GetUserManager;" & _
                                         "ptr GetImageManager;" & _
                                         "ptr GetActivityManager;" & _
                                         "ptr GetRelationshipManager;" & _
                                         "ptr GetLobbyManager;" & _
                                         "ptr GetNetworkManager;" & _
                                         "ptr GetOverlayManager;" & _
                                         "ptr GetStorageManager;" & _
                                         "ptr GetStoreManager;" & _
                                         "ptr GetVoiceManager;" & _
                                         "ptr GetAchievementManager;" & _
                                         "endstruct;"
; Application manager events
Global Const $__DISCORD_tagAPPLICATIONMANAGEREVENTS = "struct;" & _
                                                      "endstruct;"
; Application manager methods
; void ValidateOrExitCallback(IntPtr ptr, Result result)
; void ValidateOrExitMethod(IntPtr methodsPtr, IntPtr callbackData, ValidateOrExitCallback callback)
; void GetCurrentLocaleMethod(IntPtr methodsPtr, StringBuilder locale)
; void GetCurrentBranchMethod(IntPtr methodsPtr, StringBuilder branch)
; void GetOAuth2TokenCallback(IntPtr ptr, Result result, ref OAuth2Token oauth2Token)
; void GetOAuth2TokenMethod(IntPtr methodsPtr, IntPtr callbackData, GetOAuth2TokenCallback callback)
; void GetTicketCallback(IntPtr ptr, Result result, [MarshalAs(UnmanagedType_LPStr)]ref string data)
; void GetTicketMethod(IntPtr methodsPtr, IntPtr callbackData, GetTicketCallback callback)
Global Const $__DISCORD_tagAPPLICATIONMANAGERMETHODS = "struct;" & _
                                                       "ptr ValidateOrExit;" & _
                                                       "ptr GetCurrentLocale;" & _
                                                       "ptr GetCurrentBranch;" & _
                                                       "ptr GetOAuth2Token;" & _
                                                       "ptr GetTicket;" & _
                                                       "endstruct;"
; User manager events
; void CurrentUserUpdateHandler(IntPtr ptr)
Global Const $__DISCORD_tagUSERMANAGEREVENTS = "struct;" & _
                                               "ptr OnCurrentUserUpdate;" & _
                                               "endstruct;"
; User manager methods
; Result GetCurrentUserMethod(IntPtr methodsPtr, ref User currentUser)
; void GetUserCallback(IntPtr ptr, Result result, ref User user)
; void GetUserMethod(IntPtr methodsPtr, Int64 userId, IntPtr callbackData, GetUserCallback callback)
; Result GetCurrentUserPremiumTypeMethod(IntPtr methodsPtr, ref PremiumType premiumType)
; Result CurrentUserHasFlagMethod(IntPtr methodsPtr, UserFlag flag, ref bool hasFlag)
Global Const $__DISCORD_tagUSERMANAGERMETHODS = "struct;" & _
                                                "ptr GetCurrentUser;" & _
                                                "ptr GetUser;" & _
                                                "ptr GetCurrentUserPremiumType;" & _
                                                "ptr CurrentUserHasFlag;" & _
                                                "endstruct;"
; Image manager events
Global Const $__DISCORD_tagIMAGEMANAGEREVENTS = "struct;" & _
                                                "endstruct;"
; Image manager methods
; void FetchCallback(IntPtr ptr, Result result, ImageHandle handleResult)
; void FetchMethod(IntPtr methodsPtr, ImageHandle handle, bool refresh, IntPtr callbackData, FetchCallback callback)
; Result GetDimensionsMethod(IntPtr methodsPtr, ImageHandle handle, ref ImageDimensions dimensions)
; Result GetDataMethod(IntPtr methodsPtr, ImageHandle handle, byte[] data, Int32 dataLen)
Global Const $__DISCORD_tagIMAGEMANAGERMETHODS = "struct;" & _
                                                 "ptr Fetch;" & _
                                                 "ptr GetDimensions;" & _
                                                 "ptr GetData;" & _
                                                 "endstruct;"
; Activity manager events
; void ActivityJoinHandler(IntPtr ptr, [MarshalAs(UnmanagedType_LPStr)]string secret)
; void ActivitySpectateHandler(IntPtr ptr, [MarshalAs(UnmanagedType_LPStr)]string secret)
; void ActivityJoinRequestHandler(IntPtr ptr, ref User user)
; void ActivityInviteHandler(IntPtr ptr, ActivityActionType type, ref User user, ref Activity activity)
Global Const $__DISCORD_tagACTIVITYMANAGEREVENTS = "struct;" & _
                                                   "ptr OnActivityJoin;" & _
                                                   "ptr OnActivitySpectate;" & _
                                                   "ptr OnActivityJoinRequest;" & _
                                                   "ptr OnActivityInvite;" & _
                                                   "endstruct;"
; Activity manager methods
; Result RegisterCommandMethod(IntPtr methodsPtr, [MarshalAs(UnmanagedType_LPStr)]string command)
; Result RegisterSteamMethod(IntPtr methodsPtr, UInt32 steamId)
; void UpdateActivityCallback(IntPtr ptr, Result result)
; void UpdateActivityMethod(IntPtr methodsPtr, ref Activity activity, IntPtr callbackData, UpdateActivityCallback callback)
; void ClearActivityCallback(IntPtr ptr, Result result)
; void ClearActivityMethod(IntPtr methodsPtr, IntPtr callbackData, ClearActivityCallback callback)
; void SendRequestReplyCallback(IntPtr ptr, Result result)
; void SendRequestReplyMethod(IntPtr methodsPtr, Int64 userId, ActivityJoinRequestReply reply, IntPtr callbackData, SendRequestReplyCallback callback)
; void SendInviteCallback(IntPtr ptr, Result result)
; void SendInviteMethod(IntPtr methodsPtr, Int64 userId, ActivityActionType type, [MarshalAs(UnmanagedType_LPStr)]string content, IntPtr callbackData, SendInviteCallback callback)
; void AcceptInviteCallback(IntPtr ptr, Result result)
; void AcceptInviteMethod(IntPtr methodsPtr, Int64 userId, IntPtr callbackData, AcceptInviteCallback callback)
Global Const $__DISCORD_tagACTIVITYMANAGERMETHODS = "struct;" & _
                                                    "ptr RegisterCommand;" & _
                                                    "ptr RegisterSteam;" & _
                                                    "ptr UpdateActivity;" & _
                                                    "ptr ClearActivity;" & _
                                                    "ptr SendRequestReply;" & _
                                                    "ptr SendInvite;" & _
                                                    "ptr AcceptInvite;" & _
                                                    "endstruct;"
; Relationship manager events
Global Const $__DISCORD_tagRELATIONSHIPMANAGEREVENTS = "struct;" & _
                                                       "ptr OnRefresh;" & _
                                                       "ptr OnRelationshipUpdate;" & _
                                                       "endstruct;"
; Relationship manager methods
Global Const $__DISCORD_tagRELATIONSHIPMANAGERMETHODS = "struct;" & _
                                                        "ptr Filter;" & _
                                                        "ptr Count;" & _
                                                        "ptr Get;" & _
                                                        "ptr GetAt;" & _
                                                        "endstruct;"
; Lobby manager events
Global Const $__DISCORD_tagLOBBYMANAGEREVENTS = "struct;" & _
                                                "ptr OnLobbyUpdate;" & _
                                                "ptr OnLobbyDelete;" & _
                                                "ptr OnMemberConnect;" & _
                                                "ptr OnMemberUpdate;" & _
                                                "ptr OnMemberDisconnect;" & _
                                                "ptr OnLobbyMessage;" & _
                                                "ptr OnSpeaking;" & _
                                                "ptr OnNetworkMessage;" & _
                                                "endstruct;"
; Lobby manager methods
Global Const $__DISCORD_tagLOBBYMANAGERMETHODS = "struct;" & _
                                                 "ptr GetLobbyCreateTransaction;" & _
                                                 "ptr GetLobbyUpdateTransaction;" & _
                                                 "ptr GetMemberUpdateTransaction;" & _
                                                 "ptr CreateLobby;" & _
                                                 "ptr UpdateLobby;" & _
                                                 "ptr DeleteLobby;" & _
                                                 "ptr ConnectLobby;" & _
                                                 "ptr ConnectLobbyWithActivitySecret;" & _
                                                 "ptr DisconnectLobby;" & _
                                                 "ptr GetLobby;" & _
                                                 "ptr GetLobbyActivitySecret;" & _
                                                 "ptr GetLobbyMetadataValue;" & _
                                                 "ptr GetLobbyMetadataKey;" & _
                                                 "ptr LobbyMetadataCount;" & _
                                                 "ptr MemberCount;" & _
                                                 "ptr GetMemberUserId;" & _
                                                 "ptr GetMemberUser;" & _
                                                 "ptr GetMemberMetadataValue;" & _
                                                 "ptr GetMemberMetadataKey;" & _
                                                 "ptr MemberMetadataCount;" & _
                                                 "ptr UpdateMember;" & _
                                                 "ptr SendLobbyMessage;" & _
                                                 "ptr GetSearchQuery;" & _
                                                 "ptr Search;" & _
                                                 "ptr LobbyCount;" & _
                                                 "ptr GetLobbyId;" & _
                                                 "ptr ConnectVoice;" & _
                                                 "ptr DisconnectVoice;" & _
                                                 "ptr ConnectNetwork;" & _
                                                 "ptr DisconnectNetwork;" & _
                                                 "ptr FlushNetwork;" & _
                                                 "ptr OpenNetworkChannel;" & _
                                                 "ptr SendNetworkMessage;" & _
                                                 "endstruct;"
; Network manager events
Global Const $__DISCORD_tagNETWORKMANAGEREVENTS = "struct;" & _
                                                  "ptr OnMessage;" & _
                                                  "ptr OnRouteUpdate;" & _
                                                  "endstruct;"
; Network manager methods
Global Const $__DISCORD_tagNETWORKMANAGERMETHODS = "struct;" & _
                                                   "ptr GetPeerId;" & _
                                                   "ptr Flush;" & _
                                                   "ptr OpenPeer;" & _
                                                   "ptr UpdatePeer;" & _
                                                   "ptr ClosePeer;" & _
                                                   "ptr OpenChannel;" & _
                                                   "ptr CloseChannel;" & _
                                                   "ptr SendMessage;" & _
                                                   "endstruct;"
; Overlay manager events
Global Const $__DISCORD_tagOVERLAYMANAGEREVENTS = "struct;" & _
                                                  "ptr OnToggle;" & _
                                                  "endstruct;"
; Overlay manager methods
Global Const $__DISCORD_tagOVERLAYMANAGERMETHODS = "struct;" & _
                                                   "ptr IsEnabled;" & _
                                                   "ptr IsLocked;" & _
                                                   "ptr SetLocked;" & _
                                                   "ptr OpenActivityInvite;" & _
                                                   "ptr OpenGuildInvite;" & _
                                                   "ptr OpenVoiceSettings;" & _
                                                   "endstruct;"
; Storage manager events
Global Const $__DISCORD_tagSTORAGEMANAGEREVENTS = "struct;" & _
                                                  "endstruct;"
; Storage manager methods
Global Const $__DISCORD_tagSTORAGEMANAGERMETHODS = "struct;" & _
                                                   "ptr Read;" & _
                                                   "ptr ReadAsync;" & _
                                                   "ptr ReadAsyncPartial;" & _
                                                   "ptr Write;" & _
                                                   "ptr WriteAsync;" & _
                                                   "ptr Delete;" & _
                                                   "ptr Exists;" & _
                                                   "ptr Count;" & _
                                                   "ptr Stat;" & _
                                                   "ptr StatAt;" & _
                                                   "ptr GetPath;" & _
                                                   "endstruct;"
; Store manager events
Global Const $__DISCORD_tagSTOREMANAGEREVENTS = "struct;" & _
                                                "ptr OnEntitlementCreate;" & _
                                                "ptr OnEntitlementDelete;" & _
                                                "endstruct;"
; Store manager methods
Global Const $__DISCORD_tagSTOREMANAGERMETHODS = "struct;" & _
                                                 "ptr FetchSkus;" & _
                                                 "ptr CountSkus;" & _
                                                 "ptr GetSku;" & _
                                                 "ptr GetSkuAt;" & _
                                                 "ptr FetchEntitlements;" & _
                                                 "ptr CountEntitlements;" & _
                                                 "ptr GetEntitlement;" & _
                                                 "ptr GetEntitlementAt;" & _
                                                 "ptr HasSkuEntitlement;" & _
                                                 "ptr StartPurchase;" & _
                                                 "endstruct;"
; Voice manager events
Global Const $__DISCORD_tagVOICEMANAGEREVENTS = "struct;" & _
                                                "ptr OnSettingsUpdate;" & _
                                                "endstruct;"
; Voice manager methods
Global Const $__DISCORD_tagVOICEMANAGERMETHODS = "struct;" & _
                                                 "ptr GetInputMode;" & _
                                                 "ptr SetInputMode;" & _
                                                 "ptr IsSelfMute;" & _
                                                 "ptr SetSelfMute;" & _
                                                 "ptr IsSelfDeaf;" & _
                                                 "ptr SetSelfDeaf;" & _
                                                 "ptr IsLocalMute;" & _
                                                 "ptr SetLocalMute;" & _
                                                 "ptr GetLocalVolume;" & _
                                                 "ptr SetLocalVolume;" & _
                                                 "endstruct;"
; Achievement manager events
Global Const $__DISCORD_tagACHIEVEMENTMANAGEREVENTS = "struct;" & _
                                                      "ptr OnUserAchievementUpdate;" & _
                                                      "endstruct;"
; Achievement manager methods
Global Const $__DISCORD_tagACHIEVEMENTMANAGERMETHODS = "struct;" & _
                                                       "ptr SetUserAchievement;" & _
                                                       "ptr FetchUserAchievements;" & _
                                                       "ptr CountUserAchievements;" & _
                                                       "ptr GetUserAchievement;" & _
                                                       "ptr GetUserAchievementAt;" & _
                                                       "endstruct;"
; ===============================================================================================================================