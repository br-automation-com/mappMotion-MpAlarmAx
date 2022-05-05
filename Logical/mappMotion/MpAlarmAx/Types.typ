
TYPE
	MpAlarmAxState_enum : 
		( (*Alarm state machine*)
		STATE_FIND_ENTRY, (*Find error number in logger*)
		STATE_FIND_DEPENDECIES, (*Find dependencies for error number*)
		STATE_READ_TEXT, (*Read error text*)
		STATE_DONE, (*Command is finished*)
		STATE_ERROR (*Error state*)
		);
	MpAlarmAxLanguage_enum : 
		( (*Alrm text language*)
		REL_ERR_LANGUAGE_DE, (*German*)
		REL_ERR_LANGUAGE_EN (*English*)
		);
	MpAlarmAxData_typ : 	STRUCT  (*Alarm data*)
		Records : MpAlarmAxRecords_typ; (*Alarm record details*)
		RecordsTotal : USINT; (*Number of records found*)
	END_STRUCT;
	MpAlarmAxRecords_typ : 	STRUCT  (*Alarm record details*)
		EventID : ARRAY[0..MAX_NO_ENTRIES]OF DINT;
		ErrorText : ARRAY[0..MAX_NO_ENTRIES]OF STRING[200];
		Severity : ARRAY[0..MAX_NO_ENTRIES]OF USINT;
		RecordID : ARRAY[0..MAX_NO_ENTRIES]OF ArEventLogRecordIDType;
		OriginRecordID : ARRAY[0..MAX_NO_ENTRIES]OF ArEventLogRecordIDType;
		TimeStamp : ARRAY[0..MAX_NO_ENTRIES]OF STRING[25]; (*Date and time*)
		DTsec : ARRAY[0..MAX_NO_ENTRIES]OF UDINT; (*Date and time in sec*)
		DTmsec : ARRAY[0..MAX_NO_ENTRIES]OF UDINT; (*Additional milliseconds*)
	END_STRUCT;
	MpAlarmAxInternal_typ : 	STRUCT  (*Internaö structure*)
		fbArEventLogGetIdent : ArEventLogGetIdent;
		fbArEventLogGetLatestRecordID : ArEventLogGetLatestRecordID;
		fbArEventLogGetPreviousRecordID : ArEventLogGetPreviousRecordID;
		fbArEventLogRead : ArEventLogRead;
		fbArEventLogReadAddData : ArEventLogReadAddData;
		fbArEventLogReadObjectID : ArEventLogReadObjectID;
		fbArEventLogReadErrorNumber : ArEventLogReadErrorNumber;
		fbArEventLogReadDescription : ArEventLogReadDescription;
		fbMC_ReadAxisError : MC_ReadAxisError;
		fbMC_BR_GetHardwareInfo : MC_BR_GetHardwareInfo;
		State : MpAlarmAxState_enum;
		InternalDescription : STRING[256];
		FB_httpUtf8ToString : httpUtf8ToString;
		RecordID : ArEventLogRecordIDType;
		EventID : DINT;
		GetParent : BOOL;
		SearchAxisError : BOOL;
		tmpDT : DATE_AND_TIME;
		tmpDTstruct : DTStructure;
		j : UINT;
		k : UINT;
		l : UINT;
	END_STRUCT;
END_TYPE
