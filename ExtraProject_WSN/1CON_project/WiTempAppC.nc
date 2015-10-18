configuration WiTempAppC
{
}
implementation
{
	//general
	components WiTempC as App;
	components MainC;
	components LedsC;
	components new TimerMilliC();
	components PlatformSerialC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
	
	//for temperature sensor
	//components new SensirionSht11C() as TempSensor;
	
	//App.TempRead -> TempSensor.Temperature;
	
	//radioComm
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	components SerialActiveMessageC as Serial;
	
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC; 
		
	App.SerialControl -> Serial;
	App.UartByte -> PlatformSerialC;	
}