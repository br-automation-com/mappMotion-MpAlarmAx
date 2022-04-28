// --------------------------------------------------------------------------------------------------------------------
// Motion sample for using nettime
// --------------------------------------------------------------------------------------------------------------------
PROGRAM _INIT
	MpAxisBasic_0.Enable	 := TRUE;
	MpAxisBasic_0.MpLink	 := ADR(gAxis_1);
	MpAxisBasic_0.Parameters := ADR(MpAxisBasicPar_0);
	MpAxisBasic_0();
END_PROGRAM

// -----------------------------------------------------------------------------------------------------------
// Cyclic part
// -----------------------------------------------------------------------------------------------------------	
PROGRAM _CYCLIC
	MpAxisBasic_0.Power			:= MpAxisBasic_0.Active AND MpAxisBasic_0.Info.ReadyToPowerOn AND cmdAxisPower;
	MpAxisBasic_0.ErrorReset	:= cmdAxisErrorReset;
	MpAxisBasic_0.Home			:= MpAxisBasic_0.PowerOn AND NOT MpAxisBasic_0.IsHomed XOR cmdAxisHome;
	MpAxisBasic_0.MoveVelocity	:= MpAxisBasic_0.PowerOn AND MpAxisBasic_0.IsHomed AND cmdAxisMoveVelocity;
	
	IF MpAxisBasic_0.PowerOn AND MpAxisBasic_0.IsHomed AND cmdAxisMoveAbs THEN
		MpAxisBasicPar_0.Position := AxisPosition;
		MpAxisBasic_0.MoveAbsolute := TRUE;
	END_IF

	IF AxisVelocity <> MpAxisBasicPar_0.Velocity OR AxisAcceleration <> MpAxisBasicPar_0.Acceleration THEN
		MpAxisBasicPar_0.Velocity		:= AxisVelocity;
		MpAxisBasicPar_0.Acceleration	:= AxisAcceleration;
		MpAxisBasicPar_0.Deceleration	:= AxisAcceleration;
		MpAxisBasic_0.Update := TRUE;
	END_IF
	MpAxisBasic_0();

	IF MpAxisBasic_0.UpdateDone THEN
		MpAxisBasic_0.Update := FALSE;
	END_IF
	IF MpAxisBasic_0.InPosition THEN
		MpAxisBasic_0.MoveAbsolute := FALSE;
	END_IF
END_PROGRAM