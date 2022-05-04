
TYPE
	State_enum : 
		(
		STATE_FIND_ENTRY,
		STATE_FIND_DEPENDECIES,
		STATE_READ_TEXT,
		STATE_DONE,
		STATE_ERROR
		);
	Data_typ : 	STRUCT 
		Records : Records_typ;
		RecordsTotal : USINT;
	END_STRUCT;
	Internal_typ : 	STRUCT 
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
		State : State_enum;
		InternalDescription : STRING[256];
		FB_httpUtf8ToString : httpUtf8ToString;
		RecordID : ArEventLogRecordIDType;
		EventID : DINT;
		GetParent : BOOL;
		tmpDT : DATE_AND_TIME;
		tmpDTstruct : DTStructure;
		j : UINT;
		k : UINT;
	END_STRUCT;
	Records_typ : 	STRUCT 
		ErrorNumber : ARRAY[0..MAX_NO_ENTRIES]OF UDINT;
		Severity : ARRAY[0..MAX_NO_ENTRIES]OF USINT;
		RecordID : ARRAY[0..MAX_NO_ENTRIES]OF ArEventLogRecordIDType;
		OriginRecordID : ARRAY[0..MAX_NO_ENTRIES]OF ArEventLogRecordIDType;
		EventID : ARRAY[0..MAX_NO_ENTRIES]OF DINT;
		ErrorText : ARRAY[0..MAX_NO_ENTRIES]OF STRING[200];
		TimeStamp : ARRAY[0..MAX_NO_ENTRIES]OF STRING[25]; (*Date and time*)
		DTsec : ARRAY[1..MAX_NO_ENTRIES]OF UDINT; (*Date and time in sec*)
		DTmsec : ARRAY[1..MAX_NO_ENTRIES]OF UDINT; (*Additional milliseconds*)
	END_STRUCT;
	ReadEvLogEntriesLanguage_enum : 
		(
		REL_ERR_LANGUAGE_DE,
		REL_ERR_LANGUAGE_EN
		);
END_TYPE
