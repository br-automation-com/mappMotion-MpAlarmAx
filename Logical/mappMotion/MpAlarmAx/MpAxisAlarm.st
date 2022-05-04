
// --------------------------------------------------------------------------------------------------------------------
// Read axis errors from Logbook and write into structure
// --------------------------------------------------------------------------------------------------------------------
FUNCTION_BLOCK MpAxisAlarm

	// -----------------------------------------------------------------------------------------------------------
	// Get motion logbook
	IF Internal.fbArEventLogGetIdent.Ident = 0 THEN
		Internal.fbArEventLogGetIdent(Execute := TRUE, Name := '$$motion');
	END_IF
	
	// -----------------------------------------------------------------------------------------------------------
	// Reset function block when not executed
	IF NOT Execute THEN
		// Reset counters and function blocks
		Internal.RecordID := 0;
		Internal.EventID := 0;
		Internal.j := 0;
		brsmemset(ADR(Data), 0, SIZEOF(Data));
		
		Internal.fbMC_BR_GetHardwareInfo(Execute := FALSE);
		Internal.fbMC_ReadAxisError(Enable := FALSE);
		Internal.fbArEventLogReadDescription(Execute := FALSE);

		Internal.State := STATE_FIND_ENTRY;
		Status := ERR_FUB_ENABLE_FALSE;
	ELSE
		// Make sure that axis name is valid
		IF Axis.mappLinkInternal.Internal[0] = 0 THEN
			Status := ERROR_MPLINK_MISSING;
			Internal.State := STATE_ERROR;
			RETURN;
		END_IF
	END_IF
	
	// -----------------------------------------------------------------------------------------------------------
	// Get axis name and  error
	IF Axis.mappLinkInternal.Internal[0] <> 0 THEN
		Internal.fbMC_BR_GetHardwareInfo(Execute := TRUE, Axis := ADR(Axis));
		
		IF Internal.fbMC_BR_GetHardwareInfo.Done AND NOT Internal.fbMC_BR_GetHardwareInfo.Error THEN
			Internal.fbMC_ReadAxisError(Enable := TRUE, Axis := ADR(Axis));
		END_IF
	END_IF
	
	// -----------------------------------------------------------------------------------------------------------
	IF Internal.fbArEventLogGetIdent.Ident <> 0 AND Execute THEN
		FOR Internal.k:=0 TO OVERRIDE DO
			CASE Internal.State OF
				// -----------------------------------------------------------------------------------------------------------
				// Find error entry
				// -----------------------------------------------------------------------------------------------------------	
				STATE_FIND_ENTRY:
					// Execute once on positive edge
					IF Internal.RecordID = 0 THEN
						Status := ERR_FUB_BUSY;
						Internal.GetParent := FALSE;
						
						// Use function error in first run
						IF Internal.EventID = 0 THEN
							Internal.EventID := ErrorID;
						// Use drive error in second run
						ELSE
							Internal.EventID := Internal.fbMC_ReadAxisError.AxisErrorID;
							Internal.fbMC_ReadAxisError(ReadNext := FALSE);
							Internal.fbMC_ReadAxisError(ReadNext := TRUE);
						END_IF
						
						// Read first record
						Internal.fbArEventLogGetLatestRecordID(Execute := FALSE);
						Internal.fbArEventLogGetLatestRecordID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident);
						Internal.RecordID := Internal.fbArEventLogGetLatestRecordID.RecordID;
				
						// Get error id
						Internal.fbArEventLogRead(Execute := FALSE);
						Internal.fbArEventLogRead(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Internal.fbArEventLogGetLatestRecordID.RecordID);

						// Get axis name
						Internal.fbArEventLogReadObjectID(Execute := FALSE);
						Internal.fbArEventLogReadObjectID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Internal.RecordID);

						// Found error id we are looking for			
						IF Internal.fbArEventLogRead.EventID = ErrorID AND Internal.fbArEventLogReadObjectID.ObjectID = Internal.fbMC_BR_GetHardwareInfo.HardwareInfo.Axis.AxisName THEN
							Internal.State := STATE_FIND_DEPENDECIES;
							EXIT;
						END_IF;
					ELSE
						// Read next record
						Internal.fbArEventLogGetPreviousRecordID(Execute := FALSE);
						Internal.fbArEventLogGetPreviousRecordID(Execute := TRUE, Ident	:= Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
						Internal.RecordID := Internal.fbArEventLogGetPreviousRecordID.PrevRecordID;

						// Get error id
						Internal.fbArEventLogRead(Execute := FALSE);
						Internal.fbArEventLogRead(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
						
						// Get axis name
						Internal.fbArEventLogReadObjectID(Execute := FALSE);
						Internal.fbArEventLogReadObjectID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
		
						// Found error id we are looking for			
						IF Internal.fbArEventLogRead.EventID = ErrorID AND Internal.fbArEventLogReadObjectID.ObjectID = Internal.fbMC_BR_GetHardwareInfo.HardwareInfo.Axis.AxisName THEN
							Internal.State := STATE_FIND_DEPENDECIES;
							EXIT;
						END_IF;
					END_IF	
					// -----------------------------------------------------------------------------------------------------------
				// Find dependencies and read details
				// -----------------------------------------------------------------------------------------------------------	
				STATE_FIND_DEPENDECIES:
					// Get parent record
					IF Internal.GetParent THEN
						Internal.RecordID := Internal.fbArEventLogRead.OriginRecordID;
						Internal.fbArEventLogRead(Execute := FALSE);
						Internal.fbArEventLogRead(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
					END_IF
					Internal.GetParent := TRUE;
					
					// Get error number
					Internal.fbArEventLogReadErrorNumber(Execute := FALSE);
					Internal.fbArEventLogReadErrorNumber(Execute := TRUE, Ident	:= Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
					
					Data.Records.ErrorNumber[Data.RecordsTotal] := Internal.fbArEventLogReadErrorNumber.ErrorNumber;
					Data.Records.Severity[Data.RecordsTotal] := Internal.fbArEventLogReadErrorNumber.Severity;
					Data.Records.RecordID[Data.RecordsTotal] := Internal.RecordID;
					Data.Records.OriginRecordID[Data.RecordsTotal] := Internal.fbArEventLogRead.OriginRecordID;
					Data.Records.EventID[Data.RecordsTotal] := Internal.fbArEventLogRead.EventID;
					
					// Store date and time
					Data.Records.DTsec[Data.RecordsTotal] := Internal.fbArEventLogRead.TimeStamp.sec;
					Data.Records.DTmsec[Data.RecordsTotal] := Internal.fbArEventLogRead.TimeStamp.nsec/1000000;
					// Add timestamp
					Internal.tmpDT := UDINT_TO_DT(Internal.fbArEventLogRead.TimeStamp.sec);
					DT_TO_DTStructure(Internal.tmpDT, ADR(Internal.tmpDTstruct));
					brsmemset(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), 0, SIZEOF(Data.Records.TimeStamp[Data.RecordsTotal]));
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.day, '');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.month, '.');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.year, '.');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.hour, ' ');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.minute, ':');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Internal.tmpDTstruct.second, ':');
					NormalizeDateTime(ADR(Data.Records.TimeStamp[Data.RecordsTotal]), Data.Records.DTmsec[Data.RecordsTotal], '.');

					Data.RecordsTotal := Data.RecordsTotal + 1;
					
					// Make sure we dont exceed entry limit
					IF Data.RecordsTotal > MAX_NO_ENTRIES THEN
						Status := ERROR_MAX_NO_ENTRIES;
						Internal.State := STATE_ERROR;
					END_IF
						
					// Jump to next step when there no more dependencies
					IF Internal.fbArEventLogRead.OriginRecordID = 0 THEN
						Internal.State := STATE_READ_TEXT;
						EXIT;
					END_IF
				// -----------------------------------------------------------------------------------------------------------
				// Read error text
				// -----------------------------------------------------------------------------------------------------------	
				STATE_READ_TEXT:
					// Set text language
					CASE Language OF
						REL_ERR_LANGUAGE_DE: Internal.fbArEventLogReadDescription.LanguageCode := 'de';
						REL_ERR_LANGUAGE_EN: Internal.fbArEventLogReadDescription.LanguageCode := 'en';
						ELSE
							Internal.fbArEventLogReadDescription.LanguageCode := 'en';
					END_CASE;
					Internal.fbArEventLogReadDescription(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Data.Records.RecordID[Internal.j], TextBuffer := ADR(Internal.InternalDescription), TextBufferSize := SIZEOF(Internal.InternalDescription));
					
					// Success
					IF Internal.fbArEventLogReadDescription.Done = TRUE THEN
						Internal.FB_httpUtf8ToString(enable := TRUE, pSrc := ADR(Internal.InternalDescription), pDest := ADR(Data.Records.ErrorText[Internal.j]), destSize := SIZEOF(Data.Records.ErrorText[Internal.j]));
						Internal.fbArEventLogReadDescription(Execute := FALSE);
						Internal.j := Internal.j + 1;
						
						// Last entry reached
						IF Internal.j = Data.RecordsTotal THEN
							// Read axis errors if there are any
							IF Internal.fbMC_ReadAxisError.AxisErrorID <> 0 AND Internal.fbMC_ReadAxisError.AxisErrorID <> ErrorID THEN
								Internal.State := STATE_FIND_ENTRY;
							// Finish up
							ELSE
								Internal.State := STATE_DONE;
								Status := 0;
								EXIT;
							END_IF
						END_IF
					// Error
					ELSIF Internal.fbArEventLogReadDescription.Error = TRUE THEN
						Status := Internal.fbArEventLogReadDescription.StatusID;
						Internal.State := STATE_ERROR;
					END_IF
			END_CASE;
		END_FOR;
	END_IF	

END_FUNCTION_BLOCK

// --------------------------------------------------------------------------------------------------------------------
// Normalize 2 digit date and time values
// --------------------------------------------------------------------------------------------------------------------
FUNCTION NormalizeDateTime
	tmpSTR2 := addSTR;
	IF(value < 10) THEN
		brsstrcat(ADR(tmpSTR2), ADR('0'));
	END_IF
	brsitoa(value, ADR(tmpSTR1));
	brsstrcat(ADR(tmpSTR2), ADR(tmpSTR1));
	brsstrcat(target, ADR(tmpSTR2));
	NormalizeDateTime := TRUE;
END_FUNCTION
