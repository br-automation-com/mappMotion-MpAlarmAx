
// Read axis errors from Logbook and write into structure
FUNCTION_BLOCK MpAxisAlarm
	
	// -----------------------------------------------------------------------------------------------------------
	// Get motion logbook
	IF Internal.fbArEventLogGetIdent.Ident = 0 THEN
		Internal.fbArEventLogGetIdent(Execute := TRUE, Name := '$$motion');
	END_IF
	
	// Reset function block when not executed
	IF NOT Execute THEN
		Internal.RecordID := 0;
		brsmemset(ADR(Records), 0, SIZEOF(Records));
		Internal.State := STATE_FIND_ENTRY;
	ELSE
		// Make sure that axis name is valid
		IF AxisName = '' THEN
			Status := ERROR_AXIS_NAME;
			Internal.State := STATE_ERROR;
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
						NumberOfIDs := 0;
						j := 0;
						
						// Read first record
						Internal.fbArEventLogGetLatestRecordID(Execute := FALSE, Ident := Internal.fbArEventLogGetIdent.Ident);
						Internal.fbArEventLogGetLatestRecordID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident);
						RecordID := Internal.fbArEventLogGetLatestRecordID.RecordID;
				
						// Get error id
						Internal.fbArEventLogRead(Execute := FALSE);
						Internal.fbArEventLogRead(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Internal.fbArEventLogGetLatestRecordID.RecordID);

						// Get axis name
						Internal.fbArEventLogReadObjectID(Execute := FALSE);
						Internal.fbArEventLogReadObjectID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Internal.RecordID);

						// Found error id we are looking for			
						IF Internal.fbArEventLogRead.EventID = ErrorID AND Internal.fbArEventLogReadObjectID.ObjectID = AxisName THEN
							Internal.EventIDFound := TRUE;
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
						IF Internal.fbArEventLogRead.EventID = ErrorID AND Internal.fbArEventLogReadObjectID.ObjectID = AxisName THEN
							Internal.EventIDFound := TRUE;
							Internal.State := STATE_FIND_DEPENDECIES;
							EXIT;
						END_IF;
					END_IF	
					// -----------------------------------------------------------------------------------------------------------
				// Find dependencies and read details
				// -----------------------------------------------------------------------------------------------------------	
				STATE_FIND_DEPENDECIES:
					IF NumberOfIDs > 0 THEN
						Internal.RecordID := Internal.fbArEventLogRead.OriginRecordID;
						Internal.fbArEventLogRead(Execute := FALSE);
						Internal.fbArEventLogRead(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
					END_IF
					
					// Get axis name
					Internal.fbArEventLogReadObjectID(Execute := FALSE);
					Internal.fbArEventLogReadObjectID(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
					// Get errro number
					Internal.fbArEventLogReadErrorNumber(Execute := FALSE);
					Internal.fbArEventLogReadErrorNumber(Execute := TRUE, Ident	:= Internal.fbArEventLogGetIdent.Ident, RecordID:= Internal.RecordID);
					// Get additional event data
					IF Internal.fbArEventLogRead.AddDataSize > 0 THEN
						Internal.fbArEventLogReadAddData(Execute := FALSE); 
						Internal.fbArEventLogReadAddData(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Internal.RecordID, AddData := ADR(Records[NumberOfIDs].AddData), BytesToRead := SIZEOF(Records[NumberOfIDs].AddData));
					END_IF
					Records[NumberOfIDs].ObjectID := Internal.fbArEventLogReadObjectID.ObjectID;
					Records[NumberOfIDs].ErrorNumber := Internal.fbArEventLogReadErrorNumber.ErrorNumber;
					Records[NumberOfIDs].Severity := Internal.fbArEventLogReadErrorNumber.Severity;
					Records[NumberOfIDs].RecordID := Internal.RecordID;
					Records[NumberOfIDs].OriginRecordID := Internal.fbArEventLogRead.OriginRecordID;
					Records[NumberOfIDs].EventID := Internal.fbArEventLogRead.EventID;
					Records[NumberOfIDs].AddDataFormat := Internal.fbArEventLogRead.AddDataFormat;
					Records[NumberOfIDs].AddDataSize := Internal.fbArEventLogRead.AddDataSize;
					Records[NumberOfIDs].TimeStamp := Internal.fbArEventLogRead.TimeStamp;
					NumberOfIDs := NumberOfIDs + 1;
					
					// Make sure we dont exceed entry limit
					IF NumberOfIDs > MAX_NO_ENTRIES THEN
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
					//Texte auslesen
					CASE Language OF
						REL_ERR_LANGUAGE_DE: fbArEventLogReadDescription.LanguageCode := 'de';
						REL_ERR_LANGUAGE_EN: fbArEventLogReadDescription.LanguageCode := 'en';
						ELSE
							Internal.fbArEventLogReadDescription.LanguageCode := 'en';
					END_CASE;
					Internal.fbArEventLogReadDescription(Execute := TRUE, Ident := Internal.fbArEventLogGetIdent.Ident, RecordID := Records[j].RecordID, TextBuffer := ADR(Internal.InternalDescription), TextBufferSize := SIZEOF(Internal.InternalDescription));
					
					IF fbArEventLogReadDescription.Done = TRUE THEN
						FB_httpUtf8ToString(enable := TRUE, pSrc := ADR(Internal.InternalDescription), pDest := ADR(Records[j].ErrorText), destSize := SIZEOF(Records[j].ErrorText));
						fbArEventLogReadDescription(Execute	:= FALSE);
						Internal.j := Internal.j + 1;
						
						// Last entry reached
						IF Internal.j = NumberOfIDs THEN
							Internal.State := STATE_DONE;
							Status := 0;
							EXIT;
						END_IF
					END_IF
			END_CASE;
		END_FOR;
	END_IF	

END_FUNCTION_BLOCK
