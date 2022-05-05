// --------------------------------------------------------------------------------------------------------------------
// Motion sample
// --------------------------------------------------------------------------------------------------------------------
PROGRAM _INIT
END_PROGRAM

// -----------------------------------------------------------------------------------------------------------
// Cyclic part
// -----------------------------------------------------------------------------------------------------------	
PROGRAM _CYCLIC
	IF AxisVelocity <> MpAxisBasicPar_0.Velocity OR AxisAcceleration <> MpAxisBasicPar_0.Acceleration OR AxisPosition <> MpAxisBasicPar_0.Position THEN
		MpAxisBasicPar_0.Velocity := AxisVelocity;
		MpAxisBasicPar_0.Acceleration := AxisAcceleration;
		MpAxisBasicPar_0.Deceleration := AxisAcceleration;
		MpAxisBasicPar_0.Position := AxisPosition;
		MpAxisBasic_0.Update := TRUE;
	END_IF
	
	IF MpAxisBasic_0.UpdateDone THEN
		MpAxisBasic_0.Update := FALSE;
	END_IF

	IF EDGENEG(MpAxisBasic_0.MoveActive) THEN
		MpAxisBasic_0.MoveVelocity := FALSE;
		MpAxisBasic_0.MoveAbsolute := FALSE;
		MpAxisBasic_0.Stop := FALSE;
	END_IF

	IF MpAxisBasic_0.Error THEN
		MpAxisBasic_0.MoveVelocity := FALSE;
		MpAxisBasic_0.MoveAbsolute := FALSE;
	END_IF
	
	// Motion basic function block call
	MpAxisBasic_0.Enable := TRUE;
	MpAxisBasic_0.MpLink := ADR(gAxis_1);
	MpAxisBasic_0.Parameters := ADR(MpAxisBasicPar_0);	
	MpAxisBasic_0();

	// Motion alarm function block call
	MpAxisAlarm_0.Axis := ADR(gAxis_1);
	MpAxisAlarm_0.Execute := MpAxisBasic_0.Error;
	MpAxisAlarm_0.ErrorID := MpAxisBasic_0.Info.Diag.Internal.ID;
	MpAxisAlarm_0();
		
END_PROGRAM