
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
		State : State_enum;
		InternalDescription : STRING[256];
		FB_httpUtf8ToString : httpUtf8ToString;
		RecordID : ArEventLogRecordIDType;
		EventIDFound : BOOL;
		j : UINT;
		k : UINT;
	END_STRUCT;
	Records_typ : 	STRUCT 
		ObjectID : STRING[36];
		ErrorNumber : UDINT;
		Severity : USINT;
		RecordID : ArEventLogRecordIDType;
		OriginRecordID : ArEventLogRecordIDType;
		EventID : DINT;
		ErrorText : STRING[200];
		AddData : ARRAY[0..256]OF USINT;
		AddDataFormat : USINT;
		AddDataSize : UDINT;
		TimeStamp : ArEventLogTimeStampType;
	END_STRUCT;
	ReadEvLogEntriesLanguage_enum : 
		(
		REL_ERR_LANGUAGE_DE,
		REL_ERR_LANGUAGE_EN
		);
END_TYPE
