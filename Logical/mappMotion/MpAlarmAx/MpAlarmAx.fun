
FUNCTION_BLOCK MpAxisAlarm (*Funktionblock to read errors from the motion logger*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Execute : BOOL;
		AxisName : STRING[40];
		ErrorID : DINT;
		Language : {REDUND_UNREPLICABLE} ReadEvLogEntriesLanguage_enum;
	END_VAR
	VAR_OUTPUT
		Records : {REDUND_UNREPLICABLE} ARRAY[0..MAX_NO_ENTRIES] OF ErrRecords_Type; (* *) (* *) (*#PAR*)
	END_VAR
	VAR
		Status : UINT;
		NumberOfIDs : {REDUND_UNREPLICABLE} UINT;
		zzEdge00000 : BOOL;
		Internal : Internal_typ;
	END_VAR
END_FUNCTION_BLOCK
