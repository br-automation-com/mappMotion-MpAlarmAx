
{REDUND_UNREPLICABLE} FUNCTION_BLOCK MpAxisAlarm (*Funktionblock to read errors from the motion logger*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Execute : {REDUND_UNREPLICABLE} BOOL;
		Axis : REFERENCE TO McAxisType;
		ErrorID : {REDUND_UNREPLICABLE} DINT;
		Language : {REDUND_UNREPLICABLE} MpAlarmAxLanguage_enum := REL_ERR_LANGUAGE_EN;
	END_VAR
	VAR_OUTPUT
		Data : {REDUND_UNREPLICABLE} MpAlarmAxData_typ; (* *) (* *) (*#PAR*)
	END_VAR
	VAR
		Status : {REDUND_UNREPLICABLE} DINT;
		Internal : {REDUND_UNREPLICABLE} MpAlarmAxInternal_typ;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION NormalizeDateTime : UDINT
	VAR_INPUT
		target : UDINT;
		value : UDINT;
		addSTR : STRING[5];
	END_VAR
	VAR
		tmpSTR1 : STRING[10];
		tmpSTR2 : STRING[10];
	END_VAR
END_FUNCTION
